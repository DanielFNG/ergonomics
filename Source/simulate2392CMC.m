function simulate2392CMC(osim_model, controls, states, actuators, loads, save_path)

    % Import OpenSim libraries
    import org.opensim.modeling.*
    
    % Load the model
    osim = Model(osim_model);
    
    % Load the ForceSet specified by the actuators file.
    force_set = ForceSet(actuators, true);
    
    % Downcast and append 
    for i = 0:2
        osim.addForce(PointActuator.safeDownCast(force_set.get(i)));
    end
    for i = 3:5
        osim.addForce(TorqueActuator.safeDownCast(force_set.get(i)));
    end
    for i = 6:18
        osim.addForce(CoordinateActuator.safeDownCast(force_set.get(i)));
    end
    
    
    % Create prescribed controllers for each actuator 
    actuator_controls = Data(controls);
    for i = 2:actuator_controls.NCols
        
        % Get actuator name & object
        name = actuator_controls.Labels{i};
        try
            actuator = osim.updActuators().get(name);

            % Create & link a prescribed controller
            controller = PrescribedController();
            controller.addActuator(actuator);

            % Convert control data in to a piecewise constant function
            signal = PiecewiseConstantFunction();
            values = actuator_controls.getColumn(name);
            for j = 1:actuator_controls.NFrames
                signal.addPoint(actuator_controls.Timesteps(j), values(j));
            end

            % Link the controller and function
            controller.prescribeControlForActuator(name, signal);

            % Rename controller
            controller.setName([name '_controls']);

            % Link controller to model
            osim.addController(controller);
        catch
        end
    end
    
    % Load the ExternalLoads specified in the loads file
    external_loads = ExternalLoads(loads, true);
    osim.addModelComponent(external_loads);
    
    % Initialise model state
    state = initialiseFromStates(osim, states);
    
    % Create a simulation manager
    simulation = org.opensim.modeling.Manager(osim);
    state.setTime(actuator_controls.Timesteps(1));
    simulation.initialize(state);
    
    % Simulate
    for i = 1:length(actuator_controls.Timesteps)
        
        % Show progress
        fprintf('Simulating... t = %fs (final time = %f).\n', ...
            actuator_controls.Timesteps(i), actuator_controls.Timesteps(end));
        
        % Simulate forward to next timestep
        simulation.integrate(actuator_controls.Timesteps(i));
    end
    
    % Write results to file
    writeStatesData(simulation, save_path);
    
end