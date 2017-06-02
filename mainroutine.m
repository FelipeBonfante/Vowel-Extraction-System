% ========================================================================%
% Trabalho de conclus�o de curso - Engenharia de Computa��o               %
% Universidade Tecnol�gica Federal do Paran�                              %
% Extra��o autom�tica de f�nemas voc�licos em sinais de �udio             %
%                                                                         %
% Arquivo principal o qual le um arquivo no formato wav e grava todas as  %
% vogais \a\ encontradas                                                  %
%                                                                         %   
% ========================================================================%

clc
clear all
close all

% Adiciona as pastas necess�rias que cont�m arquivos de fun��es utilizadas
% ao caminho do matlab
voiceboxpath = genpath('voicebox');
featureextractionpath = genpath('featureExtraction');
utilpath = genpath('util');
trainingandneuralnetworktoolspath = genpath('trainingAndNeuralNetworkTools');
outputpath = genpath('output');
trainingpath = genpath('training');
addpath(voiceboxpath,featureextractionpath,utilpath,trainingandneuralnetworktoolspath,outputpath,trainingpath);

disp('carregando arquivo de �udio...')
% carrega o �udio para extrair as vogais \a\ 
filetoextract = 'palavra1faca.wav';
[y,Fs] = audioread(filetoextract);

disp('�udio carregado. Segmentando o sinal em frames de 20ms sem overlap');
% segmenta o �udio em frames sem overlaping de 20ms
framelength = floor(Fs*0.02);
% overlap = floor(framelength/2);
% yframed = enframe(y,framelength,overlap);
yframed = enframe(y,framelength);

% estrutura de c�lula para guardar a refer�ncia de quais frames s�o vogais
vogaisref = cell(1,size(yframed,1));

% carrega a rede neural treinada para usar na classifica��o
load nettr22;
view(nettr)
% vari�veis para controle de �ndices de acesso
i = 1;
p = 2;

% trecho de teste
% teste = y(10*framelength:11*framelength);
% plot(teste)
% sound(teste,Fs)
% cep = extractmfcc(teste,Fs);
% res = nettr(cep');

disp('iniciando a rotina de busca por vogais \a\')
%calcula o total de frames a partir dos frames gerados
totalframes = size(yframed,1);
% vari�vel pra armazenar a quantidade de \as\ encontrados
contadordeas = 0;
% come�a a itera��o nos frames para an�lise e classifica��o
% while i<totalframes
%     % extrai o frame atual para an�lise
%     frame = y(i*framelength:p*framelength);
%     
%     % extrai o mfcc do trecho
%     ceps = extractmfcc(frame,Fs);
%     
%     % aplica os coeficientes na rede para obter a sa�da estimada
%     saida = nettr(ceps');
%     saidaa = max(saida);
%     
%     
%     % verifica se a sa�da representa um poss�vel a    
%     if saidaa >=0.9
%         disp('poss�vel a encontrado')
%         % agora come�a uma sub verifica��o, para ver at� onde o poss�vel 
%         % a se extende        
%         curr = i + 1;
%         pos = curr + 1;
%         % flag para indicar se � ou n�o a
%         flag = 1;
%         % enquanto a flag for positiva e n�o se atingiu o final do �udio
%         while(flag && curr<totalframes)
%             % repete os mesmos processos anteriores para classificar
%             frameaux = y(curr*framelength:pos*framelength);
%             cepsaux = extractmfcc(frameaux,Fs);
%             saidaaux = nettr(cepsaux');            
%             saidaauxa = max(saidaaux); 
%             % se ainda � a continua a rotina incrementando as vari�veis de
%             % indice
%             if saidaauxa >= 0.9
%                 flag = 1;
%                 curr = curr + 1;
%                 pos = curr+1;
%             else
%                 flag = 0;
%                 flag2 =1;
%                 acumulador = [];
%                 k = i;
%                 while k < curr
%                     low = k;
%                     high = k+1;
%                     acumular = y(low*framelength:high*framelength-1);
%                     acumulador = cat(1,acumulador,acumular);                    
%                     k = k + 1;
%                 end
%                 i = curr - 1;
%             end
%         end
%         
%         % se encontrou vogal \a\ a flag 2 estar� true
%         if flag2
%             % se o trecho de poss�vel a for significante, isto �, ter pelo 
%             % menos tamanho superior a 40ms, este � contabilizado e salvo
%             if length(acumulador)>2*framelength+1
%                 disp('encontrei um a')
%                 contadordeas = contadordeas + 1;
%                 saveaudiofile(acumulador,Fs);
%             end
%             % zera a flag para a an�lise do poss�vel pr�ximo a
%             flag2 = 0;
%         end
%        
%         
%     end
%     i = i + 1;
%     p = i + 1;
% 
% end
% 
% disp('fim do procedimento')
% contadorstr = num2str(contadordeas);
% saidatexto = sprintf('foram encontrados %s fonemas a',contadorstr);
% disp(saidatexto)


