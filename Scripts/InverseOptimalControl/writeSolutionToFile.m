function writeSolutionToFile(solution, save_dir, X)

    % Generate save name based on weights
    name = [];
    fields = fieldnames(X);
    switch isa(X, 'table')
        case true
            upper = length(fields) - 3;
        case false
            upper = length(fields);
    end
    for i = 1:upper % Ignore table properties etc
        name = [name '_' fields{i} '=' num2str(X.(fields{i}))]; %#ok<AGROW>
    end
    save_name = [save_dir filesep 'solution' name '.sto'];
    reduced_name = [save_dir filesep 'reduced' name '.sto'];
    
    % Unseal solution if needed, to be printed for posterity
    if ~success
        solution.unseal();
    end
    
    % Write the full solution to file
    solution.write(save_name);
    
    % Note: was getting some sort of bug where the Gamma variables in
    % the last timestep of the solution file were NaNs. These variables
    % are actually not needed for the BK so we can filter them out
    % manually with the following.
    [values, labels, header] = MOTSTOTXTData.load(save_name);
    reduced = STOData(values(:, 1:end-6), header, labels(1:end-6));
    reduced.writeToFile(reduced_name);

end