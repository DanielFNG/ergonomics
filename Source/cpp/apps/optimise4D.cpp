#include <string>
#include <MocoMultiJointReactionGoal.hpp>
#include <OpenSim/Moco/osimMoco.h>
#include <OpenSim/Common/STOFileAdapter.h>
//#include <fstream>

using namespace OpenSim;

int main(int argc, char *argv[]) {

    // Fixed parameters
    std::string lumbar_path = "/jointset/lumbar/";
    std::string hip_path = "/jointset/hip_r";
    std::string knee_path = "/jointset/knee_r/";
    std::string ankle_path = "/jointset/ankle_r";
    int max_iterations = 2000;

    // Parse program inputs - 5
    // Path to model file, path to guess trajectory, output file path, and the weight 
    // See below for order 
    std::string model_path = argv[1];
    std::string guess_path = argv[2];
    std::string output_path = argv[3];
    std::string reference_path = argv[4];
    double w_lumbar = atof(argv[5]);
    double w_hip = atof(argv[6]);
    double w_knee = atof(argv[7]);
    double w_ankle = atof(argv[8]);
    int parallel = 1;
    if (argc == 9) {
        parallel = atoi(argv[9]);
    }

    // Initialise study
    MocoStudy study;

    // Isolate problem & assign model
    MocoProblem& problem = study.updProblem();
    ModelProcessor model_processor = ModelProcessor(model_path);
    problem.setModelProcessor(model_processor);

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

    // Specify bounds on positions
    using SimTK::Pi;
    problem.setStateInfo("/jointset/groundPelvis/pelvis_tilt/value", 
        {0*Pi/180, 50*Pi/180}, 43.426*Pi/180, 0);
    problem.setStateInfo("/jointset/groundPelvis/pelvis_tx/value", 
        {-2, 2}, 0.05);
    problem.setStateInfo("/jointset/groundPelvis/pelvis_ty/value", 
        {0, 2}, 0.572);
    problem.setStateInfo("/jointset/hip_l/hip_flexion_l/value", 
        {-180*Pi/180, 180*Pi/180}, 48.858*Pi/180, 0);
    problem.setStateInfo("/jointset/hip_r/hip_flexion_r/value", 
        {-180*Pi/180, 180*Pi/180}, 48.858*Pi/180, 0);
    problem.setStateInfo("/jointset/knee_l/knee_angle_l/value", 
        {-180*Pi/180, 180*Pi/180}, -112.113*Pi/180, 0);
    problem.setStateInfo("/jointset/knee_r/knee_angle_r/value", 
        {-180*Pi/180, 180*Pi/180}, -112.113*Pi/180, 0);
    problem.setStateInfo("/jointset/ankle_l/ankle_angle_l/value", 
        {-180*Pi/180, 180*Pi/180}, 19.827*Pi/180, 0);
    problem.setStateInfo("/jointset/ankle_r/ankle_angle_r/value", 
        {-180*Pi/180, 180*Pi/180}, 19.827*Pi/180, 0);
    problem.setStateInfo("/jointset/lumbar/lumbar/value", 
        {-180*Pi/180, 180*Pi/180}, -53.183*Pi/180, 0);

    // Specify bounds on speeds
    problem.setStateInfo("/jointset/groundPelvis/pelvis_tilt/speed", 
        {-360*Pi/180, 360*Pi/180}, 0);
    problem.setStateInfo("/jointset/groundPelvis/pelvis_tx/speed", 
        {-5, 5}, 0);
    problem.setStateInfo("/jointset/groundPelvis/pelvis_ty/speed", 
        {-2, 10}, 0);
    problem.setStateInfo("/jointset/hip_l/hip_flexion_l/speed", 
        {-360*Pi/180, 360*Pi/180}, 0);
    problem.setStateInfo("/jointset/hip_r/hip_flexion_r/speed", 
        {-360*Pi/180, 360*Pi/180}, 0);
    problem.setStateInfo("/jointset/knee_l/knee_angle_l/speed", 
        {-360*Pi/180, 360*Pi/180}, 0);
    problem.setStateInfo("/jointset/knee_r/knee_angle_r/speed", 
        {-360*Pi/180, 360*Pi/180}, 0);
    problem.setStateInfo("/jointset/ankle_l/ankle_angle_l/speed", 
        {-360*Pi/180, 360*Pi/180}, 0);
    problem.setStateInfo("/jointset/ankle_r/ankle_angle_r/speed", 
        {-360*Pi/180, 360*Pi/180}, 0);
    problem.setStateInfo("/jointset/lumbar/lumbar/speed", 
        {-360*Pi/180, 360*Pi/180}, 0);

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