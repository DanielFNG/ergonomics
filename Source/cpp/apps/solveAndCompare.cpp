#include <string>
#include <vector>
#include <MocoImporter.hpp>
#include <Tasks.hpp>

int main(int argc, char* argv[])
{
    // Parse program inputs
    //  * Name of task function
    //  * Path to config file
    //  * Weights (double)
    const int WEIGHTS_START = 5;
    std::string task_function = argv[1];
    std::string config_path = argv[2];
    std::string output_path = argv[3];
    std::string reference_path = argv[4];
    std::vector<double> weights;
    for (int i = WEIGHTS_START; i < argc; i++)
    {
        weights.push_back(atof(argv[i]));
    }

    // Create & run specific task
    OpenSim::MocoSolution sol = Tasks::TASK_MAP[task_function](config_path, weights);

    // Load the provided reference
    OpenSim::MocoTrajectory reference = OpenSim::MocoTrajectory(reference_path);
    double comparison = sol.compareContinuousVariablesRMS(reference);

    // Write the resulting RMS to the specified output file
    std::ofstream output_file(output_path);
    output_file << comparison;
    output_file.close();

    return EXIT_SUCCESS;
}