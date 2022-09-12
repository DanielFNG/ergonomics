#include <string>
#include <vector>
#include <map>
#include <functional>
#include <MocoImporter.hpp>
#include <SitToStandTracked.hpp>

int main(int argc, char* argv[])
{
    // Parse program inputs
    //  * Name of task function
    //  * Path to config file
    //  * Path to output file
    //  * Weights (double)
    const int WEIGHTS_START = 5;
    std::string task_function = argv[1];
    std::string config_path = argv[2];
    std::string output = argv[3];
    std::string reference = argv[4];
    std::vector<double> weights;
    for (int i = WEIGHTS_START; i < argc; i++)
    {
        weights.push_back(atof(argv[i]));
    }

    // Create & run specific task. TASK_MAP constant maintained in Tasks.hpp.
    OpenSim::MocoSolution sol = SitToStandTracked(config_path, weights, reference);

    // Write to output file
    sol.write(output);
}