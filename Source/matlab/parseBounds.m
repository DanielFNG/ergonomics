function bounds = parseBounds(filename, osim)

    % Open file
    fid = fopen(filename);
    
    in_degrees = true
    %% Read degrees header & close the file
    %header = strsplit(fgetl(fid), '\t');
    %in_degrees = strcmp(header{2}, 'yes');
    %fclose(fid);
    
    % Import the rest of the data as a table
    bounds = readtable(filename);
    
    % Trim state names
    for i = 1:height(bounds)
        bounds.Name{i} = strtrim(bounds.Name{i});
    end
    
    % Convert from degrees to radians if necessary
    if in_degrees
        coordinate_set = osim.getCoordinateSet();
        for i = 1:height(bounds)
            state = bounds.Name{i};
            coordinate_path = fileparts(state);
            [~, coordinate_name] = fileparts(coordinate_path);
            motion_type = char(coordinate_set.get(coordinate_name). ...
                getMotionType().toString());
            if strcmp(motion_type, 'Rotational')
                bounds.LowerBound(i) = bounds.LowerBound(i)*pi/180;
                bounds.UpperBound(i) = bounds.UpperBound(i)*pi/180;
                bounds.InitialValue(i) = bounds.InitialValue(i)*pi/180;
                bounds.FinalValue(i) = bounds.FinalValue(i)*pi/180;
            end
        end
    end

end