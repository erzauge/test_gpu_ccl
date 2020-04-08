#include "NewmanZiff_CPU.hpp"
#include "Logging.hpp"
#include "UnionFind.hpp"

#include <algorithm>
#include <iostream>


NewmanZiffCPU::NewmanZiffCPU(int size, int stride_):L(size),stride(stride_){
    it=0;
    randV = new int[L*L];
    Image = new int[L*L];
    for (int i=0;i<L*L;i++){
        randV[i]=i;
    }
    gen.seed(12345UL);

}

NewmanZiffCPU::~NewmanZiffCPU(){
    delete[] randV;
    delete[] Image;
}

std::vector<int> NewmanZiffCPU::iteration(){
    std::vector<int> result;

    for (int i=0;i<L*L;i++){
        Image[i]=0;
    }
    std::shuffle(&randV[0], &randV[L*L], gen);

    while (nextStep()){
 
        result.push_back(GetBigestCluster());
    }
    it=0;
    return result;

}

bool NewmanZiffCPU::nextStep(){
    
    if (it+stride<L*L){
        for (size_t i = 0; i < stride; i++){
            Image[randV[it+i]]=1;
        }
        it+=stride;
        return true;
    }
    else{
        return false;
    }

}

int NewmanZiffCPU::GetBigestCluster(){
    UnionFind Label(L*L);
    for (int y = 0; y < L; y++)
    {
        for (int x = 0; x < L; x++)
        {
            int id =y*L+x;
            if(x!=0 && Image[id] && Image[id-1]){
                Label.Union(id,id-1);
            }
            if(y!=0 && Image[id] && Image[id-L]){
                Label.Union(id,id-L);
            }
        }
        
    }
    
    std::vector<long> r = Label.ClusterSize();
    int SMax=0;
    for (auto &&i : r )
    {
        if(i>SMax){
            SMax=i;
        }
    }

    return SMax;
}
