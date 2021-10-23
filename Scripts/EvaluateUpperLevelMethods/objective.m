function result = objective(x)

    load('fittedmodel_linear.mat');
    result = fittedmodel(x(1), x(2));
    
    if x(1) > 0.45
        result = 100;
    end

end