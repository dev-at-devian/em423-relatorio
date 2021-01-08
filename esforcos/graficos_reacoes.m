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
    alongamento

    torque_interno = integrate_noconst(torques);
    torcao = (1 / (viga.shear * viga.Ip)) * integrate(torque_interno);
    # A constante será dada pelo apoio (o apoio fixo ou pino), onde o ângulo de torção é nulo
    for i = 1:length(apoios)
        if !isnan(apoios{i}.horizontal)
            defineconst(torcao, apoios{i}.position, 0);
        endif
    endfor
    torque_interno
    torcao

    figura_atual = 1;

    figure(figura_atual);
    figura_atual = figura_atual + 1;
    plot(normal, [0, viga.width], "color", [1, 0.435, 0]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Força Normal");
    xlabel("x [m]");
    ylabel("N(x) [N]");

    figure(figura_atual);
    figura_atual = figura_atual + 1;
    plot(forca_cortante, [0, viga.width], "color", [1, 0.757, 0.027]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Força Cortante");
    xlabel("x [m]");
    ylabel("V(x) [N]");

    figure(figura_atual);
    figura_atual = figura_atual + 1;
    plot(momentum, [0, viga.width], "color", [0.682, 0.918, 0]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Momento");
    xlabel("x [m]");
    ylabel("M(x) [Nm]");

    figure(figura_atual);
    figura_atual = figura_atual + 1;
    plot(torque_interno, [0, viga.width], "color", [1, 0.09, 0.016]);
    grid on;
    set(gca, "fontsize", 12);
    title("Esforços Internos - Torque");
    xlabel("x [m]");
    ylabel("T(x) [Nm]");

    figure(figura_atual);
    figura_atual = figura_atual + 1;
    plot(alongamento, [0, viga.width], "color", [0.03, 0.5, 1]);
    grid on;
    set(gca, "fontsize", 12);
    title("Alongamento da viga");
    xlabel("x [m]");
    ylabel("delta L(x) [m]");

    figure(figura_atual);
    figura_atual = figura_atual + 1;
    plot(torcao, [0, viga.width], "color", [0.961, 0, 0.341]);
    grid on;
    set(gca, "fontsize", 12);
    title("Ângulo de torção da viga");
    xlabel("x [m]");
    ylabel("phi(x) [rad]");

    figure(figura_atual);
    figura_atual = figura_atual + 1;
    plot(inclinacao, [0, viga.width], "color", [0.835, 0, 0.976]);
    grid on;
    set(gca, "fontsize", 12);
    title("Inclinação da viga");
    xlabel("x [m]");
    ylabel("theta(x) [rad]");

    figure(figura_atual);
    figura_atual = figura_atual + 1;
    plot(deflexao, [0, viga.width], "color", [0.192, 0.106, 0.573]);
    grid on;
    set(gca, "fontsize", 12);
    title("Deflexão da viga");
    xlabel("x [m]");
    ylabel("v(x) [m]");


    # Quando não temos uma barra (quando temos uma viga circular ou circular vazada), devemos
    # calcular tensões, tensões principais e de cisalhamento máximas em pontos extremos
    if !strcmp(viga.type, "bar")

        # Nesse trecho calcularemos:
        #
        # 1. Tensão normal provocada por força normal
        #       sigma = forças normais N * (1 / área)
        # onde
        #       forças normais N positivas estão "saindo" da normal dessa face que analisamos, assim
        #       como o sigma da face. Nessas condições, não precisamos alterar o sinal.
        #
        # 2. Tensão normal provocada por momento
        #       sigma = - momento M * posição no eixo y * (1 / momento de inércia no eixo y, Iy)
        # onde
        #       usamos momento de inércia no eixo y, Iy, tirado dos exercícios da aula 9 (estava na
        #       dúvida se usávamos I polar, mas estamos vendo um corte em y de fato)
        # e ainda
        #       momento M positivo é antihorário na face que analisamos. Nessas condições, haveria
        #       compressão no topo da viga e tração na parte inferior. Como compressão acontece com
        #       y positivo mas sua tensão deve ser negativa, temos que ter um sinal negativo na
        #       fórmula.
        #
        # 3. Tensão normal resultante
        #       sigma = sigma_normal + sigma_momento
        #
        # 4. Tensão de cisalhamento provocada por forças cortantes
        #       tau = - (4 / 3) * (forças cortantes V) * (1 / área) * fator de correção
        # onde
        #       Para circular maciça:
        #           fator de correção = 1
        #       Para circular vazada:
        #           fator de correção = (raio externo ^ 2 + raio externo * raio interno + raio interno ^ 2) / (raio externo ^ 2 + raio interno ^ 2)
        # e ainda
        #       força cortante V positiva acontece para baixo nessa face, mas o tau dessa face é
        #       para cima. Nessas condições, a tensão é para baixo com cortante
        #       positiva e isso é o contrário do tau, então temos que trocar o sinal.
        # também
        #       essa tensão é nula nos pontos máximos e mínimos da viga no eixo y.
        #
        # 5. Tensão de cisalhamento provocada por torção
        #       tau = +/- torques internos T * posição no raio * (1 / momento de inércia polar)
        # onde
        #       considerando torque T positivo, seu vetor sai da normal da face, o que indica, pela
        #       regra da mão direita, que no ponto em z negativo, temos T coincidente com o tau da
        #       face e não precisamos trocar de sinal. Já em pontos de z positivo, temos um T oposto
        #       ao tau da face, e nesses pontos, devemos trocar o sinal.
        # e ainda
        #       Para pontos em y positivo, torque positivo produz tensão horizontal para a esquerda,
        #       o que coincide com tau da face deste lado. Já em y negativo, precisamos inverter o
        #       sinal, pois torque positivo produz tensão horizontal para a direita enquanto o tau
        #       é para a esquerda.
        # 6. Tensão de cisalhamento resultante
        #       tau = tau_cortantes + tau_torcao
        #


        # Pegamos o raio dos diferentes tipos de viga cilindrica
        raio = viga.radius;
        fator_correcao = 1;
        if strcmp(viga.type, "hollow")
            # Se temos um cilindro vazado, temos que manualmente pegar o raio externo
            raio = viga.outer_radius;
            fator_correcao = (viga.outer_radius^2 + viga.outer_radius * viga.inner_radius + viga.inner_radius^2) / (viga.outer_radius^2 + viga.inner_radius^2);
        endif

        G = viga.shear;
        E = viga.elasticity;
        v = E / (2 * G) - 1;

        # Para os gráficos feitos manualmente
        intervalo_grafico = 0:(viga.width / 500):viga.width;


        # Ponto A
        # (Maior valor dentro da viga no eixo y, centro do eixo z)
        # (y, z) = (+viga.raio, 0)
        # Nesse ponto, nas condições que estudamos, temos (em valores absolutos):
        # - tensão normal causada por forças normais constante
        # - tensão normal causada por momento MÁXIMA
        # - tensão de cisalhamento causada por força cortante NULA
        # - tensão de cisalhamento causada por torque MÁXIMA (por estar no raio máximo)

        # Tensão normal provocada por força normal
        tensao_normal_normal_A = normal * (1 / viga.area)
        # Tensão normal provocada por momento
        tensao_normal_momento_A = - momentum * raio * (1 / viga.Iy)
        # Calculamos a tensão normal resultante
        tensao_normal_A = tensao_normal_normal_A + tensao_normal_momento_A

        # Tensão de cisalhamento provocada por forças cortantes
        tensao_cisalhamento_cortantes_A_xy = 0 # zero devido posição
        # Calculamos a tensão de cisalhamento provocada por torção
        tensao_cisalhamento_torcao_A_xz = torque_interno * raio * (1 / viga.Ip)
        # Calculamos a tensão de cisalhamento provocada por torção
        tensao_cisalhamento_A_xy = tensao_cisalhamento_cortantes_A_xy
        tensao_cisalhamento_A_xz = tensao_cisalhamento_torcao_A_xz

        # Tensões principais e de cisalhamento máxima abs. calculadas em função de x
        tensao_principal_1_A = [];
        tensao_principal_2_A = [];
        tensao_cisalhamento_max_abs_A = [];
        deformacao_normal_A_x = [];
        deformacao_normal_A_y = [];
        deformacao_normal_A_z = [];
        deformacao_cisalhamento_A_xy = [];
        deformacao_cisalhamento_A_yz = [];
        deformacao_cisalhamento_A_zx = [];
        # Laço para fazer o gráfico, vários pontos em toda a viga
        for posicao_x = intervalo_grafico
            # Pegamos os valores na posição atual
            tensao_normal_A_ = tensao_normal_A(posicao_x);
            tensao_cisalhamento_A_xz_ = tensao_cisalhamento_A_xz(posicao_x);

            tensao_principal_termo_A = sqrt((tensao_normal_A_ / 2)^2 + (tensao_cisalhamento_A_xz_)^2);
            tensao_principal_1_A_ = (tensao_normal_A_ / 2) + tensao_principal_termo_A;
            tensao_principal_2_A_ = (tensao_normal_A_ / 2) - tensao_principal_termo_A;
            tensao_principal_1_A(end+1) = tensao_principal_1_A_;
            tensao_principal_2_A(end+1) = tensao_principal_2_A_;

            # Tensao de cisalhamento máxima absoluta
            tensao_cisalhamento_max_abs_A_ = (max([tensao_principal_1_A_, tensao_principal_2_A_, 0]) - min([tensao_principal_1_A_, tensao_principal_2_A_, 0])) / 2;
            tensao_cisalhamento_max_abs_A(end+1) = tensao_cisalhamento_max_abs_A_;

            # Deformação normal
            deformacao_normal_A_x(end+1) = tensao_normal_A_ / E;
            deformacao_normal_A_y(end+1) = -v * tensao_normal_A_ / E;
            deformacao_normal_A_z(end+1) = -v * tensao_normal_A_ / E;
            # Deformação de cisalhamento
            deformacao_cisalhamento_A_xy(end+1) = 0; # é zerada
            deformacao_cisalhamento_A_yz(end+1) = 0; # não possuímos tau_yz
            deformacao_cisalhamento_A_zx(end+1) = tensao_cisalhamento_A_xz_ / G;
        endfor

        # Ponto B
        # (Centro do eixo y e maior valor dentro da viga no eixo z)
        # (y, z) = (0, +viga.raio)
        # Nesse ponto, nas condições que estudamos, temos (em valores absolutos):
        # - tensão normal causada por forças normais constante
        # - tensão normal causada por momento NULA
        # - tensão de cisalhamento causada por força cortante MÁXIMA
        # - tensão de cisalhamento causada por torque MÁXIMA (por estar no raio máximo)

        # Tensão normal provocada por força normal
        tensao_normal_normal_B = normal * (1 / viga.area)
        # Tensão normal provocada por momento
        tensao_normal_momento_B = 0 # zero devido posição
        # Calculamos a tensão normal resultante
        tensao_normal_B = tensao_normal_normal_B + tensao_normal_momento_B

        # Tensão de cisalhamento provocada por forças cortantes
        tensao_cisalhamento_cortantes_B_xy = - (4 / 3) * forca_cortante * (1 / viga.area) * fator_correcao
        # Calculamos a tensão de cisalhamento provocada por torção
        tensao_cisalhamento_torcao_B_xy = - torque_interno * raio * (1 / viga.Ip) # negativo pela posição
        # Calculamos a tensão de cisalhamento provocada por torção
        tensao_cisalhamento_B_xy = tensao_cisalhamento_torcao_B_xy + tensao_cisalhamento_cortantes_B_xy
        tensao_cisalhamento_B_xz = 0

        # Tensões principais e de cisalhamento máxima abs. calculadas em função de x
        tensao_principal_1_B = [];
        tensao_principal_2_B = [];
        tensao_cisalhamento_max_abs_B = [];
        deformacao_normal_B_x = [];
        deformacao_normal_B_y = [];
        deformacao_normal_B_z = [];
        deformacao_cisalhamento_B_xy = [];
        deformacao_cisalhamento_B_yz = [];
        deformacao_cisalhamento_B_zx = [];
        # Laço para fazer o gráfico, vários pontos em toda a viga
        for posicao_x = intervalo_grafico
            # Pegamos os valores na posição atual
            tensao_normal_B_ = tensao_normal_B(posicao_x);
            tensao_cisalhamento_B_xy_ = tensao_cisalhamento_B_xy(posicao_x);

            tensao_principal_termo_B = sqrt((tensao_normal_B_ / 2)^2 + (tensao_cisalhamento_B_xy_)^2);
            tensao_principal_1_B_ = (tensao_normal_B_ / 2) + tensao_principal_termo_B;
            tensao_principal_2_B_ = (tensao_normal_B_ / 2) - tensao_principal_termo_B;
            tensao_principal_1_B(end+1) = tensao_principal_1_B_;
            tensao_principal_2_B(end+1) = tensao_principal_2_B_;

            # Tensao de cisalhamento máxima absoluta
            tensao_cisalhamento_max_abs_B_ = (max([tensao_principal_1_B_, tensao_principal_2_B_, 0]) - min([tensao_principal_1_B_, tensao_principal_2_B_, 0])) / 2;
            tensao_cisalhamento_max_abs_B(end+1) = tensao_cisalhamento_max_abs_B_;

            # Deformação normal
            deformacao_normal_B_x(end+1) = tensao_normal_B_ / E;
            deformacao_normal_B_y(end+1) = -v * tensao_normal_B_ / E;
            deformacao_normal_B_z(end+1) = -v * tensao_normal_B_ / E;
            # Deformação de cisalhamento
            deformacao_cisalhamento_B_xy(end+1) = tensao_cisalhamento_B_xy_ / G;
            deformacao_cisalhamento_B_yz(end+1) = 0; # não possuímos tau_yz
            deformacao_cisalhamento_B_zx(end+1) = 0; # é zerada
        endfor

        # Ponto C
        # (Centro do eixo y e maior valor dentro da viga no eixo z)
        # (y, z) = (-viga.raio, 0)
        # Nesse ponto, nas condições que estudamos, temos (em valores absolutos):
        # - tensão normal causada por forças normais constante
        # - tensão normal causada por momento MÁXIMA
        # - tensão de cisalhamento causada por força cortante NULA
        # - tensão de cisalhamento causada por torque MÁXIMA (por estar no raio máximo)

        # Tensão normal provocada por força normal
        tensao_normal_normal_C = normal * (1 / viga.area)
        # Tensão normal provocada por momento
        tensao_normal_momento_C = - momentum * (-raio) * (1 / viga.Iy)
        # Calculamos a tensão normal resultante
        tensao_normal_C = tensao_normal_normal_C + tensao_normal_momento_C

        # Tensão de cisalhamento provocada por forças cortantes
        tensao_cisalhamento_cortantes_C_xy = 0 # zero devido posição
        # Calculamos a tensão de cisalhamento provocada por torção
        tensao_cisalhamento_torcao_C_xz = - torque_interno * raio * (1 / viga.Ip) # negativo pela posição
        # Calculamos a tensão de cisalhamento provocada por torção
        tensao_cisalhamento_C_xy = tensao_cisalhamento_cortantes_C_xy
        tensao_cisalhamento_C_xz = tensao_cisalhamento_torcao_C_xz

        # Tensões principais e de cisalhamento máxima abs. calculadas em função de x
        tensao_principal_1_C = [];
        tensao_principal_2_C = [];
        tensao_cisalhamento_max_abs_C = [];
        deformacao_normal_C_x = [];
        deformacao_normal_C_y = [];
        deformacao_normal_C_z = [];
        deformacao_cisalhamento_C_xy = [];
        deformacao_cisalhamento_C_yz = [];
        deformacao_cisalhamento_C_zx = [];
        # Laço para fazer o gráfico, vários pontos em toda a viga
        for posicao_x = intervalo_grafico
            # Pegamos os valores na posição atual
            tensao_normal_C_ = tensao_normal_C(posicao_x);
            tensao_cisalhamento_C_xz_ = tensao_cisalhamento_C_xz(posicao_x);

            tensao_principal_termo_C = sqrt((tensao_normal_C_ / 2)^2 + (tensao_cisalhamento_C_xz_)^2);
            tensao_principal_1_C_ = (tensao_normal_C_ / 2) + tensao_principal_termo_C;
            tensao_principal_2_C_ = (tensao_normal_C_ / 2) - tensao_principal_termo_C;
            tensao_principal_1_C(end+1) = tensao_principal_1_C_;
            tensao_principal_2_C(end+1) = tensao_principal_2_C_;

            # Tensao de cisalhamento máxima absoluta
            tensao_cisalhamento_max_abs_C_ = (max([tensao_principal_1_C_, tensao_principal_2_C_, 0]) - min([tensao_principal_1_C_, tensao_principal_2_C_, 0])) / 2;
            tensao_cisalhamento_max_abs_C(end+1) = tensao_cisalhamento_max_abs_C_;

            # Deformação normal
            deformacao_normal_C_x(end+1) = tensao_normal_C_ / E;
            deformacao_normal_C_y(end+1) = -v * tensao_normal_C_ / E;
            deformacao_normal_C_z(end+1) = -v * tensao_normal_C_ / E;
            # Deformação de cisalhamento
            deformacao_cisalhamento_C_xy(end+1) = 0; # é zerada
            deformacao_cisalhamento_C_yz(end+1) = 0; # não possuímos tau_yz
            deformacao_cisalhamento_C_zx(end+1) = tensao_cisalhamento_C_xz_ / G;
        endfor

        # Ponto D
        # (Centro do eixo y e maior valor dentro da viga no eixo z)
        # (y, z) = (0, -viga.raio)
        # Nesse ponto, nas condições que estudamos, temos (em valores absolutos):
        # - tensão normal causada por forças normais constante
        # - tensão normal causada por momento NULA
        # - tensão de cisalhamento causada por força cortante MÁXIMA
        # - tensão de cisalhamento causada por torque MÁXIMA (por estar no raio máximo)

        # Tensão normal provocada por força normal
        tensao_normal_normal_D = normal * (1 / viga.area)
        # Tensão normal provocada por momento
        tensao_normal_momento_D = 0 # zero devido posição
        # Calculamos a tensão normal resultante
        tensao_normal_D = tensao_normal_normal_D + tensao_normal_momento_D

        # Tensão de cisalhamento provocada por forças cortantes
        tensao_cisalhamento_cortantes_D_xy = - (4 / 3) * forca_cortante * (1 / viga.area) * fator_correcao
        # Calculamos a tensão de cisalhamento provocada por torção
        tensao_cisalhamento_torcao_D_xy = torque_interno * raio * (1 / viga.Ip)
        # Calculamos a tensão de cisalhamento provocada por torção
        tensao_cisalhamento_D_xy = tensao_cisalhamento_torcao_D_xy + tensao_cisalhamento_cortantes_D_xy
        tensao_cisalhamento_D_xz = 0

        # Tensões principais e de cisalhamento máxima abs. calculadas em função de x
        tensao_principal_1_D = [];
        tensao_principal_2_D = [];
        tensao_cisalhamento_max_abs_D = [];
        deformacao_normal_D_x = [];
        deformacao_normal_D_y = [];
        deformacao_normal_D_z = [];
        deformacao_cisalhamento_D_xy = [];
        deformacao_cisalhamento_D_yz = [];
        deformacao_cisalhamento_D_zx = [];
        # Laço para fazer o gráfico, vários pontos em toda a viga
        for posicao_x = intervalo_grafico
            # Pegamos os valores na posição atual
            tensao_normal_D_ = tensao_normal_D(posicao_x);
            tensao_cisalhamento_D_xy_ = tensao_cisalhamento_D_xy(posicao_x);

            tensao_principal_termo_D = sqrt((tensao_normal_D_ / 2)^2 + (tensao_cisalhamento_D_xy_)^2);
            tensao_principal_1_D_ = (tensao_normal_D_ / 2) + tensao_principal_termo_D;
            tensao_principal_2_D_ = (tensao_normal_D_ / 2) - tensao_principal_termo_D;
            tensao_principal_1_D(end+1) = tensao_principal_1_D_;
            tensao_principal_2_D(end+1) = tensao_principal_2_D_;

            # Tensao de cisalhamento máxima absoluta
            tensao_cisalhamento_max_abs_D_ = (max([tensao_principal_1_D_, tensao_principal_2_D_, 0]) - min([tensao_principal_1_D_, tensao_principal_2_D_, 0])) / 2;
            tensao_cisalhamento_max_abs_D(end+1) = tensao_cisalhamento_max_abs_D_;

            # Deformação normal
            deformacao_normal_D_x(end+1) = tensao_normal_D_ / E;
            deformacao_normal_D_y(end+1) = -v * tensao_normal_D_ / E;
            deformacao_normal_D_z(end+1) = -v * tensao_normal_D_ / E;
            # Deformação de cisalhamento
            deformacao_cisalhamento_D_xy(end+1) = tensao_cisalhamento_D_xy_ / G;
            deformacao_cisalhamento_D_yz(end+1) = 0; # não possuímos tau_yz
            deformacao_cisalhamento_D_zx(end+1) = 0; # é zerada
        endfor

        # Graficamos nossos resultados anteriores
        #
        # Ponto A

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_normal_A, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao normal no ponto A");
        xlabel("x [m]");
        ylabel("sigma(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_cisalhamento_A_xy, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento vertical no ponto A");
        xlabel("x [m]");
        ylabel("tau_xy(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_cisalhamento_A_xz, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento horizontal no ponto A");
        xlabel("x [m]");
        ylabel("tau_xz(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_principal_1_A, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao principal 1 no ponto A");
        xlabel("x [m]");
        ylabel("sigma_1(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_principal_2_A, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao principal 2 no ponto A");
        xlabel("x [m]");
        ylabel("sigma_2(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_cisalhamento_max_abs_A, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento maxima absoluta no ponto A");
        xlabel("x [m]");
        ylabel("tau_max(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(
            intervalo_grafico, deformacao_normal_A_x, "--;deformacao x;",
            intervalo_grafico, deformacao_normal_A_y, "-.;deformacao y;",
            intervalo_grafico, deformacao_normal_A_z, ":;deformacao z;"
        );
        grid on;
        set(gca, "fontsize", 12);
        title("Deformações normais no ponto A");
        xlabel("x [m]");
        ylabel("epsilon(x)");


        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(
            intervalo_grafico, deformacao_cisalhamento_A_xy, "--;deformacao xy;",
            intervalo_grafico, deformacao_cisalhamento_A_yz, "-.;deformacao yz;",
            intervalo_grafico, deformacao_cisalhamento_A_zx, ":;deformacao zx;"
        );
        grid on;
        set(gca, "fontsize", 12);
        title("Deformações de cisalhamento no ponto A");
        xlabel("x [m]");
        ylabel("gama(x)");


        # Ponto B
        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_normal_B, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao normal no ponto B");
        xlabel("x [m]");
        ylabel("sigma(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_cisalhamento_B_xy, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento vertical no ponto B");
        xlabel("x [m]");
        ylabel("tau_xy(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_cisalhamento_B_xz, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento horizontal no ponto B");
        xlabel("x [m]");
        ylabel("tau_xz(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_principal_1_B, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao principal 1 no ponto B");
        xlabel("x [m]");
        ylabel("sigma_1(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_principal_2_B, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao principal 2 no ponto B");
        xlabel("x [m]");
        ylabel("sigma_2(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_cisalhamento_max_abs_B, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento maxima absoluta no ponto B");
        xlabel("x [m]");
        ylabel("tau_max(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(
            intervalo_grafico, deformacao_normal_B_x, "--;deformacao x;",
            intervalo_grafico, deformacao_normal_B_y, "-.;deformacao y;",
            intervalo_grafico, deformacao_normal_B_z, ":;deformacao z;"
        );
        grid on;
        set(gca, "fontsize", 12);
        title("Deformações normais no ponto B");
        xlabel("x [m]");
        ylabel("epsilon(x)");


        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(
            intervalo_grafico, deformacao_cisalhamento_B_xy, "--;deformacao xy;",
            intervalo_grafico, deformacao_cisalhamento_B_yz, "-.;deformacao yz;",
            intervalo_grafico, deformacao_cisalhamento_B_zx, ":;deformacao zx;"
        );
        grid on;
        set(gca, "fontsize", 12);
        title("Deformações de cisalhamento no ponto B");
        xlabel("x [m]");
        ylabel("gama(x)");


        # Ponto C
        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_normal_C, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao normal no ponto C");
        xlabel("x [m]");
        ylabel("sigma(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_cisalhamento_C_xy, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento vertical no ponto C");
        xlabel("x [m]");
        ylabel("tau_xy(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_cisalhamento_C_xz, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento horizontal no ponto C");
        xlabel("x [m]");
        ylabel("tau_xz(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_principal_1_C, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao principal 1 no ponto C");
        xlabel("x [m]");
        ylabel("sigma_1(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_principal_2_C, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao principal 2 no ponto C");
        xlabel("x [m]");
        ylabel("sigma_2(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_cisalhamento_max_abs_C, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento maxima absoluta no ponto C");
        xlabel("x [m]");
        ylabel("tau_max(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(
            intervalo_grafico, deformacao_normal_C_x, "--;deformacao x;",
            intervalo_grafico, deformacao_normal_C_y, "-.;deformacao y;",
            intervalo_grafico, deformacao_normal_C_z, ":;deformacao z;"
        );
        grid on;
        set(gca, "fontsize", 12);
        title("Deformações normais no ponto C");
        xlabel("x [m]");
        ylabel("epsilon(x)");


        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(
            intervalo_grafico, deformacao_cisalhamento_C_xy, "--;deformacao xy;",
            intervalo_grafico, deformacao_cisalhamento_C_yz, "-.;deformacao yz;",
            intervalo_grafico, deformacao_cisalhamento_C_zx, ":;deformacao zx;"
        );
        grid on;
        set(gca, "fontsize", 12);
        title("Deformações de cisalhamento no ponto C");
        xlabel("x [m]");
        ylabel("gama(x)");


        # Ponto D
        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_normal_D, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao normal no ponto D");
        xlabel("x [m]");
        ylabel("sigma(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_cisalhamento_D_xy, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento vertical no ponto D");
        xlabel("x [m]");
        ylabel("tau_xy(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(tensao_cisalhamento_D_xz, [0, viga.width], "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento horizontal no ponto D");
        xlabel("x [m]");
        ylabel("tau_xz(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_principal_1_D, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao principal 1 no ponto D");
        xlabel("x [m]");
        ylabel("sigma_1(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_principal_2_D, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao principal 2 no ponto D");
        xlabel("x [m]");
        ylabel("sigma_2(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(intervalo_grafico, tensao_cisalhamento_max_abs_D, "color", [1, 0.106, 0.573]);
        grid on;
        set(gca, "fontsize", 12);
        title("Tensao de cisalhamento maxima absoluta no ponto D");
        xlabel("x [m]");
        ylabel("tau_max(x) [Pa]");

        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(
            intervalo_grafico, deformacao_normal_D_x, "--;deformacao x;",
            intervalo_grafico, deformacao_normal_D_y, "-.;deformacao y;",
            intervalo_grafico, deformacao_normal_D_z, ":;deformacao z;"
        );
        grid on;
        set(gca, "fontsize", 12);
        title("Deformações normais no ponto D");
        xlabel("x [m]");
        ylabel("epsilon(x)");


        figure(figura_atual);
        figura_atual = figura_atual + 1;
        plot(
            intervalo_grafico, deformacao_cisalhamento_D_xy, "--;deformacao xy;",
            intervalo_grafico, deformacao_cisalhamento_D_yz, "-.;deformacao yz;",
            intervalo_grafico, deformacao_cisalhamento_D_zx, ":;deformacao zx;"
        );
        grid on;
        set(gca, "fontsize", 12);
        title("Deformações de cisalhamento no ponto D");
        xlabel("x [m]");
        ylabel("gama(x)");

    endif

endfunction
