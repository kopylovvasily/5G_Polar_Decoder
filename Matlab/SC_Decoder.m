function  msgcapSC = SC_Decoder(r,N,A,Q)



n=log2(N);%depth
K=A;%information bits






%INSTALL 5G ToolBox 
 
Q1 = Q(Q<=N);%THe reliability squence for N

%We have to keep the frozen bits as well since in the decoder we have to
%check if the particular index is frozen or not
F=Q1(1:N-K);


%Frozen positions: Q1(1:N-k)
%Message position: Q1(N-K+1:end)




%nonfrozenpositions


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%LLR are defined in this way = r*2/(sigma^square) 



%r is the received value


%SC decoder


%% Decoding 
L = zeros(n+1,N);%storage of LLRs (2D array)

ucap=zeros(n+1,N);          %decisions that are coming back, we use the ucap as the array which stroes all the decisions that are 
%coming back and we store all the positions in the same way as L, on the
%same place where you computed the L position, on the same place we will
%place the u position, in the same way we arranged the L, we will arrange
%the ucap also, the incoming U cap will be even after an r and even after a
%L,
ns=zeros(1,2*N-1); %node state vector

%lets define f and g function 
%assumption is that a and b will be vectors

f=@(a,b)(1-2*(a<0)).*(1-2*(b<0)).*min(abs(a),abs(b));%minsum
g=@(a,b,c) b+(1-2*c).*a; %gfuncntion



node = 0; depth=0; %start at root 
L(1,:)=r; %belief or root 
done=0; %decoder has finieshed or not

%the loop will keep running as long as done=0--> decoder has not finished
%yet;

while(done==0)%traversal loop till all bits are decoded
  
    npos = (2^depth-1)+node+1; %position of node in node state vector
    
    
    
    
    
    %we need to check and know if we are leaf or not
  
    if depth == n
       %at depth n we need to check if the node n+1 is frozen or not 
            if any(F==(node+1))%check if the node is frozen
                %we are at the bottom most and at the bottom most it is easy to
                %adress 
                ucap(n+1,node+1)=0;

            
             else
              if L(n+1, node+1)>=0
                ucap(n+1, node+1)=0;
             else
                ucap(n+1, node+1)=1;

              end
            end

   %once we are done we hand over to the parent     
   %we have to check if this is the last one, if we made a decision on the
   %last node or not,

               if node == (N-1)
                   done=1;

               else
                   node = floor(node/2);
                   depth = depth - 1;
               end

        
    
    
    else
        
      
    
    
        %we are at the root, we know the position, what we need to do is to
       %check the state


        
       %If I am not leaf I am in state 0 and what we have to do is minsum
           if ns(npos) == 0 %step L and go to left child
              % disp('L');
              % disp([node depth]);
               
               temp=2^(n-depth);
               
               Ln=L(depth+1,temp*node+1:temp*(node+1));%incoming beliefs         
               a=Ln(1:temp/2); b=Ln(temp/2+1:end);%split beliefs into 2
               
               node=node*2; depth=depth+1; %ndext node:left child
               temp=temp/2;%incoming belief length for left child
               %since we are going down to a belief at a deeper level and it is divided by 2
               L(depth+1, temp*node+1:temp*(node+1))=f(a,b);
               ns(npos)=1;



           else
               
               %here we deal with the right case, we need to use the states
               %from the left here as well.
                   if ns(npos) == 1 %step R and go to right child
                         % disp('R');
                         % disp([node depth]);
               
                           temp=2^(n-depth);
                           Ln=L(depth+1,temp*node+1:temp*(node+1));%incoming beliefs
                           a=Ln(1:temp/2); b=Ln(temp/2+1:end);%split beliefs into 2
                           %we hace to catch up the info from left child
                           lnode=2*node; ldepth=depth + 1; %left child coordinates
                           ltemp = temp/2; %when you go to left child
                           ucapn = ucap(ldepth+1, ltemp*lnode+1:ltemp*(lnode+1)); %incoming decisions from left child
                           node=node*2 + 1; depth=depth+1; %ndext node:right child
                           temp=temp/2;%incoming belief length for right child
                           %since we are going down to a belief at a deeper level and it is divided by 2
                           L(depth+1, temp*node+1:temp*(node+1))=g(a,b,ucapn); %g and storage
                           ns(npos)=2;
                           
                   else     %step u and go to parent
                            %when state is 2, what you need to do is first
                            %compute temp
                           temp=2^(n-depth); % we dont need a or b 
                           lnode=2*node; rnode=2*node+1; cdepth=depth + 1; %left child coordinates
                           ctemp = temp/2; %when you go to left child
                           ucapl = ucap(cdepth+1, ctemp*lnode+1:ctemp*(lnode+1)); %incoming decisions from left child
                           ucapr = ucap(cdepth+1, ctemp*rnode+1:ctemp*(rnode+1));%incoming decisions from right child
                           ucap(depth+1,temp*node+1:temp*(node+1)) = [mod(ucapl+ucapr,2) ucapr]; %combine 
                           node= floor(node/2); depth=depth-1;
                           
                   end

             end
   
   
       end  
end
  
  
%actual message is in the last row of Ucap

msgcapSC=ucap(n+1,Q1(N-K+1:end));

end




