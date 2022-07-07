#include <string>
#include <ProblemBounds.hpp>
#include <OpenSim/Moco/osimMoco.h>

int main(int argc, char *argv[]) {

    // Parse program inputs - bounds in, bounds out, model path
    std::string bounds_in = argv[1];
    std::string bounds_out = argv[2];
    std::string model_path = argv[3];

    // Load OpenSim model
    const OpenSim::Model& osim = OpenSim::Model(model_path);

    // Parse bounds
    ProblemBounds bounds = ProblemBounds(bounds_in, osim);

    // Write to new text file
    bounds.writeToFile(bounds_out);

}