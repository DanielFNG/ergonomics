function writeStatesData(manager, input)
% Use manager to write state data to file. 

    [path, ~, ext] = fileparts(input);
    states = manager.getStatesTable();
    stofile = org.opensim.modeling.STOFileAdapter;
    
    if isempty(ext)
        % Input is a directory
        if ~isfolder(input)
            mkdir(input);
        end
        stofile.write(states, [input filesep 'states.sto']);
    else
        % Input is a filename
        if ~isempty(path) && ~isfolder(path)
            mkdir(path);
        end
        stofile.write(states, input);
    end
    
end