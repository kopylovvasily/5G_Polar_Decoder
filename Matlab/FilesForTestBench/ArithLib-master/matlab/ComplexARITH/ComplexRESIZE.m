function out = ComplexRESIZE(in,FixP,QType,IDString)
% function out = ComplexRESIZE(in,FixP,QType)
% Quantize comlex valued number to fixedpoint configuration
% in: input vector
% FixP: fixedpoint configuration of output vector {WINT,WFRAC,'s'} or {WINT,WFRAC}
%       WINT, WFRAC are integer
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')

%add real and imag tags to LogID

%variable input args
switch nargin
 case 3 % normal
  out = RealRESIZE(real(in),FixP,QType) + ...
        sqrt(-1)*RealRESIZE(imag(in),FixP,QType);  
 case 4 % + Log ID
  %add real and imag tags to LogID
  IDStringREAL = [IDString,'(REAL)'];
  IDStringIMAG = [IDString,'(IMAG)'];
  out = RealRESIZE(real(in),FixP,QType,IDStringREAL) + ...
        sqrt(-1)*RealRESIZE(imag(in),FixP,QType,IDStringIMAG);  
 otherwise
  error('Current number of input arguments (=%d) not supported!',nargin)
end

% out = ComplexMERGE(real(in),imag(in),FixP,QType);
