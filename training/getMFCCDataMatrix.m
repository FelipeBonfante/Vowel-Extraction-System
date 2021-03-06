function M = getMFCCDataMatrix( fileList )
% Retorna a matrix com os 39 coeffs para a lista de arquivos de �udio passadas
% input
%   - fileList: lista de arquivos .wav
% output
%   - M = estrutura de c�lula contendo todas as amostras de coeffs para a
%       lista de �udio. Cada linha da c�lula possui a matrix de coeffs para
%       cada �udio
    M = cell(size(fileList,1),1);
    preemph = [1 0.97];
    
    for i=1:1:size(fileList)
        [filep,name,ext] = fileparts(strjoin(fileList(i)));
        [y,Fs] = audioread(strcat(filep,'\',name,ext));
        framelength = pow2(floor(log2(0.020*Fs)));
        inc = framelength/2;
        p = floor(3*log(Fs));
        y = filter(1,preemph,y);
        yframe = enframe(y,floor(Fs*0.020),floor(Fs*0.020/2));
        acumulador = [];
        for k = 1:size(yframe,1)            
            acumulador = vertcat(acumulador,melcepst(yframe(k,:),Fs,'EdD',12,p,framelength,inc));
        end
        M{i} = acumulador;
    end

end

