import org.opensim.modeling.*

model_file = 'assisted.osim';
bounds_file = 'bounds_matlab.txt';
start_time = 0;
end_time = 1.5;

study = MocoStudy();
osim = Model(model_file);
osim.initSystem();
problem = study.updProblem();
problem.setModel(osim);
bounds = parseBounds(bounds_file, osim);
for i = 5:12
    bounds.FinalValue(i) = nan;
end
applyStateBounds(problem, bounds);
problem.setTimeBounds(start_time, [0, end_time]);

solver = study.initCasADiSolver();
guess = solver.createGuess();

guess.write('guess_init.sto');

%% DONT USE THIS BEFORE YOU FIX IT! THE ORDERING CAN EASILY BE WRONG BELOW.
% WHY NOT USE STRINGS INSTEAD OF INDICES?

test = Data('guess_init.sto');
test.Timesteps = linspace(0, end_time, test.NFrames);
test.Values(:, 1) = test.Timesteps;
test.Values(:, 2) = linspace(deg2rad(55.668), deg2rad(0), test.NFrames); 
test.Values(:, 3) = linspace(deg2rad(-71.705), deg2rad(0), test.NFrames);
test.Values(:, 4) = linspace(deg2rad(4.516), deg2rad(0), test.NFrames);
test.Values(:, 5) = linspace(deg2rad(-22.667), deg2rad(0), test.NFrames);
test.Values(:, 6) = linspace(deg2rad(60.201), deg2rad(60.201), test.NFrames);
test.Values(:, 7) = linspace(deg2rad(40.175), deg2rad(40.175), test.NFrames);
test.Values(:, 8) = linspace(deg2rad(0.113), deg2rad(0.113), test.NFrames);
test.Values(:, 9) = linspace(deg2rad(0.297), deg2rad(0.297), test.NFrames);
test.Values(:, 10) = linspace(deg2rad(0.490), deg2rad(0.490), test.NFrames);
test.Values(:, 11) = linspace(deg2rad(-0.052), deg2rad(-0.052), test.NFrames);
test.Values(:, 12) = linspace(deg2rad(30.130), deg2rad(30.130), test.NFrames);
test.Values(:, 13) = linspace(deg2rad(26.241), deg2rad(26.241), test.NFrames);
test.writeToFile('guess_new_auto.sto');
