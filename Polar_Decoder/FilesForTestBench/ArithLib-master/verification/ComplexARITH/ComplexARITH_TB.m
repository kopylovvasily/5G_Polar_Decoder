% Testbench for ComplexARITH Library

% All fixedpoint configurations that are tested are stored in the FixP
% array, consisting of Nx4 cell arrays. N is the number of fixedpoint
% configurations and there are cell arrays for InpA, InpB, Shift and Out
% signals. The cell arrays for these signals look like {WINT, WFRAC, Type},
% with WINT and WFRAC being integers that represent the number of bits of
% integer and fractional part of the number and Type is 's' (signed) for
% InA, InB and Out or one of {'s','u','i'} for Shift. Additionally, there
% is an array QType of size Nx1 with entries chosen from {'WrpTrc',
% 'WrpRnd', 'SatTrc', 'SatRnd', 'ClpTrc', 'ClpRnd'} that specifies how the
% output has to be quantized. There is also an Nx1 array ImplSpeed
% specifying the VHDL architecture of the complex multiplier ('fast' or
% 'slow').

% For each fixedpoint configuration, input values that match the
% requirements of {WINT, WFRAC, Type} of InA, InB and Shift are generated
% either randomly or exhaustive. The VHDL-Testbench is then compiled for
% the current fixedpoint configuration and the stimuli file is processed.

% The VHDL-testbench generates a response file for each ComplexARITH
% function that has inputs/output corresponding to the current fixedpoint
% configuration.

% For each generated response file, the Matlab responses are computed and
% compared against the VHDL responses. All mismatches are reported in the
% ComplexARITH error file.

% Note that for exhaustive input value generation, the widths of the inputs
% should be very limited (approx. 4 bits) in order to have reasonnable
% simulation times.

clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mismatches between Matlab and VHDL are stored as text in 'err_file'
err_file = './ComplexARITH/simvectors/ComplexARITH.err';

FixP_mode = 'r'; % For random fixedpoint testcase generation
% FixP_mode = 's'; % For specific testcases
% FixP_mode = 'b'; % Both: first specific, then random testcases

N_FixP_rand = 100; % Number of random fixedpoint testcases (if any)
% Range from which the random FixP testcases are drawn:
% Keep the range of A, B and S small in the case of exhaustive testing!
AWINT_range  = [-5:5]; % InA integer part
AWFRAC_range = [-5:5]; % InA fractional part
BWINT_range  = [-3:3]; % InB integer part
BWFRAC_range = [-3,3]; % InB fractional part
SWINT_range  = [1:3];  % Shift int. part (SWFRAC must always be 0!)
OWINT_range  = [-10:10]; % Output integer part
OWFRAC_range = [-10:10]; % Output fractional part

% For specific fixedpoint testcases: either load FixP_spec cell array from
% file or define it here:
% Dim. 1: number of testcases, Dim. 2: {A_FixP,B_FixP,Shift_FixP,Out_FixP}
FixP_spec = {{2,3,'s'},{2,3,'s'},{3,0,'u'},{1,1,'s'};...
             {2,3,'s'},{2,3,'s'},{3,0,'u'},{1,1,'s'};...
             {2,3,'s'},{2,3,'s'},{3,0,'u'},{1,1,'s'};...
             {2,3,'s'},{2,3,'s'},{3,0,'u'},{1,1,'s'}};
% QType_spec = {'SatRnd';'SatTrc';'WrpRnd';'WrpTrc';'ClpRnd';'ClpTrc'}; % Quantization type
QType_spec = {'SatRnd';'SatTrc';'WrpRnd';'WrpTrc'}; % Quantization type
ImplSpeed_spec = {'slow';'fast'};
% load('../simvectors/FixP.mat'); % Contains FixP_spec, QType_spec, ImplSpeed

Value_mode = 'r'; % For random input numbers according to current FixP
% Value_mode = 'e'; % For exhaustive testing

N_rand = 50; % Number of generated random input numbers (if any)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(fopen(err_file,'w')); % Making sure that the file is empty

Type_range = {'s'}; % signal types for InA, InB and Out
SType_range = {'s','u','i'}; % signal types for Shift
% QType_range = {'WrpTrc','WrpRnd','SatTrc','SatRnd','ClpTrc','ClpRnd'}; % Quantization types
QType_range = {'WrpTrc','WrpRnd','SatTrc','SatRnd'}; % Quantization types
ImplSpeed_range = {'slow','fast'}; % ComplexMULT architecture speed

disp('Compiling ''ComplexARITH.vhd'' library');
system('cd ../modelsim/scripts/ComplexARITH; vsim -do coquComplexARITH.do -c; cd -');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixedpoint testcases generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Generating fixedpoint testcases')

