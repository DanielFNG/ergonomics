% Produces the reference coordinates for the tracking guess

% Inputs
input_data = 'inputIK.mot';
osim_model = '2D_gait_contact_constrained_activation.osim';
sub_model = {'lumbar'};
sub_data = {'lumbar_extension'};
save_dir = createOutputFolder(pwd);

% Load model & input data
input = Data(input_data);
osim = org.opensim.modeling.Model(osim_model);

% Project data on to 2D model
projection = projectIK(input, osim, sub_model, sub_data);

% Make symmetric
symmetric = produceSymmetricIK(projection);

% Convert to Moco STO format
sto = convertIKToMocoSTO(symmetric, osim);

% Write resulting data to file
sto.writeToFile([save_dir filesep 'referenceSitToStand.sto']);
