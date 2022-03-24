#include <string>
#include <OpenSim/Moco/osimMoco.h>
#include <OpenSim/Moco/MocoGoal/MocoOutputGoal.h>
#include "Goals/MocoMultiJointReactionGoal.h"
#include <OpenSim/Common/STOFileAdapter.h>
#include <fstream>

using namespace OpenSim;

int main(int argc, char *argv[]) {

    // Fixed parameters
    std::string lumbar_path = "/jointset/lumbar/";
    std::string hip_path = "/jointset/hip_r";
    std::string knee_path = "/jointset/knee_r/";
    std::string ankle_path = "/jointset/ankle_r";
    int max_iterations = 1000;

    // Parse program inputs - 8
    // Path to model file, path to guess trajectory, output file path, 
    // path to reference trajectory, and the weights 
    // See below for order 
    std::string model_path = argv[1];
    std::string guess_path = argv[2];
    std::string output_path = argv[3];
    std::string reference_path = argv[4];
    double w_lumbar = atof(argv[5]);
    double w_hip = atof(argv[6]);
    double w_knee = atof(argv[7]);
    double w_ankle = atof(argv[8]);

    // Initialise study
    MocoStudy study;
    study.setName("test_MocoOutput");

    // Isolate problem & assign model
    MocoProblem& problem = study.updProblem();
    ModelProcessor model_processor = ModelProcessor(model_path);
    problem.setModelProcessor(model_processor);

    // Set up effort goal
    auto* effort_goal = problem.addGoal<MocoControlGoal>("effort", 0.1);
    effort_goal->setDivideByDisplacement(true);
    effort_goal->setExponent(3);

    // Set up joint loading
    auto* joint_loading = problem.addGoal<MocoMultiJointReactionGoal>("joint_loading");
    joint_loading->setJointPathAndWeight(lumbar_path, w_lumbar);
    joint_loading->setJointPathAndWeight(hip_path, w_hip);
    joint_loading->setJointPathAndWeight(knee_path, w_knee);
    joint_loading->setJointPathAndWeight(ankle_path, w_ankle);

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
    solver.set_parallel(0);
    //solver.set_multibody_dynamics_mode("implicit");
    //solver.set_minimize_implicit_multibody_accelerations(true);

    // Specify an initial guess.
    MocoTrajectory guess = MocoTrajectory(guess_path);
    //guess.generateAccelerationsFromSpeeds();
    solver.setGuess(guess);

    // Solve the problem.
    MocoSolution solution = study.solve();
    std::cout << "Solution status: " << solution.getStatus() << std::endl;

    // Load the reference solution
    MocoTrajectory reference = MocoTrajectory(reference_path);
    double upper_objective = solution.compareContinuousVariablesRMS(reference);

    // Write the value to a result file
    std::ofstream output_file(output_path);
    output_file << upper_objective;
    output_file.close();


    // // Extract ground reaction forces
    // std::vector<std::string> contact_r;
    // std::vector<std::string> contact_l;
    // contact_r.push_back("chair_r");
    // contact_r.push_back("r_1");
    // contact_r.push_back("r_2");
    // contact_r.push_back("r_3");
    // contact_r.push_back("r_4");
    // contact_l.push_back("chair_l");
    // contact_l.push_back("l_1");
    // contact_l.push_back("l_2");
    // contact_l.push_back("l_3");
    // contact_l.push_back("l_4");
    // Model model = model_processor.process();
    // model.initSystem();
    // TimeSeriesTable external_forces = createExternalLoadsTableForGait(
    //     model, solution, contact_r, contact_l);
    // STOFileAdapter::write(external_forces, "test.sto");

    // Compute metric

    // Write metric to output file

    return EXIT_SUCCESS;

}