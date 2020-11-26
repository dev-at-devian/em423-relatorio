function out = parse_beam(tokens, line) 
    global viga;
    width = 0;
    height = 0;
    elasticity = 0;
    shear = 0;
    i = 2;
    while i <= length(tokens)
        switch tokens{i}
            case "#"
                i = length(tokens);
            case "comprimento"
                width = str2num(tokens{++i});
            case "altura"
                height = str2num(tokens{++i});
            case "modulo"
                if strcmp(tokens{i+1}, "elastico")
                    i++;
                    elasticity = str2num(tokens{++i});
                elseif strcmp(tokens{i+1}, "cisalhamento")
                    i++;
                    shear = str2num(tokens{++i});
                else
                    error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
                endif
            otherwise
                error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
        end
        i++;
    end

    viga.width = width;
    viga.height = height;
    viga.elasticity = elasticity;
    viga.shear = shear;

endfunction
