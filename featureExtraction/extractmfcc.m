function [ ceps ] = extractmfcc( frame,Fs )
%EXTRACTMFCC Extrai os coeficientes de mfcc, com energia e coeficientes
%delta e delta-delta
%   inputs:
%       - frame: sinal a ser extraído os coefs
%       - Fs: frequência de amostragem
%   outputs:
%       - ceps: 39 coeficientes
    framelengthanalysis = pow2(floor(log2(0.020*Fs)));
    inc = framelengthanalysis/2;
    p = floor(3*log(Fs));
    preemph = [1 0.97];
    frame = filter(1,preemph,frame);
    ceps = melcepst(frame,Fs,'EdD',12,p,framelengthanalysis,inc);

end

