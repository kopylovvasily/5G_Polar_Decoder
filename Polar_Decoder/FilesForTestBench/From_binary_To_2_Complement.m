function complement_2 = From_binary_To_2_Complement(number,bitwidth_int,bitwidth_float)

% number = -0.5112; bitwidth=7;
sign=number;
integ0 = fix(number);
fract0 = abs(number - integ0);
fract = abs(number - integ0);

%     if(number < 1 && number>-1)
%     
%     else
%     complement2integer = dec2bin(integ,bitwidth);
%     end
    
    if(number>=0) 
      complement2integer = dec2bin(number,bitwidth_int);  
      complement2float = zeros(1,bitwidth_float);
      i=1;
              while(i<=bitwidth_float)

                temp = fract*2;
                integ = fix(temp);
                if(integ ==1)
                    complement2float(i) = 1;


                else
                      complement2float(i) = 0;

                end
                fract = abs(temp - integ);
                i=i+1;
              end
              
              
              string_complement2float=strings([1,bitwidth_float]);
               for f = 1:bitwidth_float
               string_complement2float(f)= strcat(num2str(complement2float(f)));
               end
     % string_complement2float = strcat(num2str(complement2float(1)),num2str(complement2float(2)),num2str(complement2float(3)),num2str(complement2float(4)),num2str(complement2float(5)),num2str(complement2float(6)),num2str(complement2float(7)));         
                
                x =str2double(string_complement2float);
                y = int2str(x);
                y = strrep(y,' ','');
%                 y = 0;
%                 for i = 1:length(x)
%                     y = y + (10^(i-1))*x(length(x)+1-i);
%                 end
                string_float = string(y);
          complement_2= strcat('0',complement2integer,string_float);    
              
              
              
              

    else 
        
        
      complement2integer = dec2bin(-integ0,bitwidth_int);  
      complement2float = zeros(1,bitwidth_float);
      i=1;
              while(i<=bitwidth_float)

                temp = fract0*2;
                integ = fix(temp);
                if(integ ==1)
                    complement2float(i) = 1;


                else
                      complement2float(i) = 0;

                end
                fract0 = abs(temp - integ);
                i=i+1;
              end

        
              
        integer_array=zeros(1,numel(complement2integer));
        for i=1:numel(complement2integer)
        integer_array(i)=str2num(complement2integer(i));
        end       
              
%                         x =str2double(integer_array);
%                 y = int2str(x);
%                 y = strrep(y,' ','');
% %                 y = 0;
% %                 for i = 1:length(x)
% %                     y = y + (10^(i-1))*x(length(x)+1-i);
% %                 end
%                 string_float = string(y);
%         
        
        
        
        Full_array = [0 integer_array complement2float];
        
              
              
              
              
              
              
              
        
       j=1;
       
            while(j<=((bitwidth_int+bitwidth_float)+1))
                
               if(Full_array(j) == 1)
                   
                 Full_array(j) = 0;
               else
                 Full_array(j) = 1;
               end
               j=j+1;
                               
            end
            
        for k=((bitwidth_int+bitwidth_float)+1):-1:1
            
            if(Full_array(k) == 0)
                Full_array(k)=1;
                break;
            else
                Full_array(k) = 0;
            end
            
            
        end
      
        
        %Lindi check this 
                Full_nrstring=strings([1,(bitwidth_float+bitwidth_int+1)]);
               for n = 1:(bitwidth_float+bitwidth_int+1)
               Full_nrstring(n)= strcat(num2str(Full_array(n)));
               end
        
               
                x =str2double(Full_nrstring);
                y = int2str(x);
                y = strrep(y,' ','');
%                 y = 0;
%                 for i = 1:length(x)
%                     y = y + (10^(i-1))*x(length(x)+1-i);
%                 end
                Full_nrstring = string(y);
%           complement_2= strcat(complement2integer,string_float);  
               
               
               
               
         % Full_nrstring = strcat(num2str(Full_array(1)),num2str(Full_array(2)),num2str(Full_array(3)),num2str(Full_array(4)),num2str(Full_array(5)),num2str(Full_array(6)),num2str(Full_array(7)),num2str(Full_array(8)),num2str(Full_array(9)),num2str(Full_array(10)),num2str(Full_array(11)),num2str(Full_array(12)),num2str(Full_array(13)),num2str(Full_array(14)),num2str(Full_array(15)));         
              
          complement_2=Full_nrstring ;   
        
        
        
        
        
        
    end

    
%     string_complement2float = strcat(num2str(complement2float(1)),num2str(complement2float(2)),num2str(complement2float(3)),num2str(complement2float(4)),num2str(complement2float(5)),num2str(complement2float(6)),num2str(complement2float(7))); 
%     
%     
%     if(sign<=-0.5)
%     complement_2 = strcat(complement2integer,string_complement2float);
%     elseif(sign<0 && sign>-0.5 )
%       complement_2= strcat('1',complement2integer,string_complement2float); 
%     else
%     complement_2= strcat('0',complement2integer,string_complement2float);
%     end
    
end




