% Inputs
model_path = '2D_gait_contact_constrained_activation.osim';
tracking_path = 'TrackingSolution.sto';
output_dir = createOutputFolder('4_MatlabCPPInterface');
output_path = [output_dir filesep 'prediction.sto'];
executable = 'optimise7D';


% Run a sit-to-stand prediction with each metric seperately at 0.1 weight
for i = 1:7
    weights = zeros(1, 7);
    weights(i) = 0.1;
    mocoExecutableInterface(executable, model_path, tracking_path, 
        output_path, weights);
end

% Run a sit-to-stand prediction with all metrics combined
weights = 0.1*ones(1, 7);
mocoExecutableInterface(executable, model_path, tracking_path, output_path, 
    weights);