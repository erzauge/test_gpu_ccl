#include "gpu_kernal.h"
#include <stdio.h>

__device__ int start_distance(int p,int x){
    return __clz(~(p<<(32-x)));
}

__device__ int end_distance(int p,int x){
    return __ffs(~(p>>(x+1)));
}

__device__ void merge(int *L,int label1,int label2){
    //find
    while (label1!=label2&&label1!=L[label1]){
        label1=L[label1];
    }

    while (label1!=label2&&label2!=L[label2]){
        label2=L[label2];
    }

    
    while (label1!=label2){
        if (label1<label2) {
            //swap
            int swap = label1;
            label1 = label2;
            label2 = swap;
        }

        int label3 = atomicMin(&L[label1],label2);
        if (label1==label3){
            label1=label2;
        }
        else{
            label1=label3;
        }
    }
}


__global__ void HA4_Strip_Labeling(int *I,int *L, unsigned width) {
    extern __shared__ int sPixels[];
    int lineBase    = (blockIdx.y*blockDim.y+threadIdx.y)*width+ threadIdx.x;
    int distanceY   = 0;
    int distanceYm  = 0;
    for(int i=0; i < width;i+=32){
        int id      = lineBase+i;
        int pY      = I[id];
        int pixelsY = __ballot_sync(FULL_MASK,pY);
        int sDistY  = start_distance(pixelsY,threadIdx.x);
        if (pY && sDistY==0){
            if(threadIdx.x!=0){
                L[id]=id;
            }
            else{
                L[id]=id-distanceY;
            }
        }
        __syncthreads();
        if (threadIdx.x==0){
            sPixels[threadIdx.y]=pixelsY;
        } 
        __syncthreads();
        int pixelsYm    = (threadIdx.y>0)?sPixels[threadIdx.y-1]:0;
        int pYm         = (pixelsYm>>threadIdx.x)&1;
        int sDistYm     = start_distance(pixelsYm,threadIdx.x);
        if (threadIdx.x==0){
            sDistY  = distanceY;
            sDistYm = distanceYm;
        }
        if (pY && pYm && (sDistY==0 || sDistYm==0)){
            int label1 = id - sDistY;
            int label2 = id - width -sDistYm;
            merge(L,label1,label2);
        }
        int d       = start_distance(pixelsYm,32);
        distanceYm  = d+(d==32?distanceYm:0);
        d           = start_distance(pixelsY,32);
        distanceY   = d+(d==32?distanceY:0);
    }
}

__global__ void HA4_Strip_Merge(int *I,int *L, unsigned width,unsigned blockH){
    int y = (blockIdx.y*blockDim.y+threadIdx.y);
    int x = (blockIdx.x*blockDim.x+threadIdx.x);
    if (y>0&&y<width){
        int idY     = y*width+x;
        int idYm    = idY-width;
        int pY      = I[idY];
        int pYm     = I[idYm];
        int pixelsY = __ballot_sync(FULL_MASK,pY);
        int pixelsYm= __ballot_sync(FULL_MASK,pYm);
        if (pY && pYm){
            int sDistY  = start_distance(pixelsY,threadIdx.x);
            int sDistYm = start_distance(pixelsYm,threadIdx.x);
            if (sDistY==0 || sDistYm==0){
                merge(L,idY-sDistY,idYm-sDistYm);
            }
        }
    }
}

__global__ void HA4_Relabeling(int *I,int *L, unsigned width){
    int y = (blockIdx.y*blockDim.y+threadIdx.y);
    int x = (blockIdx.x*blockDim.x+threadIdx.x);
    int id = y*width+x;
    int p = I[id];
    int pixels = __ballot_sync(FULL_MASK,p);
    int sDist =start_distance(pixels,threadIdx.x);
    int label = 0;
    if (p && sDist==0){
        label = L[id];
        while (label != L[label]){
            label = L[label];
        }
    }
    label=__shfl_sync(FULL_MASK, label, threadIdx.x -sDist);
    if (p){
        L[id]=label;
    }
    else{
        L[id]=-1;
    }

}

__global__ void HA4_ClusterSize(int *I,int *L, unsigned width,int *S){
    int y = (blockIdx.y*blockDim.y+threadIdx.y);
    int x = (blockIdx.x*blockDim.x+threadIdx.x);
    int id = y*width+x;
    int p = I[id];
    int pixels =__ballot_sync(FULL_MASK,p);
    int sDist = start_distance(pixels,threadIdx.x);
    int count = end_distance(pixels,threadIdx.x);
    if (p && sDist==0){
        int label= L[id];
        while (label!=L[label]){
            label=L[label];
        }
        if(count==0){
            count=32-threadIdx.x;
        }
        atomicAdd(&S[label],count);
    }
}

__global__ void SetMem2Value(int * write, int * id, int start, int stride,int value){
    int x = (blockIdx.x*blockDim.x+threadIdx.x);
    if(x<stride){
        write[id[start+x]]=value;
    }
}
