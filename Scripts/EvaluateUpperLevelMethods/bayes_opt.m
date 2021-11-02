% Optimal Control Weights
w_effort = optimizableVariable('w_effort', [0, 0.40], 'Type', 'real');
w_translation = optimizableVariable('w_translation', [0, 1], 'Type', 'real');
optimisation_variables = [w_effort, w_translation];

% Call Bayesopt
results = bayesopt(@objective_bayesopt, optimisation_variables, ...
    'MaxObjectiveEvaluations', 100, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'NumSeedPoints', 10);

function result = objective_bayesopt(x)

    result = objective([x.w_effort x.w_translation]);

end