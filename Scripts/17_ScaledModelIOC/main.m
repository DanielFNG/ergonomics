% Mode selection
mode = 'perturbed';

% Paths
model = ['models' filesep 'configured.osim'];
ik_folder = [mode filesep 'ik'];
bounds_file = [mode filesep 'config.txt'];
save_folder = [mode filesep 'sols'];
mkdir(save_folder);
guess_path = 'guess.sto';

% Weights & constants
w_states = 1;
w_controls = 0;
states_path = 'ik_states.sto';
save_path = 'TrackingSolution.sto';
guess_iters = 100;
sol_iters = 1000;

% Load model & bounds
osim = org.opensim.modeling.Model(model);
bounds = parseBounds(bounds_file, osim);

% Loop over all ik files
[n, files] = getFilePaths(ik_folder, '.mot');

% Hunt for an initial guess
if ~isfile(guess_path)
    for i = 1:n
        ik = Data(files{i});
        sto = convertIKToMocoSTO(ik, osim);
        sto.writeToFile(states_path);
        sol = produceTrackingGuess('TrackingSolution', w_states, w_controls, ...
            model, states_path, bounds, guess_iters);
        delete(states_path);
        if ~sol.isSealed()
            sol.write(guess_path);
            break;
        end
        if i == n
            error('No valid guess found - model strengthening needed.');
        end
    end
end

% Compute tracking solutions
for i = 1:n
    ik = Data(files{i});
    sto = convertIKToMocoSTO(ik, osim);
    sto.writeToFile(states_path);
    save_path = [save_folder filesep num2str(i) '.sto'];
    sol = produceTrackingGuess('TrackingSolution', w_states, w_controls, ...
        model, states_path, bounds, sol_iters, guess_path);
    sol.write(save_path);
    delete(states_path);
end