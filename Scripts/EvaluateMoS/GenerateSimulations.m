% Parameters
allowable_weights = [0, 0.01, 0.1, 1];
n_weights = length(allowable_weights);
save_dir = [pwd filesep 'simulations'];
mkdir(save_dir);

% Generate simulations
for i = 1:n_weights
    for j = 1:n_weights
        for k = 1:n_weights
            command = ['./main ' num2str(allowable_weights(i)) ' ' ...
                num2str(allowable_weights(j)) ' ' ...
                num2str(allowable_weights(k)) ' ' save_dir];
            system(command);
        end
    end
end