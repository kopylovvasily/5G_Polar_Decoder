function [F,qPC,nPCwm] = Construct_no_PC(K,E,nMax)
%construct Polar code construction
%
%   Note: This is an internal undocumented function and its API and/or
%   functionality may change in subsequent releases.
%
%   F = nr5g.internal.polar.construct(K,E,NMAX) returns an N-bit vector, F,
%   as the output where K entries in the output would be 0 (information bit
%   locations), and N-K entries in the output would be 1 (frozen bit
%   locations). E is the rate-matched output length and NMAX is the maximum
%   n value (either of 9 or 10). The mother code rate is given by K/N,
%   while the effective code rate after rate-matching is K/E. K, E and NMAX
%   must be all scalars.
%
%   [F,QPC,NPCWM] = nr5g.internal.polar.construct(K,E,NMAX) also outputs
%   the set of bit indices for parity check bits QPC and the number of
%   parity check bits of minimum row weight NPCWM, for K valued in the
%   range 18<=K<=25.
%
%   Example:
%   % Construct a code with a message length of 48 bits and a rate matched
%   % output length of 144.
%
%   nMax = 9;               % maximum value of n
%   K = 48;                 % message length
%   E = 144;                % rate-matched output length
%   F = nr5g.internal.polar.construct(K,E,nMax);
%
%   See also nrPolarEncode, nrPolarDecode.

%   Copyright 2018-2019 The MathWorks, Inc.

% References:
%   [1] 3GPP TS 38.212, "3rd Generation Partnership Project; Technical
%   Specification Group Radio Access Network; NR; Multiplexing and channel
%   coding (Release 15). Section 5.3.1.2.

%#codegen

    % Get N, Section 5.3.1
    N = nr5g.internal.polar.getN(K,E,nMax);

    % Check and set PC-Polar parameters
%     if (K>=18 && K<=25)  % for PC-Polar, Section 6.3.1.3.1
%         nPC = 3;
%         if (E-K > 189)
%             nPCwm = 1;
%         else
%             nPCwm = 0;
%         end
%     else                 % for CA-Polar

%     end
        nPC = 0;
        nPCwm = 0;
    % Get sequence for N, ascending ordered, Section 5.3.1.2
    s10 = nr5g.internal.polar.sequence;         % for nMax=10
    idx = (s10 < N);
    qSeq = s10(idx);                            % 0-based

    % Get frozen, information bit indices sets, qF, qI
    jn = nr5g.internal.polar.subblockInterleaveMap(N);  % 0-based
    qFtmp = [];
    if E < N
        if K/E <= 7/16  % puncturing
            for i = 0:(N-E-1)
                qFtmp = [qFtmp; jn(i+1)];   %#ok
            end
            if E >= 3*N/4
                uLim = ceil(3*N/4-E/2);
                qFtmp = [qFtmp; (0:uLim-1).'];
            else
                uLim = ceil(9*N/16-E/4);
                qFtmp = [qFtmp; (0:uLim-1).'];
            end
            qFtmp = unique(qFtmp);
        else            % shortening
            for i = E:N-1
                qFtmp = [qFtmp; jn(i+1)];   %#ok
            end
        end
    end

    % Get qI from qFtmp and qSeq
    qI = zeros(K+nPC,1);
    j = 0;
    for i = 1:N
        ind = qSeq(N-i+1);      % flip for most reliable
        if any(ind==qFtmp)
            continue;
        end
        j = j+1;
        qI(j) = ind;
        if j==(K+nPC)
            break;
        end
    end

    % Form the frozen bit vector
    if coder.target('MATLAB')
        qF = setdiff(qSeq,qI);     % sorted doesn't matter now
    else
        qF = lclsetdiff(qSeq,qI);
    end
    F = zeros(N,1);
    F(qF+1) = ones(length(qF),1);

    % PC-Polar
    qPC = zeros(nPC,1);
    if nPC > 0
        qPC(1:(nPC-nPCwm),1) = qI(end-(nPC-nPCwm)+1:end); % least reliable

        if nPCwm>0  % assumes ==1, if >0.

            % Get G, nth Kronecker power of kernel
            n = log2(N);
            ak0 = [1 0; 1 1];   % Arikan's kernel
            allG = cell(n,1);   % Initialize cells
            for i = 1:n
                allG{i} = zeros(2^i,2^i);
            end
            allG{1} = ak0;      % Assign cells
            for i = 1:n-1
                allG{i+1} = kron(allG{i},ak0);
            end
            G = allG{n};
            wg = sum(G,2);              % row weight

            qtildeI = qI(1:end-nPC,1);
            wt_qtildeI = wg(qtildeI+1);
            minwt = min(wt_qtildeI);    % minimum weight
            allminwtIdx = find(wt_qtildeI==minwt);

            % most reliable, minimum row weight is first value
            qPC(nPC,1) = qtildeI(allminwtIdx(1));
        end
    end
end

function medC = lclsetdiff(tallA,shortB)
% Output DELTA has the values in TALLA that are not in SHORTB.
% Assumptions:
%   Both TALLA and SHORTB are columns with unique elements.

    medC = zeros(length(tallA)-length(shortB),1);
    c = 0;
    for i = 1:length(tallA)
        tmp = tallA(i);
        k = 0;
        for j = 1:length(shortB)
            if shortB(j)==tmp
                break;
            else
                k = k+1;
            end
        end
        if k == length(shortB)
            c = c+1;
            medC(c) = tmp;
        end
    end

end