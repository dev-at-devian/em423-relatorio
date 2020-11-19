function graficos_reacoes(viga, singfun_carregamentos, singfun_forcas_x, singfun_torques) 
    aux_fy = singfunsum();  
    force_y = singfunsum();  
    momentum = singfunsum();  

    aux_fx = singfunsum();  
    force_x = singfunsum();  

    aux_t = singfunsum();  
    torque = singfunsum();  

    for i = 1:length(singfun_carregamentos)
        aux_fy = aux_fy + singfun_carregamentos{i};  
    endfor
    for i = 1:length(singfun_forcas_x)
        aux_fx = aux_fx + singfun_forcas_x{i};  
    endfor
    for i = 1:length(singfun_torques)
        aux_t = aux_t + singfun_torques{i};  
    endfor

    force_y = integrate(aux_fy);
    momentum = integrate(force_y);
    
    force_x = integrate(aux_fx);
    torque = integrate(aux_t);

    figure(1);
    plot(force_x, [0, viga.width], "linewidth", 2, "color", [1, 0.435, 0]);
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

endfunction

