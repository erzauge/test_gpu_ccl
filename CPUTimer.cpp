#include "CPUTimer.hpp"
typedef std::chrono::duration<int, std::milli> ms;

void CPUTimer::Start(){
    start = std::chrono::high_resolution_clock::now();
}

void CPUTimer::Stop(){
    stop  = std::chrono::high_resolution_clock::now();
}

float CPUTimer::Elapsed(){
    auto elapsed = std::chrono::duration_cast<ms>(stop - start);
    return elapsed.count();
}