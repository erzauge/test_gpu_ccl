#pragma once

#include "Logging.hpp"
#include <random>
class test_ccl
{
private:
	int *LabelD;
	int *ImageD;
	int	*ImageH;
	unsigned int L;
public:
	test_ccl(unsigned int size);
	~test_ccl();

	void Labeing();
	void RandomImage(double p);
};