% ========================================================================%
% Trabalho de conclusão de curso - Engenharia de Computação               %
% Universidade Tecnológica Federal do Paraná                              %
% Extração automática de fônemas vocálicos em sinais de áudio             %
%                                                                         %
% Arquivo principal o qual le um arquivo no formato wav e grava todas as  %
% vogais \a\ encontradas                                                  %
%                                                                         %   
% ========================================================================%

clc
clear all
close all

% Adiciona as pastas necessárias que contém arquivos de funções utilizadas
% ao caminho do matlab
voiceboxpath = genpath('voicebox');
featureextractionpath = genpath('featureExtraction');
utilpath = genpath('util');
trainingandneuralnetworktoolspath = genpath('trainingAndNeuralNetworkTools');
outputpath = genpath('output');
trainingpath = genpath('training');
addpath(voiceboxpath,featureextractionpath,utilpath,trainingandneuralnetworktoolspath,outputpath,trainingpath);

disp('carregando arquivo de áudio...')
% carrega o áudio para extrair as vogais \a\ 
filetoextract = 'palavra1faca.wav';
[y,Fs] = audioread(filetoextract);

disp('áudio carregado. Segmentando o sinal em frames de 20ms sem overlap');
% segmenta o áudio em frames sem overlaping de 20ms
framelength = floor(Fs*0.02);
% overlap = floor(framelength/2);
% yframed = enframe(y,framelength,overlap);
yframed = enframe(y,framelength);

% estrutura de célula para guardar a referência de quais frames são vogais
vogaisref = cell(1,size(yframed,1));

% carrega a rede neural treinada para usar na classificação
load nettr22;
view(nettr)
% variáveis para controle de índices de acesso
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
% variável pra armazenar a quantidade de \as\ encontrados
contadordeas = 0;
% começa a iteração nos frames para análise e classificação
% while i<totalframes
%     % extrai o frame atual para análise
%     frame = y(i*framelength:p*framelength);
%     
%     % extrai o mfcc do trecho
%     ceps = extractmfcc(frame,Fs);
%     
%     % aplica os coeficientes na rede para obter a saída estimada
%     saida = nettr(ceps');
%     saidaa = max(saida);
%     
%     
%     % verifica se a saída representa um possível a    
%     if saidaa >=0.9
%         disp('possível a encontrado')
%         % agora começa uma sub verificação, para ver até onde o possível 
%         % a se extende        
%         curr = i + 1;
%         pos = curr + 1;
%         % flag para indicar se é ou não a
%         flag = 1;
%         % enquanto a flag for positiva e não se atingiu o final do áudio
%         while(flag && curr<totalframes)
%             % repete os mesmos processos anteriores para classificar
%             frameaux = y(curr*framelength:pos*framelength);
%             cepsaux = extractmfcc(frameaux,Fs);
%             saidaaux = nettr(cepsaux');            
%             saidaauxa = max(saidaaux); 
%             % se ainda é a continua a rotina incrementando as variáveis de
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
%         % se encontrou vogal \a\ a flag 2 estará true
%         if flag2
%             % se o trecho de possível a for significante, isto é, ter pelo 
%             % menos tamanho superior a 40ms, este é contabilizado e salvo
%             if length(acumulador)>2*framelength+1
%                 disp('encontrei um a')
%                 contadordeas = contadordeas + 1;
%                 saveaudiofile(acumulador,Fs);
%             end
%             % zera a flag para a análise do possível próximo a
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


