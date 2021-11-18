function f_min = getMinimumForces(forces)

    n_forces = length(forces);
    f_min = zeros(1, n_forces);

    for i = 1:n_forces
        f_min(i) = forces{i}.get_constant_contact_force();
    end

end