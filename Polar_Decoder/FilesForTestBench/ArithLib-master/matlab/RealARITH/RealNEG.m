function out = RealNEG(in,FixP,QType,IDString)
% function out = RealNEG(in,FixP,QType)
% Negated value of real number:
% in: input vector
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')

if FixP{3} ~= 's'
    error('RealNEG exists only for signed output type');
end

%variable input args
switch nargin
 case 3 % normal
  out = RealRESIZE(-in,FixP,QType);  
 case 4 % + Log ID
  out = RealRESIZE(-in,FixP,QType,IDString);
 otherwise
  error('Current number of input arguments (=%d) not supported!',nargin)
end
