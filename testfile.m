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
global viga = struct();


# Obtemos as informações do problema contidas no arquivo dados.txt
file_parse("testdata.txt");
