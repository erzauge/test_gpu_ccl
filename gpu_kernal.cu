#define FULL_MASK 0xffffffff

__device__ int start_distance(int p,int x){
    return __clz(~(p<<(32-x)));
}

__device__ int end_distance(int p,int x){
    return __ffs(~(p>>(x+1)));
}

__device__ void merge(int *L,int label1,int label2){
    while (label1!=label2&&label1!=L[label1]){
        label1=L[label1];
    }

    while (label1!=label2&&label2!=L[label2]){
        label2=L[label2];
    }

    while (label1!=label2){
        if (label1<label2) {
            int swap = label1;
            label2 = label1;
            label1 = swap;
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
        if (threadIdx.x==0){
            sPixels[threadIdx.y]=pixelsY;
        } 
        __syncthreads();
        int pixelsYm    = threadIdx.y>0?sPixels[threadIdx.y-1]:0;
        int pYm         = pixelsYm&(1>>threadIdx.y);
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

//to be removed 
int main(){

    return 0;
}
