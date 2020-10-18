function out = parse_beam(tokens, line) 
    global viga;
    width = 0;
    height = 0;
    i = 2;
    while i <= length(tokens)
        switch tokens{i}
            case "#"
                i = length(tokens);
            case "comprimento"
                width = str2num(tokens{++i});
            case "altura"
                height = str2num(tokens{++i});
            otherwise
                error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
        end
        i++;
    end

    viga{end+1} = width;
    viga{end+1} = height;

endfunction
