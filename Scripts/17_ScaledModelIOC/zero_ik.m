modes = {'unperturbed', 'perturbed'};
destination = 'ik_zerod';

for mode = 1:2
    mkdir([modes{mode} filesep 'ik_zerod']);
    for i = 1:5
        test = Data([modes{mode} filesep 'ik' filesep num2str(i) '.mot']);
        test.Timesteps = test.Timesteps - test.Timesteps(1);
        test.Values(:, 1) = test.Timesteps;
        test.writeToFile([modes{mode} filesep 'ik_zerod' filesep num2str(i) '.mot']);
    end
end

