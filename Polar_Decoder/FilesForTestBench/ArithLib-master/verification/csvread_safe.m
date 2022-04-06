function res = csvread_safe( filename )
    fileinfo = dir(filename);
    if isempty(fileinfo) || fileinfo.bytes == 0 
        res = [];
        return;
    end
    res = csvread(filename);
end

