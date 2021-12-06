x = optimizableVariable('x', [-10, 10], 'Type', 'real');
y = optimizableVariable('y', [-10, 10], 'Type', 'real');
optimisation_variables = [x, y];

results = bayesopt(@objective, optimisation_variables, ...
    'MaxObjectiveEvaluations', 100, 'NumSeedPoints', 10, ...
    'IsObjectiveDeterministic', true); 

function result = objective(X)
    result = X.x^2 + X.y^2;
end