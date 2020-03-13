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
        //to be continud
    }
}

//to be removed 
int main(){

    return 0;
}
