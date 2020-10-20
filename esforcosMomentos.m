function retval = esforcosMomentos (vetorMomentos, momentos, apoios, carregamentos, L)
  

  # Junta os apoios com reacao vertical ao conjunto forcas
  n_apoios = size(apoios, 2);

  for i = 1:n_apoios
	apoio = cell2mat(apoios{i});	
    	if !isnan(apoio(4))
       		momentos{end+1} = {apoio(4), apoio(1)};
    	end
	if !isnan(apoio(3))
		if(apoio(1) != 0)
       			vetorMomentos{end+1} = {apoio(1) * apoio(3), apoio(1)};
		else
			vetorMomentos{end+1} = {apoio(3), apoio(1)};
		end			
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
  n_momentos_puros = size(momentos, 2);

  sum_puros = 0;

  # momentos puros
  for j = 1:n_momentos_puros
	sum_puros -= momentos{j}{1};
  end
  
  Fv_hist = [Fv_hist 0];
  x_hist = [x_hist 0];

  for x = 0:0.01:L
    res = sum_puros;
    index_carregamento = 0;

    # Busca se posicao esta dentro de carregamento ou nao
    for j = 1:n_carregamentos
	if((x < carregamentos{j}{2}) && (x > carregamentos{j}{1}))
		index_carregamento = j;
                xi = carregamentos{j}{1};
		break;
	end
    end
    
    # Se for carregamento, realiza tratamento especifico
    if index_carregamento != 0
	 # momentos de forca
   	 for j = 1:nMomentos
         	if xi >= vetorMomentos{j}{2}
			if(vetorMomentos{j}{2} != 0)
				res += (x - vetorMomentos{j}{2}) * vetorMomentos{j}{1} / vetorMomentos{j}{2};
			else
				res += (x - vetorMomentos{j}{2}) * vetorMomentos{j}{1};
			end
   		else
			break;
		end 
	 end
         polinomio = cell2mat(carregamentos{index_carregamento}{3}); 
         int_poli = polyint(polinomio);
         int_mom = polyint([polinomio 0]);
         res_forca = polyval(int_poli, x) - polyval(int_poli, xi);
         centroide = (polyval(int_mom, x) - polyval(int_mom, xi)) / res_forca;
         res += (x - centroide) * (res_forca);
    else
 	 # momentos de forca
   	 for j = 1:nMomentos
         	if x > vetorMomentos{j}{2}
			if(vetorMomentos{j}{2} != 0)
				res += (x - vetorMomentos{j}{2}) * vetorMomentos{j}{1} / vetorMomentos{j}{2};
			else
				res += (x - vetorMomentos{j}{2}) * vetorMomentos{j}{1};
			end
   		else
			break;
		end 
	 end
    end
    x_hist = [x_hist x];
    Fv_hist = [Fv_hist res];	
  end
 
  [xs, ys] = stairs(x_hist, Fv_hist);
  figure(4);
  plot(xs, ys, "linewidth", 2, "color", [0.682, 0.918, 0]);
  grid on;
  set(gca, "fontsize", 12);
  title("Esforços Internos - Momento");
  xlabel("x [m]");
  ylabel("M [Nm]");

endfunction
