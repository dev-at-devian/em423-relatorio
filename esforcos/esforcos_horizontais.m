function retval = esforcosHorizontais (forcas_horizontais, apoios, L)

  vetorHorizontal = forcas_horizontais;

  # Junta os apoios com reacao horizontal ao conjunto de forcas
  n_apoios = length(apoios);

  for i = 1:n_apoios
	apoio = apoios{i};
    	if !isnan(apoio.horizontal)
       		vetorHorizontal{end+1} = struct("value", apoio.horizontal, "position", apoio.position);
    	end
  end

  # Sort forcas horizontais baseado em sua posicao x
  n_horizontais = length(vetorHorizontal);

  for i = 1:n_horizontais
	smaller = vetorHorizontal{i}.position;
        smaller_index = i;
	for j = i:n_horizontais
		if(vetorHorizontal{j}.position < smaller)
			smaller = vetorHorizontal{j}.position;
			smaller_index = j;
		end
	end
        swap = vetorHorizontal{i};
        vetorHorizontal{i} = vetorHorizontal{smaller_index};
	vetorHorizontal{smaller_index} = swap;
  end

  sumHorizontal = 0;
  x_hist = [];
  T_hist = [];

  T_hist = [T_hist 0];
  x_hist = [x_hist 0];

  for i = 1:n_horizontais
    x_hist = [x_hist vetorHorizontal{i}.position];
    sumHorizontal -= vetorHorizontal{i}.value;
    T_hist = [T_hist sumHorizontal];
  end

  T_hist = [T_hist sumHorizontal];
  x_hist = [x_hist L];

  [xs, ys] = stairs(x_hist, T_hist);
  figure(1);
  plot(xs, ys, "linewidth", 2, "color", [1, 0.435, 0]);
  grid on;
  set(gca, "fontsize", 12);
  title("Esforços Internos - Força Normal");
  xlabel("x [m]");
  ylabel("N(x) [N]");

endfunction
