/*
 * Miscellaneous utility functions for MATLAB MEX programming
 *
 * $Header$
 *
 * $Log$
 * Revision 1.3  2004/03/21 18:02:20  moriborg
 * - C-style comments
 *
 * Revision 1.2  2001/11/20 20:38:32  moriborg
 * Rolled in getBase/setBase
 * array bounds checking for getDoubleElement etc.
 *
 * Revision 1.1  2001/11/12 23:50:34  moriborg
 * Initial Checkin
 *
 *
 */

#include <stdio.h>
#include "mexheader.h"
#include "mexutils.h"

doublePtr
arrGetElementPtrR1D(mxArrayConstPtr arr, long r)
{
  long m;
  m = mxGetM(arr) * mxGetN(arr);

#ifdef HARDCORE_DEBUGGING
  if(!((r>=0) && (r<m)))
  {
    char s[256];
    sprintf(s, "arrGetElementPtrR: arr: M=%ld N=%ld r=%ld", m, n, r);
    mxAssert((r>=0) && (r<m), s);
  }
#else
  mxAssert((r>=0) && (r<m), "arrGetElementPtrR");
#endif
  return mxGetPr(arr) + ((unsigned long)r);
}


doublePtr
arrGetElementPtrR(mxArrayConstPtr arr, long r, long c)
{
  long m, n;
  m = mxGetM(arr);
  n = mxGetN(arr);

#ifdef HARDCORE_DEBUGGING
  if(!((r>=0) && (r<m)))
  {
    char s[256];
    sprintf(s, "arrGetElementPtrR: arr: M=%ld N=%ld r=%ld c=%ld", m, n, r, c);
    mxAssert((r>=0) && (r<m), s);
  }
  if(!((c>=0) && (c<n)))
  {
    char s[256];
    sprintf(s, "arrGetElementPtrR: arr: M=%ld N=%ld r=%ld c=%ld", m, n, r, c);
    mxAssert((c>=0) && (c<n), s);
  }
#else
  mxAssert((r>=0) && (r<m), "arrGetElementPtrR");
  mxAssert((c>=0) && (c<n), "arrGetElementPtrR");
#endif
  return mxGetPr(arr) + ((unsigned long)c)*m + ((unsigned long)r);
}

doublePtr
arrGetElementPtrI(mxArrayConstPtr arr, long r, long c)
{
  long m, n;
  doublePtr p;
  
  m = mxGetM(arr);
  n = mxGetN(arr);
  p = mxGetPr(arr);

  mxAssert(p, "arrGetElementPtrR");
#ifdef HARDCORE_DEBUGGING
  if(!((r>=0) && (r<m)))
  {
    char s[256];
    sprintf(s, "arrGetElementPtrI: arr: M=%ld N=%ld r=%ld c=%ld", m, n, r, c);
    mxAssert((r>=0) && (r<m), s);
  }
  if(!((c>=0) && (c<n)))
  {
    char s[256];
    sprintf(s, "arrGetElementPtrI: arr: M=%ld N=%ld r=%ld c=%ld", m, n, r, c);
    mxAssert((c>=0) && (c<n), s);
  }
#else
  mxAssert((r>=0) && (r<m), "arrGetElementPtrI");
  mxAssert((c>=0) && (c<n), "arrGetElementPtrI");
#endif
  
  return p + ((unsigned long)c)*m + ((unsigned long)r);
}


/* Assert that a function has been called with correct type of arguments */
void
userAssertValidArgument(const mxArray *prhs[], unsigned int ind, unsigned int m, unsigned int n, mxClassID class)
{
  char	s[256];
  const mxArray *arr = prhs[ind];
	
  if(m)
    if(mxGetM(arr) != m)
    {
      sprintf(s, "Wrong number of rows in input parameter #%d. Expected %d, got %zd.",
	      ind+1, m, (size_t) mxGetM(arr));
      mexErrMsgTxt(s);
    }
	
  if(n)
    if(mxGetN(arr) != n)
    {
      sprintf(s, "Wrong number of columns in input parameter #%d. Expected %d, got %zd.",
	      ind+1, n, (size_t) mxGetN(arr));
      mexErrMsgTxt(s);
    }
	
	
  if(class)
    if(mxGetClassID(arr) != class)
    {
      sprintf(s, "Wrong array class type in input parameter #%d.", ind+1);
      mexErrMsgTxt(s);
    }
}

