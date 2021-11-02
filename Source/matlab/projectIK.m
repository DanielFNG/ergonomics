function output = projectIK(mot, osim, sub_model, sub_data)
    
    % Generate new labels & transform data
    coordinates = osim.getCoordinateSet();
    n_coordinates = coordinates.getSize();
    labels = cell(n_coordinates, 1);
    values = zeros(mot.NFrames, n_coordinates);
    for i = 0:n_coordinates - 1
        coord = coordinates.get(i);
        name = char(coord.getName());
        labels{i + 1} = name;
        sub_index = find(contains(sub_model, name));
        if ~isempty(sub_index)
            name = sub_data{sub_index};
        end
        values(:, i + 1) = mot.getColumn(name);
    end
    
    % Create new .mot file
    values = [mot.Timesteps, values];
    labels = [{'time'}; labels];
    output = MOTData(values, mot.Header, labels);
        
end