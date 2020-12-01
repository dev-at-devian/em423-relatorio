# singfunsum - Soma de funções de singularidade
#
# Uso :  = soma = singfun(funcao1, funcao2,...,funcaon);
#          soma = funcao1 + funcao2 + ... + funcaon;
#
# Forma: k1*⟨x-a1⟩^n1 + k2*⟨x-a2⟩^n2 + ... + kn*⟨x-an⟩^nn
#
# Atributos:
# - functions: funções que compõem a soma
# - def_poly: coeficientes do polinômio gerado pelas constantes definidas durante integrações
# - undef_poly: coeficientes do polinômio gerado pelas constantes ainda indefinidas durante integrações
#
# Métodos:
# - soma(numero): retorna o valor da soma com o x dado
# - soma{numero}: retorna a função presente no índice dado
# - integrate_noconst(soma) / soma.integrate_noconst(): retorna um singfunsum contendo a integral sem constantes de cada função da soma original
# - integrate(soma) / soma.integrate(): retorna a integral da soma + uma constante indefinida
# - setconst(soma,índice,valor) / soma.setconst(índice,valor): Define a constante do índice dado com o valor dado
# - defineconst(soma,valor_x,valor_y) / soma.defineconst(valor_x,valor_y): Se houver apenas uma constante, calcula e define seu valor com base no ponto soma(x/x+/x-) = y conhecido.
# - copy(soma) / soma.copy(): retorna uma cópia da função (soma2 = soma torna ambas dependentes uma da outra)
# - numero*soma / soma*numero: multiplica o multiplicador de cada função da soma pelo número dado
# - -soma: multiplica o multiplicador de cada função da soma por -1
# - soma + soma2: Retorna a combinação de ambas as somas
# - soma - soma2: Retorna a combinação da primeira soma e da negativa da segunda
# - soma + funcao / funcao + soma: Retorna a soma das funções da primeira soma mais a função dada
# - soma - funcao / funcao - soma: Retorna a soma das funções da primeira soma mais a negativa da função dada, e vice-versa
# - length(soma): retorna o número de termos da soma, incluindo coeficientes dos polinômios definidos e indefinidos não-nulos
# - plot(soma, [inicio fim], ... ): plota o gráfico da soma no intervalo dado