/* Dump a matrix to stdout, mostly useful for debugging purposes */
void
dumpMatrix_(const mxArray* arr, const char *s)
{
  unsigned int n,m;
	
  mexPrintf(" %s [%d, %d] = \n", s, mxGetM(arr), mxGetN(arr));
  for (m=0;m<mxGetM(arr);m++)
  {
    for (n=0;n<mxGetN(arr);n++)
    {
      switch(mxGetClassID(arr))
      {
      case mxDOUBLE_CLASS:
	mexPrintf(" %10g ", doubleElement(arr, m, n));
	if(mxIsComplex(arr))
	  mexPrintf("+ %10gi  ", doubleElementI(arr, m, n));	  
	break;
      case mxUINT16_CLASS:
	mexPrintf(" %7d ", uint16Element(arr, m, n));
	break;
      case mxFUNCTION_CLASS:
        mexPrintf(" FUNCTION");
	break;
      default:
	mexPrintf("Class ID %d not supported", mxGetClassID(arr));
	break;
      }
    }
    mexPrintf("\n");
  }
  mexPrintf("\n");
}


double *
getDoubleColPr(const mxArray* arr, unsigned int col)
{
  mxAssert(col < mxGetN(arr), "getColPtr");
  mxAssert(mxGetClassID(arr) == mxDOUBLE_CLASS, "getColPtr");
  return mxGetPr(arr) + col*mxGetM(arr);
}

UINT16_T *
getUint16ColPr(const mxArray* arr, unsigned int col)
{
  mxAssert(col < mxGetN(arr), "getColPtr");
  mxAssert(mxGetClassID(arr) == mxUINT16_CLASS, "getColPtr");
  return ((UINT16_T *)mxGetData(arr)) + col*mxGetM(arr);
}

/* Copy contents of one MATLAB array to another already existing one */
void
mxCopyArray(mxArrayConstPtr arr1, mxArrayConstPtr arr2)
{
  long bufbytes;
  doublePtr baseI1, baseI2;
  char s[256];
  
  baseI1 = mxGetPi(arr1); baseI2 = mxGetPi(arr2);

  sprintf(s, "mxCopyArray: N(arr1)=%zd, N(arr2)=%zd", (size_t) mxGetN(arr1), (size_t) mxGetN(arr2));
  mxAssert(mxGetN(arr1) == mxGetN(arr2), s);
  sprintf(s, "mxCopyArray: M(arr1)=%zd, M(arr2)=%zd", (size_t) mxGetM(arr1), (size_t) mxGetM(arr2));
  mxAssert(mxGetM(arr1) == mxGetM(arr2), s);
	   
  
  mxAssert(mxGetClassID(arr1) == mxGetClassID(arr2), "mxCopyArray: Array class must be identical");
  mxAssert(!(baseI1 && !baseI2), "mxCopyArray: source has imag data, but dest hast NULL imag base ptr");
  
  bufbytes = mxGetM(arr1)*mxGetN(arr1)*mxGetElementSize(arr1);
  memcpy(mxGetPr(arr2), mxGetPr(arr1), bufbytes);
  
  if(baseI1 && baseI2)
    memcpy(baseI2, baseI1, bufbytes);
  
  if(!baseI1 && baseI2)
    memset(baseI2, 0, bufbytes);
}


/* Various functions for manipulating the Pr and Pi base pointers of an array */
void
getBase(mxArrayConstPtr arr, arrBase *base)
{
  base->buflen = (long)mxGetN(arr)*(long)mxGetM(arr);
  base->r = mxGetPr(arr);
  base->i = mxGetPi(arr);
}

void
setBase(mxArrayPtr arr, arrBase const *base)
{
  mxSetPr(arr, base->r);
  mxSetPi(arr, base->i);
}

void
setBaseOffset(mxArrayPtr arr, arrBase const *base, long offset)
{
  long arrBuflen;
  
  arrBuflen = (long)mxGetN(arr)*(long)mxGetM(arr);
#ifdef HARDCORE_DEBUGGING
  if((offset <0) || (offset + arrBuflen > base->buflen))
    mexPrintf("arrBuflen=%ld offset: %ld\n", arrBuflen, offset);
#endif
  mxAssert(offset >= 0, "setBaseOffset: Attempt to set negative offset");
  mxAssert(offset + arrBuflen <= base->buflen,
	   "setBaseOffset: Attempt to advance array pointer out of bounds");
  
  mxSetPr(arr, base->r + offset);
  if(base->i)
    mxSetPi(arr, base->i + offset);
  else
    mxSetPi(arr, nil);
}
