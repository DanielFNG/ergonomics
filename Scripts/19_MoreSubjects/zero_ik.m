subjects = 1:2;
modes = {'unperturbed', 'perturbed'};
destination = 'ik_zerod';

for subject = subjects
    for mode = 1:2
        mkdir(['s' num2str(subject) filesep modes{mode} filesep 'ik_zerod']);
        for i = 1:5
            test = Data(['s' num2str(subject) filesep modes{mode} filesep 'ik' filesep num2str(i) '.mot']);
            test.Timesteps = test.Timesteps - test.Timesteps(1);
            test.Values(:, 1) = test.Timesteps;
            test.writeToFile(['s' num2str(subject) filesep modes{mode} filesep 'ik_zerod' filesep num2str(i) '.mot']);
        end
    end
end

