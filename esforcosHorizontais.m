function retval = esforcosHorizontais (forcas_horizontais, apoios, L)

  vetorHorizontal = forcas_horizontais;

  # Junta os apoios com reacao horizontal ao conjunto de forcas
  n_apoios = size(apoios, 2);

  for i = 1:n_apoios
	apoio = cell2mat(apoios{i});	
    	if !isnan(apoio(2))
       		vetorHorizontal{end+1} = {apoio(2), apoio(1)};
    	end
  end

  # Sort forcas horizontais baseado em sua posicao x
  n_horizontais = size(vetorHorizontal, 2);

  for i = 1:n_horizontais
	smaller = vetorHorizontal{i}{2};
        smaller_index = i;
	for j = i:n_horizontais
		if(vetorHorizontal{j}{2} < smaller)
			smaller = vetorHorizontal{j}{2};
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
    x_hist = [x_hist vetorHorizontal{i}{2}];
    sumHorizontal -= vetorHorizontal{i}{1};
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
