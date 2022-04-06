/*
 * C header file with several useful definitions for MATLAB MEX programming
 *
 * $Header$
 *
 * Copyright (C) 2001 by Moritz Borgmann
 *
 * $Log$
 * Revision 1.2  2001/11/14 02:26:05  moriborg
 * Defined nil
 *
 * Revision 1.1  2001/11/12 23:50:35  moriborg
 * Initial Checkin
 *
 *
 */

#ifndef __MEXHEADER__
#define __MEXHEADER__

#include <mex.h>
#include <math.h>
#include <string.h>
#if defined (__sun)
  #include <sys/int_types.h>
#else
  #include <stdint.h>
#endif
/* #include <values.h> */

#define MAX(a,b) ((a)>(b) ? (a) : (b))
#define NIL 0L
#define nil 0L

/* ############### */
/* The following is taken verbatim from MATLAB's tmwtypes.h.
   For compatibility with octave. */

/*#ifndef BOOLEAN_T
# if defined(UINT8_T)
#  define BOOLEAN_T UINT8_T
# else
#  define BOOLEAN_T unsigned int
# endif
#endif
typedef BOOLEAN_T boolean_T;*/

#if !defined(__cplusplus) && !defined(__bool_true_false_are_defined)

#ifndef _bool_T
#define _bool_T

/*typedef boolean_T bool;*/

#ifndef false
#define false (0)
#endif
#ifndef true 
#define true (1)
#endif

#endif /* _bool_T */

#endif /* !__cplusplus */

/* ############### */

typedef mxArray * mxArrayPtr;
typedef const mxArray * mxArrayConstPtr;
typedef double * doublePtr;

#endif
