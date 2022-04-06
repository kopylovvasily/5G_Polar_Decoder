/*
 * Interface definition header file for mexutils.c
 *
 * $Header$
 *
 * $Log$
 * Revision 1.3  2004/03/21 18:02:21  moriborg
 * - C-style comments
 *
 * Revision 1.2  2001/11/20 20:37:44  moriborg
 * Rolled in getBase/setBase functions
 * getDoubleElement and friends now use array bounds checking unless NDEBUG is defined
 *
 * Revision 1.1  2001/11/12 23:50:34  moriborg
 * Initial Checkin
 *
 *
 */

#ifndef __MEXUTILS__
#define __MEXUTILS__

#include "mexheader.h"

typedef struct {
  long buflen;
  doublePtr r, i;
} arrBase;


void mxCopyArray(const mxArray* arr1, const mxArray* arr2);
void* getColPr(const mxArray* arr, unsigned int col);
double *getDoubleColPr(const mxArray* arr, unsigned int col);
UINT16_T *getUint16ColPr(const mxArray* arr, unsigned int col);


void getBase(mxArrayConstPtr arr, arrBase *base);
void setBase(mxArrayPtr arr, arrBase const *base);
void setBaseOffset(mxArrayPtr arr, arrBase const *base, long offset);


/* Useful accessors for array elements */
doublePtr arrGetElementPtrR(mxArrayConstPtr arr, long r, long c);
doublePtr arrGetElementPtrI(mxArrayConstPtr arr, long r, long c);
doublePtr arrGetElementPtrR1D(mxArrayConstPtr arr, long r);

#define element2D(ptr, m, n, M) (*((ptr) + ((unsigned long)(n))*(M) + ((unsigned long)(m))))
#define element1D(ptr, m) (*((ptr) + ((unsigned long)(m))))

#ifdef NDEBUG
#define doubleElementR(arr, m, n) (*(mxGetPr(arr) + ((unsigned long)n)*mxGetM(arr) + ((unsigned long)m)))
#define doubleElementI(arr, m, n) (*(mxGetPi(arr) + ((unsigned long)n)*mxGetM(arr) + ((unsigned long)m)))
#define doubleElementR1D(arr, m) (*(mxGetPr(arr) + ((unsigned long)m)))
#else
#define doubleElementR(arr, m, n) (*arrGetElementPtrR(arr, m, n))
#define doubleElementI(arr, m, n) (*arrGetElementPtrI(arr, m, n))
#define doubleElementR1D(arr, m) (*arrGetElementPtrR1D(arr, m))
#endif

#define doubleElement(arr, m, n) doubleElementR(arr, m, n)


#define uint16Element(arr, m, n) (*(((UINT16_T*)mxGetData(arr)) + ((unsigned long)n)*mxGetM(arr) + ((unsigned long)m)))

#define dumpMatrix(a) dumpMatrix_(a, #a)
void dumpMatrix_(const mxArray* arr, const char *s);

/* Debugging functions */
#define debugInt(a) mexPrintf(#a " = %d\n", a)

#define userAssert(test, msg) if(!(test)) mexErrMsgTxt(msg)
void userAssertValidArgument(const mxArray *prhs[], unsigned int ind, unsigned int m, unsigned int n, mxClassID class);

#endif
