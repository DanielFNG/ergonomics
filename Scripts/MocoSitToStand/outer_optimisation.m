% Optimal Control Weights
w_effort = optimizableVariable('w_effort', [0, 100], 'Type', 'real');
w_reaction = optimizableVariable('w_reaction', [0, 100], 'Type', 'real');
w_translation = optimizableVariable('w_translation', [0, 100], 'Type', 'real');
w_rotation = optimizableVariable('w_rotation', [0, 100], 'Type', 'real');
optimisation_variables = [w_effort, w_reaction, w_translation, w_rotation];

tic;

results = bayesopt(@predictSitToStand, optimisation_variables, ...
    'MaxObjectiveEvaluations', 30, 'NumSeedPoints', 10, 'PlotFcn', []);
