function result = objective(weights)

    % Hard-coded properties for now
    save_dir = [pwd filesep 'results'];
    reduced_dir = [pwd filesep 'results-reduced'];
    save_name = ['w_effort=' ...
        sprintf('%.5g', weights(1)) repmat('0', 1, 8 - length(sprintf('%.5g', weights(1)))) '_w_mos=' ...
        sprintf('%.5g', weights(2)) repmat('0', 1, 8 - length(sprintf('%.5g', weights(2)))) '_w_pmos=' ...
        sprintf('%.5g', weights(3)) repmat('0', 1, 8 - length(sprintf('%.5g', weights(3)))) '_w_wmos=' ...
        sprintf('%.5g', weights(4)) repmat('0', 1, 8 - length(sprintf('%.5g', weights(4)))) '_w_aload=' ...
        sprintf('%.5g', weights(5)) repmat('0', 1, 8 - length(sprintf('%.5g', weights(5)))) '_w_kload=' ...
        sprintf('%.5g', weights(6)) repmat('0', 1, 8 - length(sprintf('%.5g', weights(6)))) '_w_hload=' ...
        sprintf('%.5g', weights(7)) repmat('0', 1, 8 - length(sprintf('%.5g', weights(7)))) '.sto'];
    save_path = [save_dir filesep save_name];
    reduced_path = [reduced_dir filesep save_name];
    obj = @sumSquaredStateDifference;
    reference_path = 'ReferenceData.sto';
    reference_data = Data(reference_path);
    labels = reference_data.Labels(2:end);
    args = {reference_path, labels};

    % Generate command 
    command = ['./main'];
    for i = 1:length(weights)
        command = [command  ' ' num2str(weights(i))];
    end
    command = [command ' ' save_dir];

    % Run command 
    return_status = system(command);
    
    switch return_status
        case 0
            [values, labels, header] = MOTSTOTXTData.load(save_path);
            reduced = STOData(values(:, 1:end-6), header, labels(1:end-6));
            result = gradeSitToStand(reduced, obj, args, []);
        otherwise
            result = -1;
    end

end