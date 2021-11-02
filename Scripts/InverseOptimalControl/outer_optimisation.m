% Inputs
save_dir = 'TestProtocolSlackenedSpeeds';
objective = @sumSquaredStateDifference;
obj_args = {[pwd filesep 'Guess' filesep 'reduced_w_effort=0.001_w_translation=0.8.sto'], ...
    '/jointset/groundPelvis/pelvis_tx/speed'};

% Optimal Control Weights
w_effort = optimizableVariable('w_effort', [0, 0.1], 'Type', 'real');
%w_reaction = optimizableVariable('w_reaction', [0, 1], 'Type', 'real');
w_translation = optimizableVariable('w_translation', [0, 1], 'Type', 'real');
%w_rotation = optimizableVariable('w_rotation', [0, 1], 'Type', 'real');
optimisation_variables = [w_effort, w_translation];

% Internal objective function
obj = @(x) bayesoptObjective(x, save_dir, objective, obj_args);

% Call Bayesopt
results = bayesopt(temp, optimisation_variables, ...
    'MaxObjectiveEvaluations', 30, ...
    'IsObjectiveDeterministic', true, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'NumSeedPoints', 10);

% Save results
save([save_dir filesep 'results.mat'], 'results');


% Bayesopt function
function result = bayesoptObjective(X, save_dir, obj, obj_args, filter)

    % Predict sit-to-stand with the given weights
    solution = predictSitToStand(X);
    
    % Write solution to file
    solution_path = writeSolutionToFile(solution, save_dir, X);
    
    % Load data object
    solution_data = Data(solution_path);
    
    % Grade solution
    result = gradeSitToStand(solution_data, obj, obj_args, filter);

end
