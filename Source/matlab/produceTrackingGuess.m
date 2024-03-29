function solution = produceTrackingGuess(...
    name, w_states, w_controls, osim, input, bounds, max_iter, guess_path)
% Currently, in the absence of measured seat forces, this function performs
% kinematic tracking only & does not consider any measured GRFs.

    % Import OpenSim modeling libraries
    import org.opensim.modeling.*

    % Define the optimal control problem
    track = MocoTrack();
    track.setName(name);
    table_processor = TableProcessor(input);
    table_processor.append(TabOpLowPassFilter(6));
    model_processor = ModelProcessor(osim);
    track.setModel(model_processor);
    track.setStatesReference(table_processor);
    track.set_states_global_tracking_weight(w_states);
    track.set_allow_unused_references(true);
    track.set_track_reference_position_derivatives(true);
    track.set_apply_tracked_states_to_guess(true);
    
    % Get & set start & end times
    input_data = Data(input);
    track.set_initial_time(input_data.Timesteps(1));
    track.set_final_time(input_data.Timesteps(end));

    % Initialise study & problem
    try
        study = track.initialize();
    catch err
        warning(err.message);
        track.set_final_time(input_data.Timesteps(end) + 0.001);
        study = track.initialize();
    end
    problem = study.updProblem();

    % Model processing 
    model = model_processor.process();
    model.initSystem();

    % Get a reference to the MocoControlGoal that is added to every 
    % MocoTrack problem by default and change the weight
    effort = MocoControlGoal.safeDownCast(...
        problem.updGoal('control_effort'));
    effort.setWeight(w_controls);

    % Apply joint angle & speed bounds
    applyStateBoundsTracking(problem, bounds);

    % Set initial guess
    if nargin >= 7
        solver = MocoCasADiSolver.safeDownCast(study.updSolver());
        solver.set_optim_max_iterations(max_iter);
    end
    if nargin == 8
        solver.setGuessFile(guess_path);
    end

    % Solve tracking problem
    solution = study.solve();

end





