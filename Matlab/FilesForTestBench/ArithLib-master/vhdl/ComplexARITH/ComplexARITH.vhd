------------------------------------------------------------------------------
-- Title      : Complex Arithmetic Library
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ComplexARITH.vhd
-- Author     : Andreas P. Burg (apburg@iis.ee.ethz.ch)
-- Company    : Integrated Systems Laboratory, ETH Zurich
-------------------------------------------------------------------------------
-- Description: This package contains a set of functions and types to work with
-- complex variables/signals in VHDL. Arithmetic operations on such types are
-- carried out using functions and procedures.
-- Functions are beased on functions of the RealARITH and VHDLTools packages
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Integrated Systems Laboratory, ETH Zurich
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003        1.0      apburg  Created
-- 10/03/2004  1.1      apburg  First Release
-- 14/01/2005  1.2      apburg  Corrected ComplexRESIZE, that no error occurs when EstraLSBs=0
-- 04/09/2007  1.3      zwicky  Major revision, 'unsigned' no longer supported
-- 05/12/2016  1.4      weberbe Added ComplexRealDIV
-------------------------------------------------------------------------------

library IEEE, work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.VHDLTools.all;
use work.RealARITH.all;
-- translate_off
library STD;
use STD.textio.all;
-- translate_on

package ComplexARITH is

  -----------------------------------------------------------------------------
  -- Speed grades
  -----------------------------------------------------------------------------
  type ComplexARITHImplSpeed is (slow, fast);

  -----------------------------------------------------------------------------
  -- Get word width of complex number
  -----------------------------------------------------------------------------
  function ComplexWIDTH (constant InA_FixP : FixP) return integer;

  -----------------------------------------------------------------------------
  -- Get REAL and IMAG parts of a Complex Number
  -----------------------------------------------------------------------------
  function GetREAL (constant InA : signed) return signed;
  function GetIMAG (constant InA : signed) return signed;

  -----------------------------------------------------------------------------
  -- Merge REAL and IMAG parts of a Complex Number
  -----------------------------------------------------------------------------
  function ComplexMERGE (constant InRe : signed;
                         constant InIm : signed) return signed;
  function ComplexMERGE (constant InRe      : signed;
                         constant InIm      : signed;
                         constant InRe_FixP : FixP;
                         constant InIm_FixP : FixP;
                         constant Out_FixP  : FixP;
                         constant QuantType : ARITHQuant) return signed;

  -----------------------------------------------------------------------------
  -- Resize
  -----------------------------------------------------------------------------
  function ComplexRESIZE (constant InA       : signed;
                          constant InA_FixP  : FixP;
                          constant Out_FixP  : FixP;
                          constant QuantType : ARITHQuant) return signed;

  -----------------------------------------------------------------------------
  -- ASL, ASR
  -----------------------------------------------------------------------------
  function ComplexASL (constant InA       : signed;
                       constant InSHIFT   : unsigned;
                       constant InA_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed;
  function ComplexASR (constant InA       : signed;
                       constant InSHIFT   : unsigned;
                       constant InA_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed;
  function ComplexAS (constant InA       : signed;
                      constant InSHIFT   : integer;
                      constant InA_FixP  : FixP;
                      constant Out_FixP  : FixP;
                      constant QuantType : ARITHQuant) return signed;
  function ComplexAS (constant InA       : signed;
                      constant InSHIFT   : signed;
                      constant InA_FixP  : FixP;
                      constant Out_FixP  : FixP;
                      constant QuantType : ARITHQuant) return signed;

  -----------------------------------------------------------------------------
  -- Full Complex MULT
  -----------------------------------------------------------------------------
  function ComplexMULT (constant InA       : in signed;
                        constant InB       : in signed;
                        constant InA_FixP  : in FixP;
                        constant InB_FixP  : in FixP;
                        constant Out_FixP  : in FixP;
                        constant QuantType : in ARITHQuant;
                        constant ImplSpeed : in ComplexARITHImplSpeed) return signed;

  -----------------------------------------------------------------------------
  -- Multiplication Complex times Real
  -----------------------------------------------------------------------------
  function ComplexRealMULT (constant InA       : in signed;
                            constant InB       : in signed;
                            constant InA_FixP  : in FixP;
                            constant InB_FixP  : in FixP;
                            constant Out_FixP  : in FixP;
                            constant QuantType : in ARITHQuant) return signed;

  -----------------------------------------------------------------------------
  -- Divison Complex by Real
  -----------------------------------------------------------------------------
  function ComplexRealDIV (constant InA       : in signed;
                           constant InB       : in signed;
                           constant InA_FixP  : in FixP;
                           constant InB_FixP  : in FixP;
                           constant Out_FixP  : in FixP;
                           constant QuantType : in ARITHQuant) return signed;

  -----------------------------------------------------------------------------
  -- Complex ADD
  -----------------------------------------------------------------------------
  function ComplexADD (constant InA       : signed;
                       constant InB       : signed;
                       constant InA_FixP  : FixP;
                       constant InB_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed;

  -----------------------------------------------------------------------------
  -- Complex SUB
  -----------------------------------------------------------------------------
  function ComplexSUB (constant InA       : signed;
                       constant InB       : signed;
                       constant InA_FixP  : FixP;
                       constant InB_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed;

  -----------------------------------------------------------------------------
  -- Complex CONJUGATE
  -----------------------------------------------------------------------------
  function ComplexCONJ (constant InA       : in signed;
                        constant InA_FixP  : in FixP;
                        constant Out_FixP  : in FixP;
                        constant QuantType : in ARITHQuant) return signed;

  -----------------------------------------------------------------------------
  -- Negate both real and imaginary part
  -----------------------------------------------------------------------------
  function ComplexNEG (constant InA       : signed;
                       constant InA_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed;

end ComplexARITH;

package body ComplexARITH is

  function ComplexWIDTH (
    constant InA_FixP : FixP) return integer is
  begin  -- RealWIDTH
    if InA_FixP.SIG_TYPE = s then
      return 2*(InA_FixP.WIDTH_INT+InA_FixP.WIDTH_FRAC+1);
    else
      assert false report "FixP.SIG_TYPE of complex signals must be s (signed)" severity failure;
      return 0;
    end if;
  end ComplexWIDTH;

  -----------------------------------------------------------------------------
  -- Get REAL and IMAG parts of a complex number
  -----------------------------------------------------------------------------
  function GetREAL (constant InA : signed) return signed is
    variable v_out : signed((InA'length/2)-1 downto 0);
  begin
    v_out := InA((InA'length/2)-1 downto 0);
    return v_out;
  end GetREAL;

  function GetIMAG (constant InA : signed) return signed is
    variable v_out : signed((InA'length/2)-1 downto 0);
  begin
    v_out := InA(InA'length-1 downto (InA'length/2));
    return v_out;
  end GetIMAG;


  -----------------------------------------------------------------------------
  -- Merge REAL and IMAG parts of a Complex Number
  -----------------------------------------------------------------------------
  function ComplexMERGE(constant InRe : signed;
                        constant InIm : signed) return signed is
  begin
    return (InIm & InRe);
  end;
  function ComplexMERGE(constant InRe      : signed;
                        constant InIm      : signed;
                        constant InRe_FixP : FixP;
                        constant InIm_FixP : FixP;
                        constant Out_FixP  : FixP;
                        constant QuantType : ARITHQuant) return signed is
    constant c_extFixP : FixP := (max(InRe_FixP.WIDTH_INT, InIm_FixP.WIDTH_INT),
                                  max(InRe_FixP.WIDTH_FRAC, InIm_FixP.WIDTH_FRAC), s);
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealRESIZE(RealALIGN(InRe, InRe_FixP, InIm_FixP, 0), c_extFixP, Out_FixP, QuantType);
    v_im := RealRESIZE(RealALIGN(InIm, InIm_FixP, InRe_FixP, 0), c_extFixP, Out_FixP, QuantType);
    return (v_im & v_re);
  end;

  -----------------------------------------------------------------------------
  -- Resize
  -----------------------------------------------------------------------------
  function ComplexRESIZE (constant InA       : signed;
                          constant InA_FixP  : FixP;
                          constant Out_FixP  : FixP;
                          constant QuantType : ARITHQuant) return signed is
  begin
    return ComplexMERGE(GetREAL(InA), GetIMAG(InA), InA_FixP, InA_FixP, Out_FixP, QuantType);
  end ComplexRESIZE;

  -----------------------------------------------------------------------------
  -- ASL, ASR
  -----------------------------------------------------------------------------
  function ComplexASL (constant InA       : signed;
                       constant InSHIFT   : unsigned;
                       constant InA_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealASL(GetREAL(InA), InSHIFT, InA_FixP, Out_FixP, QuantType);
    v_im := RealASL(GetIMAG(InA), InSHIFT, InA_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexASL;

  function ComplexASR (constant InA       : signed;
                       constant InSHIFT   : unsigned;
                       constant InA_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealASR(GetREAL(InA), InSHIFT, InA_FixP, Out_FixP, QuantType);
    v_im := RealASR(GetIMAG(InA), InSHIFT, InA_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexASR;

  function ComplexAS (constant InA       : signed;
                      constant InSHIFT   : integer;  -- assumed constant
                      constant InA_FixP  : FixP;
                      constant Out_FixP  : FixP;
                      constant QuantType : ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealAS(GetREAL(InA), InSHIFT, InA_FixP, Out_FixP, QuantType);
    v_im := RealAS(GetIMAG(InA), InSHIFT, InA_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexAS;

  function ComplexAS (constant InA       : signed;
                      constant InSHIFT   : signed;
                      constant InA_FixP  : FixP;
                      constant Out_FixP  : FixP;
                      constant QuantType : ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealAS(GetREAL(InA), InSHIFT, InA_FixP, Out_FixP, QuantType);
    v_im := RealAS(GetIMAG(InA), InSHIFT, InA_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexAS;

  -----------------------------------------------------------------------------
  -- Full Complex MULT
  -----------------------------------------------------------------------------

  function ComplexMULT (constant InA       : in signed;
                        constant InB       : in signed;
                        constant InA_FixP  : in FixP;
                        constant InB_FixP  : in FixP;
                        constant Out_FixP  : in FixP;
                        constant QuantType : in ARITHQuant;
                        constant ImplSpeed : in ComplexARITHImplSpeed) return signed is
    -- slow
    constant c_sumAFixP : FixP := (InA_FixP.WIDTH_INT+1, InA_FixP.WIDTH_FRAC, s);
    constant c_sumBFixP : FixP := (InB_FixP.WIDTH_INT+1, InB_FixP.WIDTH_FRAC, s);
    constant c_mult1FixP : FixP := (InA_FixP.WIDTH_INT+c_sumBFixP.WIDTH_INT+1,
                                    InA_FixP.WIDTH_FRAC+c_sumBFixP.WIDTH_FRAC, s);
    constant c_mult2FixP : FixP := (InB_FixP.WIDTH_INT+c_sumAFixP.WIDTH_INT+1,
                                    InB_FixP.WIDTH_FRAC+c_sumAFixP.WIDTH_FRAC, s);
    variable v_xs, v_ys : signed(RealWIDTH(c_sumBFixP)-1 downto 0);
    variable v_zs       : signed(RealWIDTH(c_sumAFixP)-1 downto 0);
    variable v_xm, v_ym : signed(RealWIDTH(c_mult1FixP)-1 downto 0);
    variable v_zm       : signed(RealWIDTH(c_mult2FixP)-1 downto 0);
    -- fast
    constant c_multFixP : FixP := (InA_FixP.WIDTH_INT+InB_FixP.WIDTH_INT+1,
                                   InA_FixP.WIDTH_FRAC+InB_FixP.WIDTH_FRAC, s);
    variable v_rr, v_ii   : signed(RealWIDTH(c_multFixP)-1 downto 0);
    variable v_ri, v_ir   : signed(RealWIDTH(c_multFixP)-1 downto 0);
    -- common
    variable InARE, InAIM : signed(InA'length/2-1 downto 0);
    variable InBRE, InBIM : signed(InB'length/2-1 downto 0);
    variable v_outRe      : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_outIm      : signed(RealWIDTH(Out_FixP)-1 downto 0);

  begin
    InARE := GetREAL(InA);
    InAIM := GetIMAG(InA);
    InBRE := GetREAL(InB);
    InBIM := GetIMAG(InB);
    if ImplSpeed = slow then
      v_xs := RealSUB(InBIM, InBRE, InB_FixP, InB_FixP, c_sumBFixP, WrpTrc);
      v_ys := RealADD(InBRE, InBIM, InB_FixP, InB_FixP, c_sumBFixP, WrpTrc);
      v_zs := RealADD(InARE, InAIM, InA_FixP, InA_FixP, c_sumAFixP, WrpTrc);

      v_xm := RealMULT(InARE, v_xs, InA_FixP, c_sumBFixP, c_mult1FixP, WrpTrc);
      v_ym := RealMULT(InAIM, v_ys, InA_FixP, c_sumBFixP, c_mult1FixP, WrpTrc);
      v_zm := RealMULT(InBRE, v_zs, InB_FixP, c_sumAFixP, c_mult2FixP, WrpTrc);

      v_outRe := RealSUB(v_zm, v_ym, c_mult2FixP, c_mult1FixP, Out_FixP, QuantType);
      v_outIm := RealADD(v_xm, v_zm, c_mult1FixP, c_mult2FixP, Out_FixP, QuantType);
    else
      v_rr := RealMULT(InARE, InBRE, InA_FixP, InB_FixP, c_multFixP, WrpTrc);
      v_ii := RealMULT(InAIM, InBIM, InA_FixP, InB_FixP, c_multFixP, WrpTrc);
      v_ri := RealMULT(InARE, InBIM, InA_FixP, InB_FixP, c_multFixP, WrpTrc);
      v_ir := RealMULT(InAIM, InBRE, InA_FixP, InB_FixP, c_multFixP, WrpTrc);

      v_outRe := RealSUB(v_rr, v_ii, c_multFixP, c_multFixP, Out_FixP, QuantType);
      v_outIm := RealADD(v_ri, v_ir, c_multFixP, c_multFixP, Out_FixP, QuantType);
    end if;
    return ComplexMERGE(v_outRe, v_outIm, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexMULT;

  -----------------------------------------------------------------------------
  -- Multiplication Complex times Real
  -----------------------------------------------------------------------------
  function ComplexRealMULT (constant InA       : in signed;
                            constant InB       : in signed;
                            constant InA_FixP  : in FixP;
                            constant InB_FixP  : in FixP;
                            constant Out_FixP  : in FixP;
                            constant QuantType : in ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealMULT(GetREAL(InA), InB, InA_FixP, InB_FixP, Out_FixP, QuantType);
    v_im := RealMULT(GetIMAG(InA), InB, InA_FixP, InB_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexRealMULT;

  -----------------------------------------------------------------------------
  -- Division Complex by Real
  -----------------------------------------------------------------------------
  function ComplexRealDIV (constant InA       : in signed;
                           constant InB       : in signed;
                           constant InA_FixP  : in FixP;
                           constant InB_FixP  : in FixP;
                           constant Out_FixP  : in FixP;
                           constant QuantType : in ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealDIV(GetREAL(InA), InB, InA_FixP, InB_FixP, Out_FixP, QuantType);
    v_im := RealDIV(GetIMAG(InA), InB, InA_FixP, InB_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexRealDIV;

  -----------------------------------------------------------------------------
  -- Complex ADD
  -----------------------------------------------------------------------------
  function ComplexADD (constant InA       : signed;
                       constant InB       : signed;
                       constant InA_FixP  : FixP;
                       constant InB_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealADD(GetREAL(InA), GetREAL(InB), InA_FixP, InB_FixP, Out_FixP, QuantType);
    v_im := RealADD(GetIMAG(InA), GetIMAG(InB), InA_FixP, InB_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexADD;

  -----------------------------------------------------------------------------
  -- Complex SUB
  -----------------------------------------------------------------------------
  function ComplexSUB (constant InA       : signed;
                       constant InB       : signed;
                       constant InA_FixP  : FixP;
                       constant InB_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealSUB(GetREAL(InA), GetREAL(InB), InA_FixP, InB_FixP, Out_FixP, QuantType);
    v_im := RealSUB(GetIMAG(InA), GetIMAG(InB), InA_FixP, InB_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexSUB;

  -----------------------------------------------------------------------------
  -- CONJUGATE
  -----------------------------------------------------------------------------
  function ComplexCONJ (constant InA       : in signed;
                        constant InA_FixP  : in FixP;
                        constant Out_FixP  : in FixP;
                        constant QuantType : in ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealRESIZE(GetREAL(InA), InA_FixP, Out_FixP, QuantType);
    v_im := RealNEG(GetIMAG(InA), InA_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexCONJ;

  -----------------------------------------------------------------------------
  -- Negate both real and imaginary part
  -----------------------------------------------------------------------------
  function ComplexNEG (constant InA       : signed;
                       constant InA_FixP  : FixP;
                       constant Out_FixP  : FixP;
                       constant QuantType : ARITHQuant) return signed is
    variable v_re : signed(RealWIDTH(Out_FixP)-1 downto 0);
    variable v_im : signed(RealWIDTH(Out_FixP)-1 downto 0);
  begin
    v_re := RealNEG(GetREAL(InA), InA_FixP, Out_FixP, QuantType);
    v_im := RealNEG(GetIMAG(InA), InA_FixP, Out_FixP, QuantType);
    return ComplexMERGE(v_re, v_im, Out_FixP, Out_FixP, Out_FixP, QuantType);
  end ComplexNEG;



end ComplexARITH;


