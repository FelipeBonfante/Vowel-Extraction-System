function [M] = obtainZerosEnergy( fileslist )
%OBTAINZEROSENERGY Summary of this function goes here
%   Detailed explanation goes here
    zcd = dsp.ZeroCrossingDetector;
    M = cell(2,size(fileslist,1));
    
    for i=1:size(fileslist,1)
        [filep,name,ext] = fileparts(strjoin(fileslist(i)));
        [y,Fs] = audioread(strcat(filep,'\',name,ext));
        framelength = floor(0.01*Fs);
        yframed = enframe(y,framelength);
        tamframes = size(yframed,1);
        zeros = [];
        energies = [];
        for k = 1 : tamframes
            frame = yframed(k,:);
            release(zcd);
            zeros(k) = double(step(zcd,frame(:)))/framelength;
            energies(k) = sum(frame.^2)/framelength;
        end
        
        M{1,i} = zeros;
        M{2,i} = energies;
    end

end

