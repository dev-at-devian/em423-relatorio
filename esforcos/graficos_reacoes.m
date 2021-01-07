function graficos_reacoes(viga, apoios, singfun_carregamentos, singfun_forcas_x, singfun_torques)
    forcas_y = singfunsum();
    forca_cortante = singfunsum();
    momentum = singfunsum();
    inclinacao = singfunsum();
    deflexao = singfunsum();

    forcas_x = singfunsum();
    normal = singfunsum();
    alongamento = singfunsum();

    torques = singfunsum();
    torque_interno = singfunsum();
    torcao = singfunsum();

    for i = 1:length(singfun_carregamentos)
        forcas_y = forcas_y + singfun_carregamentos{i};
    endfor

    for i = 1:length(singfun_forcas_x)
        forcas_x = forcas_x + singfun_forcas_x{i};
    endfor

    for i = 1:length(singfun_torques)
        torques = torques + singfun_torques{i};
    endfor

    forca_cortante = integrate_noconst(forcas_y)
    momentum = integrate_noconst(forca_cortante)

    inclinacao = (1 / (viga.Iz * viga.elasticity)) * integrate(momentum);
    # A constante será dada pelo apoio fixo, onde a inclinacão é nula
    for i = 1:length(apoios)
        if !isnan(apoios{i}.momentum)
            defineconst(inclinacao, apoios{i}.position, 0);
        endif
    endfor
    inclinacao

    deflexao = integrate(inclinacao);
    # A constante será dada por qualquer apoio fixo, rolete ou pino, onde a deflexão é nula
    defineconst(deflexao, apoios{1}.position, 0);
    deflexao


    normal = integrate_noconst(forcas_x);
    alongamento = (1 / (viga.area * viga.elasticity)) * integrate(normal);
    # A constante será dada pelo apoio (o apoio fixo ou pino), onde o alongamento é nulo
    for i = 1:length(apoios)
        if !isnan(apoios{i}.horizontal)
            defineconst(alongamento, apoios{i}.position, 0);
        endif
    endfor

    torque_interno = integrate_noconst(torques);
    torcao = (1 / (viga.shear * viga.Ip)) * integrate(torque_interno);
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
    plot(forca_cortante, [0, viga.width], "linewidth", 2, "color", [1, 0.757, 0.027]);
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
    ylabel("M(x) [Nm]");

    figure(4);
    plot(torque_interno, [0, viga.width], "linewidth", 2, "color", [1, 0.09, 0.016]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Torque");
    xlabel("x [m]");
    ylabel("T(x) [Nm]");

    figure(5);
    plot(alongamento, [0, viga.width], "linewidth", 2, "color", [0.03, 0.5, 1]);
    grid on;
    set(gca, "fontsize", 12);
    title("Alongamento da viga");
    xlabel("x [m]");
    ylabel("delta L(x) [m]");

    figure(6);
    plot(torcao, [0, viga.width], "linewidth", 2, "color", [0.961, 0, 0.341]);
    grid on;
    set(gca, "fontsize", 12);
    title("Ângulo de torção da viga");
    xlabel("x [m]");
    ylabel("phi(x) [rad]");

    figure(7);
    plot(inclinacao, [0, viga.width], "linewidth", 2, "color", [0.835, 0, 0.976]);
    grid on;
    set(gca, "fontsize", 12);
    title("Inclinação da viga");
    xlabel("x [m]");
    ylabel("theta(x) [rad]");

    figure(8);
    plot(deflexao, [0, viga.width], "linewidth", 2, "color", [0.192, 0.106, 0.573]);
    grid on;
    set(gca, "fontsize", 12);
    title("Deflexão da viga");
    xlabel("x [m]");
    ylabel("v(x) [m]");


    # Quando não temos uma barra (quando temos uma viga circular ou circular vazada), devemos
    # calcular tensões, tensões principais e de cisalhamento máximas em pontos extremos
    if !strcmp(viga.type, "bar")
        raio = viga.radius;
        if strcmp(viga.type, "hollow")
            # Se temos um cilindro vazado, temos que manualmente pegar o raio externo
            raio = viga.outer_radius;
        endif

        # Ponto A
        # (Maior valor no eixo y, centro do eixo z)
        # y, z = (viga.raio, 0)

        # Calculamos tensão normal provocada por força normal
        #   sigma = forças normais N * (1 / área)
        tensao_normal_normal_A = normal * (1 / viga.area);

        # Calculamos tensão normal provocada por momento
        #   sigma = - momento M * posição no eixo y * (1 / momento de inércia no eixo y)
        # (momento de inércia no eixo y tirado dos exercícios da aula 9 -- estava na dúvida se usávamos I polar)
        tensao_normal_momento_A = - momentum * raio * (1 / viga.Iy);

        # Calculamos a tensão normal resultante
        #   sigma = sigma_normal + sigma_momento
        tensao_normal_A = tensao_normal_normal_A + tensao_normal_momento_A;

        # Calculamos a tensão de cisalhamento provocada por forças cortantes
        #   tau = (4 / 3) * (forças cortantes V) * (1 / área) * fator de correção
        # onde
        #   Para circular maciça:
        #       fator de correção = 1
        #   Para circular vazada:
        #       fator de correção = (raio externo ^ 2 + raio externo * raio interno + raio interno ^ 2) / (raio externo ^ 2 + raio interno ^ 2)
        fator_correcao = 1;
        if strcmp(viga.type, "hollow")
            fator_correcao = (viga.outer_radius^2 + viga.outer_radius * viga.inner_radius + viga.inner_radius^2) / (viga.outer_radius^2 + viga.inner_radius^2);
        endif
        tensao_cisalhamento_cortantes_A = (4 / 3) * forca_cortante * (1 / viga.area) * fator_correcao;

        # Calculamos a tensão de cisalhamento provocada por torção
        #   tau = torques internos T * posição no raio * (1 / momento de inércia polar)
        tensao_cisalhamento_torcao_A = torque_interno * raio * (1 / viga.Ip);

        # Calculamos a tensão de cisalhamento provocada por torção
        #   tau = tau_cortantes + tau_torcao
        tensao_cisalhamento_A = tensao_cisalhamento_cortantes_A + tensao_cisalhamento_torcao_A;

        # Ponto B
        # (Centro do eixo y e maior valor dentro da viga no eixo z)
        # y, z = (viga.raio, 0)


        figure(9);
        plot(tensao_normal_A, [0, viga.width], "linewidth", 2, "color", [0.192, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao normal no ponto  A");
        xlabel("x [m]");
        ylabel("sigma(x) [Pa]");

        figure(10);
        plot(tensao_cisalhamento_A, [0, viga.width], "linewidth", 2, "color", [0.192, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento no ponto  A");
        xlabel("x [m]");
        ylabel("tau(x) [Pa]");

    endif

endfunction

