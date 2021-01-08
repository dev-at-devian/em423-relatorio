function out = parse_momentum(tokens, line)
    global momentos;
    global singfun_carregamentos;
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
    momentum = struct("value", value, "position", position);
    momentos{end+1} = momentum;
    # Aqui invertemos o valor para adotarmos a convenção de esforços internos no corte à direita
    singfun_carregamentos{end+1} = singfun(-2, position, -value);

endfunction
