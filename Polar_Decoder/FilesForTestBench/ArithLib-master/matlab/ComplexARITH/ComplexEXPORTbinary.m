function [out] = ComplexEXPORTbinary(x, FixP, QuantType)
% ComplexEXPORTbinary
% Takes arguments x, FixP, QuantTupe and produces a string of the binary representation

      width = ComplexWIDTH(FixP);  
      num = x;
      num = ComplexRESIZE(num, FixP, QuantType);
      
      im = imag(num)*2^FixP{2};
      re = real(num)*2^FixP{2};      

      if im < 0
          im = 2^(width/2) - abs(im);
      end;      
      if re < 0
          re = 2^(width/2) - abs(re);
      end
      
      im_o = dec2bin(im, width/2);
      re_o = dec2bin(re, width/2);
      
      out = '"';      
      for k = 1:width/2        
        if im_o(k) == '1'
         out = strcat(out, '1');
        else
         out = strcat(out, '0');
        end;        
      end      
      
      for k = 1:width/2        
        if re_o(k) == '1'
         out = strcat(out, '1');
        else
         out = strcat(out, '0');
        end;        
      end      
      out = strcat(out,'"');
end

% alternate implementation of similar functionality
%function floatToFix(value,fixP)
%
%fracBits = fixP{2};
%integerBits = fixP{1};
%value = value*2^fracBits;
%
%  for z = 1:length(value)
%      if real(value(z)) < 0
%          binValRe = dec2bin(2^(fracBits+integerBits+1)+real(value(z)),fracBits+integerBits+1);
%      else
%          binValRe = dec2bin(real(value(z)),fracBits+integerBits+1);
%      end;
%      if imag(value(z)) < 0
%          binValIm = dec2bin(2^(fracBits+integerBits+1)+imag(value(z)),fracBits+integerBits+1);
%      else
%          binValIm = dec2bin(imag(value(z)),fracBits+integerBits+1);
%      end;      
%      
%      fprintf(1,'%s %s (frac: %e)\n',binValIm,binValRe,(value(z)-round(value(z)))*2^-fracBits);
%  end;
%  
%end
