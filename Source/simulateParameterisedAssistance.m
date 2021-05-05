function simulateParameterisedAssistance(start, duration, magnitude, direction)
    
    % Load the model
    osim = org.opensim.modeling.Model(['C:\Users\danie\Documents\GitHub' ...
        '\ergonomics\Models\Generic\fullbodyH3.osim']);

    % Specify timesteps - for now assist over 2.5s
    start_time = 0;
    end_time = 2.5;
    increment = 0.001;
    timesteps = start_time:increment:end_time;

    % Compute FX & FY assistance functions
    [fx, fy] = parameterisedAssistance(...
        timesteps, start, duration, magnitude, direction);

    % Create piecewise constant functions for FX & FY
    fx_func = org.opensim.modeling.PiecewiseConstantFunction();
    fy_func = org.opensim.modeling.PiecewiseConstantFunction();
    n_timesteps = length(timesteps);
    for i = 1:n_timesteps
        fx_func.addPoint(timesteps(i), fx(i));
        fy_func.addPoint(timesteps(i), fy(i));
    end
    % Modify the prescribed force
    prescribed_force = org.opensim.modeling.PrescribedForce.safeDownCast(...
        osim.updForceSet().get('prescribedForce'));
    force_functions = prescribed_force.updForceFunctions();
    force_functions.set(0, fx_func);
    force_functions.set(1, fy_func);
    
    % Initialise state
    state = osim.initSystem();

    % Create simulation manager
    simulation = org.opensim.modeling.Manager(osim);
    simulation.initialize(state);

    % Simulate for 2.5s
    simulation.integrate(timesteps(end));

    % Write resulting states data
    writeStatesData(simulation, 'temp.sto');

end
% 
% % Use states to perform analysis
% results = Data('temp.sto');
% end_val = results.getValue(n_timesteps, ...
%     '/jointset/ground_H3_back/H3_back_ty/value');
% metric = abs(1 - end_val);

% What I want to check next is instead of reloading all of these things
% just setting them up & then changing e.g. 