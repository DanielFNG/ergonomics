% Variables
x = optimizableVariable('x', [0, 1], 'Type', 'real');
y = optimizableVariable('y', [0, 1], 'Type', 'real');
optimisation_variables = [x, y];

results = bayesopt(@negSumSquared, optimisation_variables, ...
    'MaxObjectiveEvaluations', 100, ...
    'IsObjectiveDeterministic', true, ...
    'AcquisitionFunctionName', 'expected-improvement-plus');

function result = negSumSquared(X)

    result = -(X.x^2 + X.y^2);

end