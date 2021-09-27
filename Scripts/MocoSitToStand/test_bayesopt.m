x = optimizableVariable('x', [-10, 10], 'Type', 'real');
y = optimizableVariable('y', [-10, 10], 'Type', 'real');
optimisation_variables = [x, y];

results = bayesopt(@objective, optimisation_variables, ...
    'MaxObjectiveEvaluations', 30, 'NumSeedPoints', 10, 'PlotFcn', []); 

function result = objective(X)
    result = (-X.x - X.y)^2;
end