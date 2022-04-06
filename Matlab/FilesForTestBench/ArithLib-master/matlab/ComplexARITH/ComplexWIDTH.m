function out = ComplexWIDTH(FixP)
% function out = ComplexWIDTH(FixP)
% returns total number of bits that are required to represent a complex
% number of type FixP (including two sign bits)

if FixP{3} ~= 's'
  error('Signal type of complex numbers must be signed (''s'').')
  out = 0;
else
  out = 2*(FixP{1}+FixP{2}+1);
end