#pragma once

#define FULL_MASK 0xffffffff

__device__ int start_distance(int p,int x);
__device__ int end_distance(int p,int x);
__device__ void merge(int *L,int label1,int label2);
__global__ void HA4_Strip_Labeling(int *I,int *L, unsigned width);
__global__ void HA4_Strip_Merge(int *I,int *L, unsigned width,unsigned blockH);
__global__ void HA4_Relabeling(int *I,int *L, unsigned width);
__global__ void HA4_ClusterSize(int *I,int *L, unsigned width,int *S);
__global__ void SetMem2Value(int * write, int * id, int start, int stride,int value = 1);
