#include <vector>
#include <string>
#include <OpenSim/Moco/osimMoco.h>

void configureGoals(OpenSim::MocoProblem&, std::vector<double>);
OpenSim::MocoSolution SitToStand(std::string, std::vector<double>);