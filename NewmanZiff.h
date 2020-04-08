#pragma once

#include <vector>
#include <random>

class NewmanZiff
{
private:
    int L;
    int stride;
    int it;
    int *randVH;
    int *LabelD;
	int *ImageD;
	int *SizeD;
    int *randVD;
    std::mt19937 gen;
    bool nextStep();
    int GetBigestCluster();
    void PrintLabel();
public:
    NewmanZiff(int size,int stride);
    ~NewmanZiff();

    std::vector<int> iteration();
};