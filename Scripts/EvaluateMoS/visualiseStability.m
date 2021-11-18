function visualiseStability(savedir, n_timesteps, ...
    pbos, bos, wbos, trajectories, trajectory_names)

    % Initialise figure
    f = figure;
    hold on;
    
    % Initialise legend entries
    legend_entries = {};
    
    % Save number of trajectories
    if ~isempty(trajectories)
        n_trajectories = length(trajectories);
    else
        n_trajectories = 0;
    end
    
    % For each timestep...
    for t = 1:n_timesteps
        
        % Plot PBoS
        if ~isempty(pbos)
            projection = polyshape(pbos{t}(1, :), pbos{t}(2, :));
            convex = convhull(projection);
            pj = plot(convex);
            pj.EdgeColor = [0 0 0];
            pj.FaceColor = [1 1 1];
            legend_entries = [legend_entries 'PBoS'];
        end
        
        % Plot BoS
        if ~isempty(bos)
            n_vertices = size(bos{t}, 2);
            if n_vertices > 2
                polygon = polyshape(bos{t}(1, :), bos{t}(2, :));
                pk = plot(polygon);
                pk.EdgeColor = 'none';
            elseif n_vertices == 2
                plot(bos{t}(1, :), bos{t}(2, :));
            else
                error('Placeholder');
            end
            legend_entries = [legend_entries 'BoS'];
        end
        
        % Plot weighted vertices
        if ~isempty(wbos)
            n_vertices = size(pbos{t}, 2);
            if isempty(pbos) 
                error('Requires PBoS.');
            end
            for i = 1:n_vertices
                [~, on] = isinterior(convex, pbos{t}(1, i), pbos{t}(2, i));
                if on
                    colour_vector = [1 1 1] * abs(wbos(t, i)/max(max(wbos)));
                    if i > 1
                        handle_visibility = 'off';
                    else
                        handle_visibility = 'on';
                    end
                    plot(pbos{t}(1, i), pbos{t}(2, i), '-o', 'MarkerSize', 20, ...
                        'LineWidth', 1, 'MarkerEdgeColor', 'black', ...
                        'MarkerFaceColor', colour_vector, ...
                        'HandleVisibility', handle_visibility);
                    if i == 1
                        legend_entries = [legend_entries 'WBoS'];
                    end
                end
                colormap gray;
                c = colorbar;
                c.Label.FontSize = 15;
                c.Label.String = 'Vertex Weight';
            end
        end
        
        % Plot any number of trajectories
        for i = 1:n_trajectories
            plot(trajectories{i}(t, 1), trajectories{i}(t, 2), 'x', ...
                'MarkerSize', 20, 'LineWidth', 4);
            legend_entries = [legend_entries trajectory_names{i}];
        end
        
        % Formatting
        legend(legend_entries);
        legend_entries = {};
        xlim([-0.2 0.7]);
        xlabel('X (m)');
        ylabel('Z (m)');
        title('Stability');
        set(gca, 'FontSize', 15);
        
        % Save image at this frame
        saveas(f, [savedir filesep num2str(t) '.png']);
        
        % Reset figure
        clf;
        hold on;
    
    end
    
    % Close figure
    close(f);

end