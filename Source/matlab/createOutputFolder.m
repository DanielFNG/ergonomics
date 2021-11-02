function output = createOutputFolder(source)

    [scripts_path, name] = fileparts(source);
    root_path = fileparts(scripts_path);
    output = [root_path filesep 'Output' filesep name];
    mkdir(output);

end