function out = ComplexNEG(in,FixP,QType,IDString)
% function out = ComplexNEG(in,FixP,QType)
% Negation of both real and imaginary part of a vector:
% in: input vector
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,'s'}
%       WINT, WFRAC are integer
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')


%variable input args
switch nargin
 case 3 % normal
  out = ComplexRESIZE(-in,FixP,QType);  
 case 4 % + Log ID
  out = ComplexRESIZE(-in,FixP,QType,IDString);
 otherwise
  error('Current number of input arguments (=%d) not supported!',nargin)
end
