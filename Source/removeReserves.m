function removeReserves(input, output)

    % Check strings
    check = {'FX', 'FY', 'FZ', 'MX', 'MY', 'MZ', 'reserve'};

    control_set = org.opensim.modeling.ControlSet(input);
    
    n_controls = control_set.getSize();
    
    % Loop and remove all reserve & residual controls
    for i = n_controls - 1:-1:0
        name = char(control_set.get(i).getName());
        if contains(name, check)
            control_set.remove(i);
        end
    end
    
    % Output the reduced control constraint file
    control_set.print(output);

end