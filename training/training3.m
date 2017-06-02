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

concatenated = [afilelist;efilelist;ehfilelist;ifilelist;ofilelist;ohfilelist;ufilelist];

retorno = obtainZerosEnergy(concatenated);
zeros = cell2mat(retorno(1,1:end));
energies = cell2mat(retorno(2,1:end));
meanzero = mean(zeros);
maxzero = max(zeros);
minzero = min(zeros);
meanenergy = mean(energies);
maxenergy = max(energies);
minenergy = min(energies);


ztre = mean([meanzero minzero]);
etre = mean([meanenergy/4 2*minenergy]);