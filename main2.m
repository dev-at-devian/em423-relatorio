clc
clear all
format long

addpath("parser");
addpath("printer");

global forcas_verticais = {};      # { struct(value, position) }
global forcas_horizontais = {};    # { struct(value, position) }
global apoios = {};                # { struct(position, horizontal, vertical, momentum, torque) }
global momentos = {};              # { struct(value, position) }
global torques = {};               # { struct(value, position) }
global carregamentos = {};         # { struct(start_position, end_position, coefficients) }
global singfun_carregamentos = {}; # { singfun(degree,a,multiplier) }
global singfun_forcas_x = {};      # { singfun(degree,a,multiplier) }
global singfun_torques = {};       # { singfun(degree,a,multiplier) }
global viga = struct("width", 0, "height", 0);


# Obtemos as informações do problema contidas no arquivo dados.txt
file_parse(); 
printf("Carregamentos:\n");
for i = 1:length(singfun_carregamentos)
    disp(singfun_carregamentos{i});
end
printf("Forças em x:\n");
for i = 1:length(singfun_forcas_x)
    disp(singfun_forcas_x{i});
end
printf("Torques:\n");
for i = 1:length(singfun_torques)
    disp(singfun_torques{i});
end
printf("Torques:\n");
for i = 1:length(apoios)
    disp(apoios{i});
end

calcular_reacoes2();
printf("Carregamentos:\n");
for i = 1:length(singfun_carregamentos)
    disp(singfun_carregamentos{i});
end
printf("Forças em x:\n");
for i = 1:length(singfun_forcas_x)
    disp(singfun_forcas_x{i});
end
printf("Torques:\n");
for i = 1:length(singfun_torques)
    disp(singfun_torques{i});
end
printf("Apoios:\n");
for i = 1:length(apoios)
    disp(apoios{i});
end
print_support_reactions();
graficos_reacoes(viga, singfun_carregamentos, singfun_forcas_x, singfun_torques);

