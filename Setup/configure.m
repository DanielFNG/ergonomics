function configure()
% Adds the appropriate source directories to the Matlab path. 

% Modify the Matlab path to include the source folder.
addpath(genpath(['..' filesep 'Source']));

% Add an output folder for saving local results
mkdir(['..' filesep 'Output']);

% Add a bin directory to hold executables
mkdir(['..' filesep 'bin']);

% Save resulting path.
savepath;

% Create an environment variable so we know where the root directory is
root_dir = fileparts(pwd);
createEnvironmentVariable('ERGONOMICS_ROOT', root_dir);

% Set the environment variable for the active session so users don't have
% to restart Matlab 
setenv('ERGONOMICS_ROOT', root_dir);

end
