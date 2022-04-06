//////////////////////////////////////////////////////////////////////////////
// Title      : RealARITH c++ functions
// Project    : 
///////////////////////////////////////////////////////////////////////////////
// File       : RealARITH.cpp
// Author     : Michael Schaffner (schaffner@iis.ee.ethz.ch)
// Company    : Integrated Systems Laboratory, ETH Zurich
///////////////////////////////////////////////////////////////////////////////
// Description:
//
// see header file (RealARITH.h).
//
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012 Integrated Systems Laboratory, ETH Zurich
///////////////////////////////////////////////////////////////////////////////
// Revisions  :
// Date        Version  Author     Description
// 2012/10/26  1.0      schaffner  created
// 2015/02/25  1.0.1    cavigelli  C99 compat., generic datatype, some opt.
///////////////////////////////////////////////////////////////////////////////

#include "RealARITH.h"
#include <math.h>

////////////////////////////////////////////////////////////////////////////////
// static inline helper functions

static inline double Max(double a, double b)
{
  return (a>b)?a:b;
}

static inline real Min(real a, real b)
{
  return (a<b)?a:b;
}


static inline real Mod(real a, real b)
{
  return a-floor(a/b)*b;
}

////////////////////////////////////////////////////////////////////////////////
FixP FixP_new(bool S, char I, char F) {

  // check range  
  if(((int)I) + ((int)F) > MANTISSA + 1)  
    print_warning(WARNING_TOO_WIDE_NUMBER_FORMAT);
  else if(((int)I) + ((int)F) < 1)
    print_warning(WARNING_ZERO_WIDTH_NUMBER);

  FixP s;   
  s.Signed   = S;
  s.IntBits  = I;
  s.FracBits = F; 

  return s;
}
////////////////////////////////////////////////////////////////////////////////
real RealRESIZE (const real     InA, 
                   const FixP       Out_FixP, 
                   const ARITHQuant QuantType)
{   
    
  // shift comma to the right position
  real factorToInt = pow(2.0,(real)Out_FixP.FracBits);
  real Tmp = InA*factorToInt;
    
  // Rnd
  if((QuantType == WrpRnd) || (QuantType == SatRnd)) {
    Tmp += 0.5;
  }
    
  // convert to integer value (Rnd and Trc)
  Tmp = floor(Tmp);
    
  // Sat (with symmetric range!)
  if((QuantType == SatTrc) || (QuantType == SatRnd)) {
    real MaxVal = pow(2.0, (real)Out_FixP.IntBits + (real)Out_FixP.FracBits) - 1.0;
        
    if(Out_FixP.Signed) {
      Tmp = Max(Min(Tmp, MaxVal), -MaxVal);
    } else {
      Tmp = Max(Min(Tmp, MaxVal), 0.0);
    }
  } else { //Wrp
    // add minimum possible value (this offset is zero for unsigned values...)
    // the minimum possible value is the "weird" number in the case of a signed number
    real MaxVal = pow(2.0, (real)Out_FixP.IntBits + (real)Out_FixP.FracBits);
        
    if(Out_FixP.Signed) {
      Tmp = Mod(Tmp + MaxVal, MaxVal*2.0) - MaxVal;
    } else {
      Tmp = Mod(Tmp, MaxVal);
    }
  }
    
  // normalize number
  return Tmp/factorToInt; //Tmp*pow(2.0,-(real)Out_FixP.FracBits);
}

////////////////////////////////////////////////////////////////////////////////
real RealABS (const real     InA, 
                const FixP       Out_FixP, 
                const ARITHQuant QuantType)
{
  real Tmp = abs(InA);
  return RealRESIZE(Tmp,Out_FixP,QuantType);
}
////////////////////////////////////////////////////////////////////////////////
real RealNEG (const real     InA, 
                const FixP       Out_FixP, 
                const ARITHQuant QuantType)
{
  real Tmp = -InA;
  return RealRESIZE(Tmp,Out_FixP,QuantType);
}
////////////////////////////////////////////////////////////////////////////////
real RealASL (const real        InA, 
                const unsigned char Shift,
                const FixP          Out_FixP, 
                const ARITHQuant    QuantType)
{
    
  real Tmp = InA*pow(2.0,(real)Shift);
  return RealRESIZE(Tmp,Out_FixP,QuantType);
}
////////////////////////////////////////////////////////////////////////////////
real RealASR (const real        InA, 
                const unsigned char Shift,
                const FixP          Out_FixP, 
                const ARITHQuant    QuantType)
{
    
  real Tmp = InA*pow(2.0,-(real)Shift);
  return RealRESIZE(Tmp,Out_FixP,QuantType);
}
////////////////////////////////////////////////////////////////////////////////
real RealAS (const real        InA, 
               const char          Shift,
               const FixP          Out_FixP, 
               const ARITHQuant    QuantType)
{
    
  real Tmp = InA*pow(2.0,(real)Shift);
  return RealRESIZE(Tmp,Out_FixP,QuantType);
}
////////////////////////////////////////////////////////////////////////////////
real RealADD (const real        InA, 
                const real        InB, 
                const FixP          Out_FixP, 
                const ARITHQuant    QuantType)
{
    
  real Tmp = InA+InB;
  return RealRESIZE(Tmp,Out_FixP,QuantType);
}
////////////////////////////////////////////////////////////////////////////////
real RealSUB (const real        InA, 
                const real        InB, 
                const FixP          Out_FixP, 
                const ARITHQuant    QuantType)
{
    
  real Tmp = InA-InB;
  return RealRESIZE(Tmp,Out_FixP,QuantType);
}
////////////////////////////////////////////////////////////////////////////////
real RealMULT(const real        InA, 
                const real        InB, 
                const FixP          Out_FixP, 
                const ARITHQuant    QuantType)
{
    
  real Tmp = InA*InB;
  return RealRESIZE(Tmp,Out_FixP,QuantType);
}
////////////////////////////////////////////////////////////////////////////////

