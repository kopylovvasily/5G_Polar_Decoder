function out = RealWIDTH(FixP)
% function out = RealWIDTH(FixP)
% returns total number of bits that are required to represent a real
% number of type FixP (including sign bit if signal is of type signed)

if FixP{3} == 's'
  out = FixP{1}+FixP{2}+1;
elseif FixP{3} == 'u'
  out = FixP{1}+FixP{2};
else
  error('Signal type of real numbers must be signed (''s'') or unsigned (''u'').')
  out = 0;
end