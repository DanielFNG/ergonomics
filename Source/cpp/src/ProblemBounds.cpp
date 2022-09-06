#include <ProblemBounds.hpp>
#include <string>
#include <vector>
#include <limits>
#include <sstream>
#include <iostream>
#include <fstream>
#include <MocoImporter.hpp>

ProblemBounds::ProblemBounds() {};

ProblemBounds::ProblemBounds(std::string filename, const OpenSim::Model& osim) {

    // Open bounds file
    std::ifstream bounds_file;
    bounds_file.open(filename);

    // Get the in_degrees property
    std::string line;
    std::getline(bounds_file, line, '\t');
    std::getline(bounds_file, line, '\n');
    for (int i = 0; i < line.length(); i++) 
    {
        line[i] = tolower(line[i]);
    }
    in_degrees = (line == "true") ? true : false;

    // Get time bounds
    std::getline(bounds_file, line, '\t');
    std::getline(bounds_file, line, '\t');
    time_bound.push_back(std::stod(line));
    std::getline(bounds_file, line, '\n');
    time_bound.push_back(std::stod(line));

    // Ignore the line of headers
    std::getline(bounds_file, line, '\n');

    // Read in the data
    while (bounds_file.good())
    {
        // Read first entry. Assume we're done if there's an empty line at the end of the file.
        std::getline(bounds_file, line, '\t');
        if (line.empty() || line == "\n") {
            break;
        }
        coordinate_name.push_back(trim(line));

        // Create vector of bound values 
        std::vector<double> bound_values;
        for (int i = 0; i < 4; i++)
        {
            char delim = (i < 3) ? '\t' : '\n';
            std::getline(bounds_file, line, delim);
            line = trim(line);
            line.empty() ? bound_values.push_back(std::numeric_limits<double>::quiet_NaN()) : bound_values.push_back(std::stod(line));
        }

        // Store whether joints are rotational or not
        const OpenSim::CoordinateSet& coordinate_set = osim.getCoordinateSet();
        std::vector<std::string> path_decomposed = split(coordinate_name[coordinate_name.size() - 1], '/');
        std::string this_coordinate_name = path_decomposed[path_decomposed.size() - 2];
        const OpenSim::Coordinate& coordinate = coordinate_set.get(this_coordinate_name);
        bool is_rotational = (coordinate.getMotionType() == OpenSim::Coordinate::Rotational) ? true : false;
        rotational_coord.push_back(is_rotational);

        // Internally convert from degrees to radians if necessary
        if (in_degrees && is_rotational) 
        {
            for (int i = 0; i < 4; i++)
            {
                bound_values[i] = bound_values[i]*SimTK::Pi/180.0;
            }
        }

        // Assign the values to the bounds struct
        lower_bound.push_back(bound_values[0]);
        upper_bound.push_back(bound_values[1]);
        initial_value.push_back(bound_values[2]);
        final_value.push_back(bound_values[3]);
    }

    // Close bounds file
    bounds_file.close();
}

void ProblemBounds::writeToFile(std::string output_path, bool in_degrees) {

    std::ofstream output_file(output_path);

    if (!output_file)
    {
        std::cerr << "Specified output file could not be opened.\n";
    }

    std::string in_degrees_str = (in_degrees) ? "true" : "false";
    output_file << "indegrees\t" << in_degrees_str << "\n";
    output_file << "timerange\t" << time_bound[0] << '\t' << time_bound[1] << '\n';
    output_file << "Name\t" << "LowerBound\t" << "UpperBound\t" << "InitialValue\t" << "FinalValue\n";  
    for (int i = 0; i < coordinate_name.size(); i++)
    {
        double multiplier = (rotational_coord[i] && in_degrees) ? 180.0/SimTK::Pi : 1;
        output_file << coordinate_name[i] << '\t';
        output_file << multiplier*lower_bound[i] << '\t';
        output_file << multiplier*upper_bound[i] << '\t';
        output_file << multiplier*initial_value[i] << '\t';
        output_file << multiplier*final_value[i] << '\n';
        
    }

}

std::string trim(const std::string& line)
{
    const char* white_space = " \t\v\r\n";
    if (line.find_first_not_of(white_space) != std::string::npos)
    {
        std::size_t start = line.find_first_not_of(white_space);
        std::size_t end = line.find_last_not_of(white_space);
        return line.substr(start, end - start + 1);
    }
    else
    {
        return std::string();
    }
}

std::vector<std::string> split (const std::string &s, char delim) 
{
    std::vector<std::string> result;
    std::stringstream ss(s);
    std::string item;

    while (std::getline(ss, item, delim))
    {
        result.push_back(item);
    }

    return result;
}
