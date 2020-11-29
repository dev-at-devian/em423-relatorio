clc
clear all
format long

addpath("parser");
addpath("printer");

# DEFINIÇÕES:

# FORÇAS VERTICAIS (cell array de structs)
# Atributos:
# - value: valor
# - position: posição

global forcas_verticais = {};

# FORÇAS HORIZONTAIS (cell array de structs)
# Atributos:
# - value: valor
# - position: posição

global forcas_horizontais = {};

# APOIOS (cell array de structs)
# Atributos:
# - position: posicao
# - horizontal: reação de apoio horizontal
# - vertical: reação de apoio vertical
# - momentum: reação de apoio momentum
# - torque: reação de apoio torque

global apoios = {};

# MOMENTOS (cell array de structs)
# Atributos:
# - value: valor
# - position: posição

global momentos = {};

# TORQUES (cell array de structs)
# Atributos:
# - value: valor
# - position: posição

global torques = {};

# CARREGAMENTOS (cell array de structs)
# Atributos:
# - start_position: posição de início
# - start_position: posição do fim
# - coefficients: cell array contendo os coeficientes do polinômio do carregamento

global carregamentos = {};

# SINGFUN CARREGAMENTOS (cell array de singfun)
# Contém as funções de singularidade para os carregamentos, forças verticais e momentos
# Atributos:
# - degree: grau
# - a: posição da função
# - multiplier: multiplicador
# Mais informações em singfun.m

global singfun_carregamentos = {};

# SINGFUN FORÇAS X (cell array de singfun)
# Contém as funções de singularidade para as forças horizontais
# Atributos:
# - degree: grau
# - a: posição da função
# - multiplier: multiplicador
# Mais informações em singfun.m

global singfun_forcas_x = {};

# SINGFUN TORQUES (cell array de singfun)
# Contém as funções de singularidade para os torques
# Atributos:
# - degree: grau
# - a: posição da função
# - multiplier: multiplicador
# Mais informações em singfun.m

global singfun_torques = {};

# VIGA (struct)
# Atributos:
# - type: tipo [bar (barra) / cylinder (cilindro) / hollow (cilindro oco)]
# - width: largura
# - area: area
# - volume: volume
# - elasticity: módulo de elasticidade
# - shear: módulo de cisalhamento
# - Iz: momento de inércia (eixo z)
# - Iy: momento de inércia (eixo y)
# - Ip: momento de inércia (polar)
#
# - Para tipo bar:
#   - height: altura
#   - length_z: espessura / comprimento no eixo z
#
# - Para tipo cylinder
#   - radius: raio
#
# - Para tipo hollow
#   - outer_radius: raio externo
#   - inner_radius: raio interno

global viga = struct();

# CÓDIGO:

# Obtemos as informações do problema contidas no arquivo dados.txt
file_parse("dados.txt"); 

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
