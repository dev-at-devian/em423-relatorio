
function apoios = calcular_reacoes(apoios, forcas_y, forcas_x, momentos, torques)
  nIncognitas = 0;
  
  # Passamos por cada apoio para verificar o número de reações que devemos
  # determinar no problema
  for i = 1:size(apoios, 2)
    apoio = cell2mat(apoios{i});
    apoio_x = apoio(1);
    apoio_reacoes = apoio(2:5);
    
    # Para cada reação disponível no apoio, verificamos as que não são NaN
    # (NaN -- not a number -- representa reação indisponível)
    for j = 1:4
      if !isnan(apoio_reacoes(j))
        nIncognitas = nIncognitas + 1;
      endif
    endfor
  endfor
  
  # Com o número de incógnitas, fazemos as nossas matrizes para solucionar o
  # sistema
  #
  # A primeira eq. será das forças verticais
  # Segunda eq. será das forças horizontais
  # Terceira eq. será dos momentos
  # Quarta eq. será dos torques
  A = zeros(4, nIncognitas);
  B = zeros(4, 1);
  incognitaUtilizadas = 0;
  
  # Agora que sabemos o número de reações que temos, passamos por cada reação
  # para preencher o vetor que representa o nossos sitema linear
  for i = 1:size(apoios, 2)
    apoio = cell2mat(apoios{i});
    apoio_x = apoio(1);
    apoio_reacoes = apoio(2:5);
    
    # Verificamos se há reação horizontal
    reacao_horizontal = apoio_reacoes(1);
    if !isnan(reacao_horizontal)
      # Se há reação horizontal, entrará apenas na somatória de forças
      # horizontais
      
      # Como há uma incógnita, adicionamos ao número de incógnitas
      # e utilizamos esse índice para representar essa reação
      incognitaUtilizadas = incognitaUtilizadas + 1;
      A(1, incognitaUtilizadas) = A(1, incognitaUtilizadas) + 1;
    endif
    
    # Verificamos se há reação vertical
    reacao_vertical = apoio_reacoes(2);
    if !isnan(reacao_vertical)
      # Se há reação vertical, temos que incluí-la na matriz do sistema nas eqs.
      # de somatório de forças verticais iguais a zero e também na de momento
      
      # Como há uma incógnita, adicionamos ao número de incógnitas
      # e utilizamos esse índice para representar essa reação
      incognitaUtilizadas = incognitaUtilizadas + 1;
      A(2, incognitaUtilizadas) = A(2, incognitaUtilizadas) + 1;
      
      # Para cálculo do momento, não temos o coeficiente 1, mas sim o momento
      # da força, pois a soma de momentos de forças pontuais é no formato:
      # F1 * d1 + F2 * d2 + ... + Fn * dn = 0
      # Então se F1 é a incógnita, ela é multiplicada pelo seu braço de
      # ação da força. Como nosso referêncial é a origem (x=0), o braço de
      # ação será a posição de aplicação da força
      A(3, incognitaUtilizadas) = A(3, incognitaUtilizadas) + apoio_x;
    endif
    
    # Verificamos se há reação de momento
    reacao_momento = apoio_reacoes(3);
    if !isnan(reacao_momento)
      # Se há reação de momento, entrará na somatória de momentos
      
      # Como há uma incógnita, adicionamos ao número de incógnitas
      # e utilizamos esse índice para representar essa reação
      incognitaUtilizadas = incognitaUtilizadas + 1;
      A(3, incognitaUtilizadas) = A(3, incognitaUtilizadas) + 1;
    endif
    
    
    # Verificamos se há reação de torque
    reacao_torque = apoio_reacoes(4);
    if !isnan(reacao_torque)
      # Se há reação de torque, entrará na somatória de torques
      
      # Como há uma incógnita, adicionamos ao número de incógnitas
      # e utilizamos esse índice para representar essa reação
      incognitaUtilizadas = incognitaUtilizadas + 1;
      A(4, incognitaUtilizadas) = A(4, incognitaUtilizadas) + 1;
    endif
  endfor
  
  
  # Agora pegamos as forças dadas pelo problema e colocamos na parte direita
  # das equações (o sinal ficará trocado e entrarão no vetor B)
  # OBS: o sinal fica trocado pois fazemos:
  # F1 + F2 + F3 + ... + Fn = 0
  # Se F1 e F2 são incógnitas,
  # F1 + F2 = -F3 - F4 ... - Fn
  # onde F3...n são valores numéricos, então o lado direito da equação será um
  # valor numérico
  # F1 + F2 = V
  
  # Para cada força horizontal...
  for i = 1:size(forcas_x, 2)
    # Pegamos as informações da força
    forca_modulo = forcas_x{i}{1};
    forca_x = forcas_x{i}{2};
    
    # Invertemos o sinal e somamos à matriz B na equação de forças horizontais
    B(1) = B(1) - forca_modulo;
  endfor
  
  # Para cada força vertical..
  for i = 1:size(forcas_y, 2)
    # Pegamos as informações da força
    forca_modulo = forcas_y{i}{1};
    forca_x = forcas_y{i}{2};
    
    # Invertemos o sinal e somamos à matriz B na equação de forças verticais
    B(2) = B(2) - forca_modulo;
  endfor
  
  # Para cada momento...
  nForcas = size(momentos, 2);
  for i = 1:nForcas
    # Pegamos as informações da força
    momento_modulo = momentos{i}{1};
    momento_x = momentos{i}{2};
    
    # Invertemos o sinal e somamos à matriz B na equação de momentos
    B(3) = B(3) - momento_modulo;
  endfor
  
  
  # Para cada momento...
  for i = 1:size(torques, 2)
    # Pegamos as informações da força
    torque_modulo = torques{i}{1};
    torque_x = torques{i}{2};
    
    # Invertemos o sinal e somamos à matriz B na equação de torques
    B(4) = B(4) - torque_modulo;
  endfor
  
  
  # Agora, finalmente, resolvemos o sistema
  x = linsolve(A, B);
    
  # Zeramos as incógnitas para determinar novamente o valor
  incognitaUtilizadas = 0;
  # Voltamos às reações de apoio
  for i = 1:size(apoios, 2)
    apoio = cell2mat(apoios{i});
    
    for j = 2:5
      # Verificamos se há reação
      if !isnan(apoio(j))
        incognitaUtilizadas = incognitaUtilizadas + 1;
        apoio(j) = x(incognitaUtilizadas);
      endif
    endfor
    apoios{i} = {apoio(1), apoio(2), apoio(3), apoio(4), apoio(5)};
  endfor
endfunction
  
