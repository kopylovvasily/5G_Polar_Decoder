function out = ComplexConjMULT(inA,inB,FixP,QType,IDString)
% function out = ComplexConjMULT(inA,inB,FixP,QType)
% Multiplication of two complex numbers where the second input will be complex conjugated:
% inA, inB: input vectors
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,'s'} or {WINT,WFRAC}
%       WINT, WFRAC are integer
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')

%variable input args
switch nargin
 case 4 % normal
  out = ComplexRESIZE(inA.*inB.'',FixP,QType);  
 case 5 % + Log ID
  out = ComplexRESIZE(inA.*inB.'',FixP,QType,IDString);
 otherwise
  error('Current number of input arguments (=%d) not supported!',nargin)
end
