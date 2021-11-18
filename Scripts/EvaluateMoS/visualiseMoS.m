function [pcen, cen, wcen, pcom, xcom, mos, wmos, timesteps] = ...
    visualiseMoS(model_path, solution_path, save_folder)

    % Initialise figure
    f = figure;
    f.Position = [100 100 900 600];

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
    
    % Initialise 
    pcen.x = zeros(solution.NFrames, 1);
    cen.x = pcen.x;
    wcen.x = pcen.x;
    pcom.x = pcen.x;
    xcom.x = pcen.x;
    pcen.z = zeros(solution.NFrames, 1);
    cen.z = pcen.z;
    wcen.z = pcen.z;
    pcom.z = pcen.z;
    xcom.z = pcen.z;
    mos = pcen.x;
    wmos = mos;
    
    % Compute model weight
    model_weight = abs(model.getGravity().get(1)*model.getTotalMass(state));
    
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
        
        max(point_weights)
        
        % Plot projected points
        projection = polyshape(projected_points(1, :), projected_points(2, :));
        ch_projection = convhull(projection);
        pj = plot(ch_projection);
        pj.EdgeColor = [0 0 0];
        pj.FaceColor = [1 1 1];
        hold on;
        
        % Plot centre of projection
        
        % Compute weighted centroid
        wcen.x(i) = 0;
        wcen.z(i) = 0;
        for point = 1:length(projected_points)
            wcen.x(i) = wcen.x(i) + ...
                projected_points(1, point)*point_weights(point);
            wcen.z(i) = wcen.z(i) + ...
                projected_points(2, point)*point_weights(point);
        end
        wcen.x(i) = wcen.x(i)/sum(point_weights);
        wcen.z(i) = wcen.z(i)/sum(point_weights);
        
        % If our polygon is non-empty...
        if ~isempty(polygon_points)
            
            % Change of behaviour depending on number of support points
            n_points = length(polygon_points);
            if n_points > 2
                
                % Compute centre of polygon
                polygon = polyshape(polygon_points(1, :), polygon_points(2, :));
                [cen.x(i), cen.z(i)] = centroid(polygon);
                pk = plot(polygon);
                pk.EdgeColor = 'none';
                
            elseif n_points == 2
                
                % Compute line midpoint
                cen.x(i) = sum(polygon_points(1, :))/2;
                cen.z(i) = sum(polygon_points(2, :))/2;
                plot(polygon_points(1, :), polygon_points(2, :));
                
            else
                
                % Single point of support
                cen.x(i) = polygon_points(1, 1);
                cen.z(i) = polygon_points(2, 1);
                
            end
            
            % Plot centre of projected boundary of support
            [pcen.x(i), pcen.z(i)] = centroid(ch_projection);
            plot(pcen.x(i), pcen.z(i), 'kx', 'MarkerSize', 20, 'LineWidth', 2);
            
            % Plot centre of boundary of support
            plot(cen.x(i), cen.z(i), 'rx', 'MarkerSize', 20, 'LineWidth', 2);
            
            % Plot weighted centroid 
            plot(wcen.x(i), wcen.z(i), 'bx', 'MarkerSize', 20, 'LineWidth', 2);
            
            % Compute model CoM and CoM_v
            mass = 0;
            com = [0, 0, 0];
            com_v = com;
            body_set = model.getBodySet();
            for j = 0:body_set.getSize() - 1
                body = body_set.get(j);
                body_com = body.get_mass_center();
                pos = body.findStationLocationInGround(state, body_com);
                vel = body.findStationVelocityInGround(state, body_com);
                mass = mass + body.get_mass();
                com = com + [body.get_mass() * pos.get(0), ...
                    body.get_mass() * pos.get(1), body.get_mass() * pos.get(2)];
                com_v = com_v + [body.get_mass * vel.get(0), ...
                    body.get_mass() * vel.get(1), body.get_mass() * vel.get(2)];
            end
            com = com/mass;
            com_v = com_v/mass;
            
            % Compute XCoM
            pcom.x(i) = com(1);
            pcom.z(i) = com(3);
            xcom.x(i) = extrapolatePendulum(com(1), com_v(1), 0, com(2));
            xcom.z(i) = extrapolatePendulum(com(3), com_v(3), 0, com(2));
            
            % Plot CoM projection 
            plot(pcom.x(i), pcom.z(i), 'k+', 'MarkerSize', 20, 'LineWidth', 2);
            
            % Plot XCoM
            plot(xcom.x(i), xcom.z(i), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
            
            % Compute distance between polygon centre & CoM projection
            mos(i) = sqrt((cen.x(i) - xcom.x(i))^2 + (cen.z(i) - xcom.z(i))^2);
            wmos(i) = sqrt((wcen.x(i) - xcom.x(i))^2 + (wcen.z(i) - xcom.z(i))^2);
            
        else
            
            mos(i) = 10;
            wmos(i) = 10;
            
        end
        
        % Step through plotting vertices
        for j = 1:length(force_strings)
            [~, on] = isinterior(ch_projection, ...
                projected_points(1, j), projected_points(2, j));
            if on
                if max(abs(point_weights(j))) > 1
                    colour_vector = [1 1 1];
                else
                    colour_vector = [1 1 1]*abs(point_weights(j));
                end
                plot(projected_points(1, j), projected_points(2, j), '-o', ...
                    'MarkerSize', 20, 'LineWidth', 1, 'MarkerEdgeColor', 'black', ...
                    'MarkerFaceColor', colour_vector);
            end
        end
        
        % Add colorbar
        colormap gray;
        c = colorbar;
        c.Label.FontSize = 15;
        c.Label.String = 'Vertex Weight';
        
        % Plot legend
        legend('PBoS', 'BoS', 'PCentre', 'Centre', 'WCentre', 'PCoM', 'XCoM');
        %legend('PBoS', 'BoS', 'PCentre', 'Centre', 'WCentre');
        
        % Constrain xlim
        xlim([-0.1 0.8]);
        
        % Formatting
        xlabel('X (m)');
        ylabel('Z (m)');
        title('Evolution of Margin of Stability');
        set(gca, 'FontSize', 15);
        
        % Save image at this frame
        drawnow;
        frame = getframe(gcf);
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