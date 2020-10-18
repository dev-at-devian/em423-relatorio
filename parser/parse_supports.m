function out = parse_supports(tokens, line) 
    global apoios;
    position = 0;
    horizontal = NaN;
    vertical = NaN;
    momentum = NaN;
    torque = NaN;
    i = 2;
    while i <= length(tokens)
        switch tokens{i}
            case "#"
                i = length(tokens);
            case "tipo"
                tmp = tokens{++i};
                if (strcmp(tmp, "fixo") || strcmp(tmp, "pino") || strcmp(tmp, "rolete"))
                    vertical = 0;
                end
                if (strcmp(tmp, "fixo") || strcmp(tmp, "pino"))
                    horizontal = 0;
                    torque = 0;
                end
                if (strcmp(tmp, "fixo"))
                    momentum = 0;
                end
            case "posicao"
                position = str2num(tokens{++i});
            otherwise
                error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
                
        end
        i++;
    end

    support = {position horizontal vertical momentum torque};
    apoios{end+1} = support;

endfunction
