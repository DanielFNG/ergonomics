function [pbos_vertices, bos_vertices, wbos_weights] = ...
    computeStabilityRegionEvolution(model, solution, contact_list)
    
    % Get references to the desired contact forces
    forces = getSpecificForces(model, contact_list);
    
    % Store minimum possible force for each contact force
    f_min = getMinimumForces(forces);

    % Get contact spheres associated with the forces
    spheres = getContactSpheres(model, forces);
    
    % Initialise model state & compute model weight
    state = model.initSystem();
    model_weight = computeModelWeight(model, state);
    
    % Initialise cell arrays for stability polygons
    pbos_vertices = cell(1, solution.NFrames);
    bos_vertices = cell(1, solution.NFrames);
    wbos_weights = zeros(solution.NFrames, length(contact_list));
    
    % For each frame of the solution data...
    for i = 1:solution.NFrames
        
        % Update state using solution data 
        setStateFromReference(model, state, solution, i);
        
        % Realize model to dynamics stage
        model.realizeDynamics(state);
        
        % Assess contact forces
        fy = computeVerticalContactForces(forces, state);
        in_contact = fy > f_min;
        
        % Compute stability polygon vertices & weights
        pbos_vertices{i} = computePBoS(state, spheres);
        bos_vertices{i} = computeBoS(pbos_vertices{i}, in_contact);
        wbos_weights(i, :) = computeWBoS(fy, model_weight);
        
    end

end