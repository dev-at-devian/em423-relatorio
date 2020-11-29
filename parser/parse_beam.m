function out = parse_beam(tokens, line) 
    global viga;
    type = "bar";
    width = 0;
    height = 0;
    length_z = 0;
    radius = 0;
    outer_radius = 0;
    inner_radius = 0;
    elasticity = 0;
    shear = 0;
    area = 0;
    volume = 0;
    Iz = 0;
    Iy = 0;
    Ip = 0;
    i = 2;
    while i <= length(tokens)
        switch tokens{i}
            case "#"
                i = length(tokens);
            case "comprimento"
                width = str2num(tokens{++i});
            case "altura"
                height = str2num(tokens{++i});
            case "largura"
                length_z = str2num(tokens{++i});
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
            case "raio"
                if length(str2num(tokens{i+1})) > 0
                    radius = str2num(tokens{++i});
                elseif strcmp(tokens{i+1}, "externo")
                    i++;
                    outer_radius = str2num(tokens{++i});
                elseif strcmp(tokens{i+1}, "interno")
                    i++;
                    inner_radius = str2num(tokens{++i});
                else
                    error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
                endif
            case "tipo"
                switch tokens{++i}
                    case "barra"
                        type = "bar";
                    case "cilindro"
                        type = "cylinder";
                    case "oco"
                        type = "hollow";
                    otherwise
                        error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
                end
            otherwise
                error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
        end
        i++;
    end
    
    switch type
        case "bar" 
            area = length_z*height;
            volume = area*width;
            Iz = (length_z*(height^3))/12;
            Iy = (height*(length_z^3))/12;
            Ip = Iz+Iy;
        case "cylinder" 
            area = pi*(radius^2);
            volume = area*width;
            Iz = (pi*((2*radius)^4))/64;
            Iy = Iz;
            Ip = Iz+Iy;
        case "hollow" 
            area = (pi*(outer_radius^2)) - (pi*(inner_radius^2));
            volume = area*width;
            Iz = (pi*(((2*outer_radius)^4)-((2*inner_radius)^4)))/64;
            Iy = Iz;
            Ip = Iz+Iy;
        otherwise
            error("Erro : Tipo '%s' inválido", type);
    end

    viga.type = type;
    viga.width = width;
    viga.height = height;
    viga.length_z = length_z;
    viga.radius = radius;
    viga.outer_radius = outer_radius;
    viga.inner_radius = inner_radius;
    viga.elasticity = elasticity;
    viga.shear = shear;
    viga.area = area;
    viga.volume = volume;
    viga.Iz = Iz;
    viga.Iy = Iy;
    viga.Ip = Ip;

endfunction
