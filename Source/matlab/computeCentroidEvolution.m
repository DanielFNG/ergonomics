function trajectory = computeCentroidEvolution(vertices_evolution, weights)

    n_frames = length(vertices_evolution);
    trajectory = zeros(n_frames, 2);
    for i = 1:n_frames
        if nargin == 2
            trajectory(i, :) = computeStabilityCentroid(...
                vertices_evolution{i}, weights(i, :));
        else
            trajectory(i, :) = computeStabilityCentroid(vertices_evolution{i});
        end
    end
    
end