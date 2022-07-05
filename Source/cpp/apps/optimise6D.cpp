#include <MocoProjectedStabilityGoal.hpp>
#include <string>
#include <sstream>
#include <iostream>
#include <fstream>
#include <OpenSim/Moco/osimMoco.h>
#include <OpenSim/Common/STOFileAdapter.h>

using namespace OpenSim;

struct ProblemBounds 
{
    std::vector<std::string> name;
    std::vector<double> lower_bound;
    std::vector<double> upper_bound;
    std::vector<double> initial_value;
    std::vector<double> final_value;
};

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

std::string trim(const std::string& line)
{
    if (line.find_first_not_of(' ') != std::string::npos)
    {
        const char* white_space = " \t\v\r\n";
        std::size_t start = line.find_first_not_of(white_space);
        std::size_t end = line.find_last_not_of(white_space);
        return line.substr(start, end - start + 1);
    }
    else
    {
        return std::string();
    }
}

ProblemBounds parseBounds(std::string filename, Model osim)
{
    // Create empty ProblemBounds struct
    ProblemBounds bounds;
    
    // Open bounds file
    std::ifstream bounds_file;
    bounds_file.open(filename);

    // Get the in_degrees property
    std::string line;
    std::getline(bounds_file, line, '\t');
    std::getline(bounds_file, line, '\t');
    for (int i = 0; i < line.length(); i++) 
    {
        line[i] = tolower(line[i]);
    }
    bool in_degrees = (line == "yes") ? true : false;

    // Ignore the line of headers
    std::getline(bounds_file, line, '\n');

    // Read in the data
    while (bounds_file.good())
    {
        // Get joint name
        std::getline(bounds_file, line, '\t');
        bounds.name.push_back(trim(line));
        std::cout << "Oi" << std::endl;

        // Create vector of bound values 
        std::vector<double> bound_values;
        for (int i = 0; i < 4; i++)
        {
            char delim = (i < 3) ? '\t' : '\n';
            std::getline(bounds_file, line, delim);
            line = trim(line);
            line.empty() ? bound_values.push_back(std::numeric_limits<double>::quiet_NaN()) : bound_values.push_back(std::stod(line));
        }

        // Convert from degrees to radians if necessary
        if (in_degrees)
        {
            CoordinateSet coordinate_set = osim.getCoordinateSet();
            std::vector<std::string> path_decomposed = split(bounds.name[bounds.name.size() - 1], '/');
            std::string coordinate_name = path_decomposed[path_decomposed.size() - 2];
            Coordinate::MotionType joint_type = coordinate_set.get(coordinate_name).getMotionType(); 
            if (joint_type == Coordinate::MotionType::Rotational)
            {
                for (int i = 0; i < 4; i++)
                {
                    bound_values[i] = bound_values[i]*SimTK::Pi/180.0;
                }
            }
        }

        // Assign the values to the bounds struct
        bounds.lower_bound.push_back(bound_values[0]);
        bounds.upper_bound.push_back(bound_values[1]);
        bounds.initial_value.push_back(bound_values[2]);
        bounds.final_value.push_back(bound_values[3]);
    }

    // Close bounds file
    bounds_file.close();

    return bounds;
}

void assignBounds(MocoProblem& problem, ProblemBounds bounds)
{
    for (int i = 0; i < bounds.name.size() - 1; i++)
    {
        // Logic for handling if there are no specific initial/final values
        double initial, final;
        std::isnan(bounds.initial_value[i]) ? initial = {} : initial = bounds.initial_value[i];
        std::isnan(bounds.final_value[i]) ? final = {} : final = bounds.final_value[i];

        // Set state info
        problem.setStateInfo(bounds.name[i], {bounds.lower_bound[i], bounds.upper_bound[i]}, 
            initial, final);
    }

}

