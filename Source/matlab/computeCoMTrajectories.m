function [com_p, com_v] = computeCoMTrajectories(model, reference)
    
    % Initialise model & get state & total mass
    state = model.initSystem();
    mass = model.getTotalMass(state);
    
    % Get access to body set
    body_set = model.getBodySet();
    n_bodies = body_set.getSize();
    
    % Initialise trajectory arrays 
    com_p = zeros(reference.NFrames, 3);
    com_v = zeros(reference.NFrames, 3);

    % For each frame of the reference data...
    for frame = 1:reference.NFrames
        
        % Update the state
        setStateFromReference(model, state, reference, frame);
        
        % Realise to dynamics stage
        model.realizeDynamics(state);
        
        % Iterate over the bodies
        for body_index = 0:n_bodies - 1
            
            % Get this body
            body = body_set.get(body_index);
            
            % Get mass centre 
            body_com = body.get_mass_center();
            
            % Get com & com velocity in ground frame
            pos = body.findStationLocationInGround(state, body_com);
            vel = body.findStationVelocityInGround(state, body_com);
            
            % Compute com & com velocity
            com_p(frame, :) = com_p(frame, :) + body.get_mass() * ...
                [pos.get(0), pos.get(1), pos.get(2)];
            com_v(frame, :) = com_v(frame, :) + body.get_mass() * ...
                [vel.get(0), vel.get(1), vel.get(2)];
            
        end
        
    end
    
    % Divide by total mass
    com_p = com_p/mass;
    com_v = com_v/mass;

end
