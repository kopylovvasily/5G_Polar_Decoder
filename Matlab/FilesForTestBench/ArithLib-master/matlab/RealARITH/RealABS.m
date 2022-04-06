function out = RealABS(in,FixP,QType,IDString)
% function out = RealABS(in,FixP,QType)
% Absolute value of real number:
% in: input vector
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')

if FixP{3} ~= 'u'
    error('RealABS exists only for unsigned output type');
end

%variable input args
switch nargin
 case 3 % normal
  out = RealRESIZE(abs(in),FixP,QType);  
 case 4 % + Log ID
  out = RealRESIZE(abs(in),FixP,QType,IDString);
 otherwise
  error('Current number of input arguments (=%d) not supported!',nargin)
end
