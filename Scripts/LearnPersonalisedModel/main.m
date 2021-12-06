% Inputs 
ik_path = 'ik1.mot';
model_path = '2D_gait_contact_constrained_activation.osim';

% Convert IK to Moco STO
ik = Data(ik_path);
model = org.opensim.modeling.Model(model_path);
reference = convertIKToMocoSTO(ik, model);

% Print reference data
reference.writeToFile('reference.sto');
