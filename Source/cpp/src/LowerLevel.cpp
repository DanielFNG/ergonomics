#include <LowerLevel.hpp>
#include <OpenSim/Moco/osimMoco.h>

using namespace OpenSim;

// Construct from strings
LowerLevel::LowerLevel(std::string config_path, std::vector<double> input_weights)
{
    config = parseConfiguration(config_path);
    bounds = parseBounds(config);
    weights = input_weights;
}

// Construct from pre-made Configuration and ProblemBounds objects
LowerLevel::LowerLevel(Configuration config_in, ProblemBounds bounds_in, std::vector<double> weights_in)
{
    config = config_in;
    bounds = bounds_in;
    weights = weights_in;
}

void LowerLevel::configure()
{
    initialise();
    configureBounds();
    configureSolver();
    configureGuess();
}

void LowerLevel::initialise()
{
    MocoProblem& problem = study.updProblem();
    ModelProcessor model_processor = ModelProcessor(config.model_path);
    problem.setModelProcessor(model_processor);
}

void LowerLevel::configureBounds()
{
    MocoProblem& problem = study.updProblem();
    for (int i = 0; i < bounds.coordinate_name.size(); i++)
    {
        MocoInitialBounds initial = (std::isnan(bounds.initial_value[i])) ? MocoInitialBounds() : MocoInitialBounds(bounds.initial_value[i]);
        MocoFinalBounds final = (std::isnan(bounds.final_value[i])) ? MocoFinalBounds() : MocoFinalBounds(bounds.final_value[i]);

        // Set state info
        problem.setStateInfo(bounds.coordinate_name[i], {bounds.lower_bound[i], bounds.upper_bound[i]}, initial, final);

        // Set time info
        problem.setTimeBounds(0, {bounds.time_bound[0], bounds.time_bound[1]});
    }
}

void LowerLevel::configureSolver()
{
    // Configure solver
    MocoCasADiSolver& solver = study.initCasADiSolver();
    solver.set_optim_max_iterations(config.max_iterations);
    solver.set_num_mesh_intervals(config.num_mesh_intervals);
    solver.set_verbosity(2);
    solver.set_optim_solver("ipopt");
    solver.set_optim_convergence_tolerance(config.convergence_tolerance);
    solver.set_optim_constraint_tolerance(config.constraint_tolerance);
    solver.set_parallel(config.parallel);
}

void LowerLevel::configureGuess()
{
    // Specify initial guess
    study.updSolver<MocoCasADiSolver>().setGuessFile(config.guess_path);
}

MocoProblem& LowerLevel::updProblem()
{
    return study.updProblem();
}

MocoCasADiSolver& LowerLevel::updSolver()
{
    return study.updSolver<MocoCasADiSolver>();
}

MocoSolution LowerLevel::run()
{
    // Check if the user has correctly added goals to the problem
    if (study.getProblem().createRep().getNumCosts() == 0)
    {
        std::cerr << "Error: attempting to run LowerLevel with no goals added.\n";
        MocoSolution err_sol {};
        return err_sol;
    }
    MocoSolution sol = study.solve();
    std::cout << "Solution status: " << sol.getStatus() << std::endl;
    return sol;
}