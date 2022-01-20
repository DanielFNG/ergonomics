% Input model & reference kinematics
contact_model = '2D_gait_jointspace.osim';
block_model = '2D_gait_jointspace_welded.osim';
reference_data = 'ReferenceData.sto';

% Parse bounds
contact_osim = org.opensim.modeling.Model(contact_model);
block_osim = org.opensim.modeling.Model(block_model);
contact_bounds = parseBounds('bounds.txt', contact_osim);
block_bounds = parseBounds('bounds_block.txt', block_osim);

% Solve the tracking problem
contact_tracking_solution = produceTrackingGuess('TrackingSolution', ...
    1, 0.001, contact_model, reference_data, contact_bounds);
block_tracking_solution = produceTrackingGuess('TrackingSolution', ...
    1, 0.001, block_model, reference_data, block_bounds);

% Write it to use as an initial guess
contact_tracking_solution.write('contact_guess.sto');
block_tracking_solution.write('block_guess.sto');
