#include <vector>
#include <string>
#include <MocoImporter.hpp>

void configureGoals(OpenSim::MocoProblem&, std::vector<double>, std::string);
OpenSim::MocoSolution SitToStandTracked(std::string, std::vector<double>, std::string);