
%%testando
function vetor_apoio = reacao(x,forcas_y,forcas_x,M, T)
  
  %%posição 1 - coordenada x
  %%posição 2- Força Horizontal
  %%posição 3- Força vertical
  %%posição 4- Momento tensor
  %%posição 5- Torque
 
  %%Usuário insere o numero de apoios
  n = input(1)
  %Usuário preenche os tipos de apoio
  for i = 1:n
      apoio(1,n)=input(1)
  end for
      
     %%---------------------------------------------------------------
  for n_apoio = 1:nApoios
      %% ------------------------------------------------------------
      if apoio(1,n_apoio) == 1 %% apoio seja do tipo fixo
  %%somatório das forças na vertical 
  nForcas_y = size(forcas_y, 1);
  for forca = 1:nForcas_y
      F_v = forcas_y(forca, 2);
  end for
  %%somatório das forças na horizontal
      nForcas_x = size(forcas_x, 1);
  for forca = 1:nForcas_x
      F_h = forcas_x(forca, 2);
  end for
      %%somatório dos momentos flexores
      nMomentos = size(momentos, 1);
  for momentos = 1:nMomentos
      momento = M(momentos, 2);
  end for
      %somatório dos momentos flexores
      nTorques = size(T, 1);
  for torques = 1:nTorques
      momento = T(torques, 2);
  end for
      %%-----------------------------------------------------------------
      else %%apoio é do tipo rolamento
          %%somatório das forças na vertical 
  nForcas_y = size(forcas_y, 1);
  for forca = 1:nForcas_y
      F_v = forcas_y(forca, 2);
  end for
      F_h = 0;
      momento =0;
      Torque=0;
  end
  %% preenchimento do vetor de apoios a cada iteração
  vetor_apoio(n_apoio,1) = forca(n_apoio,1);
  vetor_apoio(n_apoio,2) = F_v;
  vetor_apoio(n_apoio,3) = F_h;
  vetor_apoio(n_apoio,4) = momento;
  vetor_apoio(n_apoio,5) = T;
  end for
      

