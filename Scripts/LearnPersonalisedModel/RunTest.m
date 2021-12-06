% Fake weights for now
weights = [0 0 0 0 0 0 0 0.1];

% Output directory
output_dir = pwd;

% Generate command 
command = ['./main'];
for i = 1:length(weights)
    command = [command  ' ' num2str(weights(i))];
end
command = [command ' ' output_dir];

% Run command 
return_status = system(command);