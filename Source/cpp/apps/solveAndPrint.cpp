#include <string>
#include <vector>
#include <map>
#include <functional>
#include <OpenSim/Moco/osimMoco.h>
#include <Tasks.hpp>

int main(int argc, char* argv[])
{
    // Parse program inputs
    //  * Name of task function
    //  * Path to config file
    //  * Path to output file
    //  * Weights (double)
    const int WEIGHTS_START = 4;
    std::string task_function = argv[1];
    std::string config_path = argv[2];
    std::string output = argv[3];
    std::vector<double> weights;
    for (int i = WEIGHTS_START; i < argc; i++)
    {
        weights.push_back(atof(argv[i]));
    }

    // Create & run specific task. TASK_MAP constant maintained in Tasks.hpp.
    OpenSim::MocoSolution sol = Tasks::TASK_MAP[task_function](config_path, weights);

    // Write to output file
    sol.write(output);
}