% Input model & reference kinematics
output_dir = createOutputFolder('7_BlockModel');
model_path = '2D_gait_jointspace_welded.osim';
reference_data = 'ReferenceData.sto';

% Parse bounds
osim = org.opensim.modeling.Model(model_path);
bounds = parseBounds('bounds_block.txt', osim);

% Solve the tracking problem
block_tracking_solution = produceTrackingGuess('TrackingSolution', ...
    1, 0, model_path, reference_data, bounds);

% Write it to use as an initial guess
block_tracking_solution.write(...
    [output_dir filesep 'TrackingSolutionBlock.sto']);

% Delete the temporary file that OpenSim Moco generates
delete([pwd filesep 'TrackingSolution_tracked_states.sto']);
