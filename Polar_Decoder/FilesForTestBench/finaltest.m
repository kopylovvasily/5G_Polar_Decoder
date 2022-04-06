bitwidth_int=5;
bitwidth_float = 1; 
Numb_simvectors=100000;
qtype = 'SatTrc_NoWarn'; 

crcLen = 24;      % Number of CRC bits for DL, Section 5.1, [6]
poly = '24C';     % CRC polynomial
nPC = 0;          % Number of parity check bits, Section 5.3.1.2, [6]
nMax = 9;         % Maximum value of n, for 2^n, Section 7.3.3, [6]
iIL = false;       % Interleave input, Section 5.3.1.1, [6]
iBIL = false;

% K = 40;             % Message length in bits, including CRC, K > 30
% E = 116;            % Rate matched output length, E <= 8192

%EbNo = -10;         % EbNo in dB
L = 1;              % List length, a power of two, [1 2 4 8]
numFrames = 10000;     % Number of frames to simulate
linkDir = 'DL';   
K=130;
E=512; %N



  
snrdB=2.5;
fileID1 = fopen('stimuli_SC512.txt','w');
fileID2 = fopen('ExpectedResponse_SC512.txt','w');  

for o =1:1:10000
    
            R = K/E;                          % Effective code rate
            bps = 2;                          % bits per symbol, 1 for BPSK, 2 for QPSK
            %EsNo = EbNo + 10*log10(bps) + 10*log10(R);
            if bps == 1 % BPSK
               % snrdB = EsNo + 10*log10(2); % real noise only
                noiseVar = 1./(10.^(snrdB/10));
            elseif (bps == 2) % QPSK
              %  snrdB = EsNo; % complex noise
                noiseVar = 1./(10.^(snrdB/10));
            else
                error('Not implemented');
            end

        
            
           chan = comm.AWGNChannel('NoiseMethod','Variance','Variance',noiseVar);
            
            
            msg = randi([0 1],K,1);
            
            
            % Attach CRC
            %msgcrc = nrCRCEncode(msg,poly);
            
            % Polar encode
            encOut = nrPolarEncode(msg,E,nMax,iIL);
            N = length(encOut);
            
            % Rate match
            modIn = nrRateMatchPolar(encOut,K,E,iBIL);
            
            % Modulate
            modOut = nrSymbolModulate(modIn,'QPSK');
            
            % Add White Gaussian noise
            rSig = chan(modOut);
            
            % Soft demodulate
            rxLLR = nrSymbolDemodulate(rSig,'QPSK',noiseVar);
            
            % Rate recover
            decIn = nrRateRecoverPolar(rxLLR,K,N,iBIL);
            
            % Fixed LLRs
            
            fixeddecIn51 = RealRESIZE(decIn, {5,1,'s'}, qtype);
            
            for k=1:1:(length(fixeddecIn51)-1)
                x=From_binary_To_2_Complement(fixeddecIn51(k)',5,1);
                fprintf(fileID1,'%s,',x);
            end
                x=From_binary_To_2_Complement(fixeddecIn51(512)',5,1);
                fprintf(fileID1,'%s\n',x);
            
            
             
            ourmsgcapFIXED5161=fixedSCLDecoder(fixeddecIn51,K,E,L,nMax, 6, 1);
            for k=1:1:(length(ourmsgcapFIXED5161)-1)
                
             fprintf(fileID2,'%d',ourmsgcapFIXED5161(k));
            end
                x=From_binary_To_2_Complement(ourmsgcapFIXED5161(512),bitwidth_int,bitwidth_float);
                fprintf(fileID2,'%d\n',ourmsgcapFIXED5161(512));         
        
end        
            
