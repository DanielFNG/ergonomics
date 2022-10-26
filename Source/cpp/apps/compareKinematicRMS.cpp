#include <string>
#include <vector>
#include <MocoImporter.hpp>

int main(int argc, char* argv[])
{
    // Parse program inputs
    //  * Name of task function
    //  * Path to config file
    //  * Weights (double)
    std::string output_path = argv[1];
    std::string solution_path = argv[2];
    std::string reference_path = argv[3];

    // Load the provided reference & solution
    OpenSim::MocoTrajectory solution = OpenSim::MocoTrajectory(solution_path);
    OpenSim::MocoTrajectory reference = OpenSim::MocoTrajectory(reference_path);
    double comparison = solution.compareContinuousVariablesRMSPattern(reference, "states", ".*value");

    // Write the resulting RMS to the specified output file
    std::ofstream output_file(output_path);
    output_file << comparison;
    output_file.close();

    return EXIT_SUCCESS;
}