function retval = esforcosMomentos (vetorMomentos, momentos, apoios, carregamentos, L)
  

  # Junta os apoios com reacao vertical ao conjunto forcas
  n_apoios = length(apoios);

  for i = 1:n_apoios
	apoio = apoios{i};	
    	if !isnan(apoio.momentum)
       		momentos{end+1} = struct("value", apoio.momentum, "position", apoio.position);
    	end
	if !isnan(apoio.vertical)
		if(apoio.position != 0)
       			vetorMomentos{end+1} = struct("value", (apoio.position * apoio.vertical), "position", apoio.position);
		else
			vetorMomentos{end+1} = struct("value", apoio.vertical, "position", apoio.position);
		end			
    	end
  end

  # Sort Momentos baseado em sua posicao x
  n_Momentos = length(vetorMomentos);

  for i = 1:n_Momentos
	smaller = vetorMomentos{i}.position;
        smaller_index = i;
	for j = i:n_Momentos
		if(vetorMomentos{j}.position < smaller)
			smaller = vetorMomentos{j}.position;
			smaller_index = j;
		end
	end
        swap = vetorMomentos{i};
        vetorMomentos{i} = vetorMomentos{smaller_index};
	vetorMomentos{smaller_index} = swap;
  end

  nMomentos = length(vetorMomentos);

  x_hist = [];
  Fv_hist = [];
  n_carregamentos = length(carregamentos);
  n_momentos_puros = length(momentos);

  sum_puros = 0;

  # momentos puros
  for j = 1:n_momentos_puros
	sum_puros -= momentos{j}.value;
  end
  
  Fv_hist = [Fv_hist 0];
  x_hist = [x_hist 0];

  for x = 0:0.01:L
    res = sum_puros;
    index_carregamento = 0;

    # Busca se posicao esta dentro de carregamento ou nao
    for j = 1:n_carregamentos
	if((x < carregamentos{j}.end_position) && (x > carregamentos{j}.start_position))
		index_carregamento = j;
                xi = carregamentos{j}.start_position;
		break;
	end
    end
    
    # Se for carregamento, realiza tratamento especifico
    if index_carregamento != 0
	 # momentos de forca
   	 for j = 1:nMomentos
         	if xi >= vetorMomentos{j}.position
			if(vetorMomentos{j}.position != 0)
				res += (x - vetorMomentos{j}.position) * vetorMomentos{j}.value / vetorMomentos{j}.position;
			else
				res += (x - vetorMomentos{j}.position) * vetorMomentos{j}.value;
			end
   		else
			break;
		end 
	 end
         polinomio = cell2mat(carregamentos{index_carregamento}.coefficients); 
         int_poli = polyint(polinomio);
         int_mom = polyint([polinomio 0]);
         res_forca = polyval(int_poli, x) - polyval(int_poli, xi);
         centroide = (polyval(int_mom, x) - polyval(int_mom, xi)) / res_forca;
         res += (x - centroide) * (res_forca);
    else
 	 # momentos de forca
   	 for j = 1:nMomentos
         	if x > vetorMomentos{j}.position
			if(vetorMomentos{j}.position != 0)
				res += (x - vetorMomentos{j}.position) * vetorMomentos{j}.value / vetorMomentos{j}.position;
			else
				res += (x - vetorMomentos{j}.position) * vetorMomentos{j}.value;
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
