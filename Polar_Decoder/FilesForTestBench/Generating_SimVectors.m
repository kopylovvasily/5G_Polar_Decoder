%% Generating stimuli and expected response of Polar Decoder
bitwidth_int=5;%Input LLRS Quantization
bitwidth_float = 1; %Input LLRS Quantization
M=512;%Max Possible N
p=0; % For padding with zeros the Expected Response when N<512
P="0000000"; %For Padding with zeros the Stimuli when N<512
Numb_simvectors=1; %Number of Simvectors you may want for a particular Rate
N_A=[256 512 128 32 64];%In this array you can put for what N you may want your stimuli

fileID_512 = fopen('Ultimate_Stimuli.txt','w'); %Name of the file in which Input Stimuli will be stored
fileID1_512 = fopen('Ultimate_Expected_Response.txt','w'); %Name of the file in which Expected Response will be stored

for i=1:length(N_A)
    
    N=N_A(i);
    
    for k=29:3:140 %Number of information bits
        for e=k+1:10:8192 %Rate matched number of bits
           NI = nr5g.internal.polar.getN(k,e,9); %Number of coded bits

           if(NI==N)
                %Input sim Vectors are generated
                B=2*randn([Numb_simvectors,N]);
                fixpu = {bitwidth_int,bitwidth_float, 'u'};
                fixp = {bitwidth_int,bitwidth_float, 's'}; % # of integer bits (wo the sign), # of fractional bits, signed
                qtype = 'SatTrc_NoWarn'; % Saturate the integer p
                B_fixed=zeros(Numb_simvectors,N);
                
                for i = 1:Numb_simvectors
                    for j = 1:N
                        B_fixed(i,j) = RealRESIZE(B(i,j), fixp, qtype);
                    end
                end

               B_1_binary = strings([Numb_simvectors,M]);

                for i = 1:Numb_simvectors
                    for j = 1:N
                        B_1_binary(i,j) = From_binary_To_2_Complement(B_fixed(i,j),bitwidth_int,bitwidth_float);
                    end
                end    


                for i=1:Numb_simvectors
                   fprintf(fileID_512,'%d,%d,',k,e);
                  for j=1:M
                    if(N~=512)  
                      if(j==M)
                          fprintf(fileID_512,'%s\n',P);       
                      elseif(j<=N) 
                          fprintf(fileID_512,'%s,',B_1_binary(i,j));
                      else           
                          fprintf(fileID_512,'%s,',P);
                      end
                     elseif(N == 512)              
                       if(j==M)   
                          fprintf(fileID_512,'%s\n',B_1_binary(i,j));                
                       elseif(j<M) 
                          fprintf(fileID_512,'%s,',B_1_binary(i,j));
                       end         
                    end
                  end      
                end
                E_f = zeros(Numb_simvectors,N);
                for m = 1:Numb_simvectors
                     E_f(m,:) = fixedSCLDecoder(B_fixed(m,:),k,e);
                end

                E_f_binary = strings([Numb_simvectors,1]);

                for i = 1:1:Numb_simvectors
                  for t=1:M              
                      if(N~=512)
                       if t<=N
                          str(t) = sprintf('%d',E_f(i,t));
                       else
                           str(t) = sprintf('%d',p);
                       end
                      elseif(N==512)

                          str(t) = sprintf('%d',E_f(i,t));

                      end          
                   end   
                   result = strcat(str);
                   E_f_binary(i,:) = result;

                end

                fprintf(fileID1_512,'%s\n',E_f_binary);
           else
             continue
           end


        end
    end
end