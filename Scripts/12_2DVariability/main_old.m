% Inputs
input_model = '2D_gait_jointspace_welded.osim';
tracking_solution = org.opensim.modeling.MocoTrajectory(...
    'guess.sto');
timerange = [0.5, 2.0];
bounds_file = 'bounds_block.txt';
w_pot = 1;
w_kin = 1;

% Create bounds
osim = org.opensim.modeling.Model(input_model);
bounds = parseBounds(bounds_file, osim);

% Effort goal
eff = org.opensim.modeling.MocoControlGoal('effort', 1);
eff.setDivideByDisplacement(true);
eff.setExponent(3);

% Potential energy goal
pot = org.opensim.modeling.MocoOutputGoal('potential', w_pot);
pot.setOutputPath('/|potential_energy');

% Kinetic energy goal
kin = org.opensim.modeling.MocoOutputGoal('kinetic', w_kin);
kin.setOutputPath('/lumbarAct|actuation');

% Combine goals
goals = {eff, kin};

% Predict
predictive_solution = predictMotion('prediction', input_model, goals, ...
    tracking_solution, timerange, bounds);