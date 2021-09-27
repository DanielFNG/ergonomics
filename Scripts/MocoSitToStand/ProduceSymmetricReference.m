% Cell arrays for swapping
left_strings = {'/jointset/hip_l/hip_flexion_l/value', '/jointset/knee_l/knee_angle_l/value', '/jointset/ankle_l/ankle_angle_l/value'};
right_strings = {'/jointset/hip_r/hip_flexion_r/value', '/jointset/knee_r/knee_angle_r/value', '/jointset/ankle_r/ankle_angle_r/value'};

% Load reference data 
reference = Data('referenceSitToStandCoordinates.sto');

% Temporary plotting bit
for i = 1:length(left_strings)
    right = reference.getColumn(right_strings{i});
    reference.setColumn(left_strings{i}, right);
end

% Produce the new file
reference.writeToFile('referenceSitToStandCoordinates_symmetric.sto');


