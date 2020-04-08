#pragma once
#include <cuda_runtime.h>
class GPUTimer
{
private:
    cudaEvent_t start,stop;
public:
    GPUTimer();
    ~GPUTimer();
    void Start();
    void Stop();
    float Elapsed();
};


