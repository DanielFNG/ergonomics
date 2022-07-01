function result = griewank(x)

    n = length(x);
    product = 1;
    for i = 1:n
        product = product*cos((x(i) - 100)/sqrt(i));
    end
    result = 1/4000 * sum(x - 100).^2 - product + 1;

end