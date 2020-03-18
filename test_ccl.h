#pragma once

#include "Logging.hpp"
#include <random>
class test_ccl
{
private:
	int *LabelD;
	int *ImageD;
	int *SizeD;
	int	*ImageH;
	unsigned int L;
public:
	test_ccl(unsigned int size);
	~test_ccl();

	void Labeling();
	void RandomImage(double p);
	void PrintLabel();
	void ClusterSize();
};