% Path to executable
executable_path = 'C:\Users\danie\Documents\GitHub\ergonomics\Source\cpp\build\Release\main.exe';

% Fake weights for now
weights = ones(1,8) * 0.1;

% Output directory
output_dir = pwd;

% Generate command 
command = [executable_path];
for i = 1:length(weights)
    command = [command  ' ' num2str(weights(i))];
end
command = [command ' ' output_dir];

% Run command 
system(command);