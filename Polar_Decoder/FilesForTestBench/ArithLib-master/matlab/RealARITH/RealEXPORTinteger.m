function y = RealEXPORTinteger(x, FixP, QuantType)
% RealEXPORTinteger
% Takes arguments x, FixP, QuantTupe and produces an integer representation of the fixed-point value

    width = RealWIDTH(FixP);
    num = x;
    num = RealRESIZE(num, FixP, QuantType);

    y = real(num)*2^FixP{2};
    if y < 0
        y = 2^(width) - abs(y);
    end
end
