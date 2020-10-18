clc
clear all
format long

addpath("parser");

global forcas_verticais = [];   # {valor, posicao}
global forcas_horizontais = []; # {valor, posicao}
global apoios = [];             # {posicao, horizontal, vertical, momento, torque}
global momentos = [];           # {valor, posicao}
global torques = [];            # {valor, posicao}
global carregamentos = [];      # {posicao_inicio, posicao_fim, {coeficiente1,...,coeficienten}};
global viga = [];               # {comprimento, altura}


# Testando todos os vetores lidos

file_parse();

printf("Viga:\n");
disp(viga);
printf("\nForças Verticais:\n");
disp(forcas_verticais);
printf("\nForças Horizontais:\n");
disp(forcas_horizontais);
printf("\nMomentos:\n");
disp(momentos);
printf("\nTorques:\n");
disp(torques);
printf("\nApoios:\n");
disp(apoios);
printf("\nCarregamentos:\n");
disp(carregamentos);

# Convertemos forças de carregamento em forças verticais para cálculo de reações 
pontuais_carregamentos = carregamentos_para_forcas(carregamentos);
forcas_verticais_com_carregamentos = [forcas_verticais, pontuais_carregamentos];
 
# Calculamos os momentos de todas as forças para cálculo de reações 
momentos_de_forcas = forcas_para_momentos(forcas_verticais_com_carregamentos);
momentos_com_carregamentos = [momentos, momentos_de_forcas];
 
# Calculamos as reações 
apoios = calcular_reacoes(apoios, forcas_verticais_com_carregamentos, forcas_horizontais, momentos_com_carregamentos, torques);
 
# Plot das reaçoes internas na horizontal 
esforcosHorizontais(forcas_horizontais, apoios, viga{1});
 
# Plot das reaçoes internas para tensores 
esforcosTorques(torques, apoios, viga{1});
 
esforcosVerticais(forcas_verticais_com_carregamentos, apoios, carregamentos, viga{1});
 
#esforcosMomentos (momentos_de_forcas, momentos, apoios, carregamentos, viga{1});
 
