function success = sitToStandInterface(...
    model_path, guess_path, output_path, weights, all_cores)

    % By default, assume we want to use all cores
    if nargin < 5
        all_cores = 1;
    end

    % Just a little check
    n_weights = 7;
    if length(weights) ~= n_weights
        error('Expecting 7 weights.');
    end

    % Path to compiled C++ executable
    if ismac
        name = 'sitToStand';
    elseif ispc
        name = 'sitToStand.exe';
    end
    executable_path = ...
        [getenv('ERGONOMICS_ROOT') filesep 'bin' filesep name];
    if ~isfile(executable_path)
        error('Need to compile C++ code.');
    end

    % Generate appropriate command line arguments
    command = [executable_path ' ' model_path ' ' guess_path ' ' ...
        output_path];
    for i = 1:n_weights
        command = [command ' ' num2str(weights(i))]; %#ok<AGROW>
    end
    command = [command ' ' num2str(all_cores)];
    
    % Execute the command
    [~, ~] = system(command);
    
    % Return indication of success
    success = true;
    if ~isfile(output_path)
        success = false;
    end

end
