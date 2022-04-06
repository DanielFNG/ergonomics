function modelParameterisedAssistance(...
    osim, output_path, start, duration, magnitude, direction, body_path)

    % Some fixed parameters for now 
    start_time = 0;
    end_time = 2.0;
    increment = 0.01;
    timesteps = start_time:increment:end_time;
    
    % Compute FX & FY assistance functions
    [fx, fy] = parameterisedAssistance(...
        timesteps, start, duration, magnitude, direction);
    
    % Create piecewise constant functions for FX & FY
    fx_func = org.opensim.modeling.PiecewiseConstantFunction();
    fy_func = org.opensim.modeling.PiecewiseConstantFunction();
    fz_func = org.opensim.modeling.PiecewiseConstantFunction();
    n_timesteps = length(timesteps);
    for i = 1:n_timesteps
        fx_func.addPoint(timesteps(i), fx(i));
        fy_func.addPoint(timesteps(i), fy(i));
        fz_func.addPoint(timesteps(i), 0);
    end
    
    % Create a prescribed force
    prescribed_force =  org.opensim.modeling.PrescribedForce();
    prescribed_force.setFrameName(body_path);
    prescribed_force.setForceIsInGlobalFrame(true);
    prescribed_force.setForceFunctions(fx_func, fy_func, fz_func);
    
    % Add to model
    force_set = osim.updForceSet();
    force_set.append(prescribed_force);
    
    % Print new model
    osim.print(output_path);

end