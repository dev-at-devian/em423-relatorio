clc
clear all
format long


global forcas_verticais = [];   # {valor, posicao}
global forcas_horizontais = []; # {valor, posicao}
global apoios = [];             # {posicao, horizontal, vertical, momento, torque}
global momentos = [];           # {valor, posicao}
global torques = [];            # {valor, posicao}
global carregamentos = [];      # {posicao_inicio, posicao_fim, {coeficiente1,...,coeficienten}};
global viga = [];               # {comprimento, altura}

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

endfunction

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

function out = parse_torque(tokens, line) 
    global torques;
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
    torque = {value, position};
    torques{end+1} = torque;

endfunction

function out = parse_load(tokens, line) 
    global carregamentos;
    start_position = 0;
    end_position = 0;
    coefficients = [];
    i = 2;
    while i <= length(tokens)
        switch tokens{i}
            case "#"
                i = length(tokens);
            case "de" 
                start_position = str2num(tokens{++i});
                if strcmp(tokens{++i}, "ate")
                    end_position = str2num(tokens{++i});
                else
                    error("Erro (linha %d, coluna %d): 'ate' esperado, '%s' encontrado", line, i, tokens{i});
                end
            case "coeficientes"
                coefficient = str2num(tokens{++i});
                if isempty(coefficient)
                    error("Erro (linha %d, coluna %d): coeficiente esperado, '%s' encontrado", line, i, tokens{i});
                end
                while (!isempty(coefficient)) && (i <= length(tokens))
                    coefficients{end+1} = coefficient;
                    try
                        coefficient = str2num(tokens{++i});
                    catch
                        i--;
                        break;
                    end_try_catch
                    if isempty(coefficient)
                        i--;
                        break;
                    end
                end
            otherwise
                error("Erro (linha %d, coluna %d): Comando '%s' inválido", line, i, tokens{i});
        end
        i++;
    end
    load = {start_position, end_position, coefficients};
    carregamentos{end+1} = load;

endfunction


# Testando todos os vetores lidos

file_parse();

printf("Viga:\n");
disp(viga);
printf("\nForças Verticais:\n");
disp(forcas_verticais);
printf("\nForças Horizontais:\n");
disp(forcas_horizontais);
printf("\nMomentos:\n");
disp(momentos);
printf("\nTorques:\n");
disp(torques);
printf("\nApoios:\n");
disp(apoios);
printf("\nCarregamentos:\n");
disp(carregamentos);

# Convertemos forças de carregamento em forças verticais para cálculo de reações
pontuais_carregamentos = carregamentos_para_forcas(carregamentos);
forcas_verticais_com_carregamentos = [forcas_verticais, pontuais_carregamentos]

# Calculamos os momentos de todas as forças para cálculo de reações
momentos_de_forcas = forcas_para_momentos(forcas_verticais_com_carregamentos);
momentos_com_carregamentos = [momentos, momentos_de_forcas]

# Calculamos as reações
apoios = calcular_reacoes(apoios, forcas_verticais_com_carregamentos, forcas_horizontais, momentos_com_carregamentos, torques)

# Plot das reaçoes internas na horizontal
esforcosHorizontais(forcas_horizontais, apoios, viga{1})

# Plot das reaçoes internas para tensores
esforcosTorques(torques, apoios, viga{1})

esforcosVerticais(forcas_verticais_com_carregamentos, apoios, carregamentos, viga{1})

#esforcosMomentos (momentos_de_forcas, momentos, apoios, carregamentos, viga{1})

