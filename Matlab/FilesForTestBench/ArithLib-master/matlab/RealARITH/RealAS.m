function out = RealAS(in,Shift,FixP,QType,IDString)
% function out = RealAS(in,Shift,FixP,QType)
% Arithmetic shift:
% in: input vector
% Shift: vector with numbers of shifted positions (pos. = left, neg. = right)
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')

%variable input args
switch nargin
 case 4 % normal
  out = RealRESIZE(in.*2.^Shift,FixP,QType);  
 case 5 % + Log ID
  out = RealRESIZE(in.*2.^Shift,FixP,QType,IDString);
 otherwise
  error('Current number of input arguments (=%d) not supported!',nargin)
end
