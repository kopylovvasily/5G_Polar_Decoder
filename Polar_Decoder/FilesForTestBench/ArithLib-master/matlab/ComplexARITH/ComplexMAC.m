function accumulate = ComplexMAC(inA,inB,MultOutFixP,MultOutQType,AccumulateFixP,AccumulateQType)
% function out = ComplexMAC(inA,inB,FixP,QType)
% Multiplicate two complex vectors, then add them up
% inA, inB: input vectors
% [XX]FixP: fixedpoint configuration of output vector {WINT,WFRAC,'s'} or {WINT,WFRAC}
%       WINT, WFRAC are integer
% [XX]QType: Quantization type ('WrpTrc', 'WrpRnd', 'SatTrc' or 'SatRnd')
% [XX] is MultOut for the output of the multiplication and Accumulate for
% the accumulation register


multOut = ComplexMULT(inA,inB,MultOutFixP,MultOutQType);

% In the regular case, we can speed up the MAC by resizing after the accumulation
if AccumulateFixP{1} >= MultOutFixP{1} && AccumulateFixP{2} >= MultOutFixP{2} && ...
        strcmp(AccumulateFixP{3},MultOutFixP{3}) && strcmp(MultOutQType,AccumulateQType) && ...
        strcmp(AccumulateQType(1:3), 'Wrp')
    accumulate = ComplexRESIZE(sum(multOut), AccumulateFixP,AccumulateQType);
else
    accumulate = 0;
    for i=1:length(multOut)
        accumulate = ComplexADD(multOut(i), accumulate,AccumulateFixP,AccumulateQType);
    end
end

end