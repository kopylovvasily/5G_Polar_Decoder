% Testbench for RealARITH Library

% All fixedpoint configurations that are tested are stored in the FixP
% array, consisting of Nx4 cell arrays. N is the number of fixedpoint
% configurations and there are cell arrays for InpA, InpB, Shift and Out
% signals. The cell arrays for these signals look like {WINT, WFRAC, Type},
% with WINT and WFRAC being integers that represent the number of bits of
% integer and fractional part of the number and Type is either 's' for
% signed or 'u' for unsigned ('s', 'u' or 'i' (integer) for Shift).
% Additionally, there is an array QType of size Nx1 with entries chosen
% from {'WrpTrc', 'WrpRnd','ClpTrc', 'ClpRnd', 'SatTrc', 'SatRnd'} that
% specifies how the output has to be quantized.

% For each fixedpoint configuration, input values that match the
% requirements of {WINT, WFRAC, Type} of InA, InB and Shift are generated
% either randomly or exhaustive. The VHDL-Testbench is then compiled for
% the current fixedpoint configuration and the stimuli file is processed.

% The VHDL-testbench generates a response file for each RealARITH function
% that has inputs/output corresponding to the current fixedpoint
% configuration (signed/unsigned).

% For each generated response file, the Matlab responses are computed and
% compared against the VHDL responses. All mismatches are reported in the
% RealARITH error file.

% Note that for exhaustive input value generation, the widths of the inputs
% should be limited (approx. 8 bits) in order to have reasonnable
% simulation times.

clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mismatches between Matlab and VHDL are stored as text in 'err_file'
err_file = './RealARITH/simvectors/RealARITH.err';

FixP_mode = 'r'; % For random fixedpoint testcase generation
% FixP_mode = 's'; % For specific testcases
% FixP_mode = 'b'; % Both: first specific, then random testcases

N_FixP_rand = 50; % Number of random fixedpoint testcases (if any)
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
FixP_spec = {{2,3,'u'},{2,3,'u'},{3,0,'u'},{1,1,'u'};...
             {2,3,'u'},{2,3,'u'},{3,0,'u'},{1,1,'u'};...
             {2,3,'u'},{2,3,'u'},{3,0,'u'},{1,1,'u'};...
             {2,3,'u'},{2,3,'u'},{3,0,'u'},{1,1,'u'}};
% QType_spec = {'SatRnd';'SatTrc';'WrpRnd';'WrpTrc';'ClpRnd';'ClpTrc'}; % Quantization type
QType_spec = {'SatRnd';'SatTrc';'WrpRnd';'WrpTrc'}; % Quantization type
% load('./simvectors/FixP.mat'); % Contains FixP_spec and QType_spec

% Value_mode = 'r'; % For random input numbers according to current FixP
Value_mode = 'e'; % For exhaustive testing

N_rand = 100; % Number of generated random input numbers (if any)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose(fopen(err_file,'w')); % Making sure that the file is empty
Type_range = {'s','u'}; % signal types for InA, InB and Out
SType_range = {'s','u','i'}; % signal types for Shift
% QType_range = {'WrpTrc','WrpRnd','SatTrc','SatRnd','ClpTrc','ClpRnd'}; % Quantization types
QType_range = {'WrpTrc','WrpRnd','SatTrc','SatRnd'}; % Quantization types
disp('Compiling ''RealARITH.vhd'' library');
system('cd ../modelsim/scripts/RealARITH; vsim -do coquRealARITH.do -c; cd -');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixedpoint testcases generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Generating fixedpoint testcases')

if FixP_mode == 'r' | FixP_mode == 'b'
    % random fixedpoint configurations:
    FixP_rand = cell(N_FixP_rand,4);
    QType_rand = cell(N_FixP_rand,1);
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
            k = k+1;
        end
    end
end
if FixP_mode == 'b'
    FixP = [FixP_spec;FixP_rand];
    QType = [QType_spec;QType_rand];
elseif FixP_mode == 's'
    FixP = FixP_spec;
    QType = QType_spec;
