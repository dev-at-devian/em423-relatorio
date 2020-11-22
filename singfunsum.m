% singfunsum - Soma de funções de singularidade
%
% Uso :  = soma = singfun(funcao1, funcao2,...,funcaon);
%          soma = funcao1 + funcao2 + ... + funcaon;
%
% Forma: k1*⟨x-a1⟩^n1 + k2*⟨x-a2⟩^n2 + ... + kn*⟨x-an⟩^nn
%
% Atributos:
% - functions: funções que compõem a soma
%
% Métodos:
% - soma(numero): retorna o valor da soma com o x dado
% - soma{numero}: retorna a função presente no índice dado
% - integrate(soma) / soma.integrate(): retorna a integral da soma (não modifica a original)
% - copy(soma) / soma.copy(): retorna uma cópia da função (soma2 = soma torna ambas dependentes uma da outra)
% - numero*soma / soma*numero: multiplica o multiplicador de cada função da soma pelo número dado
% - soma + soma2: Retorna a combinação de ambas as somas
% - soma + funcao / funcao + soma: Retorna a soma das funções da primeira soma mais a função dada
% - plot(variavel, [inicio fim], ... ): plota o gráfico da soma no intervalo dado
classdef singfunsum < handle

    properties
        functions = {};
    endproperties
    methods
        
        function s = singfunsum(varargin) 
            s.functions = varargin;
        endfunction

        function r = addfun(s,func) 
            if isa(func, "cell")
                s.functions = [s.functions, func];
            elseif isa(func, "singfun");
                s.functions{end+1} = func;
            endif
        endfunction

        function disp(s) 
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
                if sf.multiplier == 1
                    printf("<x-%d>^%d", sf.a, sf.degree);
                else
                    printf("%d*<x-%d>^%d", multip, sf.a, sf.degree);
                endif
            endfor
            printf("\n");
        endfunction
        
        function r = length(s)
            r = length(s.functions);
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
                case "{}"
                    r = s.functions{index.subs{1}};
                otherwise
                    switch index(1).subs
                        case "integrate"
                            s.integrate();
                        case "copy"
                            s.copy();
                        case "functions"
                            r = s.functions;
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
            else
                r = copy(s);
                for i = 1:length(r.functions)
                    r.functions{i}.multiplier *= n;
                endfor
            endif
        endfunction
       
        function r = plus(s1, s2)
            s1cp = copy(s1);
            s2cp = copy(s2);
            if ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addfun(s2cp.functions);
            elseif ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfun")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addfun(s2cp);
            elseif ((isa(s1cp, "singfun")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp);
                r.addfun(s2cp.functions);
            endif
        endfunction

        function r = uminus(s) 
            r = copy(s);
            for i = 1:length(r.functions)
                r.functions{i}.multiplier *= -1;
            end
        endfunction
       
        function r = minus(s1, s2)
            s1cp = copy(s1);
            s2cp = copy(s2);
            if ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addfun((-s2cp).functions);
            elseif ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfun")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addfun((-s2cp));
            elseif ((isa(s1cp, "singfun")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp);
                r.addfun((-s2cp).functions);
            endif
        endfunction

        function s_copy = integrate(s) 
            s_copy = copy(s);
            for i = 1:length(s_copy.functions)
                s_copy.functions{i} = s_copy.functions{i}.integrate();
            endfor
        endfunction

        function s_copy = copy(s) 
            s_copy = singfunsum();
            for i = 1:length(s.functions)
                s_copy.addfun(copy(s.functions{i}));
            endfor
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
