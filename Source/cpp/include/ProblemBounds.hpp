#include <string>
#include <vector>
#include <OpenSim/Moco/osimMoco.h>

class ProblemBounds {
        std::vector<std::string> coordinate_name;
        std::vector<double> lower_bound, upper_bound, initial_value, final_value;
        bool in_degrees;
        std::vector<bool> rotational_coord;
    public:
        ProblemBounds(std::string, OpenSim::Model);
        void writeToFile(std::string, bool = true);
        void assign(OpenSim::MocoProblem&);

};

std::string trim(const std::string& line);
std::vector<std::string> split (const std::string &s, char delim);
