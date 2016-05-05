function [ bw, L, n ] = maiorRegiao( img )
%Retorna uma imagem binarizada apenas com a maior regiao e a quantidade de
%regioes

    % Imagem binarizada das sementes detectadas
    bw = im2bw(img, 0.5);
    [L, n] = bwlabel(bw);

    aux = zeros(n,1);
    for i = 1 : n
        aux(i) = size(find(L==i),1);    % Salva o tamanho das regiões encontradas
    end

    [~, ind] = max(aux);

    % Na imagem fica apenas a maior regiao
    if ~isempty(ind)
        bw(L~=ind) = 0;
    end

end

