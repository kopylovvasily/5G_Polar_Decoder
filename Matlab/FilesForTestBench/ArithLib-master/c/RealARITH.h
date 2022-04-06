//////////////////////////////////////////////////////////////////////////////
// Title      : RealARITH c++ functions
// Project    : 
///////////////////////////////////////////////////////////////////////////////
// File       : RealARITH.h
// Author     : Michael Schaffner (schaffner@iis.ee.ethz.ch)
// Company    : Integrated Systems Laboratory, ETH Zurich
///////////////////////////////////////////////////////////////////////////////
// Description:
//
// the fixparith library provides golden model c++ functions for a subset of 
// the VHDL function defined in the RealARITH package. 
//
// RealARITH works with symmetric saturation ranges! 
// (i.e. a signed 4 bit number gets saturated at -7 and 7).
//
// note that the current implementation of the fixparith functions are built 
// around the double precision floating point type. thus the maximum integer precision
// is +-(2^53-1). A warning gets printed if the number format definition FixP 
// cannot be represented.
//
// Preprocessor arguments: 
// - NO_MATLAB to compile without matlab support (a printf thingy)
// - USE_FLOAT to compile using single-precision instead of double (for speed)
//
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012 Integrated Systems Laboratory, ETH Zurich
///////////////////////////////////////////////////////////////////////////////
// Revisions  :
// Date        Version  Author     Description
// 2012/10/26  1.0      schaffner  created
// 2016/02/20  1.0.1    cavigelli  C99 compat., generic datatype, some opt.
///////////////////////////////////////////////////////////////////////////////


#ifndef REAL_ARITH___
#define REAL_ARITH___

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#ifndef _USE_MATH_DEFINES
    #define _USE_MATH_DEFINES
#endif

#include <math.h>


#ifndef NO_MATLAB
    #include <mex.h>
#endif

        
// define how to print out warnings
#ifdef NO_MATLAB
    #define print_warning(X) printf(X)
#else
    #define print_warning(X) mexPrintf(X)
#endif          
       
        
// warning messages        

#ifndef USE_FLOAT
typedef double real; 
#define MANTISSA (52)
#define WARNING_TOO_WIDE_NUMBER_FORMAT "WARNING: cannot represent a number with > 53 bits.\n"
#define WARNING_ZERO_WIDTH_NUMBER      "WARNING: cannot represent a number with less than 1 bits.\n"
#else
typedef float real;
#define MANTISSA (23)
#define WARNING_TOO_WIDE_NUMBER_FORMAT "WARNING: cannot represent a number with > 24 bits.\n"
#define WARNING_ZERO_WIDTH_NUMBER      "WARNING: cannot represent a number with less than 1 bits.\n"
#endif
///////////////////////////////////////////////////////////////////////////////
// quantisation types
///////////////////////////////////////////////////////////////////////////////
typedef enum ARITHQuant {SatTrc, SatRnd, WrpTrc, WrpRnd} ARITHQuant;

///////////////////////////////////////////////////////////////////////////////
// fixed point format specifier
// to allocate a new fixed point struct use: 
// FixP MyFixPVar(Signed,ItBits,FracBits);
///////////////////////////////////////////////////////////////////////////////
typedef struct FixP { 
  bool Signed;
  char IntBits;
  char FracBits;
              
#ifdef __cplusplus
  // constructor
  FixP(bool S = false, char I = 1, char F = 0) {                
    // check range  
    if(((int)I) + ((int)F) > 53)  
      print_warning(WARNING_TOO_WIDE_NUMBER_FORMAT);
    else if(((int)I) + ((int)F) < 1)
      print_warning(WARNING_ZERO_WIDTH_NUMBER);
                
    Signed   = S;
    IntBits  = I;
    FracBits = F; 
  };
#endif
} FixP;

FixP FixP_new(bool S, char I, char F);

  
///////////////////////////////////////////////////////////////////////////////
// functions
///////////////////////////////////////////////////////////////////////////////
real RealRESIZE (const real    InA, 
                 const FixP       Out_FixP, 
                 const ARITHQuant QuantType);
///////////////////////////////////////////////////////////////////////////////
real RealABS (const real   InA, 
              const FixP       Out_FixP, 
              const ARITHQuant QuantType);
///////////////////////////////////////////////////////////////////////////////
real RealNEG (const real    InA, 
              const FixP       Out_FixP, 
              const ARITHQuant QuantType);
///////////////////////////////////////////////////////////////////////////////
real RealASL (const real       InA, 
              const unsigned char Shift,
              const FixP          Out_FixP, 
              const ARITHQuant    QuantType);
///////////////////////////////////////////////////////////////////////////////
real RealASR (const real       InA, 
              const unsigned char Shift,
              const FixP          Out_FixP, 
              const ARITHQuant    QuantType);
///////////////////////////////////////////////////////////////////////////////
real RealAS  (const real       InA, 
              const char          Shift,
              const FixP          Out_FixP, 
              const ARITHQuant    QuantType);
///////////////////////////////////////////////////////////////////////////////
real RealADD (const real       InA, 
              const real       InB, 
              const FixP          Out_FixP, 
              const ARITHQuant    QuantType);
///////////////////////////////////////////////////////////////////////////////
real RealSUB (const real       InA, 
              const real       InB, 
              const FixP          Out_FixP, 
              const ARITHQuant    QuantType);
///////////////////////////////////////////////////////////////////////////////
real RealMULT(const real       InA, 
              const real       InB, 
              const FixP          Out_FixP, 
              const ARITHQuant    QuantType);
///////////////////////////////////////////////////////////////////////////////


#endif



