function [fx, fy] = parameterisedAssistance(...
    timesteps, start, duration, magnitude, direction)

    % Checks
    if start < 0 || start + duration > 100
        error('Assistance must lie within time of motion.');
    end

    % Compute net force over trajectory
    s = (timesteps - timesteps(1))/(timesteps(end) - timesteps(1))*100;
    f = magnitude*sin((pi/duration)*(s - start));
    f(s <= start) = 0;
    f(s > start + duration) = 0;
    
    % Compute Cartesian components
    fx = f*cos(deg2rad(direction));
    fy = f*sin(deg2rad(direction));

end