function [out] = RealEXPORTbinary(x, FixP, QuantType)
% RealEXPORTbinary
% Takes arguments x, FixP, QuantTupe and produces a string of the binary representation

      width = RealWIDTH(FixP);  
      num = x;
      num = RealRESIZE(num, FixP, QuantType);
      
      re = real(num)*2^FixP{2};      
      if re < 0
          re = 2^(width) - abs(re);
      end
      
      re_o = dec2bin(re, width);
      
      out = '';      
      for k = 1:width        
        if re_o(k) == '1'
         out = strcat(out, '1');
        else
         out = strcat(out, '0');
        end;        
      end      
end
