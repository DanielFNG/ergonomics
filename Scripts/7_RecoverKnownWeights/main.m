% Inputs
output_dir = createOutputFolder('7_RecoverKnownWeights');
model_path = '2D_gait_jointspace.osim';
tracking_path = 'TrackingSolution.sto';
reference_path = 'reference.sto'; % full weights, all 0.1
upper_objective = @sumSquaredStateDifference;

% Process reference data 
reference = Data(reference_path);
labels = reference.Labels(1:end - 6);
upper_args = {reference, labels};

% Define objective 
cmaes_objective = @ (weights) objective(upper_objective, upper_args, ...
    model_path, tracking_path, output_dir, weights);

% Run CMA-ES
cmaes_modified;