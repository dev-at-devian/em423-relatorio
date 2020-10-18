
function forcas = carregamentos_para_forcas(carregamentos)
  # Iniciamos o vetor de forças de carregamento
  forcas = [];
  
  # Para cada força...
  for carregamento = 1:size(carregamentos, 2)
    # Pegamos as componentes do carregamento
    x_inicio = carregamentos{carregamento}{1};
    x_fim = carregamentos{carregamento}{2};
    polinomio = cell2mat(carregamentos{carregamento}{3});
    
    # Precisamos integrar esse polinômio e avaliá-lo na posição final - inicial
    int_forca = polyint(polinomio);
    forca_modulo = polyval(int_forca, x_fim) - polyval(int_forca, x_inicio);
    # Agora pegamos o polinomio original e multiplicar por x
    polinomio_x = [polinomio 0];
    # novamente, integramos e calculamos na posição final - inicial
    int_polinomio_x = polyint(polinomio_x);
    ans_int_polinomio_x = polyval(int_polinomio_x, x_fim) - polyval(int_polinomio_x, x_inicio);
    posicao_x = ans_int_polinomio_x / forca_modulo;
    
    # Agora temos a força completa: posição no eixo x e seu módulo
    forca = {posicao_x, forca_modulo};
    # Adicionamos à matriz resposta
    forcas{end+1} = forca;
  endfor
endfunction

