#pragma once

#include <vector>
#include <random>

class NewmanZiffCPU
{
private:
    int L;
    int stride;
    int it;
    int *randV;
    int *Image;
    std::mt19937 gen;
    bool nextStep();
    int GetBigestCluster();
public:
    NewmanZiffCPU(int size,int stride_);
    ~NewmanZiffCPU();

    std::vector<int> iteration();
};