if FixP_mode == 'r' | FixP_mode == 'b'
    % random fixedpoint configurations:
    FixP_rand = cell(N_FixP_rand,4);
    QType_rand = cell(N_FixP_rand,1);
    ImplSpeed_rand = cell(N_FixP_rand,1);
    k = 1;
    while k <= N_FixP_rand
        A_FixP = {AWINT_range(ceil(rand*length(AWINT_range))), ...
                  AWFRAC_range(ceil(rand*length(AWFRAC_range))), ...
                  Type_range{ceil(rand*length(Type_range))}};
        B_FixP = {BWINT_range(ceil(rand*length(BWINT_range))), ...
                  BWFRAC_range(ceil(rand*length(BWFRAC_range))), ...
                  Type_range{ceil(rand*length(Type_range))}};
        Shift_FixP = {SWINT_range(ceil(rand*length(SWINT_range))), ...
                      0, ...
                      SType_range{ceil(rand*length(SType_range))}};
        Out_FixP = {OWINT_range(ceil(rand*length(OWINT_range))), ...
                    OWFRAC_range(ceil(rand*length(OWFRAC_range))), ...
                    Type_range{ceil(rand*length(Type_range))}};
        if ~((A_FixP{1}+A_FixP{2}<1) | (B_FixP{1}+B_FixP{2}<1) |...
             (Out_FixP{1}+Out_FixP{2}<1))
            FixP_rand(k,1) = {A_FixP};
            FixP_rand(k,2) = {B_FixP};
            FixP_rand(k,3) = {Shift_FixP};
            FixP_rand(k,4) = {Out_FixP};
            QType_rand(k) = {QType_range{ceil(rand*length(QType_range))}};
            ImplSpeed_rand(k) = {ImplSpeed_range{ceil(rand*length(ImplSpeed_range))}};
            k = k+1;
        end
    end
end
if FixP_mode == 'b'
    FixP = [FixP_spec;FixP_rand];
    QType = [QType_spec;QType_rand];
    ImplSpeed = [ImplSpeed_spec;ImplSpeed_rand];
elseif FixP_mode == 's'
    FixP = FixP_spec;
    QType = QType_spec;
    ImplSpeed = ImplSpeed_spec;
else % FixP_mode == 'r'
    FixP = FixP_rand;
    QType = QType_rand;
    ImplSpeed = ImplSpeed_rand;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixedpoint loop %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:size(FixP,1) 
    disp(['Current fixedpoint configuration is: '...
          'A_FixP={' num2str(FixP{k,1}{1}) ',' num2str(FixP{k,1}{2}) ',' num2str(FixP{k,1}{3}) ...
       '}, B_FixP={' num2str(FixP{k,2}{1}) ',' num2str(FixP{k,2}{2}) ',' num2str(FixP{k,2}{3}) ...
       '}, Shift_FixP={' num2str(FixP{k,3}{1}) ',' num2str(FixP{k,3}{2}) ',' num2str(FixP{k,3}{3}) ...
       '}, Out_FixP={' num2str(FixP{k,4}{1}) ',' num2str(FixP{k,4}{2}) ',' num2str(FixP{k,4}{3}) ...
       '}, QuantType=' QType{k} ', SpeedType=' ImplSpeed{k}]);
    disp(['Fixedpoint config number ' num2str(k) ' of ' num2str(size(FixP,1))]);
    % Write ComplexARITH_TB_pack.vhd
    disp('Generating ''ComplexARITH_TB_pack.vhd''');
    filnam = '../vhdl/ComplexARITH/ComplexARITH_TB_pack.vhd';
    fid = fopen(filnam,'w');
    fprintf(fid,'-- THIS FILE IS AUTO-GENERATED!\n');
    fprintf(fid,'library IEEE;\n');
    fprintf(fid,'use IEEE.std_logic_1164.all;\n');
    fprintf(fid,'use IEEE.numeric_std.all;\n');
    fprintf(fid,'use work.VHDLTools.all;\n');
    fprintf(fid,'use work.RealARITH.all;\n');
    fprintf(fid,'use work.ComplexARITH.all;\n');
    fprintf(fid,'package ComplexARITH_TB_pack is\n');
    fprintf(fid,['  constant InA_FixP : FixP := (' num2str(FixP{k,1}{1}) ',' ...
      num2str(FixP{k,1}{2}) ',' FixP{k,1}{3} ');\n']);
    fprintf(fid,['  constant InB_FixP : FixP := (' num2str(FixP{k,2}{1}) ',' ...
      num2str(FixP{k,2}{2}) ',' FixP{k,2}{3} ');\n']);
    fprintf(fid,['  constant Shift_FixP : FixP := (' num2str(FixP{k,3}{1}) ',' ... 
      num2str(FixP{k,3}{2}) ',' FixP{k,3}{3} ');\n']);
    fprintf(fid,['  constant Out_FixP : FixP := (' num2str(FixP{k,4}{1}) ',' ...
      num2str(FixP{k,4}{2}) ',' FixP{k,4}{3} ');\n']);
    fprintf(fid,['  constant QuantType : ARITHQuant := ' QType{k} ';\n']);
    fprintf(fid,['  constant ImplSpeed : ComplexARITHImplSpeed := ' ImplSpeed{k} ';\n']);
