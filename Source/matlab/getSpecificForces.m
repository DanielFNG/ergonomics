function forces = getSpecificForces(model, force_names)

    n_forces = length(force_names);
    forces = cell(1, n_forces);
    for i = 1:n_forces
        forces{i}  = org.opensim.modeling.SmoothSphereHalfSpaceForce. ...
            safeDownCast(model.getComponent(force_names{i}));
    end 

end