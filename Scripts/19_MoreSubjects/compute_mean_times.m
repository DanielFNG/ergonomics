subject = 2;

perturbed_data = ['s' num2str(subject) filesep filesep 'perturbed' filesep 'sols'];
unperturbed_data = ['s' num2str(subject) filesep 'unperturbed' filesep 'sols'];

perturbed_time = computeMeanTime(perturbed_data)
unperturbed_data = computeMeanTime(unperturbed_data)

function time = computeMeanTime(folder)

    [n, files] = getFilePaths(folder, '.sto');
    times = zeros(1, n);
    for i = 1:n
        file = Data(files{i});
        times(i) = file.getTotalTime();
    end
    time = mean(times);

end