#pragma once

#include <chrono>

class CPUTimer
{
private:
    std::chrono::time_point<std::chrono::high_resolution_clock> start,stop;
public:
    CPUTimer(){}
    ~CPUTimer(){}
    void Start();
    void Stop();
    float Elapsed();
};