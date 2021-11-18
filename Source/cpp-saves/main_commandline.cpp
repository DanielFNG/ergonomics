#include "MocoMarginOfStabilityGoal.h"
#include <string>
#include <OpenSim/Moco/osimMoco.h>

using namespace OpenSim;

int main(int argc, char *argv[]) {

    // Define some inputs here for now
    std::string input_model = "2D_gait_contact_constrained_activation.osim";
    std::string study_name = "sit_to_stand";
    std::string translation_reference = 
        "adjusted_reference_StatesReporter_states.sto";
    std::vector<std::string> translation_frames = 
        {"/bodyset/calcn_r", "/bodyset/calcn_l"};
    std::string guess_trajectory = 
        "sitToStandTracking_solution_constrained_activation.sto";

    // Parse program inputs - we require the three weights & output file name.
    double w_effort = atof(argv[1]);
    auto w_effort_str = std::to_string(w_effort);
    double w_translation = atof(argv[2]);
    auto w_translation_str = std::to_string(w_translation);
    double w_margin = atof(argv[3]);
    auto w_margin_str = std::to_string(w_margin);
    std::string output_path = argv[4];
    output_path.append(std::string("/w_effort=") + w_effort_str + 
        "_w_translation=" + w_translation_str + "_w_mos=" + w_margin_str + ".sto");

    // Initialise study
    MocoStudy study;
    study.setName(study_name);

    // Isolate problem & assign model
    MocoProblem& problem = study.updProblem();
    ModelProcessor model_processor = ModelProcessor(input_model);
    problem.setModelProcessor(model_processor);

    // Set up effort goal
    auto* effort_goal = problem.addGoal<MocoControlGoal>("effort", w_effort);
    effort_goal->setDivideByDisplacement(true);
    effort_goal->setExponent(3);

    // Set up foot tracking goal
    auto* translation_goal = problem.addGoal<MocoTranslationTrackingGoal>(
        "translation", w_translation);
    TableProcessor table_processor = TableProcessor(translation_reference);
    translation_goal->setStatesReference(table_processor);
    translation_goal->setFramePaths(translation_frames);

    // Set up margin of stability goal
    auto* margin_of_stability_goal = problem.addGoal<MocoMarginOfStabilityGoal>(
        "margin_of_stability", w_margin);

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

    // Configure the solver.
    MocoCasADiSolver& solver = study.initCasADiSolver();
    solver.set_num_mesh_intervals(50);
    solver.set_verbosity(2);
    solver.set_optim_solver("ipopt");
    solver.set_optim_max_iterations(1000);
    solver.set_optim_convergence_tolerance(1e-2);
    solver.set_optim_constraint_tolerance(1e-4);    

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