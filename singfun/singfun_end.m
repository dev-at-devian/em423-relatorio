function ss = singfun_end(s, ending)
    ss = singfunsum();
    ss = ss + s;
    ss = ss + singfun(s.degree, ending, -(s.multiplier));
    if (s.degree >= 1)
        ss = ss + singfun(0, ending, -ss(ending));
        A = zeros(s.degree-1, s.degree-1);
        B = zeros(s.degree-1,1);
        for i = 1:(s.degree-1)
            sample_val = ss(ending+i);
            for j = 1:(s.degree-1)
                A(i,j) = (i)^(j);
            end
            B(i) = sample_val;
        end
        disp(A);
        disp(B);
        result = A\B;
        for i = 1:length(result)
            ss = ss + singfun(i,ending,-result(i));
        end
    end
endfunction
