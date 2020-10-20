function out = fix_loads() 
    
    global carregamentos;
    global forcas_verticais;
    global apoios;

    for i = 1:length(apoios)
        support_x = apoios{i}{1};
        for j = 1:length(carregamentos)
            load_xi = carregamentos{j}{1};
            load_xf = carregamentos{j}{2};
            if ((load_xi < support_x) && (support_x < load_xf))
                carregamentos{end+1} = carregamentos{j};
                carregamentos{j}{2} = support_x;
                carregamentos{end}{1} = support_x;
            end
        end

    end

    for i = 1:length(forcas_verticais)
        force_x = forcas_verticais{i}{2};
        for j = 1:length(carregamentos)
            load_xi = carregamentos{j}{1};
            load_xf = carregamentos{j}{2};
            if ((load_xi < force_x) && (force_x < load_xf))
                carregamentos{end+1} = carregamentos{j};
                carregamentos{j}{2} = force_x;
                carregamentos{end}{1} = force_x;
            end
        end

    end


endfunction

