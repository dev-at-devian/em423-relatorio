function out = parse_force(tokens, line)
    global forcas_verticais;
    global forcas_horizontais;
    value = 0;
    position = 0;
    angle = 0;
    i = 2;
    while i <= length(tokens)
        switch tokens{i}
            case "#"
                i = length(tokens);
            case "valor"
                value = str2num(tokens{++i});
            case "posicao"
                position = str2num(tokens{++i});
            case "angulo"
                angle = str2num(tokens{++i});
            case "vertical"
                angle = 90;
            case "horizontal"
                angle = 0;
            otherwise
                error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
        end
        i++;
    end
    
    switch angle
        case 0
            forcas_horizontais{end+1} = {value, position};
        case 90
            forcas_verticais{end+1} = {value, position};
        case 180
            forcas_horizontais{end+1} = {-value, position};
        case 270
            forcas_verticais{end+1} = {-value, position};
        otherwise
            forcas_horizontais{end+1} = {value*cosd(angle), position};
            forcas_verticais{end+1} = {value*sind(angle), position};
            
    end

endfunction
