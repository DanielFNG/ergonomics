function fy = computeVerticalContactForces(force_array, state)

    n_forces = length(force_array);
    fy = zeros(1, n_forces);
    for i = 1:n_forces
        fy(i) = computeVerticalContactForce(force_array{i}, state);
    end

end