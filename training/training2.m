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

amfccmatrix = cell2mat(amfcc(1:end));
emfccmatrix = cell2mat(emfcc(1:end));
ehmfccmatrix = cell2mat(ehmfcc(1:end));
imfccmatrix = cell2mat(imfcc(1:end));
omfccmatrix = cell2mat(omfcc(1:end));
ohmfccmatrix = cell2mat(ohmfcc(1:end));
umfccmatrix = cell2mat(umfcc(1:end));

%gera os modelos de gmm 
% agmmmodel = fitgmdist(amfccmatrix,13,'RegularizationValue',1e-5);
% egmmmodel = fitgmdist(emfccmatrix,13,'RegularizationValue',1e-5);
% ehgmmmodel = fitgmdist(ehmfccmatrix,13,'RegularizationValue',1e-5);
% igmmmodel = fitgmdist(imfccmatrix,13,'RegularizationValue',1e-5);
% ogmmmodel = fitgmdist(omfccmatrix,13,'RegularizationValue',1e-5);
% ohgmmmodel = fitgmdist(ohmfccmatrix,13,'RegularizationValue',1e-5);
% ugmmmodel = fitgmdist(umfccmatrix,13,'RegularizationValue',1e-5);


%testando 
[sig,freq]=audioread('frase1teste2.wav');
framelength = pow2(floor(log2(0.020*freq)));
inc = framelength/2;
p = floor(3*log(freq));
preemph = [1 0.97];
sig = filter(1,preemph,sig);
ceps = melcepst(sig,freq,'EdD',12,p,framelength,inc);
ceps2 = mean(ceps(1,:));
% [pa,loga]=posterior(agmmmodel,ceps);
% [pe,loge]=posterior(egmmmodel,ceps);
% [peh,logeh]=posterior(ehgmmmodel,ceps);
% [pi,logi]=posterior(igmmmodel,ceps);
% [po,logo]=posterior(ogmmmodel,ceps);
% [poh,logoh]=posterior(ohgmmmodel,ceps);
% [pu,logu]=posterior(ugmmmodel,ceps);

%treinando rna

%cria o vetor de treino e o targets
totaldata=[amfccmatrix;emfccmatrix;ehmfccmatrix;imfccmatrix;omfccmatrix;ohmfccmatrix;umfccmatrix];

targetsa = zeros(1,size(totaldata,1));
targetsa(1:size(amfccmatrix,1)) = 1;
% fimanterior = size(amfccmatrix,1)+1;
% targetse = zeros(1,size(totaldata,1));
% targetse(fimanterior:fimanterior+size(emfccmatrix,1)) = 1;
% fimanterior = fimanterior + size(emfccmatrix,1)+1;
% targetseh = zeros(1,size(totaldata,1));
% targetseh(fimanterior:fimanterior+size(ehmfccmatrix,1)) = 1;
% fimanterior = fimanterior+size(ehmfccmatrix,1)+1;
% targetsi = zeros(1,size(totaldata,1));
% targetsi(fimanterior:fimanterior+size(imfccmatrix,1)) = 1;
% fimanterior = fimanterior+size(imfccmatrix,1)+1;
% targetso = zeros(1,size(totaldata,1));
% targetso(fimanterior:fimanterior+size(omfccmatrix,1)) = 1;
% fimanterior = fimanterior+size(omfccmatrix,1)+1;
% targetsoh = zeros(1,size(totaldata,1));
% targetsoh(fimanterior:fimanterior+size(ohmfccmatrix,1)) = 1;
% fimanterior = fimanterior+size(ohmfccmatrix,1)+1;
% targetsu = zeros(1,size(totaldata,1));
% targetsu(fimanterior:end) = 1;
% fimanterior = fimanterior+size(umfccmatrix,1)+1;
% 
% targets = vertcat(targetsa,targetse,targetseh,targetsi,targetso,targetsoh,targetsu);

totaldata = totaldata';
totaldata = mapminmax(totaldata);

gpu1 = gpuDevice(1)
net = patternnet([150 150 100]);
net.divideFcn = 'dividerand';
net.divideMode = 'sample';
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
net.outputs{1}.processFcns = {'mapminmax'};
net.outputs{2}.processFcns = {'mapminmax'};

Q = size(totaldata,2);
Q1 = floor(Q * 0.90);
Q2 = Q - Q1;
ind = randperm(Q);
ind1 = ind(1:Q1);
ind2 = ind(Q1 + (1:Q2));
x1 = totaldata(:, ind1);
t1 = targetsa(:, ind1);
x2 = totaldata(:, ind2);
t2 = targetsa(:, ind2);

numNN = 10;
NN = cell(1, numNN);
perfs = zeros(1, numNN);
perfs2 = zeros(1,numNN);

x1gpu = nndata2gpu(x1);
t1gpu = nndata2gpu(t1);
x2gpu = nndata2gpu(x2);
t2gpu = nndata2gpu(t2);
net2 = configure(net,totaldata,targetsa);
for i = 1:numNN
  fprintf('Training %d/%d\n', i, numNN);
  NN{i} = train(net2,x1,t1,'useGPU','yes','showResources','yes');
  %NN{i} = train(net,totaldata,targets,'useGPU','yes','showResources','yes');
  y2 = NN{i}(x2);
  perfs(i) = mse(net, t2, y2);
  perfs2(i) = perform(net,y2,t2);
end


% % nettr = NN{6};
% % save ('nettr.mat','nettr');