classdef singfunsum < handle

    properties
        functions = {};
        def_poly = [];
        undef_poly = [];
    endproperties
    methods

        function s = singfunsum(varargin)
            s.functions = varargin;
            s.def_poly = [];
            s.undef_poly = [];
        endfunction

        function r = addfun(s,func)
            if isa(func, "cell")
                s.functions = [s.functions, func];
            elseif isa(func, "singfun");
                s.functions{end+1} = func;
            endif
        endfunction

        function addpoly(s,poly)
            if isa(poly, "double")
                if length(poly) > 1
                    if length(s.def_poly) >= length(poly)
                        new_poly = zeros(1, (length(s.def_poly) - length(poly)));
                        new_poly = [new_poly poly];
                        s.def_poly = s.def_poly + new_poly;
                    else
                        new_poly = zeros(1, (length(poly) - length(s.def_poly)));
                        new_poly = [new_poly s.def_poly];
                        poly = poly + new_poly;
                        s.def_poly = poly;
                    endif
                    elseif length(poly) == 1
                    if length(s.def_poly) >= 1
                        s.def_poly(end) += poly;
                    else
                        s.def_poly(1) = poly;
                        s.undef_poly(1) = 0;
                    end
                endif
            endif
        endfunction

        function r = setconst(s, index, value)
            const_index = 0;
            for i = 1:length(s.undef_poly)
                if isnan(s.undef_poly(i))
                    if (++const_index) == index
                        s.def_poly(i) += value;
                        s.undef_poly(i) = 0;
                        r = value;
                    endif
                endif
            endfor
        endfunction

        function r = defineconst(s, x_val, s_val)
            x_sign = 0;
            if length(x_val) > 1
                x_sign = x_val(2);
                x_val = x_val(1);
            end
            calc_val = subsref(s, struct("type", "()", "subs", {{x_val x_sign}}));
            calc_val = s_val - (calc_val.def_poly);
            r = calc_val;
            setconst(s,1,calc_val);
        endfunction

        function disp(s)
            hasFunctions = false;
            hasDefPoly = false;
            if length(s.functions) > 0
                hasFunctions = true;
            end
            if length(find(s.def_poly)) > 0
                hasDefPoly = true;
            end
            for i = 1:length(s.functions)
                sf = s.functions{i};
                multip = sf.multiplier;
                if i > 1
                    if multip < 0
                        printf(" - ");
                    else
                        printf(" + ");
                    endif
                    multip = abs(multip);
                endif
                if multip == 1
                    printf("<x-%d>^%d", sf.a, sf.degree);
                else
                    printf("%d*<x-%d>^%d", multip, sf.a, sf.degree);
                endif
            endfor
            for i = 1:length(s.def_poly)
                deg = length(s.def_poly)-i;
                sp = s.def_poly(i);
                multip = sp;
                if multip != 0
                    if (((i > 1) && (length(find(s.def_poly)) > 1)) || (hasFunctions))
                        if multip < 0
                            printf(" - ");
                        else
                            printf(" + ");
                        endif
                        multip = abs(multip);
                    endif
                    if deg == 0
                        printf("%d", multip);
                    else
                        if multip == 1
                            printf("x^%d", deg);
                        else
                            printf("%d*x^%d", multip, deg);
                        endif
                    endif
                endif
            endfor
            used_consts = 0;
            for i = 1:length(s.undef_poly)
                deg = length(s.undef_poly)-i;
                sp = s.undef_poly(i);
                if ((isnan(sp)))
                    if (((i > 1) && (length(find(s.undef_poly))) > 1) || (hasDefPoly) || (hasFunctions))
                        printf(" + ");
                    endif
                    if deg == 0;
                        printf("C%d", ++used_consts);
                    else
                        printf("C%d*x^%d", ++used_consts, deg);
                    endif
                endif
            endfor
            printf("\n");
        endfunction

        function r = length(s)
            r = length(s.functions) + length(find(s.def_poly)) + length(find(s.undef_poly));
        endfunction

        function r = subsref(s,index)
            switch index(1).type
                case "()"
                    x = index(1).subs{1};
                    x_sign = 0;
                    if (length(index(1).subs) == 2)
                        x_sign = index(1).subs{2};
                    endif
                    r = 0;
                    for i = 1:length(s.functions)
                        r += s.functions{i}(x, x_sign);
                    endfor
                    r += polyval(s.def_poly, x);
                    if length(find(s.undef_poly)) > 0
                        new_s = singfunsum();
                        new_s.functions = {};
                        new_s.def_poly = [r];
                        new_s.undef_poly = s.undef_poly;
                        r = new_s;
                    end
                case "{}"
                    nonzero_defpoly = find(s.def_poly);
                    nonzero_undefpoly = find(s.undef_poly);
                    s_func_len = length(s.functions);
                    indx = index.subs{1};
                    if indx <= s_func_len
                        r = s.functions{indx};
                    elseif indx <= (s_func_len+length(nonzero_defpoly))
                        new_indx = indx - s_func_len;
                        r = singfunsum();
                        new_poly = zeros(1, length(s.def_poly));
                        new_poly(nonzero_defpoly(new_indx)) = s.def_poly(new_indx);
                        r.def_poly = new_poly;
                        r.undef_poly = zeros(1,length(new_poly));
                    elseif indx <= (s_func_len+length(nonzero_defpoly)+length(nonzero_undefpoly))
                        new_indx = indx - s_func_len - length(nonzero_defpoly);
                        r = singfunsum();
                        new_poly = zeros(1, length(s.undef_poly));
                        new_poly(nonzero_undefpoly(new_indx)) = s.undef_poly(nonzero_undefpoly(new_indx));
                        r.def_poly = zeros(1,length(new_poly));
                        r.undef_poly = new_poly;
                    else
                        error(sprintf("out of bound %d"), indx);
                    endif
                otherwise
                    switch index(1).subs
                        case "setconst"
                            f_args = index(2).subs;
                            s.setconst(f_args{1}, f_args{2});
                        case "integrate"
                            r = s.integrate();
                        case "integrate_noconst"
                            r = s.integrate();
                        case "addfun"
                            s.addfun(index(2).subs{1});
                        case "addpoly"
                            s.addpoly(index(2).subs{1});
                        case "copy"
                            r = s.copy();
                        case "functions"
                            r = s.functions;
                        case "def_poly"
                            r = s.def_poly;
                        case "undef_poly"
                            r = s.undef_poly;
                        otherwise
                            error("Method or attribute not found");
                    endswitch

            endswitch
        endfunction

        function r = mtimes(s, n)
            if isa(s, "double")
                r = copy(n);
                for i = 1:length(r.functions)
                    r.functions{i}.multiplier *= s;
                endfor
                for i = 1:length(r.def_poly)
                    r.def_poly(i) *= s;
                endfor
            else
                r = copy(s);
                for i = 1:length(r.functions)
                    r.functions{i}.multiplier *= n;
                endfor
                for i = 1:length(r.def_poly)
                    r.def_poly(i) *= n;
                endfor
            endif
        endfunction

        function r = plus(s1, s2)
            s1cp = s1;
            s2cp = s2;
            if !isa(s1cp, "double")
                s1cp = copy(s1);
            endif
            if !isa(s2cp, "double")
                s2cp = copy(s2);
            endif
            if ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addfun(s2cp.functions);
                r.addpoly(s1cp.def_poly);
                r.addpoly(s2cp.def_poly);
            elseif ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfun")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addpoly(s1cp.def_poly);
                r.addfun(s2cp);
            elseif ((isa(s1cp, "singfun")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp);
                r.addfun(s2cp.functions);
                r.addpoly(s2cp.def_poly);
            elseif ((isa(s1cp, "singfunsum")) && (isa(s2cp, "double")))
                r = copy(s1cp);
                r.addpoly(s2cp);
            elseif ((isa(s1cp, "double")) && (isa(s2cp, "singfunsum")))
                r = copy(s2cp);
                r.addpoly(s1cp);
            endif
        endfunction

        function r = uminus(s)
            r = copy(s);
            for i = 1:length(r.functions)
                r.functions{i}.multiplier *= -1;
            end
            for i = 1:length(r.def_poly)
                r.def_poly(i) *= -1;
            end
        endfunction

        function r = minus(s1, s2)
            s1cp = s1;
            s2cp = s2;
            if !isa(s1cp, "double")
                s1cp = copy(s1);
            endif
            if !isa(s2cp, "double")
                s2cp = copy(s2);
            endif
            if ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addfun((-s2cp).functions);
            elseif ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfun")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addpoly(s1cp.def_poly);
                r.addfun((-s2cp));
            elseif ((isa(s1cp, "singfun")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp);
                r.addfun((-s2cp).functions);
                r.addpoly((-s2cp).def_poly);
            elseif ((isa(s1cp, "singfunsum")) && (isa(s2cp, "double")))
                r = copy(s1cp);
                r.addpoly(-s2cp);
            elseif ((isa(s1cp, "double")) && (isa(s2cp, "singfunsum")))
                r = copy(s2cp);
                r.addpoly(-s1cp);
            endif
        endfunction

        function s_copy = integrate(s)
            s_copy = copy(s);
            for i = 1:length(s_copy.functions)
                s_copy.functions{i} = s_copy.functions{i}.integrate_noconst();
            endfor
            if length(s_copy.undef_poly) == 0
                s_copy.undef_poly(end+1) = NaN;
                s_copy.def_poly(end+1) = 0;
            else
                s_copy.def_poly = polyint(s_copy.def_poly);
                s_copy.undef_poly = polyint(s_copy.undef_poly);
                s_copy.undef_poly(end) = NaN;
            endif
        endfunction

        function s_copy = integrate_noconst(s)
            s_copy = copy(s);
            for i = 1:length(s_copy.functions)
                s_copy.functions{i} = s_copy.functions{i}.integrate_noconst();
            endfor
        endfunction

        function s_copy = copy(s)
            s_copy = singfunsum();
            for i = 1:length(s.functions)
                s_copy.addfun(copy(s.functions{i}));
            endfor
            s_copy.def_poly = s.def_poly;
            s_copy.undef_poly = s.undef_poly;
        endfunction

        function h = plot (s, rng, varargin)
            x = [rng(1) : ((rng(2)-rng(1))/100) : rng(2)];
            y = [];
            for i = 1:length(x)
                y(end+1) = subsref(s, struct("type", "()", "subs", {{x(i)}}));
            endfor
            h = plot(x, y, varargin{:});
        endfunction

    endmethods

endclassdef
