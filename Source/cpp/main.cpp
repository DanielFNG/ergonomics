#include "MocoMarginOfStabilityGoal.h"
#include "MocoProjectedMarginOfStabilityGoal.h"
#include "MocoWeightedMarginOfStabilityGoal.h"
#include <string>
#include <OpenSim/Moco/osimMoco.h>

using namespace OpenSim;

int main(int argc, char *argv[]) {

    // Define some inputs here for now
    std::string input_model = "2D_gait_contact_constrained_activation.osim";
    std::string study_name = "sit_to_stand";
    std::string translation_reference = 
        "adjusted_reference_StatesReporter_states.sto";
    std::string guess_trajectory = 
        "sitToStandTracking_solution_constrained_activation.sto";
    std::string pelvis_path = "groundPelvis";
    std::string hip_path = "hip_r";
    std::string knee_path = "knee_r";
    std::string ankle_path = "ankle_r";

    // Parse program inputs - we require the 8 weights and the ouput file name, in that order
    double w_effort = atof(argv[1]);
    auto w_effort_str = std::to_string(w_effort);
    double w_mos = atof(argv[2]);
    auto w_mos_str = std::to_string(w_mos);
    double w_pmos = atof(argv[3]);
    auto w_pmos_str = std::to_string(w_pmos);
    double w_wmos = atof(argv[4]);
    auto w_wmos_str = std::to_string(w_wmos);
    double w_aload = atof(argv[5]);
    auto w_aload_str = std::to_string(w_aload);
    double w_kload = atof(argv[6]);
    auto w_kload_str = std::to_string(w_kload);
    double w_hload = atof(argv[7]);
    auto w_hload_str = std::to_string(w_hload);
    double w_pload = atof(argv[8]);
    auto w_pload_str = std::to_string(w_pload);
    std::string output_path = argv[9];
    output_path.append(std::string("/w_effort=") + w_effort_str + 
        "_w_mos=" + w_mos_str + "_w_pmos=" + w_pmos_str + "_w_wmos=" 
        + w_wmos_str + "_w_aload=" + w_aload_str + "_w_kload=" + w_kload_str
        + "_w_hload_=" + w_hload_str + "_w_ploat_=" + w_pload_str + ".sto");

    // Initialise study
    MocoStudy study;
    study.setName(study_name);

    // Isolate problem & assign model
    MocoProblem& problem = study.updProblem();
    ModelProcessor model_processor = ModelProcessor(input_model);
    problem.setModelProcessor(model_processor);

    // Set up effort goal
    if (w_effort > 0) 
    {
        auto* effort_goal = problem.addGoal<MocoControlGoal>("effort", w_effort);
        effort_goal->setDivideByDisplacement(true);
        effort_goal->setExponent(3);
    }

    // Set up margin of stability goal
    if (w_mos > 0)
    {
        auto* mos_goal = problem.addGoal
            <MocoMarginOfStabilityGoal>("mos", w_mos);
    }

    // Set up projected margin of stability goal
    if (w_pmos > 0)
    {
        auto* pmos_goal = problem.addGoal
            <MocoProjectedMarginOfStabilityGoal>("pmos", w_pmos);
    }

    // Set up margin of stability goal
    if (w_wmos > 0)
    {
        auto* wmos_goal = problem.addGoal
            <MocoWeightedMarginOfStabilityGoal>("wmos", w_wmos);
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

    // Set up pelvis joint loading
    if (w_pload > 0)
    {
        auto* pload_goal = 
            problem.addGoal<MocoJointReactionGoal>("pload", w_pload);
        pload_goal->setJointPath(pelvis_path);
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
        {-1500*Pi/180, 1500*Pi/180}, 0, 0);
    problem.setStateInfo("/jointset/groundPelvis/pelvis_tx/speed", 
        {-5, 5}, 0, 0);
    problem.setStateInfo("/jointset/groundPelvis/pelvis_ty/speed", 
        {-2, 10}, 0, 0);
    problem.setStateInfo("/jointset/hip_l/hip_flexion_l/speed", 
        {-2500*Pi/180, 1500*Pi/180}, 0, 0);
    problem.setStateInfo("/jointset/hip_r/hip_flexion_r/speed", 
        {-2500*Pi/180, 1500*Pi/180}, 0, 0);
    problem.setStateInfo("/jointset/knee_l/knee_angle_l/speed", 
        {-500*Pi/180, 3000*Pi/180}, 0, 0);
    problem.setStateInfo("/jointset/knee_r/knee_angle_r/speed", 
        {-500*Pi/180, 3000*Pi/180}, 0, 0);
    problem.setStateInfo("/jointset/ankle_l/ankle_angle_l/speed", 
        {-1200*Pi/180, 800*Pi/180}, 0, 0);
    problem.setStateInfo("/jointset/ankle_r/ankle_angle_r/speed", 
        {-1200*Pi/180, 800*Pi/180}, 0, 0);
    problem.setStateInfo("/jointset/lumbar/lumbar/speed", 
        {-1000*Pi/180, 2000*Pi/180}, 0, 0);

    std::cout << "oi" << std::endl;

    // Configure the solver.
    MocoCasADiSolver& solver = study.initCasADiSolver();
    std::cout << "oi" << std::endl;
    solver.set_num_mesh_intervals(50);
    solver.set_verbosity(2);
    solver.set_optim_solver("ipopt");
    solver.set_optim_max_iterations(1000);
    solver.set_optim_convergence_tolerance(1e-2);
    solver.set_optim_constraint_tolerance(1e-4);

    std::cout << "oi" << std::endl;    

    // Specify an initial guess.
    MocoTrajectory guess = MocoTrajectory(guess_trajectory);
    solver.setGuess(guess);

    // Solve the problem.
    MocoSolution solution = study.solve();
    std::cout << "Solution status: " << solution.getStatus() << std::endl;

    // For now, write the solution
    solution.write(output_path);

    return EXIT_SUCCESS;
}
