function generateMuscleConstraints(model, input, output)

    % Get the muscle names in control from from the input model file
    osim = org.opensim.modeling.Model(model);
    muscles = osim.getMuscles();
    n_muscles = muscles.getSize();
    control_names = cell(1, n_muscles);
    for i = 0:n_muscles - 1
        control_names{i + 1} = [char(muscles.get(i).getName()) '.excitation'];
    end
       
    % Load the input controls and access the set of ControlLinear objects
    control_set = xmlread(input);
    objects = control_set.getElementsByTagName('objects').item(0);
    control_linear_set = control_set.getElementsByTagName('ControlLinear');
        
    % For each control...
    n_controls = control_linear_set.getLength();
    for i = n_controls - 1:-1:0
        
        % Get each control object & its name
        this_control = control_linear_set.item(i);
        this_control_name = this_control.getAttribute('name').toCharArray()';
        
        % Remove those controls which do not come from muscles. Otherwise,
        % convert x_nodes to min_nodes and max_nodes.
        if ~contains(this_control_name, control_names)
            objects.removeChild(control_linear_set.item(i));
        else
            x_nodes = this_control.getElementsByTagName('x_nodes').item(0);
            min_nodes = this_control.getElementsByTagName('min_nodes').item(0);
            max_nodes = this_control.getElementsByTagName('max_nodes').item(0);
            control_nodes = x_nodes.getElementsByTagName('ControlLinearNode');
            for j = 0:control_nodes.getLength() - 1
                min_nodes.appendChild(control_nodes.item(j).cloneNode(true));
                max_nodes.appendChild(control_nodes.item(j).cloneNode(true));
            end
            for j = control_nodes.getLength() - 1:-1:0
                x_nodes.removeChild(control_nodes.item(j));
            end
        end
    end
    
    % Print the output control file (bit ugly, seems to be a better method
    % for doing this in Matlab R2021a which allows for prettier export).
    xmlwrite(output, control_set);
    
end