int main(int argc, char *argv[]) {

    // Fixed parameters
    std::string lumbar_path = "jointset/lumbar/";
    std::string hip_path = "jointset/hip_r";
    std::string knee_path = "jointset/knee_r/";
    std::string ankle_path = "jointset/ankle_r";
    int max_iterations = 2000;

    // Parse program inputs - 8 or 9 parameters 
    // Path to model file, path to guess trajectory, output file path, and the 5 weights
    // Optional final parameter specifies whether to run on all cores (1) or a single core (0)  
    // See below for order 
    std::string model_path = argv[1];
    std::string guess_path = argv[2];
    std::string output_path = argv[3];
    std::string reference_path = argv[4];
    double w_effort = atof(argv[5]);
    double w_stability = atof(argv[6]);
    double w_lumbar = atof(argv[7]);
    double w_hip = atof(argv[8]);
    double w_knee = atof(argv[9]);
    double w_ankle = atof(argv[10]);
    int parallel = 1;
    if (argc == 11) {
        parallel = atoi(argv[11]);
    }

    // Initialise study
    MocoStudy study;

    // Isolate problem & assign model
    MocoProblem& problem = study.updProblem();
    ModelProcessor model_processor = ModelProcessor(model_path);
    problem.setModelProcessor(model_processor);

    // Set up effort goal
    if (w_effort > 0) 
    {
        auto* effort_goal = problem.addGoal<MocoControlGoal>("effort", w_effort);
        effort_goal->setDivideByDisplacement(true);
        effort_goal->setExponent(3);
    }

    // Set up stability goal
    if (w_stability > 0)
    {
        auto* stability_goal = problem.addGoal<MocoProjectedStabilityGoal>("stability", w_stability);
    }

    // Set up joint loading with separate terms
    if (w_lumbar > 0)
    {
        auto* lumbar_goal = problem.addGoal<MocoJointReactionGoal>("lumbar", w_lumbar);
        lumbar_goal->setJointPath(lumbar_path);
    }

    if (w_hip > 0)
    {
        auto* hip_goal = problem.addGoal<MocoJointReactionGoal>("hip", w_hip);
        hip_goal->setJointPath(hip_path);
    }

    if (w_knee > 0)
    {
        auto* knee_goal = problem.addGoal<MocoJointReactionGoal>("knee", w_knee);
        knee_goal->setJointPath(knee_path);
    }

    if (w_ankle > 0)
    {
        auto* ankle_goal = problem.addGoal<MocoJointReactionGoal>("ankle", w_ankle);
        ankle_goal->setJointPath(ankle_path);
    }

    // Specify bounds on start and end time
    problem.setTimeBounds(0, {1.5, 1.5});

    // Specify bounds on joint limits and joint speeds
    Model osim = Model(model_path);
    ProblemBounds bounds = parseBounds(bounds_path, osim);
    assignBounds(problem, bounds);

    // Configure the solver.
    MocoCasADiSolver& solver = study.initCasADiSolver();
    solver.set_optim_max_iterations(max_iterations);
    solver.set_num_mesh_intervals(50);
    solver.set_verbosity(2);
    solver.set_optim_solver("ipopt");
    solver.set_optim_convergence_tolerance(1e-2);
    solver.set_optim_constraint_tolerance(1e-4);
    solver.set_parallel(parallel);  

    // Specify an initial guess.
    MocoTrajectory guess = MocoTrajectory(guess_path);
    solver.setGuess(guess);

    // Solve the problem.
    MocoSolution solution = study.solve();
    std::cout << "Solution status: " << solution.getStatus() << std::endl;

    // Change behaviour based on input reference_path
    if (reference_path == "none") {
        // Write the solution to file
        solution.write(output_path);
    }
    else {
        // Load the provided reference
        MocoTrajectory reference = MocoTrajectory(reference_path);

        // Compare solution to reference
        double upper_objective = solution.compareContinuousVariablesRMS(reference);

        // Write the resulting RMS to the specified result file
        std::ofstream output_file(output_path);
        output_file << upper_objective;
        output_file.close();
    }

    return EXIT_SUCCESS;

}
