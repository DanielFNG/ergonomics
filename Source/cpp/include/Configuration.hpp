#ifndef INCLUDE_CONFIGURATION
#define INCLUDE_CONFIGURATION

#include <string>
#include <ProblemBounds.hpp>

struct Configuration {
    std::string model_path;
    std::string bounds_path;
    std::string guess_path;
    int parallel;
    int max_iterations;
    int num_mesh_intervals;
    double convergence_tolerance;
    double constraint_tolerance;
};

void writeConfiguration(Configuration, std::string);
Configuration parseConfiguration(std::string);
ProblemBounds parseBounds(Configuration config);

#endif