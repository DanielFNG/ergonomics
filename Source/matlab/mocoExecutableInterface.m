function success = mocoExecutableInterface(...
    name, model_path, guess_path, output_path, weights, output, parallel)
    % Provides an interface for running Moco C++ executables within 
    % Matlab. We assume that the executable (name) is located within
    % ergonomics/bin, and has the standard argument list i.e.
    %       model_path, guess_path, output_path, w1, w2, w3, ..., wn, parallel
    % for the weights as passed in to this function.

    % By default, assume we want to use all cores, and have minimal program output
    if nargin < 7
        parallel = 1;
    end
    if nargin < 6
        output = false;
    end

    % Path to compiled C++ executable if on Windows
    if ispc
        name = [name '.exe'];
    end
    executable_path = ...
        [getenv('ERGONOMICS_ROOT') filesep 'bin' filesep name];
    if ~isfile(executable_path)
        error('Need to compile C++ code.');
    end

    % Generate appropriate command line arguments
    command = [executable_path ' ' model_path ' ' guess_path ' ' ...
        output_path];
    for i = 1:length(weights)
        command = [command ' ' num2str(weights(i))]; %#ok<AGROW>
    end
    command = [command ' ' num2str(parallel)];
    
    % Execute the command - capture output if not required
    if output
        system(command);
    else
        [~, ~] = system(command);
    end
    
    % Return indication of success
    success = true;
    if ~isfile(output_path)
        success = false;
        fmt = [repmat('%g, ', 1, length(weights) - 1) '%g]'];
        fprintf(['Failed for w = [' fmt '\n'], weights);
    end
    
end