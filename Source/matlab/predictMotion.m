function solution = predictMotion(...
    name, osim, goals, guess, timerange, bounds)

    % Import OpenSim modeling libraries
    import org.opensim.modeling.*

    % Define the optimal control problem
    study = MocoStudy();
    study.setName(name);
    problem = study.updProblem();
    modelProcessor = ModelProcessor(osim);
    problem.setModelProcessor(modelProcessor);
    model = modelProcessor.process();
    model.initSystem();

    % Assign goals
    for i = 1:length(goals)
        problem.addGoal(goals{i});
    end
    
    % Assign state bounds
    applyStateBounds(problem, bounds);
    
    % Apply time bounds
    problem.setTimeBounds(0, timerange);

    % Configure the solver - for now hard coded
    solver = study.initCasADiSolver();
    solver.set_num_mesh_intervals(50);
    solver.set_verbosity(2);
    solver.set_optim_solver('ipopt');
    solver.set_optim_convergence_tolerance(1e-2);
    solver.set_optim_constraint_tolerance(1e-4);
    solver.set_optim_max_iterations(2000);

    % Specify initial guess
    solver.setGuess(guess); 
    
    % Solve problem
    solution = study.solve();

end