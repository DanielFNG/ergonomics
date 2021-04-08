function state = initialiseFromStates(model, reference_path)
% Assumes that the reference trajectory is not in degrees and is of the
% /jointset/... format, as is true in states files produced by OpenSim 4.1.

    % Initialise model
    state = model.initSystem();
    
    % Load reference state data
    reference = Data(reference_path);
    
    % Build array of state data
    variable_names = model.getStateVariableNames();
    n_variables = variable_names.getSize();
    array = org.opensim.modeling.Vector(n_variables, 0);
    arrays = [];
    for i = 0:n_variables - 1
        name = variable_names.get(i);
        names{i + 1} = char(name);
        array.set(i, reference.getValue(1, char(name)));
        arrays = [arrays, reference.getValue(1, char(name))];
    end
        
    % Set state
    model.setStateVariableValues(state, array);

end