function centroid = computeWeightedCentroid(vertices, weights)

    centroid = [0; 0];
    n_vertices = length(vertices);
    for i = 1:n_vertices
        for j = 1:2
            centroid(j) = centroid(j) + vertices(j, i) * weights(i);
        end
    end
    centroid = centroid/sum(weights);

end