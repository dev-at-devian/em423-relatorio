function retval = esforcosTorques (Torques, apoios, L)
  
  vetorTorques = Torques;

  # Junta os apoios com reacao de torque ao conjunto de torques
  n_apoios = size(apoios, 2);

  for i = 1:n_apoios
	apoio = cell2mat(apoios{i});	
    	if !isnan(apoio(5))
       		vetorTorques{end+1} = {apoio(5), apoio(1)};
    	end
  end

  # Sort forcas horizontais baseado em sua posicao x
  n_Torques = size(vetorTorques, 2);

  for i = 1:n_Torques
	smaller = vetorTorques{i}{2};
        smaller_index = i;
	for j = i:n_Torques
		if(vetorTorques{j}{2} < smaller)
			smaller = vetorTorques{j}{2};
			smaller_index = j;
		end
	end
        swap = vetorTorques{i};
        vetorTorques{i} = vetorTorques{smaller_index};
	vetorTorques{smaller_index} = swap;
  end	

  %% Divisao em nTensores segmentos
  nTorques = size(vetorTorques, 2);
  
  sumTorques = 0;
  x_hist = [];
  T_hist = [];
  
  T_hist = [T_hist 0];
  x_hist = [x_hist 0];
  
  for i = 1:nTorques
    x_hist = [x_hist vetorTorques{i}{2}];
    sumTorques -= vetorTorques{i}{1};
    T_hist = [T_hist sumTorques];
  end
    
  T_hist = [T_hist sumTorques];
  x_hist = [x_hist L];
 
  [xs, ys] = stairs(x_hist, T_hist);
  figure(2); 
  plot(xs, ys, "linewidth", 2, "color", [1, 0.09, 0.016]);
  grid on;
  set(gca, "fontsize", 12);
  title("Esforços Internos - Torque");
  xlabel("x [m]");
  ylabel("T [Nm]");

endfunction
