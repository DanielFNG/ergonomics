%% Parameters
model_path = '2D_gait_jointspace.osim';
output_one = 'assisted_30.osim';
output_two = 'assisted_60.osim';
w_effort = 0.1;
start = 10;
duration = 50;
magnitude = 100;
direction_one = 30;
direction_two = 60;
body_path = '/bodyset/torso';
timerange = [1.0, 2.0];
guess_path = 'TrackingSolution.sto';
bounds_path = 'bounds.txt';

%% Create models
osim = org.opensim.modeling.Model(model_path);
modelParameterisedAssistance(osim, output_one, start, duration, ...
    magnitude, direction_one, body_path);
modelParameterisedAssistance(osim, output_two, start, duration, ...
    magnitude, direction_two, body_path);

%% Run lower-level

% Parse bounds
bounds = parseBounds(bounds_path, osim);

% Effort goal
effort_goal = org.opensim.modeling.MocoControlGoal('effort', w_effort);
effort_goal.setDivideByDisplacement(true);
effort_goal.setExponent(3);

% Combine goals
goals = {effort_goal};

% Tracking solution
tracking_solution = org.opensim.modeling.MocoTrajectory(guess_path);

% Predict
solution_zero = predictMotion(...
    'zero', model_path, goals, tracking_solution, timerange, bounds);
% solution_one = predictMotion(...
%     'one', output_one, goals, tracking_solution, timerange, bounds);
% solution_two = predictMotion(...
%     'two', output_two, goals, tracking_solution, timerange, bounds);

% Write prediction to file
solution_zero.write('zero.sto');
% solution_one.write('one.sto');
% solution_two.write('two.sto');