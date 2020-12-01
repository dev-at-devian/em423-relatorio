function retval = esforcosVerticais (vetorVerticais, apoios, carregamentos, L)


  # Junta os apoios com reacao vertical ao conjunto forcas
  n_apoios = length(apoios);

  for i = 1:n_apoios
	apoio = apoios{i};
    	if !isnan(apoio.vertical)
       		vetorVerticais{end+1} = struct("value", apoio.vertical, "position",apoio.position);
    	end
  end

  # Sort forcas verticais baseado em sua posicao x
  n_Verticais = length(vetorVerticais);

  for i = 1:n_Verticais
	smaller = vetorVerticais{i}.position;
        smaller_index = i;
	for j = i:n_Verticais
		if(vetorVerticais{j}.position < smaller)
			smaller = vetorVerticais{j}.position;
			smaller_index = j;
		end
	end
        swap = vetorVerticais{i};
        vetorVerticais{i} = vetorVerticais{smaller_index};
	vetorVerticais{smaller_index} = swap;
  end

  % Forcas verticais

  nVerticais = length(vetorVerticais);

  sumVertical = 0;
  x_hist = [];
  Fv_hist = [];
  n_carregamentos = length(carregamentos);

  Fv_hist = [Fv_hist 0];
  x_hist = [x_hist 0];

  for i = 1:nVerticais
    xm = vetorVerticais{i}.position;
    res = vetorVerticais{i}.value;
    index_carregamento = 0;

    # Busca se forca vertical vem de carregamento ou nao
    for j = 1:n_carregamentos
	if((xm < carregamentos{j}.end_position) && (xm > carregamentos{j}.start_position))
		index_carregamento = j;
		break;
	end
    end

    # Se for carregamento, realiza tratamento especifico
    if index_carregamento != 0
      x0 = carregamentos{index_carregamento}.start_position;
      x1 = carregamentos{index_carregamento}.end_position;
      polinomio = cell2mat(carregamentos{index_carregamento}.coefficients);
      int_poli = polyint(polinomio);
      for j = x0:(x1 - x0)/100:x1
        x_hist = [x_hist j];
        cul = sumVertical + (polyval(int_poli, j) - polyval(int_poli, x0));
        Fv_hist = [Fv_hist cul];
      end
      sumVertical += res;
    else
      sumVertical += res;
      Fv_hist = [Fv_hist sumVertical];
      x_hist = [x_hist xm];
    end
  end

  Fv_hist = [Fv_hist sumVertical];
  x_hist = [x_hist L];

  [xs, ys] = stairs(x_hist, Fv_hist);
  figure(3);
  plot(xs, ys, "linewidth", 2, "color", [1, 0.757, 0.027]);
  grid on;
  set(gca, "fontsize", 12);
  title("Esforços Internos - Força Cortante");
  xlabel("x [m]");
  ylabel("V(x) [N]");

endfunction
