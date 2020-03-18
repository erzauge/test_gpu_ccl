#include "test_ccl.h"
#include <cuda_profiler_api.h>

#include "Logging.hpp"

int main(int argc, char const *argv[])
{
	Logger::verbosity=6;
	/* code */
	test_ccl a(4*32);
	cudaProfilerStart();
	// LOG(LOG_ALWAYS)<< "randome";
	for (size_t i = 0; i < 10000; i++)
	{
		a.RandomImage(0.5);
		a.ClusterSize();
	}
	// LOG(LOG_ALWAYS)<< "Labeling";
	cudaProfilerStop();
	// a.PrintLabel();
	
	return 0;
}