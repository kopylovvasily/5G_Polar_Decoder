function out = RealDIV(inA,inB,inA_FixP,inB_FixP,out_FixP,QType,IDString)
% function out = RealDIV(inA,inB,inA_FixP,inB_FixP,out_FixP,QType)
% Division of two real numbers:
% inA: input dividend vector
% inB: input divisor vector
% inA_FixP: fixedpoint configuration of input dividend vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% inB_FixP: fixedpoint configuration of input divisor vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% out_FixP: fixedpoint configuration of output quotient vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')
%
% For backwards compatibility there is also a version of RealDIV which only
% requires a fixedpoint configuration for the output. Please note that in
% this version the division is done exacter than in hardware and it must
% not be used to build a bittrue model:
% function out = RealDIV(inA,inB,FixP,QType)
% Division of two real numbers:
% inA: input dividend vector
% inB: input divisor vector
% FixP: fixedpoint configuration of output quotient vector {WINT,WFRAC,Type}
%       WINT, WFRAC are integer, Type is either 's' or 'u'
% QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')
%
% Division by zero: division of a non-zero number by zero leads to the
% maximum positive or negative number, respectively, allowed with the
% specified fixedpoint configuration of the output quotient vector
% irrespective of the the quantization type.
%
% Division of zero by zero: division of zero by zero leads to zero.

% Enable error output comparing the two divider outputs distinguished by the
% legacy_mode flag before resizing to the fixed point configuration of the
% output quotient vector. This is only possible when operating in
% non-legacy mode.
error_comp = false;

% check for division by zero
divZeroFlag = (inB == 0) & (inA ~= 0);
if any(divZeroFlag)
    warning('RealDIV division by 0');
end
ZeroDivZeroFlag = (inB == 0) & (inA == 0);
if any(ZeroDivZeroFlag)
    warning('RealDIV 0 division by 0');
end

% legacy switch
switch nargin
    case {4,5}
        legacy_mode = true;
        if nargin == 5
            IDString = out_FixP;
        end
        QType = inB_FixP;
        out_FixP = inA_FixP;
        warning('Running RealDIV in legacy (not bittrue) mode');
    case {6,7}
        legacy_mode = false;
    otherwise
        error('Current number of input arguments (=%d) not supported!',nargin)
end

% division
if legacy_mode
    out = inA./inB;
else
    % convert input to integer
    frac_bits = max([inA_FixP{2}+inB_FixP{1},inA_FixP{2},inB_FixP{2},out_FixP{2}]);
    inA_int = inA.*2^frac_bits;
    inB_int = inB.*2^frac_bits;
    
    % perform equivalent division on positive integers
    sign_A = sign(inA_int);
    sign_B = sign(inB_int);
    inA_int = abs(inA_int);
    inB_int = abs(inB_int);
    out = floor(inA_int.*2^frac_bits./inB_int).*2^-frac_bits;
    out = out.*sign_A.*sign_B;
end

% overwrite values for division by zero
out(divZeroFlag) = RealRESIZE(sign(inA(divZeroFlag))*Inf,out_FixP,'SatRnd_NoWarn'); % division of non-zero by zero becomes max value
out(ZeroDivZeroFlag) = inA(ZeroDivZeroFlag); % division of zero by zero becomes zero

if error_comp && ~legacy_mode
    out_legacy = inA./inB;
    
    % overwrite values for division by zero
    out_legacy(divZeroFlag) = RealRESIZE(sign(inA(divZeroFlag))*Inf,out_FixP,'SatRnd_NoWarn'); % division of non-zero by zero becomes max value
    out_legacy(ZeroDivZeroFlag) = inA(ZeroDivZeroFlag); % division of zero by zero becomes zero
    
    disp(mean(abs(out-out_legacy)));
    keyboard;
end

switch nargin
    case {4,6} % normal
        out = RealRESIZE(out,out_FixP,QType);
    case {5,7} % + Log ID
        out = RealRESIZE(out,out_FixP,QType,IDString);
    otherwise
        error('Current number of input arguments (=%d) not supported!',nargin)
end
