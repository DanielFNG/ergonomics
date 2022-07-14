function result = noisyFunction(x, func, noise)

    result = func(x) + abs(normrnd(0, noise));

end