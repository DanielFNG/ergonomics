#ifndef INCLUDE_PROBLEMBOUNDS
#define INCLUDE_PROBLEMBOUNDS

#include <string>
#include <vector>
#include <MocoImporter.hpp>

class ProblemBounds 
{
        std::vector<bool> rotational_coord {};
    public:
        std::vector<double> time_bound {};
        std::vector<std::string> coordinate_name {};
        std::vector<double> lower_bound {}, upper_bound {}, initial_value {}, final_value {};
        bool in_degrees {};
        ProblemBounds();
        ProblemBounds(std::string, const OpenSim::Model&);
        void writeToFile(std::string, bool = true);

};

std::string trim(const std::string& line);
std::vector<std::string> split (const std::string &s, char delim);

#endif