#include "NewmanZiff.h"
#include "gpu_kernal.h"

#include "Logging.hpp"

#include <algorithm>

#include <iostream>

#define gpuErrchk(ans)                         \
  if ((ans) != cudaSuccess) {                  \
    LOG(LOG_ERROR) << cudaGetErrorString(ans) <<" : "<<ans; \
  }

#define LastError() gpuErrchk(cudaPeekAtLastError())

NewmanZiff::NewmanZiff(int size,int stride_):L(size),stride(stride_){
    it=0;
    randVH=new int[L*L];
    for (int i=0;i<L*L;i++){
        randVH[i]=i;
    }
    gen.seed(12345UL);
    gpuErrchk(cudaMalloc((void**)&LabelD, sizeof(int)*L*L));
    gpuErrchk(cudaMalloc((void**)&ImageD, sizeof(int)*L*L));
    gpuErrchk(cudaMalloc((void**)&SizeD, sizeof(int)*L*L));
    gpuErrchk(cudaMalloc((void**)&randVD, sizeof(int)*L*L));
}

NewmanZiff::~NewmanZiff(){
    cudaDeviceSynchronize();
    cudaFree(LabelD);
    cudaFree(ImageD);
    cudaFree(SizeD);
    cudaFree(randVD);
    delete[] randVH;
}

bool NewmanZiff::nextStep(){
    if (it+stride<L*L){
        int perBlock = (stride<512)?stride:512;
        int numBlock = stride/512+1;
        SetMem2Value<<<numBlock,perBlock>>>(ImageD, randVD, it, stride);
        it+=stride;
        LastError();
        return true;
    }
    else{
        return false;
    }
}

int NewmanZiff::GetBigestCluster(){
    cudaMemset(SizeD,0,sizeof(int)*L*L);
	int *SizeH =new int [L*L];
	dim3 perBlock1(32,32);
	dim3 numBlock1(1,L/32);
    HA4_Strip_Labeling<<<numBlock1,perBlock1,sizeof(int)*32>>>(ImageD,LabelD,L);
    dim3 perBlock2(32,32);
	dim3 numBlock2(L/32,L/32);
    HA4_Strip_Merge<<<numBlock2,perBlock2>>>(ImageD,LabelD,L,32);
	dim3 perBlock3(32,32);
	dim3 numBlock3(L/32,L/32);
    HA4_ClusterSize<<<numBlock3,perBlock3>>>(ImageD,LabelD,L,SizeD);
    cudaDeviceSynchronize();
	cudaMemcpy(SizeH, SizeD, sizeof(int)*L*L, cudaMemcpyDeviceToHost);
    int s_max = 0;
    int sum = 0;

	for(int i=0;i<L*L;i++){

        sum+=SizeH[i];
		if (SizeH[i]>s_max){

			s_max=SizeH[i];
		}
    }
    if(sum!=it){
        LOG(LOG_ERROR)<< "clusterzie gone wrong  sum: "<<sum<<" it: "<<it;
    }
    LastError();
    return s_max;
}

std::vector<int> NewmanZiff::iteration(){
    std::vector<int> result;
    std::shuffle(&randVH[0], &randVH[L*L], gen);
    cudaMemcpy(randVD, randVH, sizeof(int)*L*L, cudaMemcpyHostToDevice);
    cudaMemset(ImageD,0,sizeof(int)*L*L);
    
    while (nextStep()){
        result.push_back(GetBigestCluster());
    }
    it=0;
    LastError();
    return result;
}

void NewmanZiff::PrintLabel(){
    int * Label = new int [L*L];
    cudaDeviceSynchronize();
    dim3 perBlock3(32,32);
	dim3 numBlock3(L/32,L/32);
	HA4_Relabeling<<<numBlock3,perBlock3>>>(ImageD,LabelD,L);
    cudaDeviceSynchronize();

    cudaMemcpy(Label, LabelD, sizeof(int)*L*L, cudaMemcpyDeviceToHost);
    for(int y = 0;y<L;y++){
       for(int x = 0;x<L;x++){
           std::cout<<Label[y*L+x]<<" ";
       }
       std::cout<<"\t\t"<<y*L<<std::endl;
    }
    // gpuErrchk(cudaPeekAtLastError());

    std::cout<<std::endl;
    std::cout<<std::endl;
    delete[] Label;
    
}