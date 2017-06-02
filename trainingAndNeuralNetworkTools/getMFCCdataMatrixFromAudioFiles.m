function M = getMFCCdataMatrixFromAudioFiles(fileList)
% Retorna a matrix com os 39 coeffs para a lista de arquivos de áudio passadas
% input
%   - fileList: lista de arquivos .wav
% output
%   - M = estrutura de célula contendo todas as amostras de coeffs para a
%       lista de áudio. Cada linha da célula possui a matrix de coeffs para
%       cada áudio

    M = cell(size(fileList,1),1);
    preemph = [1 0.97];
    
    for i=1:1:size(fileList)
        [filep,name,ext] = fileparts(strjoin(fileList(i)));
        [y,Fs] = audioread(strcat(filep,'\',name,ext));
        framelength = pow2(floor(log2(0.020*Fs)));
        inc = framelength/2;
        p = floor(3*log(Fs));
        y = filter(1,preemph,y);
        M{i} = melcepst(y,Fs,'EdD',12,p,framelength,inc);
    end

%     for i=1:1:size(fileList)
%         [filep,name,ext] = fileparts(strjoin(fileList(i)));
%         [y,Fs] = audioread(strcat(filep,'\',name,ext));        
%         framelength = floor(0.02*Fs);        
%         inc = floor(framelength/2);
%         yframed = enframe(y,framelength);
%         subcell = cell(size(yframed,1),3);
%         for j=1:size(yframed,1)        
%             subcell{j} = formantsextraction(yframed(j,:),Fs);
%         end
%         M{i} = cell2mat(subcell);
%     end
        
end