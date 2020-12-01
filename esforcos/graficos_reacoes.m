function graficos_reacoes(viga, apoios, singfun_carregamentos, singfun_forcas_x, singfun_torques)
    aux_fy = singfunsum();
    force_y = singfunsum();
    momentum = singfunsum();

    forcas_x = singfunsum();
    normal = singfunsum();
    alongamento = singfunsum();

    aux_t = singfunsum();
    torque = singfunsum();
    torcao = singfunsum();

    for i = 1:length(singfun_carregamentos)
        aux_fy = aux_fy + singfun_carregamentos{i};
    endfor
    for i = 1:length(singfun_forcas_x)
        forcas_x = forcas_x + singfun_forcas_x{i};
    endfor
    for i = 1:length(singfun_torques)
        aux_t = aux_t + singfun_torques{i};
    endfor

    force_y = integrate_noconst(aux_fy);
    momentum = integrate_noconst(force_y);
    normal = integrate_noconst(forcas_x);
    torque = integrate_noconst(aux_t);

    alongamento = (1 / (viga.area * viga.elasticity)) * integrate(normal);
    # A constante será dada pelo apoio (o apoio fixo ou pino), onde o alongamento é nulo
    for i = 1:length(apoios)
        if !isnan(apoios{i}.horizontal)
            defineconst(alongamento, apoios{i}.position, 0);
        endif
    endfor

    torcao = (1 / (viga.shear * viga.Ip)) * integrate(torque);
    # A constante será dada pelo apoio (o apoio fixo ou pino), onde o ângulo de torção é nulo
    for i = 1:length(apoios)
        if !isnan(apoios{i}.horizontal)
            defineconst(torcao, apoios{i}.position, 0);
        endif
    endfor

    figure(1);
    plot(normal, [0, viga.width], "linewidth", 2, "color", [1, 0.435, 0]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Força Normal");
    xlabel("x [m]");
    ylabel("N(x) [N]");

    figure(2);
    plot(force_y, [0, viga.width], "linewidth", 2, "color", [1, 0.757, 0.027]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Força Cortante");
    xlabel("x [m]");
    ylabel("V(x) [N]");

    figure(3);
    plot(momentum, [0, viga.width], "linewidth", 2, "color", [0.682, 0.918, 0]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Momento");
    xlabel("x [m]");
    ylabel("M [Nm]");

    figure(4);
    plot(torque, [0, viga.width], "linewidth", 2, "color", [1, 0.09, 0.016]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Torque");
    xlabel("x [m]");
    ylabel("T [Nm]");

    figure(5);
    plot(alongamento, [0, viga.width], "linewidth", 2, "color", [0.03, 0.5, 1]);
    grid on;
    set(gca, "fontsize", 12);
    title("Alongamento da viga");
    xlabel("x [m]");
    ylabel("delta L [m]");

    figure(6);
    plot(torcao, [0, viga.width], "linewidth", 2, "color", [0.03, 0.5, 1]);
    grid on;
    set(gca, "fontsize", 12);
    title("Ângulo de torção da viga");
    xlabel("x [m]");
    ylabel("phi [rad]");
endfunction

