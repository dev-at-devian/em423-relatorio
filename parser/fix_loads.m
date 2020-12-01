function out = fix_loads()

    global carregamentos;
    global forcas_verticais;
    global apoios;

    for i = 1:length(apoios)
        support_x = apoios{i}.position;
        for j = 1:length(carregamentos)
            load_xi = carregamentos{j}.start_position;
            load_xf = carregamentos{j}.end_position;
            if ((load_xi < support_x) && (support_x < load_xf))
                carregamentos{end+1} = carregamentos{j};
                carregamentos{j}.end_position = support_x;
                carregamentos{end}.start_position = support_x;
            end
        end

    end

    for i = 1:length(forcas_verticais)
        force_x = forcas_verticais{i}.position;
        for j = 1:length(carregamentos)
            load_xi = carregamentos{j}.start_position;
            load_xf = carregamentos{j}.end_position;
            if ((load_xi < force_x) && (force_x < load_xf))
                carregamentos{end+1} = carregamentos{j};
                carregamentos{j}.end_position = force_x;
                carregamentos{end}.start_position = force_x;
            end
        end

    end


endfunction

