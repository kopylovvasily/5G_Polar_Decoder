function out = RealMULT(inA,inB,FixP,QType,IDString)
% function out = RealMULT(inA,inB,FixP,QType)
% Multiplication of two real numbers:
% inA, inB: input vectors
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')


%variable input args
switch nargin
 case 4 % normal
  out = RealRESIZE(inA.*inB,FixP,QType);  
 case 5 % + Log ID
  out = RealRESIZE(inA.*inB,FixP,QType,IDString);
 otherwise
  error('Current number of input arguments (=%d) not supported!',nargin)
end
