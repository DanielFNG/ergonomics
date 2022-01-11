% Inputs
output_dir = createOutputFolder('7_RecoverKnownWeights');
model_path = '2D_gait_jointspace.osim';
tracking_path = 'TrackingSolution.sto';
reference_path = [output_dir filesep 'reference.sto']; % full weights, all 0.1
upper_objective = @sumSquaredStateDifference;

% Generate reference motion if needed
if ~isfile(reference_path)
    weights = [0.1 0.1 0.1 0.1 0.1 0.1 0.1]; 
    sitToStandInterface(model_path, tracking_path, reference_path, weights);
end

% Process reference data 
reference = Data(reference_path);
labels = reference.Labels(1:end - 6);
upper_args = {reference, labels};

% Define objective 
outer_objective = @ (weights) objective(upper_objective, upper_args, ...
    model_path, tracking_path, output_dir, weights);

%% Bayesopt
% Optimal Control Weights
range = [0, 0.2];
names = {'w_effort', 'w_mos', 'w_pmos', 'w_wmos', ...
    'w_aload', 'w_kload', 'w_hload'};
args = {'Type', 'real'};
n_variables = length(names);
optimisation_variables = [];
for i = 1:n_variables
    optimisation_variables = [optimisation_variables ...
        optimizableVariable(names{i}, range, args{:})];
end

% Call Bayesopt
results = bayesopt(outer_objective, optimisation_variables, ...
    'MaxObjectiveEvaluations', 150, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'NumSeedPoints', 10);


%% CMA-ES full
% fitfun = @approximate_objective;
% n = 7;
% lb = 0.0;
% ub = 0.2;
% xstart = lb + rand(1, n)*(ub - lb);
% insigma = [];
% inopts.LBounds = lb;
% inopts.UBounds = ub;
% [xmin, fmin, counteval, stopflag, out, bestever] = cmaes(...
%     fitfun, xstart, insigma, inopts);

%% CMA-ES Hansen
% cmaes_hansen;

%% GA
% options = optimoptions('ga', 'Display', 'iter', ...
%     'MaxGenerations', 15, 'PlotFcn', 'gaplotscores', 'PopulationSize', 10); 
% lb = zeros(1, 7);
% ub = 0.2*ones(1, 7);
% [x, fval, exitflag, output, population, scores] = ga(...
%     cmaes_objective, 7, [], [], [], [], lb, ub, [], options);
