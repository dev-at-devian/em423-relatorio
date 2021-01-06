function out = file_parse(file_path)
    global carregamentos;
    tokens = [];
    file_string = fileread(file_path);
    lines = strsplit(file_string, "\n");
    for i = 1:(length(lines)-1)
        line_tokens = strsplit(lines(i){:}, " ");
        tokens{end+1} = line_tokens;
    end

    for i = 1:length(tokens)
        switch char(tokens{i}{1})
            case "#"
                continue
            case "viga"
                parse_beam(tokens{i}, i);
            case "forca"
                parse_force(tokens{i}, i);
            case "apoio"
                parse_supports(tokens{i}, i);
            case "momento"
                parse_momentum(tokens{i}, i);
            case "torque"
                parse_torque(tokens{i}, i);
            case "carregamento"
                parse_load(tokens{i}, i);
            otherwise
                error(
                    "Erro (linha %d, coluna %d): Comando inválido: \"%s\" na linha \"%s\"",
                    i,
                    1,
                    do_string_escapes(char(tokens{i}{1})),
                    do_string_escapes(char(tokens{i}))
                );
        end

    end

endfunction


