library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use work.VHDLTools.all;
use work.RealARITH.all;
use work.ComplexARITH.all;
use work.ComplexARITH_TB_pack.all;

entity ComplexARITH_TB is
  
  
end ComplexARITH_TB;

architecture behavioral of ComplexARITH_TB is
  
  constant simvec_dir        : string := "../../../verification/ComplexARITH/simvectors/";
  file file_Input            : text open read_mode  is simvec_dir & "/InpComplex.stim";
  file file_OutComplexRESIZE : text open write_mode is simvec_dir & "/OutComplexRESIZE.resp";
  file file_OutComplexMERGE  : text open write_mode is simvec_dir & "/OutComplexMERGE.resp";
  file file_OutComplexADD    : text open write_mode is simvec_dir & "/OutComplexADD.resp";
  file file_OutComplexSUB    : text open write_mode is simvec_dir & "/OutComplexSUB.resp";
  file file_OutComplexASL    : text open write_mode is simvec_dir & "/OutComplexASL.resp";
  file file_OutComplexASR    : text open write_mode is simvec_dir & "/OutComplexASR.resp";
  file file_OutComplexAS     : text open write_mode is simvec_dir & "/OutComplexAS.resp";
  file file_OutComplexMULT   : text open write_mode is simvec_dir & "/OutComplexMULT.resp";
  file file_OutComplexCONJ   : text open write_mode is simvec_dir & "/OutComplexCONJ.resp";
  file file_OutComplexNEG    : text open write_mode is simvec_dir & "/OutComplexNEG.resp";

  procedure GetData (
    file file_Input  :     text;
    variable v_RealA : out integer;
    variable v_ImagA : out integer;
    variable v_RealB : out integer;
    variable v_ImagB : out integer;
    variable v_S     : out integer) is
    variable line_Input : line;
    variable dummyChar  : character;
  begin  -- GetData
    -- Read real part of A
    readline(file_Input, line_Input);
    read(line_Input, v_RealA);
    -- Read spaces and comma
    while line_Input'length > 0 and (line_Input(line_Input'left) = ',' or line_Input(line_Input'left) = ' ') loop
      read(line_Input, dummyChar);
    end loop;
    -- Read imag part of A
    read(line_Input, v_ImagA);
    -- Read spaces and comma
    while line_Input'length > 0 and (line_Input(line_Input'left) = ',' or line_Input(line_Input'left) = ' ') loop
      read(line_Input, dummyChar);
    end loop;
    -- Read real part of B
    read(line_Input, v_RealB);
    -- Read spaces and comma
    while line_Input'length > 0 and (line_Input(line_Input'left) = ',' or line_Input(line_Input'left) = ' ') loop
      read(line_Input, dummyChar);
    end loop;
    -- Read imag part of B
    read(line_Input, v_ImagB);
    -- Read spaces and comma
    while line_Input'length > 0 and (line_Input(line_Input'left) = ',' or line_Input(line_Input'left) = ' ') loop
      read(line_Input, dummyChar);
    end loop;
    read(line_Input, v_S);
  end GetData;

  procedure PutData (
    file file_Output :    text;
    constant v_RealData  : in integer;
    constant v_ImagData  : in integer) is
    variable line_Output : line;
  begin  -- PutData
--       file_close(file_output);
--       file_open(file_output, OUTPUT_FILENAME, APPEND_MODE);
    write(line_Output, v_RealData);
    write(line_Output, string'(", "));
    write(line_Output, v_ImagData);
    writeline(file_Output, line_Output);
  end PutData;

begin  -- behavioral

  loop_proc : process
    variable v_RealInA : signed(RealWIDTH(InA_FixP)-1 downto 0);
    variable v_ImagInA : signed(RealWIDTH(InA_FixP)-1 downto 0);
    variable v_InA     : signed(ComplexWIDTH(InA_FixP)-1 downto 0);
    variable v_RealInB : signed(RealWIDTH(InB_FixP)-1 downto 0);
    variable v_ImagInB : signed(RealWIDTH(InB_FixP)-1 downto 0);
    variable v_InB     : signed(ComplexWIDTH(InB_FixP)-1 downto 0);
    variable v_ShiftS  : signed(RealWIDTH(Shift_FixP)-1 downto 0);
    variable v_ShiftU  : unsigned(RealWIDTH(Shift_FixP)-1 downto 0);
    variable v_RealA   : integer;
    variable v_ImagA   : integer;
    variable v_RealB   : integer;
    variable v_ImagB   : integer;
    variable v_S       : integer;
    variable v_Out     : signed(ComplexWIDTH(Out_FixP)-1 downto 0);

    
  begin  -- process loop_proc
    while not endfile(file_Input) loop
      GetData(file_Input, v_RealA, v_ImagA, v_RealB, v_ImagB, v_S);
      v_RealInA := to_signed(v_RealA, RealWIDTH(InA_FixP));
      v_ImagInA := to_signed(v_ImagA, RealWIDTH(InA_FixP));
      v_RealInB := to_signed(v_RealB, RealWIDTH(InB_FixP));
      v_ImagInB := to_signed(v_ImagB, RealWIDTH(InB_FixP));
      if Shift_FixP.SIG_TYPE = s then
        v_ShiftS := to_signed(v_S,RealWIDTH(Shift_FixP));
      elsif Shift_FixP.SIG_TYPE = u then
        v_ShiftU := to_unsigned(v_S,RealWIDTH(Shift_FixP));
      end if;
      v_InA := v_ImagInA & v_RealInA;
      v_InB := v_ImagInB & v_RealInB;

      -- ComplexMERGE (merge real(A) with imag(B) to have different FixP)
      v_Out := ComplexMERGE(v_RealInA, v_ImagInB, InA_FixP, InB_FixP, Out_FixP, QuantType);
      PutData(file_OutComplexMERGE, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      -- ComplexRESIZE
      v_Out := ComplexRESIZE(v_InA, InA_FixP, Out_FixP, QuantType);
      PutData(file_OutComplexRESIZE, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      -- ComplexASL
      if Shift_FixP.SIG_TYPE = u then
        v_Out := ComplexASL(v_InA, v_ShiftU, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutComplexASL, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      end if;
      -- ComplexASR
      if Shift_FixP.SIG_TYPE = u then
        v_Out := ComplexASR(v_InA, v_ShiftU, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutComplexASR, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      end if;
      -- ComplexAS
      if Shift_FixP.SIG_TYPE = s then
        v_Out := ComplexAS(v_InA, v_ShiftS, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutComplexAS, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      elsif Shift_FixP.SIG_TYPE = i then
        v_Out := ComplexAS(v_InA, v_S, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutComplexAS, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));        
      end if;
      -- ComplexMULT
      v_Out := ComplexMULT(v_InA, v_InB, InA_FixP, InB_FixP, Out_FixP, QuantType, ImplSpeed);
      PutData(file_OutComplexMULT, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      -- ComplexADD
      v_Out := ComplexADD(v_InA, v_InB, InA_FixP, InB_FixP, Out_FixP, QuantType);
      PutData(file_OutComplexADD, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      -- ComplexSUB
      v_Out := ComplexSUB(v_InA, v_InB, InA_FixP, InB_FixP, Out_FixP, QuantType);
      PutData(file_OutComplexSUB, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      -- ComplexCONJ
      v_Out := ComplexCONJ(v_InA, InA_FixP, Out_FixP, QuantType);
      PutData(file_OutComplexCONJ, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      -- ComplexNEG
      v_Out := ComplexNEG(v_InA, InA_FixP, Out_FixP, QuantType);
      PutData(file_OutComplexNEG, to_integer(GetREAL(v_Out)), to_integer(GetIMAG(v_Out)));
      
    end loop;
    wait;                               -- wait forever
  end process loop_proc;
end behavioral;
