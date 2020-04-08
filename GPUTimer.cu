#include "GPUTimer.h"
GPUTimer::GPUTimer()
{
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
}

GPUTimer::~GPUTimer()
{
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
}

void GPUTimer::Start(){
    cudaEventRecord(start,0);
}

void GPUTimer::Stop(){
    cudaEventRecord(stop,0);
}

float GPUTimer::Elapsed(){
    float elapsed;
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed, start, stop);
    return elapsed;
}