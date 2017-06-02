% clc
% clear all
% close all
% 
% % add as pastas util e voicebox no path para utilizar as fun��es auxiliares
% addpath(genpath('..\util\'));
% addpath(genpath('..\voicebox'));
% 
% % add a pasta dos �udios ao path
% addpath(genpath('vogais\'));
% 
% %recupera as listas de arquivos
% afilelist = getAllFiles('vogais\a','*.wav',0);
% efilelist = getAllFiles('vogais\e','*.wav',0);
% ehfilelist = getAllFiles('vogais\eh','*.wav',0);
% ifilelist = getAllFiles('vogais\i','*.wav',0);
% ofilelist = getAllFiles('vogais\o','*.wav',0);
% ohfilelist = getAllFiles('vogais\oh','*.wav',0);
% ufilelist = getAllFiles('vogais\u','*.wav',0);
% 
% %obt�m-se as matrizes de mfcc de todos eles
% amfcc = getMFCCDataMatrix(afilelist);
% emfcc = getMFCCDataMatrix(efilelist);
% ehmfcc = getMFCCDataMatrix(ehfilelist);
% imfcc = getMFCCDataMatrix(ifilelist);
% omfcc = getMFCCDataMatrix(ofilelist);
% ohmfcc = getMFCCDataMatrix(ohfilelist);
% umfcc = getMFCCDataMatrix(ufilelist);
% 
% amfccmatrix = cell2mat(amfcc(1:end-7));
% emfccmatrix = cell2mat(emfcc(1:end));
% ehmfccmatrix = cell2mat(ehmfcc(1:end));
% imfccmatrix = cell2mat(imfcc(1:end));
% omfccmatrix = cell2mat(omfcc(1:end));
% ohmfccmatrix = cell2mat(ohmfcc(1:end));
% umfccmatrix = cell2mat(umfcc(1:end));
% 
% %gera os modelos de gmm 
% % agmmmodel = fitgmdist(amfccmatrix,13,'RegularizationValue',1e-5);
% % egmmmodel = fitgmdist(emfccmatrix,13,'RegularizationValue',1e-5);
% % ehgmmmodel = fitgmdist(ehmfccmatrix,13,'RegularizationValue',1e-5);
% % igmmmodel = fitgmdist(imfccmatrix,13,'RegularizationValue',1e-5);
% % ogmmmodel = fitgmdist(omfccmatrix,13,'RegularizationValue',1e-5);
% % ohgmmmodel = fitgmdist(ohmfccmatrix,13,'RegularizationValue',1e-5);
% % ugmmmodel = fitgmdist(umfccmatrix,13,'RegularizationValue',1e-5);
% 
% 
% % [pa,loga]=posterior(agmmmodel,ceps);
% % [pe,loge]=posterior(egmmmodel,ceps);
% % [peh,logeh]=posterior(ehgmmmodel,ceps);
% % [pi,logi]=posterior(igmmmodel,ceps);
% % [po,logo]=posterior(ogmmmodel,ceps);
% % [poh,logoh]=posterior(ohgmmmodel,ceps);
% % [pu,logu]=posterior(ugmmmodel,ceps);
% 
% %treinando rna
% 
% %cria o vetor de treino e o targets
% totaldata=[amfccmatrix;emfccmatrix;ehmfccmatrix;imfccmatrix;omfccmatrix;ohmfccmatrix;umfccmatrix];
% % targets=zeros(7,size(totaldata,1));
% % targets(1,1:size(amfccmatrix,1))=1;
% % targets(2,size(amfccmatrix,1)+1:size(emfccmatrix,1)) = 1;
% % targets(3,size(emfccmatrix,1)+1:size(ehmfccmatrix,1)) = 1;
% % targets(4,size(ehmfccmatrix,1)+1:size(imfccmatrix,1)) = 1;
% % targets(5,size(imfccmatrix,1)+1:size(omfccmatrix,1)) = 1;
% % targets(6,size(omfccmatrix,1)+1:size(ohmfccmatrix,1)) = 1;
% % targets(7,size(ohmfccmatrix,1)+1:size(umfccmatrix,1)) = 1;
% 
% targetsa = zeros(1,size(totaldata,1));
% targetsa(1:size(amfccmatrix,1)) = 1;
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
% targets = zeros(1,size(totaldata,1));
% targets(1:size(amfccmatrix,1)) = 1;
% %targets = vertcat(targetsa,targetse,targetseh,targetsi,targetso,targetsoh,targetsu);
% 
% totaldata = totaldata';
% totaldata = mapminmax(totaldata);
% 
% gpu1 = gpuDevice(1)
% net = patternnet([150 100 50]);
% net.divideFcn = 'dividerand';
% net.divideMode = 'sample';
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
% 
% Q = size(totaldata,2);
% Q1 = floor(Q * 0.90);
% Q2 = Q - Q1;
% ind = randperm(Q);
% ind1 = ind(1:Q1);
% ind2 = ind(Q1 + (1:Q2));
% x1 = totaldata(:, ind1);
% t1 = targets(:, ind1);
% x2 = totaldata(:, ind2);
% t2 = targets(:, ind2);
% 
% numNN = 10;
% NN = cell(1, numNN);
% perfs = zeros(1, numNN);
% perfs2 = zeros(1,numNN);
% 
% % x1gpu = nndata2gpu(x1);
% % t1gpu = nndata2gpu(t1);
% % x2gpu = nndata2gpu(x2);
% % t2gpu = nndata2gpu(t2);
% 
% % svmmodel = fitcsvm(x1',t1','KernelFunction','gaussian','Standardize',true,'ClassNames',[-1,1]);
% % svmmodelval = crossval(svmmodel)
% % svmmodelval.Trained{1}
% % error = kfoldLoss(svmmodelval)
% 
% %net2 = configure(net,totaldata,targets);
% for i = 1:numNN
%   fprintf('Training %d/%d\n', i, numNN);
%   NN{i} = train(net,x1,t1,'useGPU','yes','showResources','yes');
%   %NN{i} = train(net,totaldata,targets,'useGPU','yes','showResources','yes');
%   y2 = NN{i}(x2);
%   perfs(i) = mse(net, t2, y2);
%   perfs2(i) = perform(net,y2,t2);
% end


nettr = NN{2};
save ('nettr22.mat','nettr');
