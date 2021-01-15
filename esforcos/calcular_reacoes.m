function apoios = calcular_reacoes()
    global viga;
    global apoios;
    global singfun_carregamentos;
    global singfun_forcas_x;
    global singfun_torques;
    global program_logger;

    # Pegamos as forças definidas em y e momentos
    forcas_y_momentos = singfunsum();
    for i = 1:length(singfun_carregamentos)
        forcas_y_momentos = forcas_y_momentos + singfun_carregamentos{i};
    endfor

    # Pegamos a equação de forças cortantes (integral das forças verticais)
    forcas_cortantes = integrate_noconst(forcas_y_momentos);
    # Pegamos a equação dos momentos internos
    momentos_internos = integrate_noconst(forcas_cortantes);

    # Sabemos que tanto as forças cortantes quanto os momentos internos são zero a esquerda do
    # início da viga e a direita do fim
    # Então teremos 4 equações para determinar tanto as forças de reação verticais quanto momentos dos apoios

    # Determinamos quais incógnitas temos

    program_logger.write_string("\\section*{Equações}\n");
    program_logger.write_string("\\subsection*{Equação das forças verticais e momentos externos}\n");

    program_logger.write_string("\\[{\\scriptstyle q(x) = ");

    incognitas_momentos = {};
    apoio_incognitas_momentos = {};
    incognitas_forcas_y = {};
    apoio_incognitas_forcas_y = {};
    for i = 1:length(apoios)
        if !isnan(apoios{i}.momentum)
            momento = singfun(-2, apoios{i}.position);
            incognitas_momentos{end+1} = momento;
            apoio_incognitas_momentos{end+1} = i;
            program_logger.write_string(sprintf("M{\\langle x-%d \\rangle}^{%d} + ", apoios{i}.position, -2));
        endif
        if !isnan(apoios{i}.vertical)
            reacao_y = singfun(-1, apoios{i}.position);
            incognitas_forcas_y{end+1} = reacao_y;
            apoio_incognitas_forcas_y{end+1} = i;
            program_logger.write_string(sprintf("Fy{\\langle x-%d \\rangle}^{%d} + ", apoios{i}.position, -1));
        endif
    endfor
    
    program_logger.write_string(program_logger.string_form(forcas_y_momentos));
    program_logger.write_string("}\\]");

    n_incognitas = length(incognitas_momentos) + length(incognitas_forcas_y);

    # As incógnitas aparecem nas forças cortantes integradas uma vez e aparecem nos momentos
    # integradas duas vezes, não precisaremos de constante pois estamos integrando apenas um único
    # termo da função singular

    # O sistema linear terá 4 linhas pois temos 2 para cada posição (antes da viga, depois da viga)
    # Nas 2 equações, uma será a de força cortante e outra de momento interno
    A = zeros(4, n_incognitas);
    B = zeros(4, 1);

    # Começamos avaliando as funções antes do início da viga (com as incógnitas, deve ser zero)
    cortantes_antes_viga = forcas_cortantes(0, -1);
    momentos_int_antes_viga = momentos_internos(0, -1);
    # e, agora, depois da viga (também deve ser zero com as incógnitas)
    cortantes_depois_viga = forcas_cortantes(viga.width, +1);
    momentos_int_depois_viga = momentos_internos(viga.width, +1);

    # Adicionamos cada equação ao vetor de respostas do sist. linear (passando a direita, trocamos
    # o sinal)
    B(1) = -cortantes_antes_viga;
    B(2) = -momentos_int_antes_viga;
    B(3) = -cortantes_depois_viga;
    B(4) = -momentos_int_depois_viga;

    # Agora adicionamos cada incógnita na sua respectiva coluna para cada equação
    coluna_atual = 1;
    for i = 1:length(incognitas_momentos)
        # Integramos duas vezes para participar corretamente da eq. de momento interno
        incogn_integrada = integrate_noconst(integrate_noconst(incognitas_momentos{i}));
        # Calculamos a sua participação na eq. de momento interno antes da viga
        coeficiente_momento_int = incogn_integrada(0, -1);
        # Adicionamos no sistema linear na eq. de momento antes da viga (segunda linha de A)
        A(2, coluna_atual) = coeficiente_momento_int;

        # Calculamos a sua participação na eq. de momento interno depois da viga
        coeficiente_momento_int = incogn_integrada(viga.width, +1);
        # Adicionamos no sistema linear na eq. de momento depois da viga (quarta linha de A)
        A(4, coluna_atual) = coeficiente_momento_int;

        # Integramos uma vez pra participar corretamente da eq. de forças cortantes
        incogn_integrada = integrate_noconst(incognitas_momentos{i});
        # Calculamos sua participação na eq. de forças cortantes antes da viga
        coeficiente_cortantes = incogn_integrada(0, -1);
        # Adicionamos no sistema linear na eq. de forças cortantes antes da viga (primeira linha de A)
        A(1, coluna_atual) = coeficiente_cortantes;

        # Calculamos sua participação na eq. de forças cortantes depois da viga
        coeficiente_cortantes = incogn_integrada(viga.width, -1);
        # Adicionamos no sistema linear na eq. de forças cortantes depois da viga (terceira linha de A)
        A(3, coluna_atual) = coeficiente_cortantes;

        # Quando acabarmos de adicionar, passamos para a próxima incógnita
        coluna_atual += 1;
    endfor

        #
        # FORÇAS CORTANTES
        #
        program_logger.write_string("\\subsection*{Equação das forças cortantes}\n");
        program_logger.write_string("\\[{\\scriptstyle V(x) = \\int_{}^{} q(x) \\,dx }\\]");
        program_logger.write_string("\\[{\\scriptstyle V(x) = ");
        if (length(incognitas_momentos) > 0)
            im_int = integrate_noconst(incognitas_momentos{i});
            program_logger.write_string(sprintf("M{\\langle x-%d \\rangle}^{%d} + ", im_int.a, im_int.degree));
        endif
        if (length(incognitas_forcas_y) > 0)
            ify_int = integrate_noconst(incognitas_forcas_y{i});
            program_logger.write_string(sprintf("Fy{\\langle x-%d \\rangle}^{%d} + ", ify_int.a, ify_int.degree));
        endif

        program_logger.write_string(program_logger.string_form(forcas_cortantes));
        program_logger.write_string("}\\]");


        #
        # MOMENTOS INTERNOS
        #
        program_logger.write_string("\\subsection*{Equação dos momentos internos}\n");
        program_logger.write_string("\\[{\\scriptstyle M(x) = \\int_{}^{} V(x) \\,dx }\\]");
        program_logger.write_string("\\[{\\scriptstyle M(x) = ");
        if (length(incognitas_momentos) > 0)
            im_int = integrate_noconst(integrate_noconst(incognitas_momentos{i}));
            program_logger.write_string(sprintf("M{\\langle x-%d \\rangle}^{%d} + ", im_int.a, im_int.degree));
        endif
        if (length(incognitas_forcas_y) > 0)
            ify_int = integrate_noconst(integrate_noconst(incognitas_forcas_y{i}));
            program_logger.write_string(sprintf("Fy{\\langle x-%d \\rangle}^{%d} + ", ify_int.a, ify_int.degree));
        endif

        program_logger.write_string(program_logger.string_form(momentos_internos));
        program_logger.write_string("}\\]");


        #
        # REAÇÕES DE APOIO
        #
        program_logger.write_string("\\subsection*{Reações de apoio}\n");
        end_val = sprintf("%d^{+}", viga.width);
        program_logger.write_string(sprintf("\\[{\\scriptstyle V(%s) = ", end_val));
        if (length(incognitas_momentos) > 0)
            im_int = integrate_noconst(incognitas_momentos{i});
            program_logger.write_string(sprintf("M{\\langle %s-%d \\rangle}^{%d} + ", end_val, im_int.a, im_int.degree));
        endif
        if (length(incognitas_forcas_y) > 0)
            ify_int = integrate_noconst(incognitas_forcas_y{i});
            program_logger.write_string(sprintf("Fy{\\langle %s-%d \\rangle}^{%d} + ", end_val, ify_int.a, ify_int.degree));
        endif

        program_logger.write_string(program_logger.string_form_evaluated(forcas_cortantes, end_val));
        program_logger.write_string(" = 0}\\]");
        program_logger.write_string(sprintf("\\[{\\scriptstyle V(%s) = ", end_val));
        if (length(incognitas_momentos) > 0)
            im_int = integrate_noconst(incognitas_momentos{i});
            program_logger.write_string(sprintf("M \\cdot %d + ", im_int(viga.width, +1)));
        endif
        if (length(incognitas_forcas_y) > 0)
            ify_int = integrate_noconst(incognitas_forcas_y{i});
            program_logger.write_string(sprintf("Fy \\cdot %d + ", ify_int(viga.width, +1)));
        endif

        program_logger.write_string(sprintf("%d ", forcas_cortantes(viga.width, +1)));
        program_logger.write_string(" = 0}\\]");

        program_logger.write_string(sprintf("\\[{\\scriptstyle M(%s) = ", end_val));
        if (length(incognitas_momentos) > 0)
            im_int = integrate_noconst(integrate_noconst(incognitas_momentos{i}));
            program_logger.write_string(sprintf("M{\\langle %s-%d \\rangle}^{%d} + ", end_val, im_int.a, im_int.degree));
        endif
        if (length(incognitas_forcas_y) > 0)
            ify_int = integrate_noconst(integrate_noconst(incognitas_forcas_y{i}));
            program_logger.write_string(sprintf("Fy{\\langle %s-%d \\rangle}^{%d} + ", end_val, ify_int.a, ify_int.degree));
        endif

        program_logger.write_string(program_logger.string_form_evaluated(momentos_internos, end_val));
        program_logger.write_string(" = 0}\\]");
        program_logger.write_string(sprintf("\\[{\\scriptstyle M(%s) = ", end_val));
        if (length(incognitas_momentos) > 0)
            im_int = integrate_noconst(integrate_noconst(incognitas_momentos{i}));
            program_logger.write_string(sprintf("M \\cdot %d + ", im_int(viga.width, +1)));
        endif
        if (length(incognitas_forcas_y) > 0)
            ify_int = integrate_noconst(integrate_noconst(incognitas_forcas_y{i}));
            program_logger.write_string(sprintf("Fy \\cdot %d + ", ify_int(viga.width, +1)));
        endif

        program_logger.write_string(sprintf("%d ", momentos_internos(viga.width, +1)));
        program_logger.write_string(" = 0}\\]");




    for i = 1:length(incognitas_forcas_y)
        # Integramos uma vez para participar corretamente da eq. de forças cortantes
        incogn_integrada = integrate_noconst(incognitas_forcas_y{i});
        # Calculamos a sua participação na eq. de forças cortantes antes da viga
        coeficiente_cortantes = incogn_integrada(0, -1);
        # Adicionamos no sistema linear na eq. de forças cortantes antes da viga (primeira linha de A)
        A(1, coluna_atual) = coeficiente_cortantes;

        # Calculamos a sua participação na eq. de forças cortantes depois da viga
        coeficiente_cortantes = incogn_integrada(viga.width, +1);
        # Adicionamos no sistema linear na eq. de forças cortantes depois da viga (terceira linha de A)
        A(3, coluna_atual) = coeficiente_cortantes;

        # Integramos duas vezes para participar corretamente da eq. de momento interno
        incogn_integrada = integrate_noconst(integrate_noconst(incognitas_forcas_y{i}));
        # Calculamos a sua participação na eq. de momento interno antes da viga
        coeficiente_momento_int = incogn_integrada(0, -1);
        # Adicionamos no sistema linear na eq. de momento antes da viga (segunda linha de A)
        A(2, coluna_atual) = coeficiente_momento_int;

        # Calculamos a sua participação na eq. de momento interno depois da viga
        coeficiente_momento_int = incogn_integrada(viga.width, +1);
        # Adicionamos no sistema linear na eq. de momento depois da viga (quarta linha de A)
        A(4, coluna_atual) = coeficiente_momento_int;

        # Quando acabarmos de adicionar, passamos para a próxima incógnita
        coluna_atual += 1;
    endfor

    x = linsolve(A, B);

    # Agora voltamos às colunas da matriz para pegar as respostas e adicionar as novas forças na
    # matriz
    coluna_atual = 1;
    for i = 1:length(incognitas_momentos)
        incog = incognitas_momentos{i};
        # Adicionamos a resposta à função de singularidade da reação
        incog.multiplier = x(coluna_atual);
        program_logger.write_string(sprintf("\\[{\\scriptstyle M = %d }\\]\n", incog.multiplier));
        # Adicionamos a função de singularidade da reação à lista de forças verticais (momentos são
        # inclusos)
        singfun_carregamentos{end+1} = incog;
        # Além disso, definimos a reação no apoio
        apoios{apoio_incognitas_momentos{i}}.momentum = x(coluna_atual);

        # Passamos para a próxima incógnita
        coluna_atual += 1;
    endfor

    for i = 1:length(incognitas_forcas_y)
        incog = incognitas_forcas_y{i};
        # Adicionamos a resposta à função de singularidade da reação
        incog.multiplier = x(coluna_atual);
        program_logger.write_string(sprintf("\\[{\\scriptstyle Fy = %d }\\]\n", incog.multiplier));
        # Adicionamos a função de singularidade da reação à lista de forças verticais
        singfun_carregamentos{end+1} = incog;
        # Além disso, definimos a reação no apoio
        apoios{apoio_incognitas_forcas_y{i}}.vertical = x(coluna_atual);

        # Passamos para a próxima incógnita
        coluna_atual += 1;
    endfor


    # Agora fazemos a mesma coisa com as forças horizontais e normais

    # Pegamos as forças definidas em x
    forcas_x = singfunsum();
    for i = 1:length(singfun_forcas_x)
        forcas_x = forcas_x + singfun_forcas_x{i};
    endfor

    # Pegamos a equação de forças normais (integral das forças horizontais)
    forcas_normais = integrate_noconst(forcas_x);

    # Sabemos que as forças normais são zero a esquerda do início da viga e a direita do fim também
    # Teremos 2 equações para calcular as forças de reação dos apoios

    program_logger.write_string("\\subsection*{Equação das forças horizontais}\n");
    program_logger.write_string("\\[{\\scriptstyle f(x) = ");

    # Determinamos quantas incógnitas teremos
    incognitas_forcas_x = {};
    apoio_incognitas_forcas_x = {};
    for i = 1:length(apoios)
        if !isnan(apoios{i}.horizontal)
            reacao_x = singfun(-1, apoios{i}.position);
            incognitas_forcas_x{end+1} = reacao_x;
            apoio_incognitas_forcas_x{end+1} = i;
            program_logger.write_string(sprintf("Fx{\\langle x-%d \\rangle}^{%d} + ", apoios{i}.position, -1));
        endif
    endfor
    n_incognitas = length(incognitas_forcas_x);

    program_logger.write_string(program_logger.string_form(forcas_x));
    program_logger.write_string("}\\]");

    # As incógnitas serão resolvidas nas duas equações de forças normais, então vamos preparar as
    # matrizes para solução do sistema lienar
    A = zeros(2, n_incognitas);
    B = zeros(2, 1);

    # Colocamos as respostas das forças normais calculadas em cada canto da viga
    B(1) = -forcas_normais(0, -1);
    B(2) = -forcas_normais(viga.width, +1);

    # Colocamos cada incognita em uma coluna de A
    coluna_atual = 1;
    for i = 1:length(incognitas_forcas_x)
        # Integramos para verificar sua participação na eq. de forças normais
        incogn_integrada = integrate_noconst(incognitas_forcas_x{i});
        # Calculamos seu coeficiente na eq. de forças normais antes da viga
        coeficiente_normal = incogn_integrada(0, -1);
        # Adicionamos na linha da matriz de incógnitas respectiva às forças normais antes da viga
        A(1, coluna_atual) = coeficiente_normal;

        # Calculamos seu coeficiente na eq. de forças normais depois da viga
        coeficiente_normal = incogn_integrada(viga.width, +1);
        # Adicionamos na linha da matriz de incógnitas respectiva às forças normais depois da viga
        A(2, coluna_atual) = coeficiente_normal;

        # Vamos para a próxima incógnita
        coluna_atual += 1;
    endfor

    # Resolvemos o sistema linear
    x = linsolve(A, B);


    #
    # FORÇAS NORMAIS
    #
    program_logger.write_string("\\subsection*{Equação das forças normais}\n");
    program_logger.write_string("\\[{\\scriptstyle N(x) = \\int_{}^{} f(x) \\,dx }\\]");
    program_logger.write_string("\\[{\\scriptstyle N(x) = ");
    if (length(incognitas_forcas_x) > 0)
        ifx_int = integrate_noconst(incognitas_forcas_x{i});
        program_logger.write_string(sprintf("Fx{\\langle x-%d \\rangle}^{%d} + ", ifx_int.a, ifx_int.degree));
    endif

    program_logger.write_string(program_logger.string_form(forcas_normais));
    program_logger.write_string("}\\]");

    #
    # REAÇÕES DE APOIO
    #
    program_logger.write_string("\\subsection*{Reações de apoio}\n");
    end_val = sprintf("%d^{+}", viga.width);
    program_logger.write_string(sprintf("\\[{\\scriptstyle N(%s) = ", end_val));

    if (length(incognitas_forcas_x) > 0)
        ifx_int = integrate_noconst(incognitas_forcas_x{i});
        program_logger.write_string(sprintf("Fx{\\langle %s-%d \\rangle}^{%d} + ", end_val, ifx_int.a, ifx_int.degree));
    endif

    program_logger.write_string(program_logger.string_form_evaluated(forcas_normais, end_val));
    program_logger.write_string(" = 0}\\]");
    program_logger.write_string(sprintf("\\[{\\scriptstyle N(%s) = ", end_val));
    if (length(incognitas_forcas_x) > 0)
        ifx_int = integrate_noconst(incognitas_forcas_x{i});
        program_logger.write_string(sprintf("Fx \\cdot %d + ", ifx_int(viga.width, +1)));
    endif

    program_logger.write_string(sprintf("%d ", forcas_normais(viga.width, +1)));
    program_logger.write_string(" = 0}\\]");


    # Colocamos a resposta na lista de forças e ainda ao suporte
    coluna_atual = 1;
    for i = 1:length(incognitas_forcas_x)
        incog = incognitas_forcas_x{i};
        # Adicionamos a resposta à função de singularidade da reação
        incog.multiplier = x(coluna_atual);
        program_logger.write_string(sprintf("\\[{\\scriptstyle Fx = %d }\\]\n", incog.multiplier));
        # Adicionamos a função de singularidade da reação à lista de forças horizontais
        singfun_forcas_x{end+1} = incog;
        # Além disso, definimos a reação no apoio
        apoios{apoio_incognitas_forcas_x{i}}.horizontal = x(coluna_atual);

        # Passamos para a próxima incógnita
        coluna_atual += 1;
    endfor


    # Agora fazemos a mesma coisa com torques

    # Pegamos os torques
    torques = singfunsum();
    for i = 1:length(singfun_torques)
        torques = torques + singfun_torques{i};
    endfor

    # Pegamos a equação de torques internos (integral dos torques externos)
    torques_internos = integrate_noconst(torques);

    # Sabemos que o torque interno é zero a esquerda do início da viga e a direita do fim da viga
    # Teremos 2 equações para calcular os torques de reação dos apoios

    program_logger.write_string("\\subsection*{Equação dos torques}\n");
    program_logger.write_string("\\[{\\scriptstyle t(x) = ");

    # Determinamos quantas incógnitas teremos
    incognitas_torques = {};
    apoio_incognitas_torques = {};
    for i = 1:length(apoios)
        if !isnan(apoios{i}.torque)
            reacao_torque = singfun(-1, apoios{i}.position);
            incognitas_torques{end+1} = reacao_torque;
            apoio_incognitas_torques{end+1} = i;
            program_logger.write_string(sprintf("T{\\langle x-%d \\rangle}^{%d} + ", apoios{i}.position, -1));
        endif
    endfor
    n_incognitas = length(incognitas_torques);

    program_logger.write_string(program_logger.string_form(torques));
    program_logger.write_string("}\\]");

    # As incógnitas serão resolvidas nas duas equações de torques internos, então vamos preparar as
    # matrizes para solução do sistema lienar
    A = zeros(2, n_incognitas);
    B = zeros(2, 1);

    # Colocamos as respostas dos torques internos calculadas em cada canto da viga
    B(1) = -torques_internos(0, -1);
    B(2) = -torques_internos(viga.width, +1);

    # Colocamos cada incognita em uma coluna de A
    coluna_atual = 1;
    for i = 1:length(incognitas_torques)
        # Integramos para verificar sua participação na eq. de torque interno
        incogn_integrada = integrate_noconst(incognitas_torques{i});
        # Calculamos seu coeficiente na eq. de torque interno antes da viga
        coeficiente_torque = incogn_integrada(0, -1);
        # Adicionamos na linha da matriz de incógnitas respectiva ao torque interno antes da viga
        A(1, coluna_atual) = coeficiente_torque;

        # Calculamos seu coeficiente na eq. de torque interno depois da viga
        coeficiente_torque = incogn_integrada(viga.width, +1);
        # Adicionamos na linha da matriz de incógnitas respectiva ao torque interno depois da viga
        A(2, coluna_atual) = coeficiente_torque;

        # Vamos para a próxima incógnita
        coluna_atual += 1;
    endfor

    # Resolvemos o sistema linear
    x = linsolve(A, B);

    #
    # TORQUES INTERNOS
    #
    program_logger.write_string("\\subsection*{Equação dos torques internos}\n");
    program_logger.write_string("\\[{\\scriptstyle T(x) = \\int_{}^{} t(x) \\,dx }\\]");
    program_logger.write_string("\\[{\\scriptstyle T(x) = ");
    if (length(incognitas_torques) > 0)
        it_int = integrate_noconst(incognitas_torques{i});
        program_logger.write_string(sprintf("T{\\langle x-%d \\rangle}^{%d} + ", it_int.a, it_int.degree));
    endif

    program_logger.write_string(program_logger.string_form(torques_internos));
    program_logger.write_string("}\\]");

    #
    # REAÇÕES DE APOIO
    #
    program_logger.write_string("\\subsection*{Reações de apoio}\n");
    end_val = sprintf("%d^{+}", viga.width);
    program_logger.write_string(sprintf("\\[{\\scriptstyle T(%s) = ", end_val));

    if (length(incognitas_torques) > 0)
        it_int = integrate_noconst(incognitas_torques{i});
        program_logger.write_string(sprintf("T{\\langle %s-%d \\rangle}^{%d} + ", end_val, it_int.a, it_int.degree));
    endif

    program_logger.write_string(program_logger.string_form_evaluated(torques_internos, end_val));
    program_logger.write_string(" = 0}\\]");
    program_logger.write_string(sprintf("\\[{\\scriptstyle T(%s) = ", end_val));
    if (length(incognitas_torques) > 0)
        it_int = integrate_noconst(incognitas_torques{i});
        program_logger.write_string(sprintf("T \\cdot %d + ", it_int(viga.width, +1)));
    endif

    program_logger.write_string(sprintf("%d ", torques_internos(viga.width, +1)));
    program_logger.write_string(" = 0}\\]");




    # Colocamos a resposta na lista de torques e ainda ao suporte
    coluna_atual = 1;
    for i = 1:length(incognitas_torques)
        incog = incognitas_torques{i};
        # Adicionamos a resposta à função de singularidade da reação
        incog.multiplier = x(coluna_atual);
        program_logger.write_string(sprintf("\\[{\\scriptstyle T = %d }\\]\n", incog.multiplier));
        # Adicionamos a função de singularidade da reação à lista de torques externos
        singfun_torques{end+1} = incog;
        # Além disso, definimos a reação no apoio
        apoios{apoio_incognitas_torques{i}}.torque = x(coluna_atual);

        # Passamos para a próxima incógnita
        coluna_atual += 1;
    endfor

endfunction
