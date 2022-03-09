function result = rastrigin(X)

    A = 10;

    if isa(X, 'table')
        n = width(X);
        result = A * n;
        for i = 1:n
            result = result + (X.(i))^2 - A * cos(2 * pi * X.(i)); 
        end
    else
        n = length(X);
        result = A * n;
        for i = 1:n
            result = result + (X(i))^2 - A * cos(2 * pi * X(i));
        end
    end
         

end