else % FixP_mode == 'r'
    FixP = FixP_rand;
    QType = QType_rand;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixedpoint loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:size(FixP,1)
    disp(['Current fixedpoint configuration is: '...
          'A_FixP={' num2str(FixP{k,1}{1}) ',' num2str(FixP{k,1}{2}) ',' num2str(FixP{k,1}{3}) ...
       '}, B_FixP={' num2str(FixP{k,2}{1}) ',' num2str(FixP{k,2}{2}) ',' num2str(FixP{k,2}{3}) ...
       '}, Shift_FixP={' num2str(FixP{k,3}{1}) ',' num2str(FixP{k,3}{2}) ',' num2str(FixP{k,3}{3}) ...
       '}, Out_FixP={' num2str(FixP{k,4}{1}) ',' num2str(FixP{k,4}{2}) ',' num2str(FixP{k,4}{3}) ...
       '}, QuantType=' QType{k}]);
    disp(['Fixedpoint config number ' num2str(k) ' of ' num2str(size(FixP,1))]);
    % Write RealARITH_TB_pack.vhd
    disp('Generating ''RealARITH_TB_pack.vhd''');
    filnam = '../vhdl/RealARITH/RealARITH_TB_pack.vhd';
    fid = fopen(filnam,'w');
    fprintf(fid,'-- THIS FILE IS AUTO-GENERATED!\n');
    fprintf(fid,'library IEEE;\n');
    fprintf(fid,'use IEEE.std_logic_1164.all;\n');
    fprintf(fid,'use IEEE.numeric_std.all;\n');
    fprintf(fid,'use work.VHDLTools.all;\n');
    fprintf(fid,'use work.RealARITH.all;\n');
    fprintf(fid,'package RealARITH_TB_pack is\n');
    fprintf(fid,['  constant InA_FixP : FixP := (' num2str(FixP{k,1}{1}) ',' ...
      num2str(FixP{k,1}{2}) ',' FixP{k,1}{3} ');\n']);
    fprintf(fid,['  constant InB_FixP : FixP := (' num2str(FixP{k,2}{1}) ',' ...
      num2str(FixP{k,2}{2}) ',' FixP{k,2}{3} ');\n']);
    fprintf(fid,['  constant Shift_FixP : FixP := (' num2str(FixP{k,3}{1}) ',' ...
      num2str(FixP{k,3}{2}) ',' FixP{k,3}{3} ');\n']);
    fprintf(fid,['  constant Out_FixP : FixP := (' num2str(FixP{k,4}{1}) ',' ...
      num2str(FixP{k,4}{2}) ',' FixP{k,4}{3} ');\n']);
    fprintf(fid,['  constant QuantType : ARITHQuant := ' QType{k} ';\n']);
