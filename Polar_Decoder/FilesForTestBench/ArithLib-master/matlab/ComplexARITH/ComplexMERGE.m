function out = ComplexMERGE(inReal,inImag,FixP,QType)
% function out = ComplexMERGE(inReal,inImag,FixP,QType)
% Merge real and imaginary part to one complex number with common fixedpoint config:
% inReal, inImag: Real input vectors (real and imag part)
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,'s'} or {WINT,WFRAC}
%       WINT, WFRAC are integer
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')
if nargin == 2
  out = inReal+sqrt(-1)*inImag;
else
  out = RealRESIZE(inReal,FixP,QType) + sqrt(-1)*RealRESIZE(inImag,FixP,QType);
end