%     fprintf(fid,['  constant Shift_type : character := ''' FixP{k,3}{3} ''';\n']);
    fprintf(fid,'end ComplexARITH_TB_pack;\n');
    fprintf(fid,'package body ComplexARITH_TB_pack is\n');
    fprintf(fid,'end ComplexARITH_TB_pack;\n');
    fclose(fid);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Input value generation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Generating input values')
    
    AW = FixP{k,1}{1}+FixP{k,1}{2};
    BW = FixP{k,2}{1}+FixP{k,2}{2};
    if FixP{k,3}{2} ~= 0
        error('Shift value must be an integer and thus WFRAC = 0');
    end
    SW = FixP{k,3}{1};
 
    
    if Value_mode == 'r'
        % random input values generation
        RealA_vec = (floor(rand(N_rand,1)*2^(AW+1))-2^AW);
        ImagA_vec = (floor(rand(N_rand,1)*2^(AW+1))-2^AW);
        RealB_vec = (floor(rand(N_rand,1)*2^(BW+1))-2^BW);
        ImagB_vec = (floor(rand(N_rand,1)*2^(BW+1))-2^BW);
        if FixP{k,3}{3} == 's' % do not allow 100..00
            S_vec = floor(rand(N_rand,1)*(2^(SW+1)-1))-2^SW+1;
        else
            S_vec = floor(rand(N_rand,1)*2^SW);
        end
        InpValues = [RealA_vec ImagA_vec RealB_vec ImagB_vec S_vec];
    else    
        % exhaustive input value definition
        A_vec = ([0:2^(AW+1)-1]-2^AW);
        RealA_vec = kron(A_vec.',ones(length(A_vec),1));
        ImagA_vec = kron(ones(length(A_vec),1),A_vec.');
        B_vec = ([0:2^(BW+1)-1]-2^BW);
        RealB_vec = kron(B_vec.',ones(length(B_vec),1));
        ImagB_vec = kron(ones(length(B_vec),1),B_vec.');
        if FixP{k,3}{3} == 's' | FixP{k,3}{3} == 'i'
            S_vec = ([1:2^(SW+1)-1]-2^SW);
        else
            S_vec = [0:2^SW-1];
        end
        A_ext = kron([RealA_vec,ImagA_vec],ones(max(length(RealB_vec),length(S_vec)),1));
        B_ext = kron(ones(ceil(length(A_ext)/length(RealB_vec)),1),[RealB_vec,ImagB_vec]);
        B_ext = B_ext(1:length(A_ext),:);
        S_ext = kron(ones(ceil(length(A_ext)/length(S_vec)),1),S_vec.');
        S_ext = S_ext(1:length(A_ext));
        InpValues = [A_ext B_ext S_ext];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stimuli file generation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Generating stimuli file')
    filnam = './ComplexARITH/simvectors/InpComplex.stim';
    dlmwrite(filnam,InpValues,'delimiter',',','precision','%i');

    % scale numbers to actual value, convert to complex numbers
    ComplA = (InpValues(:,1)+sqrt(-1)*InpValues(:,2))./2^FixP{k,1}{2};
    ComplB = (InpValues(:,3)+sqrt(-1)*InpValues(:,4))./2^FixP{k,2}{2};
    tempShift = InpValues(:,5)./2^FixP{k,3}{2};
    CInpValues = [ComplA ComplB tempShift];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Running VHDL code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Compiling testbench, running vsim');
    system('cd ../modelsim/scripts/ComplexARITH; vsim -do coruquComplexARITH_TB.do -c; cd -');

    % Get VHDL responses
    %pause(1.0);
    respAS     = csvread_safe('./ComplexARITH/simvectors/OutComplexAS.resp')./2^FixP{k,4}{2};
    respASR    = csvread_safe('./ComplexARITH/simvectors/OutComplexASR.resp')./2^FixP{k,4}{2};
    respASL    = csvread_safe('./ComplexARITH/simvectors/OutComplexASL.resp')./2^FixP{k,4}{2};
    respMULT   = csvread_safe('./ComplexARITH/simvectors/OutComplexMULT.resp')./2^FixP{k,4}{2};
    respSUB    = csvread_safe('./ComplexARITH/simvectors/OutComplexSUB.resp')./2^FixP{k,4}{2};
    respADD    = csvread_safe('./ComplexARITH/simvectors/OutComplexADD.resp')./2^FixP{k,4}{2};
    respRESIZE = csvread_safe('./ComplexARITH/simvectors/OutComplexRESIZE.resp')./2^FixP{k,4}{2};
    respMERGE  = csvread_safe('./ComplexARITH/simvectors/OutComplexMERGE.resp')./2^FixP{k,4}{2};
    respCONJ   = csvread_safe('./ComplexARITH/simvectors/OutComplexCONJ.resp')./2^FixP{k,4}{2};
    respNEG    = csvread_safe('./ComplexARITH/simvectors/OutComplexNEG.resp')./2^FixP{k,4}{2};
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Comparing VHDL responses with MATLAB responses
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['Comparing VHDL responses with MATLAB responses. Errors are stored in ' err_file '.']);
    if ~isempty(respAS)
        CrespAS = respAS(:,1)+sqrt(-1)*respAS(:,2);
        expResp = ComplexAS(CInpValues(:,1),CInpValues(:,3),FixP{k,4},QType{k});
        err = expResp-CrespAS;
        if any(err)
            write_err_line(err_file,'ComplexAS',expResp,CrespAS,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respASR)
        CrespASR = respASR(:,1)+sqrt(-1)*respASR(:,2);
        expResp = ComplexASR(CInpValues(:,1),CInpValues(:,3),FixP{k,4},QType{k});
        err = expResp-CrespASR;
        if any(err)
            write_err_line(err_file,'ComplexASR',expResp,CrespASR,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respASL)
        CrespASL = respASL(:,1)+sqrt(-1)*respASL(:,2);
        expResp = ComplexASL(CInpValues(:,1),CInpValues(:,3),FixP{k,4},QType{k});
        err = expResp-CrespASL;
        if any(err)
            write_err_line(err_file,'ComplexASL',expResp,CrespASL,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respMULT)
        CrespMULT = respMULT(:,1)+sqrt(-1)*respMULT(:,2);
        expResp = ComplexMULT(CInpValues(:,1),CInpValues(:,2),FixP{k,4},QType{k});
        err = expResp-CrespMULT;
        if any(err)
            write_err_line(err_file,'ComplexMULT',expResp,CrespMULT,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respADD)
        CrespADD = respADD(:,1)+sqrt(-1)*respADD(:,2);
        expResp = ComplexADD(CInpValues(:,1),CInpValues(:,2),FixP{k,4},QType{k});
        err = expResp-CrespADD;
        if any(err)
            write_err_line(err_file,'ComplexADD',expResp,CrespADD,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respSUB)
        CrespSUB = respSUB(:,1)+sqrt(-1)*respSUB(:,2);
        expResp = ComplexSUB(CInpValues(:,1),CInpValues(:,2),FixP{k,4},QType{k});
        err = expResp-CrespSUB;
        if any(err)
            write_err_line(err_file,'ComplexSUB',expResp,CrespSUB,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respMERGE)
        CrespMERGE = respMERGE(:,1)+sqrt(-1)*respMERGE(:,2);
        % merge real(A) with imag(B)
        expResp = ComplexMERGE(real(CInpValues(:,1)),imag(CInpValues(:,2)),FixP{k,4},QType{k});
        err = expResp-CrespMERGE;
        if any(err)
            write_err_line(err_file,'ComplexMERGE',expResp,CrespMERGE,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respCONJ)
        CrespCONJ = respCONJ(:,1)+sqrt(-1)*respCONJ(:,2);
        expResp = ComplexCONJ(CInpValues(:,1),FixP{k,4},QType{k});
        err = expResp-CrespCONJ;
        if any(err)
            write_err_line(err_file,'ComplexCONJ',expResp,CrespCONJ,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respNEG)
        CrespNEG = respNEG(:,1)+sqrt(-1)*respNEG(:,2);
        expResp = ComplexNEG(CInpValues(:,1),FixP{k,4},QType{k});
        err = expResp-CrespNEG;
        if any(err)
            write_err_line(err_file,'ComplexNEG',expResp,CrespNEG,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end 
    if ~isempty(respRESIZE)
        CrespRESIZE = respRESIZE(:,1)+sqrt(-1)*respRESIZE(:,2);
        expResp = ComplexRESIZE(CInpValues(:,1),FixP{k,4},QType{k});
        err = expResp-CrespRESIZE;
        if any(err)
            write_err_line(err_file,'ComplexRESIZE',expResp,CrespRESIZE,err,CInpValues,FixP(k,:),QType{k},ImplSpeed{k});
        end
    end     
    disp('End of current fixedpoint configuration');
end
% empty scratch (make sure no other simulation is running on same machine)
% ! rm -r /scratch/simvectors/
disp('Finished')
