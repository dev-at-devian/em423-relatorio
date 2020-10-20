function out = file_parse() 
    tokens = [];
    file_string = fileread("dados.txt");
    lines = strsplit(file_string, "\n");
    for i = 1:(length(lines)-1)
        line_tokens = strsplit(lines(i){:}, " ");
        tokens{end+1} = line_tokens;
    end

    for i = 1:length(tokens)
        switch tokens{i}{1}
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
                error("Erro (linha %d, coluna %d): Comando '%s' inválido", i, 1, tokens{i}{1});
        end
        
    end

    fix_loads();

endfunction


