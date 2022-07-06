function result = rastrigin(x)

    A = 10;
    n = length(x);
    result = A * n;
    for i = 1:n
        result = result + (x(i))^2 - A * cos(2 * pi * x(i));
    end

end