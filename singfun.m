# singfun - Função de singularidade
#
# Uso : funcao = singfun(grau, posicao, multiplicador (opcional));
#
# Forma: k*⟨x-a⟩^n
#
# Atributos:
# - degree: grau da função (n)
# - a: posicao da função (a)
# - multiplier: multiplicador da função (k)
#
# Métodos:
# - funcao(numero): retorna o valor da função com o x dado
# - integrate_noconst(funcao) / funcao.integrate_noconst(): retorna a integral da função sem constantes (retorna um objeto do tipo singfun)
# - integrate(funcao) / funcao.integrate(): retorna a integral da função e soma uma constante indefinida (retorna um objeto do tipo singfunsum)
# - copy(variável) / funcao.copy(): retorna uma cópia da função (funcao2 = funcao torna ambas dependentes uma da outra)
# - numero*funcao / funcao*numero: multiplica o multiplicador da função pelo número dado
# - funcao + funcao2: retorna um objeto do tipo singfunsum (soma de funções de singularidade) contendo ambas as funções
# - funcao - funcao2: retorna um objeto do tipo singfunsum (soma de funções de singularidade) contendo a primeira função e a negativa da segunda
# - plot(funcao, [inicio fim], ... ): plota o gráfico da função no intervalo dado

classdef singfun < handle

    properties
        degree = 0;
        a = 0;
        multiplier = 1;
    endproperties
    methods
        
        function s = singfun(degree, a, multiplier=1) 
            s.degree = degree;
            s.a = a;
            s.multiplier = multiplier;
        endfunction

        function disp(s) 
            if s.multiplier == 1
                printf("<x-%d>^%d\n", s.a, s.degree);
            else
                printf("%d*<x-%d>^%d\n", s.multiplier, s.a, s.degree);
            endif
        endfunction
        
        function r = subsref(s,index) 
            if (index(1).type == "()") || (index(1).type == "{}")
               x = index(1).subs{1};
               x_sign = 0;
               if (length(index(1).subs) == 2)
                   x_sign = index(1).subs{2};
               end
               if ((x < s.a) || ((x == s.a) && (x_sign == -1)))
                   r = 0;
               else
                   switch s.degree
                       case 2
                           r = (s.multiplier)*((x-(s.a))^2);
                       case 1
                           r = (s.multiplier)*((x-(s.a)));
                       case 0
                           r = s.multiplier;
                       case -1
                           if ((x == s.a) && (x_sign == 0))
                               r = inf;
                           else
                               r = 0;
                           endif
                       case -2
                           if (x == s.a) && (x_sign == 0)
                               r = NaN;
                           else
                               r = 0;
                           endif
                       otherwise
                           if (s.degree > 2)
                               r = (s.multiplier)*((x-(s.a))^(s.degree));
                           else
                               error("Degree out of range!");
                           endif
                   endswitch
               endif
            elseif (index(1).type == ".")
                     switch index(1).subs
                        case "integrate"
                            r = s.integrate();
                        case "integrate_noconst"
                            r = s.integrate_noconst();
                        case "copy"
                            r = s.copy();
                        case "degree"
                            r = s.degree;
                        case "multiplier"
                            r = s.multiplier;
                        case "a"
                            r = s.a;
                        otherwise
                            disp(index(1).subs);
                            error("Method or attribute not found");
                    endswitch               
            endif
        endfunction
        
        function r = mtimes(s, n) 
            if isa(s, "double")
                r = copy(n);
                r.multiplier *= s;
            else
                r = copy(s);
                r.multiplier *= n;
            endif
        endfunction
        
        function r = plus(s1, s2)
            s1cp = s1;
            s2cp = s2;
            if !isa(s1, "double")
                s1cp = copy(s1);
            endif
            if !isa(s2, "double")
                s2cp = copy(s2);
            endif
            if ((isa(s1cp, "singfun")) && (isa(s2cp, "singfun")))
                r = singfunsum(s1cp,s2cp);
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
            elseif ((isa(s1cp, "singfun")) && (isa(s2cp, "double")))
                r = singfunsum();
                r.addfun(s1cp);
                r.addpoly(s2cp);
            elseif ((isa(s1cp, "double")) && (isa(s2cp, "singfun")))
                r = singfunsum();
                r.addfun(s2cp);
                r.addpoly(s1cp);
            endif
        endfunction
        
        function r = uminus(s)
            r = copy(s);
            r.multiplier *= -1;
        endfunction

        function r = minus(s1, s2)
            s1cp = s1;
            s2cp = s2;
            if !isa(s1, "double")
                s1cp = copy(s1);
            endif
            if !isa(s2, "double")
                s2cp = copy(s2);
            endif
            if ((isa(s1cp, "singfun")) && (isa(s2cp, "singfun")))
                r = singfunsum(s1cp,-s2cp);
            elseif ((isa(s1cp, "singfunsum")) && (isa(s2cp, "singfun")))
                r = singfunsum();
                r.addfun(s1cp.functions);
                r.addpoly(s1cp.def_poly);
                r.addfun(-s2cp);
            elseif ((isa(s1cp, "singfun")) && (isa(s2cp, "singfunsum")))
                r = singfunsum();
                r.addfun(s1cp);
                r.addfun((-s2cp).functions);
                r.addpoly((-s2cp).def_poly);
            elseif ((isa(s1cp, "singfun")) && (isa(s2cp, "double")))
                r = singfunsum();
                r.addfun(s1cp);
                r.addpoly(-s2cp);
            elseif ((isa(s1cp, "double")) && (isa(s2cp, "singfun")))
                r = singfunsum();
                r.addfun(s2cp);
                r.addpoly(-s1cp);
            endif
        endfunction

        function s_copy = integrate_noconst(s) 
            s_copy = copy(s);
            switch s.degree
                case 2
                    s_copy.degree = 3;
                    s_copy.multiplier *= (1/3);
                case 1
                    s_copy.degree = 2;
                    s_copy.multiplier *= (1/2);
                case 0
                    s_copy.degree = 1;
                case -1
                    s_copy.degree = 0;
                case -2
                    s_copy.degree = -1;
                otherwise
                    if (s_copy.degree > 2)
                        s_copy.degree = s_copy.degree+1;
                        s_copy.multiplier *= (1/(s_copy.degree));
                    else
                        error("Function degree out of range");
                    endif
            endswitch
        endfunction

        function s_copy = integrate(s) 
            tmp = copy(s);
            tmp = integrate_noconst(tmp);
            s_copy = singfunsum();
            s_copy.addfun(tmp);
            s_copy.def_poly(end+1) = 0;
            s_copy.undef_poly(end+1) = NaN;
            
        endfunction

        function s_copy = copy(s) 
            s_copy = singfun(s.degree, s.a, s.multiplier);
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
