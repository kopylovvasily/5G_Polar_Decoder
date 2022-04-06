library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use work.VHDLTools.all;
use work.RealARITH.all;
use work.RealARITH_TB_pack.all;

entity RealARITH_TB is


end RealARITH_TB;

architecture behavioral of RealARITH_TB is
  constant simvec_dir : string := "../../../verification/RealARITH/simvectors/";

  file file_Input         : text open read_mode is simvec_dir & "/InpReal.stim";
  file file_OutRealRESIZE : text open write_mode is simvec_dir & "/OutRealRESIZE.resp";
  file file_OutRealABS    : text open write_mode is simvec_dir & "/OutRealABS.resp";
  file file_OutRealNEG    : text open write_mode is simvec_dir & "/OutRealNEG.resp";
  file file_OutRealADD    : text open write_mode is simvec_dir & "/OutRealADD.resp";
  file file_OutRealSUB    : text open write_mode is simvec_dir & "/OutRealSUB.resp";
  file file_OutRealASL    : text open write_mode is simvec_dir & "/OutRealASL.resp";
  file file_OutRealASR    : text open write_mode is simvec_dir & "/OutRealASR.resp";
  file file_OutRealAS     : text open write_mode is simvec_dir & "/OutRealAS.resp";
  file file_OutRealMULT   : text open write_mode is simvec_dir & "/OutRealMULT.resp";
  file file_OutRealDIV    : text open write_mode is simvec_dir & "/OutRealDIV.resp";

  procedure GetData (
    file file_Input :     text;
    variable v_A    : out integer;
    variable v_B    : out integer;
    variable v_S    : out integer) is
    variable line_Input : line;
    variable dummyChar  : character;
  begin  -- GetData
    readline(file_Input, line_Input);
    read(line_Input, v_A);
    -- Read spaces and comma
    while line_Input'length > 0 and (line_Input(line_Input'left) = ',' or line_Input(line_Input'left) = ' ') loop
      read(line_Input, dummyChar);
    end loop;
    read(line_Input, v_B);
    -- Read spaces and comma
    while line_Input'length > 0 and (line_Input(line_Input'left) = ',' or line_Input(line_Input'left) = ' ') loop
      read(line_Input, dummyChar);
    end loop;
    read(line_Input, v_S);
  end GetData;

  procedure PutData (
    file file_Output :    text;
    constant v_data  : in integer) is
    variable line_Output : line;
  begin  -- PutData
--       file_close(file_output);
--       file_open(file_output, OUTPUT_FILENAME, APPEND_MODE);
    write(line_Output, v_data);
    writeline(file_Output, line_Output);
  end PutData;

begin  -- behavioral

  loop_proc : process
    variable v_InAS   : signed(RealWIDTH(InA_FixP)-1 downto 0);
    variable v_InAU   : unsigned(RealWIDTH(InA_FixP)-1 downto 0);
    variable v_InBS   : signed(RealWIDTH(InB_FixP)-1 downto 0);
    variable v_InBU   : unsigned(RealWIDTH(InB_FixP)-1 downto 0);
    variable v_ShiftS : signed(RealWIDTH(Shift_FixP)-1 downto 0);
    variable v_ShiftU : unsigned(RealWIDTH(Shift_FixP)-1 downto 0);
    variable v_A      : integer;
    variable v_B      : integer;
    variable v_S      : integer;
    variable v_OutS   : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_OutU   : unsigned(RealWIDTH(Out_FixP)-1 downto 0);

  begin  -- process loop_proc
    while not endfile(file_Input) loop
      GetData(file_Input, v_A, v_B, v_S);
      if InA_FixP.SIG_TYPE = s then
        v_InAS := to_signed(v_A, RealWIDTH(InA_FixP));
      else
        v_InAU := to_unsigned(v_A, RealWIDTH(InA_FixP));
      end if;
      if InB_FixP.SIG_TYPE = s then
        v_InBS := to_signed(v_B, RealWIDTH(InB_FixP));
      else
        v_InBU := to_unsigned(v_B, RealWIDTH(InB_FixP));
      end if;
      if Shift_FixP.SIG_TYPE = s then
        v_ShiftS := to_signed(v_S, RealWIDTH(Shift_FixP));
      elsif Shift_FixP.SIG_TYPE = u then
        v_ShiftU := to_unsigned(v_S, RealWIDTH(Shift_FixP));
      end if;

      -- RealRESIZE
      if InA_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealRESIZE(v_InAS, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealRESIZE, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = u then
        v_OutU := RealRESIZE(v_InAU, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealRESIZE, to_integer(v_OutU));
      end if;

      -- RealABS
      if InA_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = u then
        v_OutU := RealABS(v_InAS, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealABS, to_integer(v_OutU));
      end if;

      -- RealNEG
      if InA_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealNEG(v_InAS, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealNEG, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = s then
        v_OutS := RealNEG(v_InAU, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealNEG, to_integer(v_OutS));
      end if;

      -- RealADD
      if InA_FixP.SIG_TYPE = s and InB_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealADD(v_InAS, v_InBS, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealADD, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = u then
        v_OutU := RealADD(v_InAU, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealADD, to_integer(v_OutU));
      elsif InA_FixP.SIG_TYPE = s and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = s then
        v_OutS := RealADD(v_InAS, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealADD, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealADD(v_InAU, v_InBS, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealADD, to_integer(v_OutS));
      end if;

      -- RealSUB
      if InA_FixP.SIG_TYPE = s and InB_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealSUB(v_InAS, v_InBS, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealSUB, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = u then
        v_OutU := RealSUB(v_InAU, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealSUB, to_integer(v_OutU));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = s then
        v_OutS := RealSUB(v_InAU, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealSUB, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = s and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = s then
        v_OutS := RealSUB(v_InAS, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealSUB, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealSUB(v_InAU, v_InBS, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealSUB, to_integer(v_OutS));
      end if;

      -- RealASL
      if InA_FixP.SIG_TYPE = s and Shift_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = s then
        v_OutS := RealASL(v_InAS, v_ShiftU, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealASL, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and Shift_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = u then
        v_OutU := RealASL(v_InAU, v_ShiftU, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealASL, to_integer(v_OutU));
      end if;

      -- RealASR
      if InA_FixP.SIG_TYPE = s and Shift_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = s then
        v_OutS := RealASR(v_InAS, v_ShiftU, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealASR, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and Shift_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = u then
        v_OutU := RealASR(v_InAU, v_ShiftU, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealASR, to_integer(v_OutU));
      end if;

      -- RealAS
      if InA_FixP.SIG_TYPE = s and Shift_FixP.SIG_TYPE = i and Out_FixP.SIG_TYPE = s then
        v_OutS := RealAS(v_InAS, v_S, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealAS, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and Shift_FixP.SIG_TYPE = i and Out_FixP.SIG_TYPE = u then
        v_OutU := RealAS(v_InAU, v_S, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealAS, to_integer(v_OutU));
      elsif InA_FixP.SIG_TYPE = s and Shift_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealAS(v_InAS, v_ShiftS, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealAS, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and Shift_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = u then
        v_OutU := RealAS(v_InAU, v_ShiftS, InA_FixP, Out_FixP, QuantType);
        PutData(file_OutRealAS, to_integer(v_OutU));
      end if;

      -- RealMULT
      if InA_FixP.SIG_TYPE = s and InB_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealMULT(v_InAS, v_InBS, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealMULT, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = u then
        v_OutU := RealMULT(v_InAU, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealMULT, to_integer(v_OutU));
      elsif InA_FixP.SIG_TYPE = s and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = s then
        v_OutS := RealMULT(v_InAS, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealMULT, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealMULT(v_InAU, v_InBS, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealMULT, to_integer(v_OutS));
      end if;

      -- RealDIV
      if InA_FixP.SIG_TYPE = s and InB_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealDIV(v_InAS, v_InBS, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealDIV, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = u then
        v_OutU := RealDIV(v_InAU, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealDIV, to_integer(v_OutU));
      elsif InA_FixP.SIG_TYPE = s and InB_FixP.SIG_TYPE = u and Out_FixP.SIG_TYPE = s then
        v_OutS := RealDIV(v_InAS, v_InBU, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealDIV, to_integer(v_OutS));
      elsif InA_FixP.SIG_TYPE = u and InB_FixP.SIG_TYPE = s and Out_FixP.SIG_TYPE = s then
        v_OutS := RealDIV(v_InAU, v_InBS, InA_FixP, InB_FixP, Out_FixP, QuantType);
        PutData(file_OutRealDIV, to_integer(v_OutS));
      end if;
    end loop;
    wait;                               -- wait forever
  end process loop_proc;
end behavioral;
