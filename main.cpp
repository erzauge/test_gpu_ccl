#include "test_ccl.h"
#include <cuda_profiler_api.h>

#include "Logging.hpp"

int main(int argc, char const *argv[])
{
	Logger::verbosity=6;
	/* code */
	test_ccl a(4*32);
	cudaProfilerStart();
	a.RandomImage(0.5);
	for (size_t i = 0; i < 500; i++)
	{
		a.Labeing();
	}
	cudaProfilerStop();
	a.freeGPU();
	
	return 0;
}