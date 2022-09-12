#include <LowerLevel.hpp>
#include <string>
#include <MocoImporter.hpp>
#include <MocoProjectedStabilityGoal.hpp>

using namespace OpenSim;

void configureGoals(MocoProblem& problem, std::vector<double> weights, std::string states_path)
{
    // Names
    std::vector<std::string> names = {"effort", "stability", "lumbar", "hip", "knee", "tracking"};

    // Goal definitions
    auto* effort = problem.addGoal<MocoControlGoal>(names[0], weights[0]);
    effort->setDivideByDisplacement(true);
    effort->setExponent(3);

    auto* stability = problem.addGoal<MocoProjectedStabilityGoal>(names[1], weights[1]);

    auto* lumbar = problem.addGoal<MocoJointReactionGoal>(names[2], weights[2]);
    lumbar->setJointPath("jointset/lumbar");

    auto* hip = problem.addGoal<MocoJointReactionGoal>(names[3], weights[3]);
    hip->setJointPath("jointset/hip_r");

    auto* knee = problem.addGoal<MocoJointReactionGoal>(names[4], weights[4]);
    knee->setJointPath("jointset/knee_r");

    // Tracking goal
    auto* tracking = problem.addGoal<MocoStateTrackingGoal>(names[5], weights[5]);
    TableProcessor states = TableProcessor(states_path);
    tracking->setReference(states);
    tracking->setAllowUnusedReferences(true);

    // Disable goals of 0 weight -> noticeable speed gains
    for (int i = 0; i < names.size(); i++) 
    {
        weights[i] == 0 ? problem.updGoal(names[i]).setEnabled(false) : problem.updGoal(names[i]).setEnabled(true);
    }
}

MocoSolution SitToStandTracked(std::string config_path, std::vector<double> weights, std::string states_path)
{
    // Create & configure LowerLevel optimiser
    LowerLevel lower_level = LowerLevel(config_path, weights);
    lower_level.configure();

    // Assign goals specific to this problem
    MocoProblem& problem = lower_level.updProblem();
    configureGoals(problem, weights, states_path);

    // Run
    MocoCasADiSolver& solver = lower_level.updSolver();
    return lower_level.run();
}

