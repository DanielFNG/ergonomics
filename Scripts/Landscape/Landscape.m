% Inputs
results_dir = 'FullExploration';
obj = @sumSquaredStateDifference;
obj_args = {[pwd filesep 'bk_w_effort=0.25_w_translation=0.75.sto'], ...
    '/jointset/groundPelvis/pelvis_tx/speed'};
effort_range = [0.0, 0.4];
translation_range = [0.0, 1.0];
n_effort = 3;
n_translation = 3;

% Create results directory
mkdir(results_dir);
save([results_dir filesep 'settings.mat'], 'obj', 'obj_args');

% Compute sampling points
[w_effort_points, w_translation_points] = create2DGrid(...
    effort_range, translation_range, n_effort, n_translation);

% Set up results array
n_results = n_effort * n_translation;
results = zeros(n_results, 1);

% Step through, predicting each point
for i = 1:length(w_effort_points)
    X.w_effort = w_effort_points(i);
    X.w_translation = w_translation_points(i);
    results(i) = predictSitToStand(X, results_dir, obj, obj_args);
end

% Run a fake BayesOpt just to have it do the GP modelling
w_effort = optimizableVariable('w_effort', effort_range, 'Type', 'real');
w_translation = optimizableVariable('w_translation', translation_range, 'Type', 'real');
optimisation_variables = [w_effort, w_translation];
inputs = table(w_effort_points, w_translation_points, ...
    'VariableNames', {'w_effort', 'w_translation'});
bo = bayesopt(@sin, optimisation_variables, ...
    'MaxObjectiveEvaluations', n_results, ...
    'IsObjectiveDeterministic', true, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'InitialX', inputs, 'InitialObjective', results);
save([pwd filesep results_dir filesep 'results.mat'], 'bo');

% Fit the resulting points to a GP landscape - leaving this for now as we
% can use the BayesOpt graphs to have a look anyway. 

