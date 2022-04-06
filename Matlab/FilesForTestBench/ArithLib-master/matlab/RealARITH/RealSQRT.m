function out = RealSQRT(in,FixP,QType)
% function out = RealSQRT(in,FixP,QType)
% Square root of real number:
% in: input vector
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')

if FixP{3} ~= 'u'
    error('RealSQRT exists only for unsigned output type');
end
out = RealRESIZE(sqrt(in),FixP,QType);
