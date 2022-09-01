function output = convertIKToMocoSTO(mot, osim)
    
    % Generate new labels & transform data
    coordinates = osim.getCoordinateSet();
    labels = cell(coordinates.getSize(), 1);
    labels{1} = 'time';
    values = zeros(mot.NFrames, coordinates.getSize() - 1);
    count = 2;
    for i = 2:mot.NCols
        name = mot.Labels{i};
        try
            coord = coordinates.get(name);
            fullname = char(coord.getAbsolutePathString());
            type = char(coord.getMotionType());
            switch type
                case 'Rotational'
                    values(:, count - 1) = deg2rad(mot.getColumn(name));
                case 'Translational'
                    values(:, count - 1) = mot.getColumn(name);
            end
            labels{count} = [fullname '/value'];
            count = count + 1;
        end
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