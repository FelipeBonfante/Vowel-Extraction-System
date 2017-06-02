clc
clear all
close all
% add as pastas util e voicebox no path para utilizar as funções auxiliares
addpath(genpath('..\util\'));
addpath(genpath('..\voicebox'));
addpath(genpath('..\featureExtraction\'));
% add as pastas dos áudios ao path

addpath(genpath('amostrasvogais'));
addpath(genpath('amostrasnaovogais'));

% Recupera todos os arquivos de áudio para vogais \a\
disp('arquivos de a')
aFileList = getAllFiles('amostrasvogais','*.wav',0);
% recupera todos os arquivos que não são vogais \a\
disp('arquivos de na')
naFileList = getAllFiles('amostrasnaovogais','*.wav',0);

% obtém-se os coeficientes MFCC dos áudios, já disposto em forma de matrix
% armazenando-o numa estrutura de célula
disp('mfcc de a')
AMatrixCell = getMFCCdataMatrixFromAudioFiles(aFileList);

% executa o mesmo passo anterior para as não vogais
disp('mfcc de na')
NAMatrixCell = getMFCCdataMatrixFromAudioFiles(naFileList);

% recupera as matrizes das células
aDataMatrix = cell2mat( AMatrixCell(1:size(AMatrixCell)) );
naDataMatrix = cell2mat( NAMatrixCell(1:size(NAMatrixCell)) );

amodel = fitgmdist(aDataMatrix,3);
namodel = fitgmdist(naDataMatrix,3);
% normaliza os dados
% aDataMatrix = mapminmax(aDataMatrix);
% naDataMatrix = mapminmax(naDataMatrix);
% junta as amostras e normaliza
totaldata =[aDataMatrix;naDataMatrix];
totaldata = mapminmax(totaldata);
% [totaldata,dset] = mapstd(totaldata);

% gera os targets
targets = zeros(1,size(totaldata,1));
targets(1:size(aDataMatrix,1)) = 1;
%targets(2,size(aDataMatrix,1)+1:size(totaldata,1)) = 1;
totaldata = totaldata';

% cria a rede neural patternnet e declara alguns parâmetros
% trainfunctions = {'trainlm','trainscg','trainbr'};
Q = size(totaldata,2);
Q1 = floor(Q * 0.90);
Q2 = Q - Q1;
ind = randperm(Q);
ind1 = ind(1:Q1);
ind2 = ind(Q1 + (1:Q2));
x1 = totaldata(:, ind1);
t1 = targets(:, ind1);
x2 = totaldata(:, ind2);
t2 = targets(:, ind2);

gpu1 = gpuDevice(1)
net = patternnet([100 50],'trainlm');
net.divideFcn = 'dividerand';
net.divideMode = 'sample';
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

numNN = 2;
NN = cell(1, numNN);
perfs = zeros(1, numNN);
perfs2 = zeros(1,numNN);

for i = 1:numNN
  fprintf('Training %d/%d\n', i, numNN);
  NN{i} = train(net,x1,t1,'useGPU','yes','showResources','yes');
  y2 = NN{i}(x2);
  perfs(i) = mse(net, t2, y2);
  perfs2(i) = perform(net,y2,t2);
end

neuralnetwork = NN{1};
save neuralnetwork;
% % % load neuralnetwork;
% % % 
% % % info = audioinfo('A-15-03-2002-ACV-M.wav')
save amodel;
save namodel;
[sig,freq] = audioread('vowelAsignal1.wav');
framelength = pow2(floor(log2(0.020*freq)));
inc = framelength/2;
p = floor(3*log(freq));
preemph = [1 0.97];
sig = filter(1,preemph,sig);
%sig=sig.*hamming(length(sig));

ceps = melcepst(sig,freq,'EdD',12,p,framelength,inc);
[p,logl] = posterior(amodel,ceps);
[p2,logl2] = posterior(namodel,ceps);
% ceps = mapminmax(ceps);
% ceps = ceps';
% saidaTeste = neuralnetwork(ceps);

% plot(sig(40000:100000));
%sound(sig(40100:40100+4*framelength),freq);
% siny=sin(2*pi*(0:1000)/200); 
% siny(1:100:1001)=0; 
% [zeros,timeslope] = zerocros(sig);

% info = audioinfo('A-15-03-2002-ACV-M.wav')
% [sig,freq] = audioread('LapsBM_0063.wav');
% framelength = floor(0.02*freq);
% inc = framelength/2;
% p = floor(3*log(freq));
% preemph = [1 0.97];
% sig = filter(1,preemph,sig);
% sigframe = enframe(sig,framelength,floor(framelength/2));
% saidacell = cell(size(sigframe,1));
% for k = 1:size(sigframe,1)
%     lpcval = lpcauto(sigframe(k,:),14);
%     lpcval = mapminmax(lpcval);
%     lpcval = lpcval';
%     saidacell{k} = neuralnetwork(lpcval);
% end
% 
% saidacellnum = cell2mat(saidacell);



%  Tw = 20;           % analysis frame duration (ms)
%           Ts = 10;           % analysis frame shift (ms)
%           alpha = 0.97;      % preemphasis coefficient
%           R = [ 300 3700 ];  % frequency range to consider
%           M = 20;            % number of filterbank channels 
%           C = 13;            % number of cepstral coefficients
%           L = 22;            % cepstral sine lifter parameter
%       
%           % hamming window (see Eq. (5.2) on p.73 of [1])
%           hamming = @(N)(0.54-0.46*cos(2*pi*[0:N-1].'/(N-1)));
%       
%           % Read speech samples, sampling rate and precision from file
%           [ speech, fs ] = audioread( 'A-01-02-2002-ACV-M.wav' );
%       
%           % Feature extraction (feature vectors as columns)
%           [ MFCCs, FBEs, frames ] = ...
%                           mfcc( speech, fs, Tw, Ts, alpha, hamming, R, M, C, L );
%           ceps = melcepst(speech,fs,'0');
%       
%           % Plot cepstrum over time
%           figure('Position', [30 100 800 200], 'PaperPositionMode', 'auto', ... 
%                  'color', 'w', 'PaperOrientation', 'landscape', 'Visible', 'on' ); 
%       
%           imagesc( [1:size(MFCCs,2)], [0:C-1], MFCCs ); 
%           axis( 'xy' );
%           xlabel( 'Frame index' ); 
%           ylabel( 'Cepstrum index' );
%           title( 'Mel frequency cepstrum' );
% 
% 
% [sigg, fss] = audioread('001.wav');
% subplot(2,1,1);
% plot(sigg)
% subplot(2,1,2);
% plot(speech)

% [y,fs] = audioread('vowelAsignal5.wav');
% newlength = floor((fs)*0.02);
% segmento = y(newlength*2:newlength*3);
% forms = formantsextraction(segmento,fs);
%forms = mapstd(forms);
% forms = forms';
% ymax = 1;
% ymin = -1;
% xmax = max(forms);
% xmin = min(forms);
%forms = (ymax-ymin)*(forms-xmin)/(xmax-xmin) + ymin;
%forms = mapminmax(forms);

% ysaida = neuralnetwork(forms);




