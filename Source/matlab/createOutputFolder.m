function output = createOutputFolder(name)

    root_path = getenv('ERGONOMICS_ROOT');
    output = [root_path filesep 'Output' filesep name];
    mkdir(output);

end