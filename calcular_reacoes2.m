function apoios = calcular_reacoes2()
  global viga;
  global apoios;
  global singfun_carregamentos;
  global singfun_forcas_x;
  global singfun_torques;
  nIncognitas = 0;
  carregamentoIncognitas = {};
  forcaXIncognitas = {};
  torqueIncognitas = {};
  
  # Passamos por cada apoio para verificar o número de reações que devemos
  # determinar no problema
  for i = 1:length(apoios)
    apoio = apoios{i};
    apoio_x = apoio.position;
    apoio_reacoes = [apoio.horizontal apoio.vertical apoio.momentum apoio.torque];
    
    # Para cada reação disponível no apoio, verificamos as que não são NaN
    # (NaN -- not a number -- representa reação indisponível)
    for j = 1:4
      if !isnan(apoio_reacoes(j))
        nIncognitas = nIncognitas + 1;
        switch j
            case 1
                forcaXIncognitas{end+1} = struct("apoio", i, "reacao", j);
            case 2
                carregamentoIncognitas{end+1} = struct("apoio", i, "reacao", j);
            case 3
                carregamentoIncognitas{end+1} = struct("apoio", i, "reacao", j);
            case 4
                torqueIncognitas{end+1} = struct("apoio", i, "reacao", j);
            otherwise
                error();
        endswitch
      endif
    endfor
  endfor
  
  A = zeros(4, nIncognitas);
  B = zeros(4, 1);
  incognitaUtilizadas = 0;

  if (length(carregamentoIncognitas) > 0)
      somaLadoDireitoF = singfunsum();
      somaLadoDireitoM = singfunsum();
      for i = 1:length(singfun_carregamentos)
          somaLadoDireitoF = somaLadoDireitoF + singfun_carregamentos{i};
          somaLadoDireitoM = somaLadoDireitoM + singfun_carregamentos{i};
      endfor
      for i = 1:length(carregamentoIncognitas)
          sf = singfun(-1, apoios{carregamentoIncognitas{i}.apoio}.position);
          sf = integrate(sf);
          sf2 = integrate(sf);
          incognitaUtilizadas++;
          A(1,incognitaUtilizadas) = sf(viga.width, 1);
          A(2,incognitaUtilizadas) = sf2(viga.width, 1);
          disp(sf);
          disp(sf2);
          printf("igen %d resw %d\n", sf(viga.width,1), sf2(viga.width,1));
      endfor
      disp(somaLadoDireitoF);
      somaLadoDireitoF = integrate(somaLadoDireitoF);
      somaLadoDireitoM = integrate(somaLadoDireitoF);
      disp(somaLadoDireitoF);
      disp(somaLadoDireitoM);
      B(1) = -somaLadoDireitoF(viga.width,1);
      B(2) = -somaLadoDireitoM(viga.width,1);
  endif

  if (length(forcaXIncognitas) > 0)
      somaLadoDireito = singfunsum();
      for i = 1:length(singfun_forcas_x)
          somaLadoDireito = somaLadoDireito + singfun_forcas_x{i};
      endfor
      for i = 1:length(forcaXIncognitas)
          sf = singfun(-1, apoios{forcaXIncognitas{i}.apoio}.position);
          sf = integrate(sf);
          incognitaUtilizadas++;
          A(3,incognitaUtilizadas) = sf(viga.width, 1);
          disp(sf);
      endfor
      somaLadoDireito = integrate(somaLadoDireito);
      B(3) = -somaLadoDireito(viga.width,1);
  endif

  if (length(torqueIncognitas) > 0)
      somaLadoDireito = singfunsum();
      for i = 1:length(singfun_torques)
          somaLadoDireito = somaLadoDireito + singfun_torques{i};
      endfor
      for i = 1:length(torqueIncognitas)
          sf = singfun(-1, apoios{torqueIncognitas{i}.apoio}.position);
          sf = integrate(sf);
          incognitaUtilizadas++;
          A(4,incognitaUtilizadas) = sf(viga.width, 1);
          disp(sf);
      endfor
      somaLadoDireito = integrate(somaLadoDireito);
      B(4) = -somaLadoDireito(viga.width,1);
  endif
  disp(A);
  disp(B);

  disp(A\B);

  reacoes = A\B;

  incognitaUtilizadas = 0;
  for i = 1:length(carregamentoIncognitas)
      switch carregamentoIncognitas{i}.reacao
          case 2
              apoios{carregamentoIncognitas{i}.apoio}.vertical = reacoes(++incognitaUtilizadas);
              if (reacoes(incognitaUtilizadas) != 0)
                  singfun_carregamentos{end+1} = singfun(-1, apoios{carregamentoIncognitas{i}.apoio}.position, reacoes(incognitaUtilizadas));
              end
          case 3
              apoios{carregamentoIncognitas{i}.apoio}.momento = reacoes(++incognitaUtilizadas);
              if (reacoes(incognitaUtilizadas) != 0)
                  singfun_carregamentos{end+1} = singfun(-1, apoios{carregamentoIncognitas{i}.apoio}.position, reacoes(incognitaUtilizadas));
              end
          otherwise
              error();
      end
  end
  for i = 1:length(forcaXIncognitas)
      apoios{forcaXIncognitas{i}.apoio}.horizontal = reacoes(++incognitaUtilizadas);
      if (reacoes(incognitaUtilizadas) != 0)
          singfun_forcas_x{end+1} = singfun(-1, apoios{forcaXIncognitas{i}.apoio}.position, reacoes(incognitaUtilizadas));
      end
  end
  for i = 1:length(torqueIncognitas)
      apoios{torqueIncognitas{i}.apoio}.torque = reacoes(++incognitaUtilizadas);
      if (reacoes(incognitaUtilizadas) != 0)
          singfun_torques{end+1} = singfun(-1, apoios{torqueIncognitas{i}.apoio}.position, reacoes(incognitaUtilizadas));
      end
  end

endfunction
