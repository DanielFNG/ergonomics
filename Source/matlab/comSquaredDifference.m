function result = comSquaredDifference(input, reference, osim, save_dir)

    % Settings files
    bk_settings = [pwd filesep 'bk.xml'];

    % Run BK on result
    temp_dir = [save_dir filesep 'temp'];
    runAnalyse('bk', osim, input, [], temp_dir, bk_settings);
    
    try 
        % Slice the BK position
        bk = Data([temp_dir filesep 'bk_BodyKinematics_pos_global.sto']);
        bk = bk.slice(start, finish);
        bk.writeToFile([temp_dir filesep 'bk_normalised.sto']);

        % Compute normalised squared distance to mean
        ref = Data(reference);
        x_com_ref = stretchVector(ref.getColumn('center_of_mass_X'), 101);
        y_com_ref = stretchVector(ref.getColumn('center_of_mass_Y'), 101);
        x_com = stretchVector(bk.getColumn('center_of_mass_X'), 101);
        y_com = stretchVector(bk.getColumn('center_of_mass_Y'), 101);
        result = sum((x_com' - x_com_ref').^2 + (y_com' - y_com_ref').^2);
        
        % Remove temporary files
        rmdir(temp_dir, 's');
        
    catch err
        rmdir(temp_dir, 's');
        rethrow(err);
    end

end