function centroid = computeStabilityCentroid(vertices, weights)

    n_vertices = size(vertices, 2);
    if nargin == 1
        weights = ones(1, n_vertices);
    end
    switch n_vertices
        case 0
            centroid = nan;
        case 1
            centroid = vertices;
        otherwise
            centroid = computeWeightedCentroid(vertices, weights);
    end

end