function num = ComplexIMPORTbinary(bin, FixP)
% ComplexIMPORTbinary
% Takes arguments bin, FixP and produces a fixed-point value from a binary representation. 
% It automatically detects complex and real valued numbers. If FixP is not given, it is 
% assumed to be real-valued and integer. 

  num = RealIMPORTbinary(bin, FixP)

end
