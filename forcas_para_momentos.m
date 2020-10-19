
function momentos = forcas_para_momentos(forcas_y)
  # Iniciamos o vetor de forças de carregamento
  momentos = [];
  
  # Para cada força...
  for forca = 1:size(forcas_y, 2)
    # Pegamos as componentes da força
    forca_modulo = forcas_y{forca}{1};
    forca_x = forcas_y{forca}{2};
    
    # Calculamos o momento
    # SINAL: como as forças são positivas para cima e o momento é positivo no
    # sentido anti horário, temos automaticamente o sinal correto do momento
    # pois nosso ponto de cálculo de momento é em relação ao ponto x = 0
    momento_modulo = forca_modulo * forca_x;
    # Fazemos um vetor para representar o momento
    momento = {momento_modulo, forca_x};
    
    # Colocamos no vetor
    momentos{end+1} = momento;
  endfor
endfunction

