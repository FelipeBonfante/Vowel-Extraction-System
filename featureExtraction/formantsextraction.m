function [ formants ] = formantsextraction( signal,fs )
%formantsextraction Função para extração das duas primeiras formantes,
%   utilizando o algorítmo de Burg
%     -inputs:
%             signal - vetor contendo o sinal de áudio
%             fs - frequência de amostragem
%     -outputs:
%             formants - as duas primeiras frequências formantes

    % resampling no sinal para uma frequencia de amostragem menor.
    % Resampling em 1/4 da fs
    frame = decimate(signal,4);
    
    % aplica um filtro pre enfase
    preemph = [1 0.97];
    frame = filter(1,preemph,frame);
    
    % obtém o tamanho da nova janela de 20ms em relação a nova frequência de
    % amostragem
    newlength = floor((fs/4)*0.02);
    
    % aplica uma janela de hamming de 20ms no sinal
    frame = frame.*hamming(length(newlength));
    
    % extrai os coeficientes de lpc do sinal, de ordem 14
    [coeffs,e] = lpc(frame,14);
    
    % acha as raízes complexas dos coeficientes e mantém apenas os pares
    % positivos
    r = roots(coeffs);
    r = r(imag(r) > 0);
    
    % calcula as frequências formantes a partir das raízes, pelo algorítmo 
    % de burg e ordena de forma crescente
    [ffreq,inds] = sort(atan2(imag(r), real(r)) * fs / (8*pi));
    
    % calcula a largura de banda
    bw = -((fs/4)/(2*pi))*log(abs(r(inds)));
    
    nn = 1;
    % seleciona apenas as frequências acima de 90Hz com largura de banda
    % inferior a 400
    for kk = 1:length(ffreq)
       if (ffreq(kk) > 100 && bw(kk)<800)
           formants(nn) = ffreq(kk);
           nn = nn+1;
       end
    end
    % retém-se apenas as 3 primeiras frequências formantes
    formants = formants(1:3)
end

