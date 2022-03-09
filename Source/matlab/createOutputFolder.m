function output = createOutputFolder(name)

    root_path = getenv('ERGONOMICS_ROOT');
    if isempty(root_path)
        error('Setup not complete.');
    end
    output = [root_path filesep 'Output' filesep name];
    mkdir(output);

end