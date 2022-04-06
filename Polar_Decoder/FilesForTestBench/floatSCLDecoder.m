% function  msgcapSCL = floatSCLDecoder(r,K,E)


ni=6;
 nf=1;
 nL=1;
 nMax = 9;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%N,A,nL,crcL,r

% if ((E<=(9/8)*2^((ceil(log2(E))-1)))&&( K/E<9/16))
%     n1=ceil(log2(E))-1;
% else
%     n1=ceil(log2(E));
% end
% Rmin=1/8;
% n2=ceil(log2(K/Rmin));
% nmin=5;
% n=max(min(min(n1,n2),nMax),nmin);%depth
% 
% N=2^n;

N=length(r);
n=log2(N);

%24C
crcg=([1 1 1 0 1 0 0 0 1 0 0 0 1 1 0 1 0 1 0 0 1 1 0 1 1]);
%24A
%crcg=([1 1 0 1 1 1 1 1 0 0 1 1 0 0 1 0 0 1 1 0 0 0 0 1 1]);
    
%     rmax=4; %max received value 
%     maxqr= 31; %max integer received value 
        
        %Q1 = Q(Q<=N);%THe reliability squence for N
        %F=Q1(1:N-K);
        
      %  F1 = zeros(1,N);
       % F1(Q1(1:N-K))=1; %frozen bits locations
        [F1,qPC] = nr5g.internal.polar.construct(K,E,nMax);
        F1 = F1';
        
        F2 = zeros(1,N);
        for ww = 1:1:N
            F2(ww) = ww;
        end
        
        F = F1.*F2;
%         satx = @(x,th) min(max(x,-th),th); %saturate FP values
%         
%         f=@(a,b)(1-2*(a<0)).*(1-2*(b<0)).*min(abs(a),abs(b));%minsum
%         g=@(a,b,c) satx(b+(1-2*c).*a,maxqr); %gfuncntion
%         
        
  
    f=@(a,b)(1-2*(a<0)).*(1-2*(b<0)).*min(abs(a),abs(b));%minsum
    g=@(a,b,c) b+(1-2*c).*a; %gfuncntion

    
