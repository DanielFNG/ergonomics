% Inputs
model_path = [pwd filesep '2D_gait_jointspace.osim'];
guess_path = [pwd filesep 'TrackingSolution.sto'];
output_dir = createOutputFolder(pwd);

% Weights
weights{1} = [0.1 0 0 0 0 0 0]; % effort
weights{2} = [0.01 0.1 0 0 0 0 0]; % mos
weights{3} = [0.01 0 0.1 0 0 0 0]; % pmos
weights{4} = [0.01 0 0 1.0 0 0 0]; % wmos
weights{5} = [0.01 0 0 0 0.1 0 0]; % ankle joint loading
weights{6} = [0.1 0.1 0.1 0.1 0.1 0.1 0.1];

for j = 1:length(weights)
    % Generate command 
    command = ['./main ' model_path ' ' guess_path ' ' output_dir];
    for i = 1:length(weights{j})
        command = [command  ' ' num2str(weights{j}(i))];
    end

    % Run command 
    system(command);
end