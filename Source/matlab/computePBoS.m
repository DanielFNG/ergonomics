function pbos = computePBoS(state, geometries)

    % Initialise bos array 
    n_geometries = length(geometries);
    pbos = zeros(2, n_geometries);
    
    % Compute pbos by projecting each contact on to ground
    for i = 1:n_geometries
        frame = geometries{i}.getFrame();
        location = geometries{i}.get_location();
        ground_point = frame.findStationLocationInGround(state, location);
        pbos(:, i) = [ground_point.get(0); ground_point.get(2)];
    end

end