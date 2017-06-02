clc
clear all
close all

% add as pastas util e voicebox no path para utilizar as funções auxiliares
addpath(genpath('..\util\'));
addpath(genpath('..\voicebox'));

% add a pasta dos áudios ao path
addpath(genpath('vogais\'));

%recupera as listas de arquivos
afilelist = getAllFiles('vogais\a','*.wav',0);
efilelist = getAllFiles('vogais\e','*.wav',0);
ehfilelist = getAllFiles('vogais\eh','*.wav',0);
ifilelist = getAllFiles('vogais\i','*.wav',0);
ofilelist = getAllFiles('vogais\o','*.wav',0);
ohfilelist = getAllFiles('vogais\oh','*.wav',0);
ufilelist = getAllFiles('vogais\u','*.wav',0);

%obtém-se as matrizes de mfcc de todos eles
amfcc = getMFCCDataMatrix(afilelist);
emfcc = getMFCCDataMatrix(efilelist);
ehmfcc = getMFCCDataMatrix(ehfilelist);
imfcc = getMFCCDataMatrix(ifilelist);
omfcc = getMFCCDataMatrix(ofilelist);
ohmfcc = getMFCCDataMatrix(ohfilelist);
umfcc = getMFCCDataMatrix(ufilelist);

amfccmatrix = cell2mat(amfcc(1:end-7));
emfccmatrix = cell2mat(emfcc(1:end));
ehmfccmatrix = cell2mat(ehmfcc(1:end));
imfccmatrix = cell2mat(imfcc(1:end));
omfccmatrix = cell2mat(omfcc(1:end));
ohmfccmatrix = cell2mat(ohmfcc(1:end));
umfccmatrix = cell2mat(umfcc(1:end));


%treinando rna

%cria o vetor de treino e o targets
totaldata=[amfccmatrix;emfccmatrix;ehmfccmatrix;imfccmatrix;omfccmatrix;ohmfccmatrix;umfccmatrix];
% 
% 
targets = zeros(1,size(totaldata,1));
targets(1:size(amfccmatrix,1)) = 1;
% %targets = vertcat(targetsa,targetse,targetseh,targetsi,targetso,targetsoh,targetsu);
% 
totaldata = totaldata';
% 
% gpu1 = gpuDevice(1)
% net = patternnet([150 100 50]);
% net.divideFcn = 'dividerand';
% net.divideMode = 'sample';
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
% 
% gera as matrizes de treinamento e validação
Q = size(totaldata,2);
Q1 = floor(Q * 0.80);
Q2 = Q - Q1;
ind = randperm(Q);
ind1 = ind(1:Q1);
ind2 = ind(Q1 + (1:Q2));
x1 = totaldata(:, ind1);
t1 = targets(:, ind1);
x2 = totaldata(:, ind2);
t2 = targets(:, ind2);

load nettr22.mat;
teste = nettr(x1);
teste2 = nettr(x2);
plotconfusion(t1,teste,'treinamento',t2,teste2,'validação');
% 
% numNN = 10;
% % célula para armazenar as redes treinadas
% NN = cell(1, numNN);
% % células pra armazenar os desempenhos das redes 
% perfs = zeros(1, numNN);
% perfs2 = zeros(1,numNN);
% 
% %net2 = configure(net,totaldata,targets);
% for i = 1:numNN
%   fprintf('Training %d/%d\n', i, numNN);
%   NN{i} = train(net,x1,t1,'useGPU','yes','showResources','yes');
%   y2 = NN{i}(x2);
%   perfs(i) = mse(net, t2, y2);
%   perfs2(i) = perform(net,y2,t2);
% end


% nettr = NN{2};
% save ('nettr23.mat','nettr');
