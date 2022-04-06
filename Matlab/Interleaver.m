function Output_bits = Interleaver(input_bits,Enable)

% input_bits=[1 1 0 1 1 0 1 0 1 1 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 1 1 0 1 0 1 1 1 0 0 0 0 0];
% Enable= true;
% 
% 
% Input_bits1 = encOut2_NoInterleaver;
K = length(input_bits);
K_Max=164;

Pi_initial = [  0 0 28 67 56 122 84 68 112 33 140 38 ...
                1 2 29 69 57 123 85 73 113 36 141 144 ...
                2 4 30 70 58 126 86 78 114 44 142 39 ...
                3 7 31 71 59 127 87 84 115 47 143 145 ...
                4 9 32 72 60 129 88 90 116 64 144 40 ...
                5 14 33 76 61 132 89 92 117 74 145 146 ...
                6 19 34 77 62 134 90 94 118 79 146 41 ...
                7 20 35 81 63 138 91 96 119 85 147 147 ... 
                8 24 36 82 64 139 92 99 120 97 148 148 ...
                9 25 37 83 65 140 93 102 121 100 149 149 ... 
                10 26 38 87 66 1 94 105 122 103 150 150 ...
                11 28 39 88 67 3 95 107 123 117 151 151 ...
                12 31 40 89 68 5 96 109 124 125 152 152 ...
                13 34 41 91 69 8 97 112 125 131 153 153 ...
                14 42 42 93 70 10 98 114 126 136 154 154 ... 
                15 45 43 95 71 15 99 116 127 142 155 155 ...
                16 49 44 98 72 21 100 121 128 12 156 156 ...
                17 50 45 101 73 27 101 124 129 17 157 157 ...
                18 51 46 104 74 29 102 128 130 23 158 158 ...
                19 53 47 106 75 32 103 130 131 37 159 159 ...
                20 54 48 108 76 35 104 133 132 48 160 160 ...
                21 56 49 110 77 43 105 135 133 75 161 161 ...
                22 58 50 111 78 46 106 141 134 80 162 162 ...
                23 59 51 113 79 52 107 6 135 86 163 163 ...
                24 61 52 115 80 55 108 11 136 137 0 0 ...
                25 62 53 118 81 57 109 16 137 143 0 0 ...
                26 65 54 119 82 60 110 22 138 13 0 0 ...
                27 66 55 120 83 63 111 30 139 18 0 0];
            
Pi_0_27 = Pi_initial(2:12:326);
Pi_28_55 = Pi_initial(4:12:328);
Pi_56_83 = Pi_initial(6:12:330);
Pi_84_111 = Pi_initial(8:12:332);
Pi_112_139 = Pi_initial(10:12:334);
Pi_140_163= Pi_initial(12:12:288);

Pi=[Pi_0_27 Pi_28_55 Pi_56_83 Pi_84_111 Pi_112_139 Pi_140_163];
Pi_k=inf(1,K);

%k will run from 1 to Cap_K


if(Enable == 0)
    for k=1:K
        Pi_k(k)=k;
    end

else
       
    k=1;
    for m=1:K_Max
        
        if(Pi(m) >= K_Max - K)
            Pi_k(k)=Pi(m)-(K_Max-K-1);
            k=k+1;
        end
    end
end
      



U=zeros(1,K);
U=input_bits(Pi_k);
Output_bits = U;

%         [input_bits1' U' Pi_k'];
        
        
        
 end

















