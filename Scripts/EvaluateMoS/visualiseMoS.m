function [mos, timesteps] = visualiseMoS(model_path, solution_path, save_folder)

    % Open VideoWriter
    v = VideoWriter([save_folder filesep 'evolution.avi'], 'Uncompressed AVI');
    open(v);

    % Parameters - ordering is important for geometry, these points are
    % expressed anti clockwise
    force_strings = {'chair_r', 'chair_l', 'contactHeel_l', ...
        'contactFront_l', 'contactFront_r', 'contactHeel_r'};
    sphere_strings = {'butt_r', 'butt_l', 'heel_l', 'front_l', ...
        'front_r', 'heel_r'};

    % Load solution as Data object 
    solution = Data(solution_path);
    
    % Load and initialise OpenSim model
    import org.opensim.modeling.*
    model = Model(model_path);
    state = model.initSystem();
    
    % Get access to state names
    state_names = model.getStateVariableNames();
    
    % Create array to store state data at each frame
    n_variables = state_names.getSize();
    array = Vector(n_variables, 0);
    
    % Initialise mos vector
    mos = zeros(solution.NFrames, 1);
    wmos = zeros(solution.NFrames, 1);
    
    % Compute model weight
    model_weight = abs(model.getGravity().get(1)*model.getTotalMass(state));
    
    % Initialise figure
    f = figure;
    
    % Iterate over the timesteps...
    for i = 1:solution.NFrames
        
        % Assign state values from reference data
        for j = 0:n_variables - 1
            name = state_names.get(j);
            array.set(j, solution.getValue(i, char(name)));
        end
        
        % Set state values in model
        model.setStateVariableValues(state, array);
        
        % Realise to dynamics stage
        model.realizeDynamics(state);            

        % For each contact point...
        polygon_points = [];
        projected_points = [];
        point_weights = [];
        for j = 1:length(force_strings)
            
            % Compute vertical force
            force = SmoothSphereHalfSpaceForce.safeDownCast(...
                model.getComponent(force_strings{j}));
            force_value = force.getRecordValues(state);
            
            % Get contact sphere & associated frame
            geometries = model.getContactGeometrySet();
            sphere = geometries.get(sphere_strings{j});
            frame = sphere.getFrame();
            
            % Transform sphere location to ground frame
            ground_point = frame.findStationLocationInGround(state, ...
                sphere.get_location());
            
            % Append point to projected polygon
            this_point = [ground_point.get(0); ground_point.get(2)];
            projected_points = [projected_points, this_point]; %#ok<AGROW>
            
            % Compute point weight
            this_weight = force_value.get(1)/model_weight;
            point_weights = [point_weights, this_weight];
            
            % If above a threshold...
            if force_value.get(1) > force.get_constant_contact_force()
                
                % Add to polygon
                polygon_points = [polygon_points, this_point]; %#ok<AGROW>
                
            end
            
        end
        
        % Compute weighted centroid
        wcentroid_x = 0;
        wcentroid_y = 0;
        for point = 1:length(projected_points)
            wcentroid_x = wcentroid_x + ...
                projected_points(1, point)*point_weights(point);
            wcentroid_y = wcentroid_y + ...
                projected_points(2, point)*point_weights(point);
        end
        wcentroid_x = wcentroid_x/sum(point_weights);
        wcentroid_y = wcentroid_y/sum(point_weights);
        
        % Plot projected points
        projection = polyshape(projected_points(1, :), projected_points(2, :));
        pj = plot(projection);
        pj.EdgeColor = [0 0 0];
        pj.FaceColor = [1 1 1];
        hold on;
        
        % Plot weighted centroid 
        plot(wcentroid_x, wcentroid_y, 'gx', 'MarkerSize', 20, 'LineWidth', 2);
        
        % If our polygon is non-empty...
        if ~isempty(polygon_points)
            
            % Change of behaviour depending on number of support points
            n_points = length(polygon_points);
            if n_points > 2
                
                % Compute centre of polygon
                polygon = polyshape(polygon_points(1, :), polygon_points(2, :));
                [x, z] = centroid(polygon);
                plot(polygon);
                plot(x, z, 'rx', 'MarkerSize', 20, 'LineWidth', 2);
                
            elseif n_points == 2
                
                % Compute line midpoint
                x = sum(polygon_points(1, :))/2;
                z = sum(polygon_points(2, :))/2;
                plot(polygon_points(1, :), polygon_points(2, :));
                plot(x, z, 'rx', 'MarkerSize', 20, 'LineWidth', 2);
                
            else
                
                % Single point of support
                x = polygon_points(1, 1);
                z = polygon_points(2, 1);
                plot(x, z, 'rx', 'MarkerSize', 20, 'LineWidth', 2);
                
            end
            
            % Compute model CoM
            mass = 0;
            com = [0, 0, 0];
            body_set = model.getBodySet();
            for j = 0:body_set.getSize() - 1
                body = body_set.get(j);
                body_com = body.get_mass_center();
                vec = body.findStationLocationInGround(state, body_com);
                mass = mass + body.get_mass();
                com = com + [body.get_mass() * vec.get(0), ...
                    body.get_mass * vec.get(1), body.get_mass * vec.get(2)];
            end
            com = com/mass;
            
            % Compute distance between polygon centre & CoM projection
            mos(i) = sqrt((x - com(1))^2 + (z - com(3))^2);
            
            % Plot CoM projection 
            plot(com(1), com(3), 'bx', 'MarkerSize', 20, 'LineWidth', 2);
            
        else
            
            mos(i) = 10;
            
        end
        
        % Plot legend
        legend('PBoS', 'WCentre', 'BoS', 'Centre', 'PCoM');
        
        % Constrain xlim
        xlim([-0.1 0.7]);
        
        % Formatting
        xlabel('X (m)');
        ylabel('Z (m)');
        title('Evolution of Margin of Stability');
        set(gca, 'FontSize', 15);
        
        % Save image at this frame
        drawnow;
        frame = getframe;
        writeVideo(v, frame);
        
        % Reset hold
        hold off;
        
    end
    
    % Output timesteps as well
    timesteps = solution.Timesteps;
    
    % Close video & figure
    close(v);
    close(f);

end