function out = parse_momentum(tokens, line) 
    global momentos;
    position = 0;
    value = 0;
    i = 2;
    while i <= length(tokens)
        switch tokens{i}
            case "#"
                i = length(tokens);
            case "valor"
                value = str2num(tokens{++i});
            case "posicao" 
                position = str2num(tokens{++i});
            otherwise
                error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
        end
        i++;
    end
    momentum = {value, position};
    momentos{end+1} = momentum;

endfunction
