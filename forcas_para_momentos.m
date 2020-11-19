
function momentos = forcas_para_momentos(forcas_y)
  # Iniciamos o vetor de forças de carregamento
  momentos = [];
  
  # Para cada força...
  for forca = 1:length(forcas_y)
    # Pegamos as componentes da força
    forca_modulo = forcas_y{forca}.value;
    forca_x = forcas_y{forca}.position;
    
    # Calculamos o momento
    # SINAL: como as forças são positivas para cima e o momento é positivo no
    # sentido anti horário, temos automaticamente o sinal correto do momento
    # pois nosso ponto de cálculo de momento é em relação ao ponto x = 0
    momento_modulo = forca_modulo * forca_x;
    # Fazemos um vetor para representar o momento
    momento = struct("value", momento_modulo, "position", forca_x);
    
    # Colocamos no vetor
    momentos{end+1} = momento;
  endfor
endfunction

