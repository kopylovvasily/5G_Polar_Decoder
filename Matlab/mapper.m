function [symbolstream] = mapper(bitstream, mode)

    symbolstream = [];
    if strcmp(mode, 'BPSK')
        for j = 1:length(bitstream)
            symbolstream = [symbolstream, (2*bitstream(j) - 1)];
        end
    elseif strcmp(mode, 'QPSK')
        norm_factor = sqrt(1/2);
        % pad with a zero if necessary
        if mod(length(bitstream),2) ~= 0
            bitstream(length(bitstream)+1) = 0;
        end
        % map 2 input bits to complex plane
        for j = 1:length(bitstream)/2
            symbol_img = (2*bitstream(2*j-1) -1) * norm_factor*1i;
            symbol_real = (2*bitstream(2*j) -1) * norm_factor;
            symbolstream = [symbolstream, symbol_real + symbol_img];
        end
    elseif strcmp(mode, '16-QAM')
        norm_factor = sqrt(1/10);
        % pad if necessary
        while mod(length(bitstream),4) ~= 0
            bitstream(length(bitstream)+1) = 0;
        end
        for j = 1:length(bitstream)/4
            % first bit determines sign, third determines amplitude
            % of imaginary part
            sign = (bitstream(4*j-3)*2 -1);
            % amplitude is either 3 if b == 0 or 1 if b == 1
            amp = 3 - 2*bitstream(4*j-1);
            symbol_img = sign * amp * norm_factor *1i;
            % second bit determines sign, fourth determines amplitude of 
            % real part
            sign = (bitstream(4*j-2)*2 -1);
            amp = 3 - 2*bitstream(4*j);
            symbol_real = sign * amp * norm_factor;
            symbolstream = [symbolstream, symbol_real + symbol_img];
        end
    elseif strcmp(mode, '64-QAM')
        norm_factor = sqrt(1/42);
        % pad if necessary
        while mod(length(bitstream),6) ~= 0
            bitstream(length(bitstream)+1) = 0;
        end
        for j = 1:length(bitstream)/6
            % fist bit determines sign of the imaginary part
            sign = bitstream(6*j-5)*2 -1;
            % amplitude starts at 4 (middle) with in-/decrease determined
            % by the fourth bit and the amount (either 1 or 3) by the fifth
            % bit
            amp = 4 + (1-2*bitstream(6*j-2))*(3-2*bitstream(6*j-1));
            symbol_img = sign * amp * norm_factor *1i;
            % second bit determines sign of the real part
            sign = bitstream(6*j-4)*2 -1;
            % amplitude starts at 4 (middle) with in-/decrease determined
            % by the fourth bit and the amount (either 1 or 3) by the fifth
            % bit
            amp = 4 + (1-bitstream(6*j-3)*2)*(3-(2*bitstream(6*j)));
            symbol_real = sign * amp * norm_factor;
            symbolstream = [symbolstream, symbol_real + symbol_img];
        end
    end
end