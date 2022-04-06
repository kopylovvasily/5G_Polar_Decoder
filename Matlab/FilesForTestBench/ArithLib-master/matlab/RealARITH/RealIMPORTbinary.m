function num = RealIMPORTbinary(bin, FixP)
% RealIMPORTbinary
% Takes arguments bin, FixP and produces a fixed-point value from a binary representation. 
% It automatically detects complex and real valued numbers. If FixP is not given, it is 
% assumed to be real-valued and integer. 

mask = true(length(bin),1);
mask(strfind(bin, '"')) = false(length(strfind(bin, '"')), 1);
bin = bin(mask);

len = length(bin);
negativ = false;
negativ_im = false;
negativ_re = false;

if nargin == 1
    num = 0;
    for i=0:len-1
        if strcmp(bin(i+1),'1')
            num = num + 2^(len-1-i);
        end
    end
    
elseif nargin == 2    
    num_len = FixP{1}+FixP{2};
    if strcmp(FixP{3},'s')
        num_len = num_len +1;
    end
    
    if num_len == len % real number
        if strcmp(FixP{3},'s')
            if strcmp(bin(1),'1')
                negativ = true;
            end
            bin = bin(2:end);
            num_len = num_len-1;
        end
        % convert to decimal
        num = 0;
        for i=0:num_len-1
            if strcmp(bin(i+1),'1')
                num = num + 2^(num_len-1-i);
            end
        end
        % 2s complement if necessary
        if negativ
            num = -(2^(num_len)-num);
        end
        % fractional conversion
        num = num/2^FixP{2};
        
    elseif num_len == len/2 % complex number

        bin_im = bin(1:len/2);
        bin_re = bin(len/2+1:end);
        
        if strcmp(FixP{3},'s')
            if strcmp(bin_im(1),'1')
                negativ_im = true;
            end
            bin_im = bin_im(2:end);
            if strcmp(bin_re(1),'1')
                negativ_re = true;
            end
            bin_re = bin_re(2:end);
            num_len = num_len-1;
        end
        % convert to decimal
        num_im = 0;
        for i=0:num_len-1
            if strcmp(bin_im(i+1),'1')
                num_im = num_im + 2^(num_len-1-i);
            end
        end
        num_re = 0;
        for i=0:num_len-1
            if strcmp(bin_re(i+1),'1')
                num_re = num_re + 2^(num_len-1-i);
            end
        end
        % 2s complement if necessary
        if negativ_im
            num_im = -(2^(num_len)-num_im);
        end
        if negativ_re
            num_re = -(2^(num_len)-num_re);
        end
        
        num = num_re + 1i*num_im;
        
        % fractional conversion
        num = num/2^FixP{2};
        
        
    else
        error('wrong FixP and/or Quant type.')
    end
    
else
  error('wrong number of arguments.')
end

end