%     fprintf(fid,['  constant InA_type : character := ''' FixP{k,1}{3} ''';\n']);
%     fprintf(fid,['  constant InB_type : character := ''' FixP{k,2}{3} ''';\n']);
%     fprintf(fid,['  constant Shift_type : character := ''' FixP{k,3}{3} ''';\n']);
%     fprintf(fid,['  constant Out_type : character := ''' FixP{k,4}{3} ''';\n']);
    fprintf(fid,'end RealARITH_TB_pack;\n');
    fprintf(fid,'package body RealARITH_TB_pack is\n');
    fprintf(fid,'end RealARITH_TB_pack;\n');
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
        if FixP{k,1}{3} == 's'
            A_vec = (floor(rand(N_rand,1)*2^(AW+1))-2^AW);
        else
            A_vec = floor(rand(N_rand,1)*2^AW);
        end
        if FixP{k,2}{3} == 's'
            B_vec = (floor(rand(N_rand,1)*2^(BW+1))-2^BW);
        else
            B_vec = floor(rand(N_rand,1)*2^BW);
        end
        if FixP{k,3}{3} == 's' % do not allow 100..00
            S_vec = floor(rand(N_rand,1)*(2^(SW+1)-1))-2^SW+1;
        else
            S_vec = floor(rand(N_rand,1)*2^SW);
        end
        InpValues = [A_vec B_vec S_vec];
    else
        % exhaustive input value generation
        if FixP{k,1}{3} == 's'
            A_vec = ([0:2^(AW+1)-1]-2^AW);
        else
            A_vec = [0:2^AW-1];
        end
        if FixP{k,2}{3} == 's'
            B_vec = ([0:2^(BW+1)-1]-2^BW);
        else
            B_vec = [0:2^BW-1];
        end
        if FixP{k,3}{3} == 's' | FixP{k,3}{3} == 'i'
            S_vec = ([1:2^(SW+1)-1]-2^SW);
        else
            S_vec = [0:2^SW-1];
        end
        % make sure that every combination of A with B ans S is present
        A_ext = kron(A_vec.',ones(max(length(B_vec),length(S_vec)),1));
        B_ext = kron(ones(ceil(length(A_ext)/length(B_vec)),1),B_vec.');
        B_ext = B_ext(1:length(A_ext));
        S_ext = kron(ones(ceil(length(A_ext)/length(S_vec)),1),S_vec.');
        S_ext = S_ext(1:length(A_ext));
        InpValues = [A_ext B_ext S_ext];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stimuli file generation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Generating stimuli file')
    filnam = './RealARITH/simvectors/InpReal.stim';
    % tic;
    dlmwrite(filnam,InpValues,'delimiter',',','precision','%i')
    % fastcsvwrite(filnam,InpValues);
    % write_time = toc
    
    % scale numbers to actual value
    InpValues(:,1) = InpValues(:,1)./2^FixP{k,1}{2};
    InpValues(:,2) = InpValues(:,2)./2^FixP{k,2}{2};
    InpValues(:,3) = InpValues(:,3)./2^FixP{k,3}{2};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Running VHDL code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Compiling testbench, running vsim');
    system('cd ../modelsim/scripts/RealARITH; vsim -do coruquRealARITH_TB.do -c; cd -');
    
    % Get VHDL responses (if any)
    respABS    = csvread_safe('./RealARITH/simvectors/OutRealABS.resp')./2^FixP{k,4}{2};
    respAS     = csvread_safe('./RealARITH/simvectors/OutRealAS.resp')./2^FixP{k,4}{2};
    respASR    = csvread_safe('./RealARITH/simvectors/OutRealASR.resp')./2^FixP{k,4}{2};
    respASL    = csvread_safe('./RealARITH/simvectors/OutRealASL.resp')./2^FixP{k,4}{2};
    respMULT   = csvread_safe('./RealARITH/simvectors/OutRealMULT.resp')./2^FixP{k,4}{2};
    respDIV    = csvread_safe('./RealARITH/simvectors/OutRealDIV.resp')./2^FixP{k,4}{2};
    respSUB    = csvread_safe('./RealARITH/simvectors/OutRealSUB.resp')./2^FixP{k,4}{2};
    respADD    = csvread_safe('./RealARITH/simvectors/OutRealADD.resp')./2^FixP{k,4}{2};
    respNEG    = csvread_safe('./RealARITH/simvectors/OutRealNEG.resp')./2^FixP{k,4}{2};
    respRESIZE = csvread_safe('./RealARITH/simvectors/OutRealRESIZE.resp')./2^FixP{k,4}{2};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Comparing VHDL responses with MATLAB responses
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['Comparing VHDL responses with MATLAB responses. Errors are stored in ' err_file '.']);
    if ~isempty(respRESIZE)
        expResp = RealRESIZE(InpValues(:,1),FixP{k,4},QType{k});
        err = expResp-respRESIZE;
        if any(err)
            write_err_line(err_file,'RealRESIZE',expResp,respRESIZE,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respABS)
        expResp = RealABS(InpValues(:,1),FixP{k,4},QType{k});
        err = expResp-respABS;
        if any(err)
            write_err_line(err_file,'RealABS',expResp,respABS,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respNEG)
        expResp = RealNEG(InpValues(:,1),FixP{k,4},QType{k});
        err = expResp-respNEG;
        if any(err)
            write_err_line(err_file,'RealNEG',expResp,respNEG,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respADD)
        expResp = RealADD(InpValues(:,1),InpValues(:,2),FixP{k,4},QType{k});
        err = expResp-respADD;
        if any(err)
            write_err_line(err_file,'RealADD',expResp,respADD,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respSUB)
        expResp = RealSUB(InpValues(:,1),InpValues(:,2),FixP{k,4},QType{k});
        err = expResp-respSUB;
        if any(err)
            write_err_line(err_file,'RealSUB',expResp,respSUB,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respASL)
        expResp = RealASL(InpValues(:,1),InpValues(:,3),FixP{k,4},QType{k});
        err = expResp-respASL;
        if any(err)
            write_err_line(err_file,'RealASL',expResp,respASL,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respASR)
        expResp = RealASR(InpValues(:,1),InpValues(:,3),FixP{k,4},QType{k});
        err = expResp-respASR;
        if any(err)
            write_err_line(err_file,'RealASR',expResp,respASR,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respAS)
        expResp = RealAS(InpValues(:,1),InpValues(:,3),FixP{k,4},QType{k});
        err = expResp-respAS;
        if any(err)
            write_err_line(err_file,'RealAS',expResp,respAS,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respMULT)
        expResp = RealMULT(InpValues(:,1),InpValues(:,2),FixP{k,4},QType{k});
        err = expResp-respMULT;
        if any(err)
            write_err_line(err_file,'RealMULT',expResp,respMULT,err,InpValues,FixP(k,:),QType{k});
        end
    end
    if ~isempty(respDIV)
        expResp = RealDIV(InpValues(:,1),InpValues(:,2),FixP{k,1},FixP{k,2},FixP{k,4},QType{k});
        err = expResp-respDIV;
        if any(err)
            write_err_line(err_file,'RealDIV',expResp,respDIV,err,InpValues,FixP(k,:),QType{k});
        end
    end
    disp('End of current fixedpoint configuration');
end
% empty scratch (make sure no other simulation is running on same machine)
% ! rm -r /scratch/simvectors/
disp('Finished')
