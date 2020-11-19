clc
clear all
format long

addpath("parser");
addpath("printer");

global forcas_verticais = [];   # {valor, posicao}
global forcas_horizontais = []; # {valor, posicao}
global apoios = [];             # {posicao, horizontal, vertical, momento, torque}
global momentos = [];           # {valor, posicao}
global torques = [];            # {valor, posicao}
global carregamentos = [];      # {posicao_inicio, posicao_fim, {coeficiente1,...,coeficienten}};
global viga = struct("width", 0, "height", 0);               # {comprimento, altura}


# Obtemos as informações do problema contidas no arquivo dados.txt
file_parse(); 

# Convertemos forças de carregamento em forças verticais para cálculo de reações 
pontuais_carregamentos = carregamentos_para_forcas(carregamentos);
forcas_verticais_com_carregamentos = [forcas_verticais, pontuais_carregamentos];
 
# Calculamos os momentos de todas as forças para cálculo de reações 
momentos_de_forcas = forcas_para_momentos(forcas_verticais_com_carregamentos);
momentos_com_carregamentos = [momentos, momentos_de_forcas];

# Calculamos as reações 
apoios = calcular_reacoes(apoios, forcas_verticais_com_carregamentos, forcas_horizontais, momentos_com_carregamentos, torques);

# Plot das reaçoes internas na horizontal 
esforcosHorizontais(forcas_horizontais, apoios, viga.width);

# Plot das reaçoes internas para tensores 
esforcosTorques(torques, apoios, viga.width);

# Reacoes internas verticais
esforcosVerticais(forcas_verticais_com_carregamentos, apoios, carregamentos, viga.width);

esforcosMomentos (momentos_de_forcas, momentos, apoios, carregamentos, viga.width);

# Mostramos as reações de apoio obtidas
print_support_reactions();
