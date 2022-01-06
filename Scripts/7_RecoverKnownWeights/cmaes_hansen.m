% CMA-ES algorithm from Hansen 2016, slightly modified to meet our needs
    
% Initialisation
func = outer_objective;
N = 7;
xmean = rand(N, 1);
sigma = 0.5;
stopfitness = 1e-10;
stopeval = 50;
lb = 0;
ub = 0.2;

% Parameter setting: selection
lambda = 4 + floor(3 * log(N));  % Number of offspring
mu = lambda/2;
weights = log(mu + 1/2) - log(1:mu)';
weights = weights/sum(weights);
mueff = sum(weights)^2/sum(weights.^2);

% Parameter setting: adaptation
cc = (4 + mueff/N)/(N + 4 + 2*mueff/N);
cs = (mueff + 2)/(N + mueff + 5);
c1 = 2/((N + 1.3)^2 + mueff);
cmu = 2 * (mueff - 2 + 1/mueff)/((N + 2)^2 + 2*mueff/2);
damps = 1 + 2*max(0, sqrt((mueff - 1)/(N+1))-1) + cs;

% Initialise dynamic (internal) strategy parameters and constants
pc = zeros(N, 1); 
ps = zeros(N, 1);
B = eye(N);
D = eye(N);
C = B*D*(B*D)';
eigeneval = 0;
chiN = N^0.5 * (1 - 1/(4*N) + 1/(21*N^2));

% Generation loop
counteval = 0;
while counteval < stopeval
    
    % Generate & evaluate lambda offspring
    for k = 1:lambda
        arz(:, k) = randn(N, 1);
        arx(:, k) = xmean + sigma * (B*D*arz(:, k));
        arx(arx(:, k) < lb, k) = lb;
        arx(arx(:, k) > ub, k) = ub;
        value = nan;
        while isnan(value)
            value = func(arx(:, k));
        end
        arfitness(k) = value;
        counteval = counteval + 1;
    end
    
    % Sort by fitness and compute weighted mean into xmean
    [arfitness, arindex] = sort(arfitness);
    xmean = arx(:, arindex(1:mu))*weights;
    zmean = arz(:, arindex(1:mu))*weights;
    
    % Cumulation: update evolution paths
    ps = (1 - cs)*ps + (sqrt(cs * (2 - cs) * mueff)) * (B * zmean);
    hsig = norm(ps)/sqrt(1 - (1 - cs)^(2 * counteval/lambda))/chiN < 1.5 + 2/(N+1);
    pc = (1 - cc)*pc + hsig + sqrt(cc * (2 - c) * mueff) * (B * D * zmean);
    
    % Adapt covariance matrix C
    C = (1 - c1 - cmu) * C ...
        + c1 * (pc *pc' ...
        + (1 - hsig) * cc * (2 - cc) * C) ...
        + cmu ...
        * (B * D * arz(:, arindex(1:mu))) ...
        * diag(weights) * (B * D * arz(:, arindex(1:mu)))';
    
    % Adapt step size sigma
    sigma = sigma * exp((cs/damps) * norm(ps)/chiN - 1);
    
    % Update B and D from C
    if counteval - eigeneval > lambda/(cone + cmu)/N/10
        eigeneval = counteval;
        C = triu(C) + triu(C, 1)';
        [B, D] = eig(C);
        D = diag(sqrt(diag(D)));
    end
    
    % Break, if fitness is good enough
    if arfitness(1) <= stopfitness
        break;
    end
    
    % Escape flat fitness, or better terminate?
    if arfitness(1) == arfitness(ceil(0.7*lambda))
        sigma = sigma * exp(0.2 + cs/damps);
        disp('warning: flat fitness, consider reformulating the objective');
    end
    
    disp([num2str(counteval) ': ' num2str(arfitness(1))]);
    
end

% Final message
disp([num2str(counteval) ': ' num2str(arfitness(1))]);
xmin = arx(:, arindex(1));
    
    

    