#include <LowerLevel.hpp>
#include <string>
#include <MocoImporter.hpp>
#include <MocoProjectedStabilityGoal.hpp>

using namespace OpenSim;

void configureGoals(MocoProblem& problem, std::vector<double> weights)
{
    // Names
    std::vector<std::string> names = {"effort", "stability", "lumbar", "hip", "knee", "ankle"};

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

    auto* ankle = problem.addGoal<MocoJointReactionGoal>(names[5], weights[5]);
    ankle->setJointPath("jointset/ankle_r");

    // Disable goals of 0 weight -> noticeable speed gains
    for (int i = 0; i < names.size(); i++) 
    {
        weights[i] == 0 ? problem.updGoal(names[i]).setEnabled(false) : problem.updGoal(names[i]).setEnabled(true);
    }
}

MocoSolution SitToStand(std::string config_path, std::vector<double> weights)
{
    // Create & configure LowerLevel optimiser
    LowerLevel lower_level = LowerLevel(config_path, weights);
    lower_level.configure();

    // Assign goals specific to this problem
    MocoProblem& problem = lower_level.updProblem();
    configureGoals(problem, weights);

    // Run
    MocoCasADiSolver& solver = lower_level.updSolver();
    return lower_level.run();
}

