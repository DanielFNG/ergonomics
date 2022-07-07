#include <string>
#include <Configuration.hpp>
#include <OpenSim/Moco/osimMoco.h>

int main(int argc, char *argv[]) {

    // Parse program inputs - bounds in, bounds out, model path
    std::string config_in = argv[1];
    std::string config_out = argv[2];

    // Parse bounds
    Configuration config = parseConfiguration(config_in);

    // Write to new text file
    writeConfiguration(config, config_out);

}