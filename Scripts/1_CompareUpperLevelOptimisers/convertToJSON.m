function convertToJSON(filename, savefile, methods_in, methods_out)

    x = load(filename);

    y.methods = methods_out;
    y.times = [];
    y.values = [];
    for i = 1:2
        y.times = [y.times x.time.(methods_in{i})];
        y.values = [y.values; x.deterministic.(methods_in{i}) x.noisy.(methods_in{i})];
    end

    j = jsonencode(y, 'PrettyPrint', true);
    fid = fopen(savefile, 'w');
    fprintf(fid, j);
    fclose(fid);

end