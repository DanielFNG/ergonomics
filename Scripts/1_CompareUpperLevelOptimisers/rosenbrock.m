function result = rosenbrock(x)

    n = length(x);
    result = 0;
    for i = 1:n - 1
        result = result + 100*(x(i + 1) - x(i)^2)^2 + (x(i) - 1)^2;
    end

end