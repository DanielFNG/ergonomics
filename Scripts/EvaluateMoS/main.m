%% Inputs
model = '2D_gait_contact_constrained_activation.osim';
source_data = {'mos_only.sto', 'mos_effort.sto', 'translation_only.sto', ...
    'translation_effort.sto', 'effort_only.sto'};
source_output = {'mos_only', 'mos_effort', 'translation_only', ...
    'translation_effort', 'effort_only'};
output_dir = createOutputFolder(pwd); % Change if non-default folder needed

%% Processing & Analysis

% Create cell array to hold certain outputs
n_sources = length(source_data);
mos = cell(n_sources, 1);
timesteps = cell(n_sources, 1);

% Create MoS figure
mos_fig = figure;
hold on;

% Do the rest in a loop
for i = 1:n_sources
    
    % Make directories
    source_dir = [output_dir filesep source_output{i}];
    image_dir = [source_dir filesep 'evolution'];
    grf_dir = [source_dir filesep 'grfs'];
    graphs_dir = [source_dir filesep 'graphs'];
    mkdir(image_dir);
    mkdir(grf_dir);
    mkdir(graphs_dir);

    % Create image sequences visualising each of the input motions. I then use
    % ImageJ to create GIFs, I believe this can probably be done in MATLAB 
    [mos{i}, timesteps{i}] = visualiseMoS(model, source_data{i}, image_dir);
    
    % Compare MoS evolution;
    figure(mos_fig);
    hold on;
    plot(timesteps{i}/timesteps{i}(end)*100, mos{i}, 'LineWidth', 2);

    % Produce grf files
    %produceGRFData(model, source_data{i}, grf_dir);

    % Produce grf plots
    %plotGRFs(grf_dir, graphs_dir);
end

% Finish up MoS evolution graph
figure(mos_fig);
xlabel('% of Motion');
ylabel('Margin of Stability');
legend(source_output{:}, 'Interpreter', 'none');
set(gca, 'FontSize', 15);
saveas(gcf, [output_dir filesep 'mos-comparison.png']);
close(mos_fig);

function plotGRFs(input, output)

    % Load GRF data
    heel = Data([input filesep 'heels.sto']);
    toes = Data([input filesep 'toes.sto']);
    seat = Data([input filesep 'seat.sto']);
    
    % Get timesteps 
    timesteps = heel.Timesteps/heel.Timesteps(end)*100;
    
    % Open figure
    f = figure;
    
    % Create & save plots in all 3 directions
    directions = ['x', 'y', 'z'];
    for i = 1:3
        hold on;
        plot(timesteps, heel.getColumn(['ground_force_r_v' directions(i)]), 'LineWidth', 2);
        plot(timesteps, toes.getColumn(['ground_force_r_v' directions(i)]), 'LineWidth', 2);
        plot(timesteps, seat.getColumn(['ground_force_r_v' directions(i)]), 'LineWidth', 2);
        xlabel('% of Motion');
        ylabel('Force (N)');
        title(directions(i));
        legend('heel', 'toes', 'seat');
        saveas(gcf, [output filesep directions(i) '.png']);
        clf;
    end
    
    % Close figure
    close(f);

end

function produceGRFData(model_path, solution_path, savedir)

    % Import OpenSim libaries
    import org.opensim.modeling.*

    % Load solution & model
    solution = MocoTrajectory(solution_path);
    model_processor = ModelProcessor(model_path);
    model = model_processor.process();
    model.initSystem();

    % Create contact strings
    heel_r = StdVectorString();
    heel_l = StdVectorString();
    heel_r.add('contactHeel_r');
    heel_l.add('contactHeel_l');
    toe_r = StdVectorString();
    toe_l = StdVectorString();
    toe_r.add('contactFront_r');
    toe_l.add('contactFront_l');
    seat_r = StdVectorString();
    seat_l = StdVectorString();
    seat_r.add('chair_r');
    seat_l.add('chair_l');
    
    % Get forces from the model & solution
    heel_forces = opensimMoco.createExternalLoadsTableForGait(...
        model, solution, heel_r, heel_l);
    toe_forces = opensimMoco.createExternalLoadsTableForGait(...
        model, solution, toe_r, toe_l);
    seat_forces = opensimMoco.createExternalLoadsTableForGait(...
        model, solution, seat_r, seat_l);
    
    % Write resultant files
    STOFileAdapter.write(heel_forces, [savedir filesep 'heels.sto']);
    STOFileAdapter.write(toe_forces, [savedir filesep 'toes.sto']);
    STOFileAdapter.write(seat_forces, [savedir filesep 'seat.sto']);

end