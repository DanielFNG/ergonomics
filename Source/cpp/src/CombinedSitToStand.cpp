#include <LowerLevel.hpp>
#include <string>
#include <MocoImporter.hpp>
#include <MocoProjectedStabilityGoal.hpp>

using namespace OpenSim;

void configureGoals2(MocoProblem& problem, std::vector<double> weights)
{
    // Names
    std::vector<std::string> names = {"lumbar", "stability"};

    // Goal definitions
    auto* lumbar = problem.addGoal<MocoJointReactionGoal>(names[0], weights[0]);
    lumbar->setJointPath("jointset/lumbar_h");
    /*
    auto* effort = problem.addGoal<MocoControlGoal>(names[0], weights[0]);
    effort->setDivideByDisplacement(true);
    effort->setExponent(3);
    //effort->setWeightForControl("/lumbarAct", 0);
    //effort->setWeightForControl("/r_hip_act", 0);
    //effort->setWeightForControl("/r_knee_act", 0);
    //effort->setWeightForControl("/r_ankle_act", 0);
    //effort->setWeightForControl("/r_shoulder_act", 0);
    //effort->setWeightForControl("/r_elbow_act", 0);
    */

    auto* stability = problem.addGoal<MocoProjectedStabilityGoal>(names[1], weights[1]);

    // Disable goals of 0 weight -> noticeable speed gains
    for (int i = 0; i < names.size(); i++) 
    {
        weights[i] == 0 ? problem.updGoal(names[i]).setEnabled(false) : problem.updGoal(names[i]).setEnabled(true);
    }
}

MocoSolution CombinedSitToStand(std::string config_path, std::vector<double> weights)
{
    // Create & configure LowerLevel optimiser
    LowerLevel lower_level = LowerLevel(config_path, weights);
    lower_level.configure();

    // Assign goals specific to this problem
    MocoProblem& problem = lower_level.updProblem();
    configureGoals2(problem, weights);

    // Run
    MocoCasADiSolver& solver = lower_level.updSolver();
    return lower_level.run();
}

