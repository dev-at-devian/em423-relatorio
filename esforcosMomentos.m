function retval = esforcosMomentos (vetorMomentos, momentos, apoios, carregamentos, L)
  

  # Junta os apoios com reacao vertical ao conjunto forcas
  n_apoios = size(apoios, 2);

  for i = 1:n_apoios
	apoio = cell2mat(apoios{i});	
    	if !isnan(apoio(4))
       		vetorMomentos{end+1} = {apoio(4), apoio(1)};
    	end
  end

  # Sort Momentos baseado em sua posicao x
  n_Momentos = size(vetorMomentos, 2);

  for i = 1:n_Momentos
	smaller = vetorMomentos{i}{2};
        smaller_index = i;
	for j = i:n_Momentos
		if(vetorMomentos{j}{2} < smaller)
			smaller = vetorMomentos{j}{2};
			smaller_index = j;
		end
	end
        swap = vetorMomentos{i};
        vetorMomentos{i} = vetorMomentos{smaller_index};
	vetorMomentos{smaller_index} = swap;
  end

  nMomentos = size(vetorMomentos, 2);

  x_hist = [];
  Fv_hist = [];
  n_carregamentos = size(carregamentos, 2);
  n_momentos_puros = size(momentos, 2)
  
  Fv_hist = [Fv_hist 0];
  x_hist = [x_hist 0];
   
  vetorMomentos  

  for i = 1:nMomentos
    xm = vetorMomentos{i}{2};
    res = 0

    # momentos puros
    for j = 1:n_momentos_puros
	res -= momentos{j}{1}
    end

    index_carregamento = 0;

    # Busca se Momento vem de carregamento ou nao
    for j = 1:n_carregamentos
	if((xm <= carregamentos{j}{2}) && (xm >= carregamentos{j}{1}))
		index_carregamento = j;
		break;
	end
    end
    
    # Se for carregamento, realiza tratamento especifico
    if index_carregamento != 0	
      x0 = carregamentos{index_carregamento}{1};
      x1 = carregamentos{index_carregamento}{2};
      polinomio = cell2mat(carregamentos{index_carregamento}{3}); 
      int_poli = polyint(polinomio);
      for j = x0:(x1 - x0)/100:x1
        x_hist = [x_hist j];
        cul = sumVertical - (polyval(int_poli, j) - polyval(int_poli, x0));
        Fv_hist = [Fv_hist cul];
      end
    else
 	 # momentos de forca
   	 for j = 1:(i - 1)
		res += ( - vetorMomentos{j}{2}) * vetorMomentos{j}{1} / vetorMomentos{j}{2}
   	 end
    end

 

    sumVertical -= res;
    Fv_hist = [Fv_hist sumVertical];
    x_hist = [x_hist xm];
  end
    
  Fv_hist = [Fv_hist sumVertical];
  x_hist = [x_hist L];
 
  [xs, ys] = stairs(x_hist, Fv_hist);
  plot(xs, ys)

endfunction