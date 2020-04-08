#include "test_ccl.h"
#include "NewmanZiff.h"
#include "NewmanZiff_CPU.hpp"
#include "CPUTimer.hpp"
#include "GPUTimer.h"
#include <cuda_profiler_api.h>

#include <tclap/CmdLine.h>
#include <vector>
#include <iostream>
 

#include "Logging.hpp"

int main(int argc, char const *argv[])
{
	Logger::verbosity=6;
	TCLAP::CmdLine cmd("test");
	TCLAP::ValueArg<int> LArg("L","size","system size",true,32,"multpil of 32");
	cmd.add(LArg);
	TCLAP::ValueArg<int> strideArg("s","stride","stride",false,32,"ineger");
	cmd.add(strideArg);
	TCLAP::ValueArg<int> NArg("n","repetions","number of repetions",false,10,"");
	cmd.add(NArg);
	TCLAP::SwitchArg CPUArg("","CPU","comput on cpu");
	cmd.add(CPUArg);
	cmd.parse(argc,argv);
	if (LArg.getValue()%32!=0)
	{
		LOG(LOG_ERROR)<<"L must be an multipel of 32";
		exit(2);
	}
	
	double time=0;
	int N=LArg.getValue()*LArg.getValue();
	std::vector<double> sum((N)/strideArg.getValue()-1,0.);
	std::vector<double> sum2((N)/strideArg.getValue()-1,0.);
	if (CPUArg.getValue())
	{
		NewmanZiffCPU a(LArg.getValue(),strideArg.getValue());
		CPUTimer timer;
		for (size_t i = 0; i < NArg.getValue(); i++)
		{
			timer.Start();
			std::vector<int> r=a.iteration();
			timer.Stop();
			time+= timer.Elapsed();
			for (int j = 0; j < r.size(); j++)
			{
				sum[j]+=r[j];
				sum2[j]+=(double)r[j]*(double)r[j];
			}
			
		}
	}
	else
	{
		NewmanZiff a(LArg.getValue(),strideArg.getValue());
		GPUTimer timer;
		cudaProfilerStart();
		for (size_t i = 0; i < NArg.getValue(); i++)
		{
			timer.Start();
			std::vector<int> r=a.iteration();
			timer.Stop();
			time+=timer.Elapsed();
			for (int j = 0; j < r.size(); j++)
			{
				sum[j]+=r[j];
				sum2[j]+=(double)r[j]*(double)r[j];
			}
			
		}
		cudaProfilerStop();
	}
	std::cerr<<time/NArg.getValue()<<std::endl;
	for (int i = 0; i < sum.size(); i++)
	{
		std::cout<<((double)(i+1)*strideArg.getValue())/N<<"\t"<<sum[i]/NArg.getValue()<<"\t"<<sum[i]/(NArg.getValue()*N)<<"\t"<<sum2[i]/(NArg.getValue())-(sum[i]*sum[i])/(NArg.getValue()*NArg.getValue())<<"\n";
	}
	std::cout<<std::endl;
	
	// a.PrintLabel();
	
	return 0;
}