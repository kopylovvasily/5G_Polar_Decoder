function out = ComplexCONJ(in,FixP,QType,IDString)
% function out = ComplexCONJ(in,FixP,QType)
% Complex conjugate of a vector:
% in: input vector
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,'s'} or {WINT,WFRAC}
%       WINT, WFRAC are integer
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')

%variable input args
switch nargin
 case 3 % normal
  out = ComplexRESIZE(conj(in),FixP,QType);  
 case 4 % + Log ID
  out = ComplexRESIZE(conj(in),FixP,QType,IDString);
 otherwise
  error('Current number of input arguments (=%d) not supported!',nargin)
end
