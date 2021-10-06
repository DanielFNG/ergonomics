% Optimal Control Weights
w_effort = optimizableVariable('w_effort', [0, 0.4], 'Type', 'real');
%w_reaction = optimizableVariable('w_reaction', [0, 1], 'Type', 'real');
w_translation = optimizableVariable('w_translation', [0, 1], 'Type', 'real');
%w_rotation = optimizableVariable('w_rotation', [0, 1], 'Type', 'real');
optimisation_variables = [w_effort, w_translation];

% results = bayesopt(@predictSitToStand, optimisation_variables, ...
%     'MaxObjectiveEvaluations', 50, 'NumSeedPoints', 10, 'PlotFcn', []);

results = bayesopt(@predictSitToStand, optimisation_variables, ...
    'MaxObjectiveEvaluations', 30, ...
    'IsObjectiveDeterministic', true, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'NumSeedPoints', 10);

save(['ResultsDirectory' filesep 'results.mat'], 'results');
