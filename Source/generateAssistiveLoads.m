function generateAssistiveLoads(...
    filename, timesteps, start, duration, magnitude, direction)

    % Compute parameterised assistance profiles
    [fx, fy] = parameterisedAssistance(...
        timesteps, start, duration, magnitude, direction);

    % Header
    n_timesteps = length(timesteps);
    header{1} = sprintf(...
        'Start = %f, duration = %i, magnitude = %f, direction = %i', ...
        start, duration, magnitude, direction);
    header{2} = 'datacolumns 10';
    header{3} = sprintf('datarows %i', n_timesteps);
    header{4} = sprintf('range %f %f', timesteps(1), timesteps(end));
    header{5} = 'endheader';
    
    % Labels
    labels = {'time', 'ground_force1_vx', 'ground_force1_vy', ...
        'ground_force1_vz', 'ground_force1_px', 'ground_force1_py', ...
        'ground_force1_pz', 'ground_torque1_x', 'ground_torque1_y', ...
        'ground_torque1_z'};
    
    % Values
    values = [timesteps, fx, fy, zeros(n_timesteps, length(labels) - 3)];
        
    % Create MOT
    grfs = MOTData(values, header, labels);
    grfs.writeToFile(filename);

end