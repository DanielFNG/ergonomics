model = 'C:\Users\danie\Documents\GitHub\ergonomics\Models\Adjusted\gait2392musc_contact.osim';
controls = 'C:\Users\danie\Documents\GitHub\ergonomics\OpenSim\CMC\CMC_controls.sto';
states = 'C:\Users\danie\Documents\GitHub\ergonomics\OpenSim\CMC\CMC_states.sto';
actuators = 'C:\Users\danie\Documents\GitHub\ergonomics\Settings\CMC\gait2392\actuators.xml';
loads = 'C:\Users\danie\Documents\GitHub\ergonomics\Settings\RRA\gait2392\loads.xml';
save_path = 'squat_forward_contact.sto';

simulate(model, controls, states, actuators, loads, save_path);