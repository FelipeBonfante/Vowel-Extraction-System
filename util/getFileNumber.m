function number = getFileNumber(foldername)
    files = getAllFiles(foldername,'*.wav',0);
    number = size(files,1) + 1;
end