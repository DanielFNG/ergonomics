function result = compareRelativeKinematicsAndGRFs(...
    input, reference, labels, contacts, model_path)

    % Fixed parameters
    n_grf_directions = 2;

    % Temporarily write input for use as a moco trajectory
    input.writeToFile('moco_traj.sto');
    reference.writeToFile('ref_traj.sto');
    
    % Process labels argument 
    if strcmp(labels, 'all')
        labels = reference.Labels(2:end);
    elseif isa(labels, 'char')
        labels = {labels};
    end
    
    % Initialise result
    result = zeros(1, length(labels) + n_grf_directions);
    
    % Compute sum of squared state differences over required labels
    for i = 1:length(labels)
%         ref = stretchVector(reference.getColumn(labels{i}), 101);
%         joint = stretchVector(input.getColumn(labels{i}), 101);
        ref = reference.getColumn(labels{i});
        joint = input.getColumn(labels{i});
        result(i) = abs((sqrt(sum((joint - ref).^2)/reference.NFrames))/mean(ref));
    end

    % Import OpenSim libraries
    import org.opensim.modeling.*

    % Load model & solution
    solution = MocoTrajectory('moco_traj.sto');
    model_processor = ModelProcessor(model_path);
    model = model_processor.process();
    model.initSystem();

    % For each contact element
    for i = 1:length(contacts)
        contact_strings = StdVectorString();
        contact_strings.add(contacts{i});
    end
        
    % Get forces from the model & solution
    reference_solution = MocoTrajectory('ref_traj.sto');
    forces = opensimMoco.createExternalLoadsTableForGait(...
        model, solution, contact_strings, StdVectorString());
    ref_forces = opensimMoco.createExternalLoadsTableForGait(...
        model, reference_solution, contact_strings, StdVectorString());
    
    % Write resultant file
    STOFileAdapter.write(forces, 'forces.sto');
    STOFileAdapter.write(ref_forces, 'ref_forces.sto');
    
    % Read force data
    forces = Data('forces.sto');
    ref_forces = Data('ref_forces.sto');
    f{1} = forces.getColumn('ground_force_r_vx');
    f{2} = forces.getColumn('ground_force_r_vy');
    fr{1} = ref_forces.getColumn('ground_force_r_vx');
    fr{2} = ref_forces.getColumn('ground_force_r_vy');
    for i = 1:2
        
        result(length(labels) + i) = ...
            (sqrt(sum((f{i} - fr{i}).^2)/forces.NFrames))/abs(mean(fr{i}));
    end
    
    % Take the overall mean as the result
    result = mean(result);
    
    % For now no consideration of time normalisation, could maybe divide by
    % total time

end