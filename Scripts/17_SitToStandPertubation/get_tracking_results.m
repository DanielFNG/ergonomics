folder = [pwd filesep 'Perturbed'];
model_path = 'D:\OneDrive - University of Edinburgh\Projects\Ergonomics\IOC Framework\Sit To Stand Pertubation Testing\S0\2D_gait_jointspace_welded_genericmarkers_scaled_strengthened.osim';
w_states = 10;
w_controls = 0.001;
bounds_file = 'bounds_block.txt';

osim = org.opensim.modeling.Model(model_path);
bounds = parseBounds(bounds_file, osim);

for i = 1:1
    ik = Data([folder filesep num2str(i) '.mot']);
    sto = convertIKToMocoSTO(ik, osim);
    idx = sto.getIndex('/jointset/groundPelvis/pelvis_ty/value');
    sto.Values(:, idx) = [];
    sto.Labels(idx) = [];
    idx = sto.getIndex('/jointset/groundPelvis/pelvis_tx/value');
    sto.Values(:, idx) = [];
    sto.Labels(idx) = [];
    sto.writeToFile([folder filesep num2str(i) '.sto']);
    sol = produceTrackingGuess(['Sol' num2str(i)], ...
        w_states, w_controls, model_path, [folder filesep num2str(i) '.sto'], bounds);
    so.write(['Sol' num2str(i) '.sto']);
end