%                 r1=satx(r,rmax);%this is quantization
%                 rq=round(r1/rmax*maxqr); %part of quantization too
                
                LLR=zeros(nL, n+1,N); %beliefs in nL decoders
                ucap=zeros(nL, n+1,N); %decisions in nL decoders
                
                
                PML= Inf*ones(nL,1); %Path metrics
                PML(1)=0;%We are setting the first alone to zero
               
                ns=zeros(1,2*N-1); %node state vecotor ---> same for all decoders
                
                LLR(:,1,:) = repmat(r,nL,1,1);%this is the initialization at the root, previously we did only for
              

                node=0; depth=0; %start at the root
                
   
                while(true) %traverse till all bits are decoderd
                    if depth == n
                        
                        DM = squeeze(LLR(:, n+1, node+1)); %decision metrics for a particular node for all four lists
                        % DML(:, node+1 ) = DM;
                        % PMLL(:, node+1 ) = PML;
                        
                        if any(F==(node+1)) %is node Frozen
                            %if it is frozen, we dont need to check all posibilities, but
                            %we need to update only the path metrixs, if it negative, the
                            %path metrix need to be updated
                            ucap(:,n+1,node+1) = 0; %set all decisions to 0
                            PML=PML+abs(DM).*(DM<0); %id DM is negative, add |DM|
                            
                        else
                            %it it is not frozen, than we have to make decisions based on
                            %path metrix
                            
                            
                            %if DM<0 ----> u=1
                            %if DM>0 ----> u=0
                            
                            
                            dec=DM<0; %decision as per DM
                            
                            PM2=[PML; PML+abs(DM)];
                            %if you have an array the mink will give us the least four
                            %elements from the array
                            %we get the least 4 and we also get the positions of least 4
                            %which is stored in pos
                            [PML, pos] = mink(PM2,nL); %in PM2(:), first nL are as per DM
                            %next nL are opposite of DM
                            % we need to know which one of the decisions that survived are
                            % in pos
                            pos1=pos>nL; %surviving with opposite of DM: 1, if pos is above nL
                            % we need to substract it to get the actual indices and than
                            % permute them
                            pos(pos1) = pos(pos1)-nL; %adjust index
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            dec=dec(pos); %decision of survivors
                            
                            
                            dec(pos1)= 1 - dec(pos1); %flip for opposite of DM
                            
                            
                            
                            LLR=LLR(pos,:,:); %rearrange the decoder states,
                            %we delete the decoders that are not valid and only keep the
                            %decoders that are valid and assign it to decision, we first go
                            %to 8, arrange the path metrics
                            %pick the best four of the path metrixs
                            %than we do the adjustments
                            %we consider both decisions (expanding it) than we come back to 4,
                            ucap=ucap(pos,:,:);
                            
                            
                            
                            ucap(:,n+1,node+1) = dec;
                            
                        end
                        if node == (N-1)
                            break;
                        else
                            node=floor(node/2); depth=depth-1;
                        end
                    else
                        %nonleaf
                        npos = (2^depth-1)+node+1; %position of node in node state vector
                        
                        %If I am not leaf I am in state 0 and what we have to do is minsum
                        if ns(npos) == 0 %step L and go to left child
                            %                disp('L');
                            %                disp([node depth]);
                            %
                            temp=2^(n-depth);
                            %we squeeze Ln so it will be a two dimension array
                            Ln = squeeze(LLR(:,depth+1,temp*node+1:temp*(node+1)));%we take the valyes from all the decoders;%incoming beliefs
                            if (nL == 1) 
                                Ln = Ln';
                            end
                            a=Ln(:,1:temp/2); 
                            b=Ln(:,temp/2+1:end);%split beliefs into 2
                            node=node*2; depth=depth+1; %ndext node:left child
                            temp=temp/2;%incoming belief length for left child
                            %since we are going down to a belief at a deeper level and it is divided by 2
                            LLR(:,depth+1, temp*node+1:temp*(node+1))=f(a,b); %minsum and storage
                            ns(npos)=1;
                            
                            
                            
                        else
                            
                            %here we deal with the right case, we need to use the states
                            %from the left here as well.
                            if ns(npos) == 1 %step R and go to right child
                                %                           disp('R');
                                %                           disp([node depth]);
                                
                                temp=2^(n-depth);
                                Ln=squeeze(LLR(:,depth+1,temp*node+1:temp*(node+1)));%incoming beliefs
                                if (nL == 1) 
                                    Ln = Ln';
                                end
                                a=Ln(:,1:temp/2); b=Ln(:,temp/2+1:end);%split beliefs into 2
                                %we hace to catch up the info from left child
                                lnode=2*node; ldepth=depth + 1; %left child coordinates
                                ltemp = temp/2; %when you go to left child
                                ucapn = squeeze(ucap(:,ldepth+1, ltemp*lnode+1:ltemp*(lnode+1))); %incoming decisions from left child
                                if (nL == 1) 
                                    ucapn = ucapn';
                                end
                                node=node*2 + 1; depth=depth+1; %ndext node:right child
                                temp=temp/2;%incoming belief length for right child
                                %since we are going down to a belief at a deeper level and it is divided by 2
  
                                LLR(:,depth+1, temp*node+1:temp*(node+1))=g(a,b,ucapn); %g and storage
                                ns(npos)=2;
                                %nothing changes expect that we are doing the
                                %operation for 4 decoders
                                
                            else     %step u and go to parent
                                %when state is 2, what you need to do is first
                                %compute temp
                                temp=2^(n-depth); % we dont need a or b
                                lnode=2*node; rnode=2*node+1; cdepth=depth + 1; %left child coordinates
                                ctemp = temp/2; %when you go to left child
                                ucapl = squeeze(ucap(:,cdepth+1, ctemp*lnode+1:ctemp*(lnode+1))); %incoming decisions from left child
                                if (nL == 1) 
                                    ucapl = ucapl';
                                end
                                ucapr = squeeze(ucap(:,cdepth+1, ctemp*rnode+1:ctemp*(rnode+1)));%incoming decisions from right child
                                if (nL == 1) 
                                    ucapr = ucapr';
                                end
                                ucap(:,depth+1,temp*node+1:temp*(node+1)) = [mod(ucapl+ucapr,2) ucapr]; %combine
                                node = floor(node/2); depth=depth-1;
                                
                            end
                            
                        end
                        
                        
                    end
                    
                end
                
             
                %msg_capl=squeeze(ucap(:,n+1, Q1(N-K+1:end))); %old
                msg_capl=squeeze(ucap(:,n+1, F2(F1==0))); %new
                cout=1;
                for c1=1:nL
                    
                    mid = Deinterleaver(msg_capl(c1,:),true)';
                    
                    Din = mid;
                    REG = zeros(1, 24);
                    for k=1:length(mid)
                        XEnd = REG(24);
                        REG = [mod(XEnd+Din(k),2) mod(REG(1:end-1)+crcg(2:end-1)*XEnd, 2)];
                    end
                    
                    if REG == 0
                        cout=c1;
                        break
                    end
                   
%                    % it is the old CRC check 
%                    [q1,r1]=gfdeconv(fliplr(mid),crcg);
%                    display(r1);
%                    if isequal(r1,0)
%                        cout=c1;
%                        break
%                    end
                   
                end
                
                if (nL == 1) 
                    msg_capl = msg_capl';
                end
                
                msgcapSCL = msg_capl(cout, 1:K);
                
% end                
                





