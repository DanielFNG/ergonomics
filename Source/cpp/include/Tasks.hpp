#include <SitToStand.hpp>
#include <string>
#include <vector>
#include <map>
#include <functional>

namespace Tasks
{
    std::map<std::string, std::function<OpenSim::MocoSolution(std::string, std::vector<double>)>> TASK_MAP = 
    {
        {"SitToStand", &SitToStand}
    };
}
