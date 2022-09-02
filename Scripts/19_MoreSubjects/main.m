% Mode selection
subject = 2;
mode = 'perturbed';

% Paths
model = ['s' num2str(subject) filesep 'model_configured.osim'];
ik_folder = ['s' num2str(subject) filesep mode filesep 'ik_zerod'];
bounds_file = ['s' num2str(subject) filesep mode filesep 'tracking_config.txt'];
save_folder = ['s' num2str(subject) filesep mode filesep 'sols'];
guess_path = ['s' num2str(subject) filesep 'guess.sto'];
mkdir(save_folder);
initial_guess_path = 'unperturbed_guess.sto';
guess_path = 'guess.sto';

% Weights & constants
w_states = 1;
w_controls = 0;
states_path = 'ik_states.sto';
save_path = 'TrackingSolution.sto';
guess_iters = 500;
sol_iters = 2000;

% Load model & bounds
osim = org.opensim.modeling.Model(model);
bounds = parseBounds(bounds_file, osim);

% Loop over all ik files
[n, files] = getFilePaths(ik_folder, '.mot');

% % Hunt for an initial guess
% if ~isfile(guess_path)
%     for i = 1:n
%         ik = Data(files{i});
%         sto = convertIKToMocoSTO(ik, osim);
%         sto.writeToFile(states_path);
%         sol = produceTrackingGuess('TrackingSolution', w_states, w_controls, ...
%             model, states_path, bounds, guess_iters);
%         delete(states_path);
%         if ~sol.isSealed()
%             sol.write(guess_path);
%             break;
%         end
%         if i == n
%             error('No valid guess found - model strengthening needed.');
%         end
%     end
% end

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