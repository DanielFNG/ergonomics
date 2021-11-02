function output = convertIKToMocoSTO(mot, osim)
    
    % Generate new labels & transform data
    coordinates = osim.getCoordinateSet();
    labels = cell(mot.NCols, 1);
    labels{1} = 'time';
    values = zeros(mot.NFrames, mot.NCols);
    for i = 2:mot.NCols
        name = mot.Labels{i};
        coord = coordinates.get(name);
        fullname = char(coord.getAbsolutePathString());
        type = char(coord.getMotionType());
        switch type
            case 'Rotational'
                values(:, i) = deg2rad(mot.getColumn(name));
            case 'Translational'
                values(:, i) = mot.getColumn(name);
        end
        labels{i} = fullname;
    end
    
    % Create header object
    header{1} = 'version=1';
    header{2} = 'inDegrees=no';
    header{3} = ['nRows=' num2str(mot.NFrames)];
    header{4} = ['nColumns=' num2str(mot.NCols)];
    header{5} = 'endheader';
    
    % Create & print .sto file
    values = [mot.Timesteps, values];
    output = STOData(values, header, labels);

end