function cword = PolarEncoder(msg,E,nMax,Q)


K=length(msg);


if ((E<=(9/8)*2^((ceil(log2(E))-1)))&&( K/E<9/16))
    n1=ceil(log2(E))-1;
else
    n1=ceil(log2(E));
end
Rmin=1/8;
n2=ceil(log2(K/Rmin));
nmin=5;
n=max(min(min(n1,n2),nMax),nmin);%depth


N=2^n;

 
Q1 = Q(Q<=N);


u = zeros(1,N); %unit vector at the base

% 
% positions_u = zeros(1,K);
% 
% A=Q1(N-K+1:end);
% F=sort(A,'descend');
% for c = 1:length(A)
%     
%     positions_u(c)=find(Q1==F(c));
% end
% 
% 
% u(positions_u)= msg; %assign message bits

u(Q1(N-K+1:end))= (msg); %assign message bits

m=1; %nubmer of bits combined

for d=n-1:-1:0%loop on depth
 %we start at the leafs and we combine at every depth 2*more bits
   for i=1:2*m:N
       
       
       a=u(i:i+m-1); %first part
       b=u(i+m:i+2*m-1); %second part
       u(i:i+2*m-1)=[mod(a+b,2) b]; %combining
       
   end  
   m = m * 2;
   
end


%after the encoding, we transmit and the cword will be u

cword = u;
end
