clc
clear all
format long

addpath("parser");
addpath("printer");
addpath("esforcos");
addpath("singfun");

global program_logger = logger("log.tex");

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
# - yield_strength: limite de escoamento
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

program_logger.write_header();

program_logger.write_string("\\section*{Propriedades da viga}\n");
program_logger.write_string("\\begin{itemize}\n");
program_logger.write_string(sprintf("\\item Tipo: %s\n", viga.type));
program_logger.write_string(sprintf("\\item Largura: %d\n", viga.width));
if (strcmp(viga.type, "bar"))
    program_logger.write_string(sprintf("\\item Altura: %d\n", viga.height));
    program_logger.write_string(sprintf("\\item Espessura: %d\n", viga.length_z));
elseif (strcmp(viga.type, "cylinder"))
    program_logger.write_string(sprintf("\\item Raio: %d\n", viga.radius));
elseif (strcmp(viga.type, "hollow"))
    program_logger.write_string(sprintf("\\item Raio externo: %d\n", viga.outer_radius));
    program_logger.write_string(sprintf("\\item Raio interno: %d\n", viga.inner_radius));
endif
program_logger.write_string(sprintf("\\item Área: %d\n", viga.area));
program_logger.write_string(sprintf("\\item Volume: %d\n", viga.volume));
program_logger.write_string(sprintf("\\item \\(E\\): %d\n", viga.elasticity));
program_logger.write_string(sprintf("\\item \\(G\\): %d\n", viga.shear));
program_logger.write_string(sprintf("\\item Limite de escoamento: %d\n", viga.yield_strength));
program_logger.write_string(sprintf("\\item \\(\I_{z}\\): %d\n", viga.Iz));
program_logger.write_string(sprintf("\\item \\(\I_{y}\\): %d\n", viga.Iy));
program_logger.write_string(sprintf("\\item \\(\I_{p}\\): %d\n", viga.Ip));
program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\section*{Valores}\n");
program_logger.write_string("\\begin{itemize}\n");

program_logger.write_string("\\item Forças Verticais:\n");
program_logger.write_string("\\begin{itemize}\n");
for i = 1:length(forcas_verticais)
    forca = forcas_verticais{i}
    program_logger.write_string(sprintf("\\item Valor: %d, Posição: %d\n", forca.value, forca.position));
endfor
program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\item Forças Horizontais:\n");
program_logger.write_string("\\begin{itemize}\n");
for i = 1:length(forcas_horizontais)
    forca = forcas_horizontais{i}
    program_logger.write_string(sprintf("\\item Valor: %d, Posição: %d\n", forca.value, forca.position));
endfor
program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\item Momentos:\n");
program_logger.write_string("\\begin{itemize}\n");
for i = 1:length(momentos)
    forca = momentos{i}
    program_logger.write_string(sprintf("\\item Valor: %d, Posição: %d\n", forca.value, forca.position));
endfor
program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\item Torques:\n");
program_logger.write_string("\\begin{itemize}\n");
for i = 1:length(torques)
    forca = torques{i}
    program_logger.write_string(sprintf("\\item Valor: %d, Posição: %d\n", forca.value, forca.position));
endfor
program_logger.write_string("\\end{itemize}\n");


program_logger.write_string("\\item Carregamentos:\n");
program_logger.write_string("\\begin{itemize}\n");
for i = 1:length(carregamentos)
    carregamento_str = "\\item Função: \\("
    carregamento = carregamentos{i}
    for j = 1:length(carregamento.coefficients)
        carregamento_str = sprintf("%s %d x^{%d}", carregamento_str, carregamento.coefficients{j}, (length(carregamento.coefficients)-j));
        if (j < length(carregamento.coefficients))
            carregamento_str = sprintf("%s + ", carregamento_str);
        endif
    endfor
    carregamento_str = sprintf("%s\\), Posição: \\([%d-%d]\\)", carregamento_str, carregamento.start_position, carregamento.end_position);
    program_logger.write_string(carregamento_str);
endfor
program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\section*{Funções de Singularidade}\n");
program_logger.write_string("\\begin{itemize}\n");
program_logger.write_string("\\item Carregamentos, Forças Verticais e Momentos:\n");
program_logger.write_string("\\begin{itemize}\n");
for i = 1:length(singfun_carregamentos)
    sf_carr = singfun_carregamentos{i}
    program_logger.write_string(sprintf("\\item \\( %d{\\langle x-%d \\rangle}^{%d} \\) \n", sf_carr.multiplier, sf_carr.a, sf_carr.degree));
endfor
program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\item Forças Horizontais:\n");
program_logger.write_string("\\begin{itemize}\n");
for i = 1:length(singfun_forcas_x)
    sf_carr = singfun_forcas_x{i}
    program_logger.write_string(sprintf("\\item \\( %d{\\langle x-%d \\rangle}^{%d} \\) \n", sf_carr.multiplier, sf_carr.a, sf_carr.degree));
endfor
program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\item Torques:\n");
program_logger.write_string("\\begin{itemize}\n");
for i = 1:length(singfun_torques)
    sf_carr = singfun_torques{i}
    program_logger.write_string(sprintf("\\item \\( %d{\\langle x-%d \\rangle}^{%d} \\) \n", sf_carr.multiplier, sf_carr.a, sf_carr.degree));
endfor
program_logger.write_string("\\end{itemize}\n");

program_logger.write_string("\\end{itemize}\n");

# Calculamos as reações
calcular_reacoes();


# Imprimimos as reações
print_support_reactions();

# Apresentamos os gráficos de esforcos internos, inclinacao, deflexao, alongamento e torcao
graficos_reacoes(viga, apoios, singfun_carregamentos, singfun_forcas_x, singfun_torques);

program_logger.write_footer();
program_logger.close_file();
