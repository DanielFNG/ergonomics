% A script to add controls to the generic H3-assist model.

% Load the model and the ID data
osim = org.opensim.modeling.Model(['C:\Users\danie\Documents\GitHub' ...
    '\ergonomics\Models\Generic\fullbodyH3.osim']);
id = Data(['C:\Users\danie\Documents\GitHub' ...
    '\ergonomics\OpenSim\ID\inverse_dynamics.sto']);

% Zero the timesteps
timesteps = id.Timesteps - id.Timesteps(1);

% Specify the actuators we need control for
actuator_names = {'hip_r', 'hip_l', 'knee_r', ...
    'knee_l', 'ankle_r', 'ankle_l', 'lumbar_extension'};
torques = {'hip_flexion_r_moment', 'hip_flexion_l_moment', ...
    'knee_angle_r_moment', 'knee_angle_l_moment', 'ankle_angle_r_moment', ...
    'ankle_angle_l_moment', 'lumbar_extension_moment'};

% Step through adding controllers 
controller = org.opensim.modeling.PrescribedController();
controller.setName('joint_torques');
actuators = osim.updActuators();
for i = 1:length(actuator_names)
    controller.addActuator(actuators.get(actuator_names{i}));
    control_function = org.opensim.modeling.PiecewiseConstantFunction();
    for j = 1:id.NFrames
        control_function.addPoint(timesteps(j), id.getValue(j, torques{i}));
    end
    controller.prescribeControlForActuator(actuator_names{i}, control_function);
end

% Add the controller to the model.
osim.addComponent(controller);

% Print the new model
osim.print(['C:\Users\danie\Documents\GitHub' ...
    '\ergonomics\Models\Generic\fullbodyH3_controlled.osim']);



