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
