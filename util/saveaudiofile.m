function saveaudiofile(signal,Fs)
    folder = '.\output\';
    filename = 'vowelAsignal';
    ext = '.wav';
    
    filenumber = getFileNumber(folder);
    
    fullfilename = strcat(folder,filename,int2str(filenumber),ext);
    audiowrite(fullfilename,signal,Fs);
    
end