function result = objective(x)

    model = load('fittedmodel.mat');
    result = model.fittedmodel(x(1), x(2));
    
    if x(1) > 0.45
        result = 100;
    end

end