function path = sitToStandInterface(...
    model_path, guess_path, output_dir, weights)

    % Just a little check
    n_weights = 7;
    if length(weights) ~= n_weights
        error('Expecting 7 weights.');
    end

    % Path to compiled C++ executable
    executable_path = ...
        [getenv('ERGONOMICS_ROOT') filesep 'bin' filesep 'sitToStand'];
    if ~isfile(executable_path)
        error('Need to compile C++ code.');
    end

    % Generate appropriate command line arguments
    command = [executable_path ' ' model_path ' ' guess_path ' ' ...
        output_dir];
    for i = 1:n_weights
        command = [command ' ' num2str(weights(i))]; %#ok<AGROW>
    end
    
    % Execute the command
    system(command);
    
    % Return path to resulting data, or -1 if solve failed
    path = generateSolutionPath(output_dir, weights);
    if ~isfile(path)
        path = -1;
    end
    
    function path = generateSolutionPath(output_dir, weights)
        
        % Hard-coded format spec, width & weight order from C++ source
        format = '%.3g';
        width = 8;
        labels = {'w_effort', 'w_mos', 'w_pmos', 'w_wmos', 'w_aload', ...
            'w_kload', 'w_hload'};
        
        % Generate save-name using known info from C++ source
        name = [];
        for l = 1:length(labels)
            name = [name labels{l} '=' sprintf(format, weights(l)) '_' ];  %#ok<AGROW>
        end
        name(end) = [];  % Remove the last '_' which is unneeded
        name = [name '.sto'];
        
        % Combine save_dir and name to generate full path
        path = [output_dir filesep name];
        
    end

end
