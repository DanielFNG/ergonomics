% Set input/output files
input = 'adjustedIK.mot';  % Pre-sliced and zero-leveled
example = 'referenceCoordinates.sto';
output = 'referenceSitToStandCoordinates.sto';

% Load input data
input_data = Data(input);
example_data = Data(example);

% Initialise arrays & time values
new_labels = cell(1, example_data.NCols);
new_values = zeros(input_data.NFrames, example_data.NCols);
new_labels{1} = 'time';
new_values(:, 1) = input_data.Timesteps;

% Create new label & value objects
for i = 2:example_data.NCols
    new_labels{i} = example_data.Labels{i};
    [path, ~, ~] = fileparts(example_data.Labels{i});
    [~, name, ~] = fileparts(path);
    if strcmp(name, 'lumbar')
        new_values(:, i) = deg2rad(input_data.getColumn('lumbar_extension'));
    elseif strcmp(name, 'pelvis_tx') || strcmp(name, 'pelvis_ty')
        new_values(:, i) = input_data.getColumn(name);
    else
        new_values(:, i) = deg2rad(input_data.getColumn(name));
    end
end

% Process header
header = example_data.Header;
header{2} = 'inDegrees=no';

% Create & print output data
output_data = STOData(new_values, header, new_labels);
output_data.writeToFile(output);