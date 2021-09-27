X = 0:0.01:1;
Y = X;
for i = 1:length(X)
    for j = 1:length(Y)
        Z(i, j) = predict(results.ObjectiveFcnModel, [X(i), Y(j)]);
    end
end

figure;
surf(X, Y, Z');
