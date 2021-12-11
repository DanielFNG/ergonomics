#include "MocoStabilityGoal.h"
#include <string>
#include <sstream>
#include <OpenSim/Moco/osimMoco.h>

using namespace OpenSim;

int main(int argc, char *argv[]) {

    // Fixed parameters    
    std::string study_name = "sit_to_stand";
    std::string pelvis_path = "jointset/groundPelvis";
    std::string hip_path = "jointset/hip_r";
    std::string knee_path = "jointset/knee_r";
    std::string ankle_path = "jointset/ankle_r";
    int max_iterations = 1000;

    // Set up sstream precision
    std::ostringstream oss;
    oss << std::setprecision(3);

    // Parse program inputs - 10 parameters 
    // Path to model file, path to guess trajectory, path to output directory, and the 7 weights 
    // See below for order 
    std::string model_path = argv[1];
    std::string guess_path = argv[2];
    std::string output_dir = argv[3];
    double w_effort = atof(argv[4]);
    oss << w_effort;
    std::string w_effort_str = oss.str();
    oss.str("");
    double w_mos = atof(argv[5]);
    oss << w_mos;
    std::string w_mos_str = oss.str();
    oss.str("");
    double w_pmos = atof(argv[6]);
    oss << w_pmos;
    std::string w_pmos_str = oss.str();
    oss.str("");
    double w_wmos = atof(argv[7]);
    oss << w_wmos;
    std::string w_wmos_str = oss.str();
    oss.str("");
    double w_aload = atof(argv[8]);
    oss << w_aload;
    std::string w_aload_str = oss.str();
    oss.str("");
    double w_kload = atof(argv[9]);
    oss << w_kload;
    std::string w_kload_str = oss.str();
    oss.str("");
    double w_hload = atof(argv[10]);
    oss << w_hload;
    std::string w_hload_str = oss.str();
    output_dir.append(std::string("/w_effort=") + w_effort_str + 
        "_w_mos=" + w_mos_str + "_w_pmos=" + w_pmos_str + "_w_wmos=" 
        + w_wmos_str + "_w_aload=" + w_aload_str + "_w_kload=" + w_kload_str
        + "_w_hload=" + w_hload_str + ".sto");

    // Initialise study
    MocoStudy study;
    study.setName(study_name);

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
    if (w_mos > 0 || w_pmos > 0 || w_wmos > 0)
    {
        auto* stability_goal = problem.addGoal
            <MocoStabilityGoal>("stability");
        stability_goal->setMOSWeight(w_mos);
        stability_goal->setPMOSWeight(w_pmos);
        stability_goal->setWMOSWeight(w_wmos);
    }

    // Set up ankle joint loading
    if (w_aload > 0)
    {
        auto* aload_goal = 
            problem.addGoal<MocoJointReactionGoal>("aload", w_aload);
        aload_goal->setJointPath(ankle_path);
    }

    // Set up knee joint loading
    if (w_kload > 0)
    {
        auto* kload_goal = 
            problem.addGoal<MocoJointReactionGoal>("kload", w_kload);
        kload_goal->setJointPath(knee_path);
    }

    // Set up hip joint loading
    if (w_hload > 0)
    {
        auto* hload_goal = 
            problem.addGoal<MocoJointReactionGoal>("hload", w_hload);
        hload_goal->setJointPath(hip_path);
    }

    // Specify bounds on start and end time
    problem.setTimeBounds(0, {1.0, 2.0});

    // Specify bounds on positions
    using SimTK::Pi;
    problem.setStateInfo("/jointset/groundPelvis/pelvis_tilt/value", 
        {0*Pi/180, 50*Pi/180}, 43.426*Pi/180, 0);
    problem.setStateInfo("/jointset/groundPelvis/pelvis_tx/value", 
        {0, 0.5}, 0.05);
    problem.setStateInfo("/jointset/groundPelvis/pelvis_ty/value", 
        {0.5, 1.0}, 0.535);
    problem.setStateInfo("/jointset/hip_l/hip_flexion_l/value", 
        {-15*Pi/180, 80*Pi/180}, 48.858*Pi/180, 0);
    problem.setStateInfo("/jointset/hip_r/hip_flexion_r/value", 
        {-15*Pi/180, 80*Pi/180}, 48.858*Pi/180, 0);
    problem.setStateInfo("/jointset/knee_l/knee_angle_l/value", 
        {-120*Pi/180, 5*Pi/180}, -112.113*Pi/180, 0);
    problem.setStateInfo("/jointset/knee_r/knee_angle_r/value", 
        {-120*Pi/180, 5*Pi/180}, -112.113*Pi/180, 0);
    problem.setStateInfo("/jointset/ankle_l/ankle_angle_l/value", 
        {0*Pi/180, 35*Pi/180}, 21.109*Pi/180, 0);
    problem.setStateInfo("/jointset/ankle_r/ankle_angle_r/value", 
        {0*Pi/180, 35*Pi/180}, 21.109*Pi/180, 0);
    problem.setStateInfo("/jointset/lumbar/lumbar/value", 
        {-70*Pi/180, 0*Pi/180}, -53.183*Pi/180, 0);

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
    std::cout << "oi" << std::endl;
    solver.set_num_mesh_intervals(50);
    solver.set_verbosity(2);
    solver.set_optim_solver("ipopt");
    solver.set_optim_max_iterations(max_iterations);
    solver.set_optim_convergence_tolerance(1e-2);
    solver.set_optim_constraint_tolerance(1e-4);

    std::cout << "oi" << std::endl;    

    // Specify an initial guess.
    MocoTrajectory guess = MocoTrajectory(guess_path);
    solver.setGuess(guess);

    // Solve the problem.
    MocoSolution solution = study.solve();
    std::cout << "Solution status: " << solution.getStatus() << std::endl;

    // For now, write the solution
    solution.write(output_dir);

    return EXIT_SUCCESS;
}
