#include "test_ccl.h"
 
 test_ccl::test_ccl(unsigned int size){
 	if (size%32)
 	{
 		LOG(LOG_ERROR)<<"size not an multipel of 32.  size is: "<<size;
 		exit(2);
 	}
 	L=size;
 	cudaMalloc((void**)&ImageD, sizeof(int)*L*L);
 	cudaMalloc((void**)&LabelD, sizeof(int)*L*L);
 	ImageH = new int [L*L];
 }

 test_ccl::~test_ccl(){
 	cudaFree(ImageD);
 	cudaFree(LabelD);
 }

 void test_ccl::RandomImage(double p){
 	std::random_device device;
    std::mt19937 gen(device());
    std::uniform_real_distribution dist(0,1);
    for (int i = 0; i < L*L; ++i)
     {
     	ImageH[i]=(p<=dist(gen))?0:1;
     } 
     cudaMemcpy(ImageD, ImageH, sizeof(int)*L*L, cudaMemcpyHostToDevice);

  }

 void test_ccl::Labeing(){
 	
 }