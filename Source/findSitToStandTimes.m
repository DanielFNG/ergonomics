function [start, finish] = findSitToStandTimes(bk_velocity)
% Find start & finish time of a sit to stand using CoM velocity data

    % Filter BK velocity to 6 Hz
    bk_velocity.filter4LP(6);
    
    % Isolate X & Y CoM velocity
    x_vel = bk_velocity.getColumn('center_of_mass_X');
    y_vel = bk_velocity.getColumn('center_of_mass_Y');
    
    % Find peak in X & Y velocity
    [x_max, x_max_i] = max(x_vel);
    [y_max, y_max_i] = max(y_vel);
    
    % Adjust velocity arrays for convenience
    x_vel(x_max_i + 1:end) = x_max;
    y_vel(1:y_max_i - 1) = y_max;
    
    % Find start point
    start_i = find(x_vel <= 0, 1, 'last');
    finish_i = find(y_vel <= 0, 1, 'first');
    
    % Handle edge cases
    if isempty(start_i)
        start_i = 1;
        warning('No suitable start time found - setting to first timestep.');
    end
    if isempty(finish_i)
        finish_i = bk_velocity.NFrames;
        warning('No suitable end time found - setting to last timestep.');
    end
    
    % Convert to times
    start = bk_velocity.Timesteps(start_i);
    finish = bk_velocity.Timesteps(finish_i);

end
