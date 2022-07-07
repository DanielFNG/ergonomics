#include <Configuration.hpp>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>

void writeConfiguration(Configuration config, std::string output_path)
{
    std::ofstream output_file(output_path);

    if (!output_file)
    {
        std::cerr << "Specified output file could not be opened.\n";
    }

    output_file << "model_path" << "\t" << config.model_path << "\n";
    output_file << "bounds_path" << "\t" << config.bounds_path << "\n";
    output_file << "guess_path" << "\t" << config.guess_path << "\n";
    output_file << "parallel" << "\t" << config.parallel << "\n";
    output_file << "max_iterations" << "\t" << config.max_iterations << "\n";
    output_file << "num_mesh_intervals" << "\t" << config.num_mesh_intervals << "\n";
    output_file << "convergence_tolerance" << "\t" << config.convergence_tolerance << "\n";
    output_file << "constraint_tolerance" << "\t" << config.constraint_tolerance << "\n";
}

Configuration parseConfiguration(std::string config_path)
{
    // Create an empty config
    Configuration config;

    // Open configuration file
    std::ifstream config_file;
    config_file.open(config_path);

    // Build up vectors of the parsed labels and values
    std::vector<std::string> labels;
    std::vector<std::string> values;
    std::string label;
    std::string value;
    while (config_file.good())
    {
        // Get the label and value
        std::getline(config_file, label, '\t');
        if (label.empty()) 
        {
            break;
        }
        std::getline(config_file, value, '\n');

        // Add to label & value vectors
        labels.push_back(label);
        values.push_back(value);
    }

    // Try to find indices of correct fields
    std::vector<std::string> fieldnames = {"model_path", "bounds_path", "guess_path", "parallel", "max_iterations", 
        "num_mesh_intervals", "convergence_tolerance", "constraint_tolerance"};
    std::vector<int> indices;
    for (int i = 0; i < fieldnames.size(); i++) 
    {
        std::vector<std::string>::iterator it = std::find(labels.begin(), labels.end(), fieldnames[i]);
        if (it == labels.end())
        {
            std::cerr << "Required parameter " + fieldnames[i] + " not found in configuration file.\n";
            return config;    
        }
        int index = std::distance(labels.begin(), it);
        indices.push_back(index);
    }

    // Assign the values appropriately
    config.model_path = values[indices[0]];
    config.bounds_path = values[indices[1]];
    config.guess_path = values[indices[2]];
    config.parallel = std::stoi(values[indices[3]]);
    config.max_iterations = std::stoi(values[indices[4]]);
    config.num_mesh_intervals = std::stoi(values[indices[5]]);
    config.convergence_tolerance = std::stod(values[indices[6]]);
    config.constraint_tolerance = std::stod(values[indices[7]]);

    return config;
}