#include "test_ccl.h"
#include "gpu_kernal.h"
#include <iostream>
// #include <cuda.h>

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess) 
   {
		LOG(LOG_ERROR)<<"GPUassert: "<< cudaGetErrorString(code)<<" "<<file<<" "<<line;
	   if (abort) exit(code);
   }
}

 test_ccl::test_ccl(unsigned int size){
 	if (size%32)
 	{
 		LOG(LOG_ERROR)<<"size not an multipel of 32.  size is: "<<size;
 		exit(2);
 	}
 	L=size;
 	cudaMalloc((void**)&ImageD, sizeof(int)*L*L);
	cudaMalloc((void**)&LabelD, sizeof(int)*L*L);
	cudaMalloc((void**)&SizeD, sizeof(int)*L*L);
	ImageH = new int [L*L];
	gpuErrchk(cudaPeekAtLastError());
 
 }

 test_ccl::~test_ccl(){
	cudaDeviceSynchronize();
 	cudaFree(ImageD);
	cudaFree(LabelD);
	cudaFree(SizeD);
	
	gpuErrchk(cudaPeekAtLastError());

 }

 void test_ccl::RandomImage(double p){
 	std::random_device device;
    std::mt19937 gen(device());
    std::uniform_real_distribution<> dist(0,1);
    for (int i = 0; i < L*L; ++i)
     {
     	ImageH[i]=(p<=dist(gen))?1:0;
	 } 
	 cudaMemcpy(ImageD, ImageH, sizeof(int)*L*L, cudaMemcpyHostToDevice);
	 gpuErrchk(cudaPeekAtLastError());


  }

 void test_ccl::Labeling(){
	dim3 perBlock1(32,32);
	dim3 numBlock1(1,L/32);
	HA4_Strip_Labeling<<<numBlock1,perBlock1,sizeof(int)*L/32>>>(ImageD,LabelD,L);
	dim3 perBlock2(32,(L/32)<32?L/32:32);
	dim3 numBlock2(L/32,(L/32)<32?1:L/64);
	HA4_Strip_Merge<<<numBlock2,perBlock2>>>(ImageD,LabelD,L,32);
	dim3 perBlock3(32,32);
	dim3 numBlock3(L/32,L/32);
	HA4_Relabeling<<<numBlock3,perBlock3>>>(ImageD,LabelD,L);
	
	// cudaDeviceSynchronize();
	// gpuErrchk(cudaPeekAtLastError());
 	
 }

 void test_ccl::PrintLabel(){
	 int * Label = new int [L*L];
	 cudaDeviceSynchronize();

	 cudaMemcpy(Label, LabelD, sizeof(int)*L*L, cudaMemcpyDeviceToHost);
	 for(int y = 0;y<L;y++){
		for(int x = 0;x<L;x++){
			std::cout<<Label[y*L+x]<<" ";
		}
		std::cout<<std::endl;
	 }
	 gpuErrchk(cudaPeekAtLastError());
	 delete[] Label;
	 
 }

 void test_ccl::ClusterSize(){
	cudaMemset(SizeD,0,sizeof(int)*L*L);
	int *SizeH =new int [L*L];
	dim3 perBlock1(32,32);
	dim3 numBlock1(1,L/32);
	HA4_Strip_Labeling<<<numBlock1,perBlock1,sizeof(int)*L/32>>>(ImageD,LabelD,L);
	dim3 perBlock2(32,(L/32)<32?L/32:32);
	dim3 numBlock2(L/32,(L/32)<32?1:L/64);
	HA4_Strip_Merge<<<numBlock2,perBlock2>>>(ImageD,LabelD,L,32);
	dim3 perBlock3(32,32);
	dim3 numBlock3(L/32,L/32);
	HA4_ClusterSize<<<numBlock3,perBlock3>>>(ImageD,LabelD,L,SizeD);
	cudaMemcpy(SizeH, SizeD, sizeof(int)*L*L, cudaMemcpyDeviceToHost);
	int s_max=0;
	for(int i=0;i<L*L;i++){
		if (SizeH[i]>s_max){
			s_max=SizeH[i];
		}
	}
	std::cout<<s_max<<std::endl;
	

	 
 }