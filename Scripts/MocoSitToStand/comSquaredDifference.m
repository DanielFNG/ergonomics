function result = comSquaredDifference(input, reference, osim)

    % Settings files
    bk_settings = [pwd filesep 'bk.xml'];

    % Run BK on result
    runAnalyse('bk', osim, input, [], [pwd filesep 'solution'], bk_settings);

    % Slice the BK position
    bk = Data('solution\bk_BodyKinematics_pos_global.sto');
    bk = bk.slice(start, finish);
    bk.writeToFile('solution\bk_normalised.sto');

    % Compute normalised squared distance to mean
    ref = Data(reference);
    x_com_ref = stretchVector(ref.getColumn('center_of_mass_X'), 101);
    y_com_ref = stretchVector(ref.getColumn('center_of_mass_Y'), 101);
    x_com = stretchVector(bk.getColumn('center_of_mass_X'), 101);
    y_com = stretchVector(bk.getColumn('center_of_mass_Y'), 101);
    result = sum((x_com' - x_com_ref').^2 + (y_com' - y_com_ref').^2);

end