function setStateFromReference(model, state, reference, frame)

    % Initialise states array
    state_names = model.getStateVariableNames();
    n_states = state_names.getSize();
    state_array = org.opensim.modeling.Vector(n_states, 0);

    % Assign state values from reference data
    for j = 0:n_states - 1
        name = state_names.get(j);
        state_array.set(j, reference.getValue(frame, char(name)));
    end
    
    % Set state values in model
    model.setStateVariableValues(state, state_array);
    
end