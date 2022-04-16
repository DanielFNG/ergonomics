% Number of passes
n_tries = 3;

% IPOPT options to change. NOTE: only the MUMPS linear solver is installed
% by OpenSim by default. Other options include the HSL solvers referenced
% below, which were fairly easy to install on mac. Installation on Windows
% was more complicated, and didn't seem to work on the version of minGW I
% had, so I just left it.
% HSL solvers: https://www.hsl.rl.ac.uk/ipopt/
if ispc
    error('Have you installed the HSL linear solvers?')
end
options = {'', ...
    'mu_strategy adaptive', ...
    'linear_solver ma27', ...
    'linear_solver ma57', ...
    'linear_solver ma77', ...
    'linear_solver ma86', ...
    'linear_solver ma97'};
option_file = 'ipopt.opt';

% Lower-level Configuration
executable = '/Users/daniel/Documents/GitHub/ergonomics/bin/optimise4D_cluster';
model = '2D_gait_jointspace_welded.osim';
guess = 'guess.sto';
weights = [0.0556 0.1667 0.0781 0.0641];

% Execute lower-levels
for i = 1:n_tries
    for j = 1:length(options)
        fid = fopen(option_file, 'w');
        try
            fprintf(fid, '%s', options{j});
            fclose(fid);
            output = ['option' num2str(j) 'run' num2str(i) '.sto'];
            command = [executable ' ' model ' ' guess ' ' output ...
                ' none ' num2str(weights)];
            system(command);
            delete(option_file);
        catch err
            delete(option_file);
            rethrow(err);
        end
    end
end