#ifndef __TIMER_H__
#define __TIMER_H__

#include <chrono>
#include <iostream>

class Timer {

public:
    Timer() {
        start = std::chrono::high_resolution_clock::now();
    }

    ~Timer() {
        end = std::chrono::high_resolution_clock::now();
        std::chrono::milliseconds duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        std::cout << "Duration: " << duration.count() << "ms" << std::endl;
    }

private:
    std::chrono::time_point<std::chrono::high_resolution_clock> start, end;
};
#endif // __TIMER_H__