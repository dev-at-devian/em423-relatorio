function out = print_support_reactions() 
    global apoios;
        
        printf("\nReações de apoio:\n\n");
        for i = 1:length(apoios)
            sign_icons = {" (→) "," (←) "," (↑) "," (↓) "," (↺) "," (↻) "," (↠) "," (↞) "};
            units = {"N", "N", "Nm", "Nm"};
            support_letter = char(96+i);
            support_letter_upper = char(64+i);
            support_reaction_prefix = {"Fx", "Fy", "M", "T"};

            printf("-- Apoio %s\n", support_letter_upper);

            for j = 1:4
                reaction_value = apoios{i}{j+1};
                if !isnan(reaction_value)
                    sign_icon = " ";
                    if reaction_value > 0
                        sign_icon = sign_icons{2*(j-1)+1};
                    elseif reaction_value < 0
                        sign_icon = sign_icons{2*j};
                    end
                    printf(" - %s%s: %d %s%s\n", support_reaction_prefix{j}, support_letter, reaction_value, units{j}, sign_icon);
                end
            end
            printf("\n", support_letter_upper);
        end
endfunction

