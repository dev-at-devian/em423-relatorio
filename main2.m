clc
clear all
format long

addpath("parser");
addpath("printer");

global forcas_verticais = {};   # {valor, posicao}
global forcas_horizontais = {}; # {valor, posicao}
global apoios = {};             # {posicao, horizontal, vertical, momento, torque}
global momentos = {};           # {valor, posicao}
global torques = {};            # {valor, posicao}
global carregamentos = {};      # {posicao_inicio, posicao_fim, {coeficiente1,...,coeficienten}};
global singfun_carregamentos = {};
global singfun_forcas_x = {};
global singfun_torques = {};
global viga = struct("width", 0, "height", 0);               # {comprimento, altura}


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

