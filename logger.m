classdef logger
    properties
        file_name = "log.tex"
        file_object
    endproperties

    methods

        function l = logger(file_name)
            l.file_name = file_name;
            l.file_object = fopen(file_name, "w");
        endfunction

        function close_file(l)
            fclose(l.file_object);
        endfunction

        function write_header(l)
            fputs(l.file_object, "\\documentclass[10pt]{article}\n\\usepackage{listings}\n\\usepackage{amsmath}\n\\usepackage{graphicx}\n\\usepackage{cases}\n\\usepackage{framed}\n\\usepackage{xcolor}\n\\graphicspath{{./img/}}\n\\usepackage[a4paper, margin=1in]{geometry}\n\\date{}\n\\newcommand{\\norm}[1]{\\left\\lVert#1\\right\\rVert}\n\\begin{document}\n\\title{Log do Programa}\n\\author{}\n\\maketitle\n\\section*{Questão 1}\n");
        endfunction

        function write_string(l, string)
            fputs(l.file_object, string);
        endfunction

        function str = string_form(l, obj)
            str = "";
            if isa(obj, "singfun")
                str = sprintf("%d{\\langle x-%d \\rangle}^{%d}", obj.multiplier, obj.a, obj.degree);
            endif
            if isa(obj, "singfunsum")
                hasFunctions = false;
                hasDefPoly = false;
                if length(obj.functions) > 0
                    hasFunctions = true;
                end
                if length(find(obj.def_poly)) > 0
                    hasDefPoly = true;
                end
                for i = 1:length(obj.functions)
                    sf = obj.functions;
                    sf = sf{i};
                    multip = sf.multiplier;
                    if i > 1
                        if multip < 0
                            str = sprintf("%s - ", str);
                        else
                            str = sprintf("%s + ", str);
                        endif
                        multip = abs(multip);
                    endif
                    if multip == 1
                        str = sprintf("%s{\\langle x-%d \\rangle}^{%d}", str, sf.a, sf.degree);
                    else
                        str = sprintf("%s%d{\\langle x-%d \\rangle}^{%d}", str, multip, sf.a, sf.degree);
                    endif
                endfor
                for i = 1:length(obj.def_poly)
                    deg = length(obj.def_poly)-i;
                    sp = obj.def_poly;
                    sp = sp(i);
                    multip = sp;
                    if multip != 0
                        if (((i > 1) && (length(find(obj.def_poly)) > 1)) || (hasFunctions))
                            if multip < 0
                                str = sprintf("%s - ", str);
                            else
                                str = sprintf("%s + ", str);
                            endif
                            multip = abs(multip);
                        endif
                        if deg == 0
                            str = sprintf("%s%d", str, multip);
                        else
                            if multip == 1
                                str = sprintf("%sx^{%d}", str, deg);
                            else
                                str = sprintf("%s%d x^{%d}", str, multip, deg);
                            endif
                        endif
                    endif
                endfor
                used_consts = 0;
                for i = 1:length(obj.undef_poly)
                    deg = length(obj.undef_poly)-i;
                    sp = obj.undef_poly;
                    sp = sp(i);
                    if ((isnan(sp)))
                        if (((i > 1) && (length(find(obj.undef_poly))) > 1) || (hasDefPoly) || (hasFunctions))
                            str = sprintf("%s + ", str);
                        endif
                        if deg == 0;
                            str = sprintf("%sC %d", str, ++used_consts);
                        else
                            str = sprintf("%sC%d x^{%d}", str, ++used_consts, deg);
                        endif
                    endif
                endfor
                str = sprintf("%s\n", str);

            endif
        endfunction

        function str = string_form_evaluated(l, obj, val)
            str = "";
            if isa(obj, "singfunsum")
                hasFunctions = false;
                hasDefPoly = false;
                if length(obj.functions) > 0
                    hasFunctions = true;
                end
                if length(find(obj.def_poly)) > 0
                    hasDefPoly = true;
                end
                for i = 1:length(obj.functions)
                    sf = obj.functions;
                    sf = sf{i};
                    multip = sf.multiplier;
                    if i > 1
                        if multip < 0
                            str = sprintf("%s - ", str);
                        else
                            str = sprintf("%s + ", str);
                        endif
                        multip = abs(multip);
                    endif
                    if multip == 1
                        str = sprintf("%s{\\langle %s-%d \\rangle}^{%d}", str, val, sf.a, sf.degree);
                    else
                        str = sprintf("%s%d{\\langle %s-%d \\rangle}^{%d}", str, multip, val, sf.a, sf.degree);
                    endif
                endfor
                for i = 1:length(obj.def_poly)
                    deg = length(obj.def_poly)-i;
                    sp = obj.def_poly;
                    sp = sp(i);
                    multip = sp;
                    if multip != 0
                        if (((i > 1) && (length(find(obj.def_poly)) > 1)) || (hasFunctions))
                            if multip < 0
                                str = sprintf("%s - ", str);
                            else
                                str = sprintf("%s + ", str);
                            endif
                            multip = abs(multip);
                        endif
                        if deg == 0
                            str = sprintf("%s%d", str, multip);
                        else
                            if multip == 1
                                str = sprintf("%s%s^{%d}", str, val, deg);
                            else
                                str = sprintf("%s%d %s^{%d}", str, multip, val, deg);
                            endif
                        endif
                    endif
                endfor
                used_consts = 0;
                for i = 1:length(obj.undef_poly)
                    deg = length(obj.undef_poly)-i;
                    sp = obj.undef_poly;
                    sp = sp(i);
                    if ((isnan(sp)))
                        if (((i > 1) && (length(find(obj.undef_poly))) > 1) || (hasDefPoly) || (hasFunctions))
                            str = sprintf("%s + ", str);
                        endif
                        if deg == 0;
                            str = sprintf("%sC %d", str, ++used_consts);
                        else
                            str = sprintf("%sC%d %s^{%d}", str, ++used_consts, val, deg);
                        endif
                    endif
                endfor
                str = sprintf("%s\n", str);

            endif

        endfunction

        function write_footer(l)
            fputs(l.file_object, "\n\\end{document}\n");
        endfunction

    endmethods
endclassdef
