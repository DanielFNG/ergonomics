function configure()
% Adds the appropriate source directories to the Matlab path. 

% Modify the Matlab path to include the source folder.
addpath(genpath(['..' filesep 'Source']));

% Add an output folder for saving local results
mkdir(['..' filesep 'Output']);

% Save resulting path.
savepath;

end
