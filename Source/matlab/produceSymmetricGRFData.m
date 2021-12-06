function produceSymmetricGRFData(...
    elements, model_path, solution_path, save_dir)

    % Import OpenSim libraries
    import org.opensim.modeling.*

    % Load model & solution
    solution = MocoTrajectory(solution_path);
    model_processor = ModelProcessor(model_path);
    model = model_processor.process();
    model.initSystem();

    % For each contact element
    for i = 1:length(elements)
        
        % For the left and right side
        for side = 'lr'
        
            % Create strings 
            string.(side) = StdVectorString();
            string.(side).add([elements{i} '_' side]);
            
        end
        
        % Get forces from the model & solution
        forces = opensimMoco.createExternalLoadsTableForGait(...
            model, solution, string.r, string.l);
        
        % Write resultant file
        savename = [save_dir filesep elements{i} '.sto'];
        STOFileAdapter.write(forces, savename);
        
    end  

end
