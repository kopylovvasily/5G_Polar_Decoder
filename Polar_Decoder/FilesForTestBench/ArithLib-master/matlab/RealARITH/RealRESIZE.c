/*
 * RealRESIZE.c
 *
 * C implementation of the RealRESIZE.m function.
 *
 * Jeffrey Staehli <staehlij@iis.ee.ethz.ch>
 *
 * Updates:
 * - 11/11/08  Supports now the "Wrp" argument. For backward compatibility the old
 *             argument "Clp" is still supported
 * - 04/28/08  Supports variable input fixed-point configs now.
 *             (Dynamic HistData array...)
 * - 04/22/08  Data for duplicate LogIDs are collected in the same struct.
 *             Useful for multi-frame simulations...
 * - 04/18/08  DataBinner() implements now the complementary/inverse cumulative
 *             density function (ccdf)
 * - 04/16/08  added logging functionality
 * - 04/15/08  fixed strange bug in the clip() function
 * - 04/15/08  threshold added to switch between faster sfloor and sclip
 *             functions (the "s" in the function name stands for speed ;))
 *             and slower functions working directly on doubles without
 *             typecasting.
 * - 04/11/08  complete rewrite of the code!
 * -----------------------------------------------------------------------------
 * - 04/09/08  fixed bug with int typecast, changed from (int) to (long int)
 * - 04/09/08  unrolling thrown out for code readability reasons.
 *             Speedwise, the simpler version performs only slightly slower
 * - 04/08/08  supports 3D matrices now
 * - 04/07/08  comments added, code cleanup
 * - 04/04/08  floor and saturate functions now defined as inline functions
 *              in separate header => "RealRESIZE.h"
 * - 04/04/08  floor function implemented with (int) type-casting
 * - 04/03/08  reduction of strcmp compares by enumerating the rounding mode strings
 * - 04/03/08  introduced clamp (saturate) function
 * - 04/02/08  some kind of "dynamic loop unrolling" implemented..
 *             input data is split into blocks of 8, remaining data items
 *              are treated one by one.
 *             => unrolling gave the biggest performance gain!
 * - 04/01/08  initial version    
 */


#define INLINE
#include <mex.h>
#include <math.h>
#include <string.h>
#include "mexheader.h"
#include "mexutils.h"
#include "RealRESIZE.h"


/* inline functions from header file */
extern double saturate(double val, double min, double max);
extern double sfloor(double f);
extern double sclip(double f,double min, double max, int signedIncr);
extern double clip(double f,double min, double max, int signedIncr);
extern unsigned int hash(char *str);


/* function prototypes */
static void RealRESIZE(double y[], const double x[], int noOfElements, int WIDTH_INT, int WIDTH_FRAC, char *SIG_TYPE, char *QType, int mute);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void DataBinner(const double x[], int inFixP[], int *bins, int noOfElements, int binDim);
void GetNoOfBins(const double x[], int noOfElements, int binDims[], int inFixP[]);
void MergeBins(int *binsOldInt, int inFixPOldInt[], int *binsInt, int inFixPInt[], int *binsMergedInt, int inFixPMergedInt[]);


/* Resize function */
static void RealRESIZE(double y[], const double x[], int noOfElements, int WIDTH_INT, int WIDTH_FRAC, char *SIG_TYPE, char *QType, 
                       int mute)
{
     int i;
     int signedIncr;  /*used for the modulo operation*/     
     double maxVal;
     double minVal_clp, minVal_sat;     
     double LSB; 
     int qTypeMode, qTypeWarn, qTypeWarnOverride;
     double tempVal, tempIn;
     
     double threshold = 2.305843009213694E18; /* <-- 2^61 : Threshold */


     qTypeWarn = 0;
     qTypeWarnOverride = 0;
     /* Translate qType string to qType modes */
     if (!strcmp(QType,"ClpTrc") ) { qTypeMode = 0; }
     else if (!strcmp(QType,"WrpTrc") ) { qTypeMode = 0; }
     else if (!strcmp(QType,"ClpRnd") ) { qTypeMode = 1; }
     else if (!strcmp(QType,"WrpRnd") ) { qTypeMode = 1; }
     else if (!strcmp(QType,"SatTrc") ) { qTypeMode = 2; }
     else if (!strcmp(QType,"SatRnd") ) { qTypeMode = 3; }
     else if (!strcmp(QType,"ClpTrc_NoWarn") ) { qTypeMode = 0; qTypeWarnOverride = 1; }
     else if (!strcmp(QType,"WrpTrc_NoWarn") ) { qTypeMode = 0; qTypeWarnOverride = 1; }
     else if (!strcmp(QType,"ClpRnd_NoWarn") ) { qTypeMode = 1; qTypeWarnOverride = 1; }
     else if (!strcmp(QType,"WrpRnd_NoWarn") ) { qTypeMode = 1; qTypeWarnOverride = 1; }
     else if (!strcmp(QType,"SatTrc_NoWarn") ) { qTypeMode = 2; qTypeWarnOverride = 1; }
     else if (!strcmp(QType,"SatRnd_NoWarn") ) { qTypeMode = 3; qTypeWarnOverride = 1; }
     else mexErrMsgTxt("QType must be one of 'WrpTrc', 'WrpRnd', 'SatTrc', 'SatRnd' or '*_NoWarn'");
     
     /* override qTypeWarnOverride if mute argument is set */
     if(mute==1){qTypeWarnOverride = 1;}

     /* Range definitions */ 
     maxVal = pow(2.0,WIDTH_INT+WIDTH_FRAC) - 1;  
     if (!strcmp(SIG_TYPE,"s") )
     {
          /*signed*/
          minVal_clp = -(maxVal+1);
          minVal_sat = minVal_clp+1;
          signedIncr = 1;         
     }
     else if (!strcmp(SIG_TYPE,"u") )
     {
          /*unsigned*/
          minVal_clp = 0;
          minVal_sat = 0;
          signedIncr = 0;          
     }
     else mexErrMsgTxt("FixP{3} must be one of 's' or 'u'");

     
     
     /* Resize depending on mode */
     LSB = pow(2.0,-WIDTH_FRAC);
     if ( qTypeMode == 0 )  
     /* WrpTrc */
     {
          for (i=0; i<noOfElements; i++)
          {
               tempVal = y[i];
               tempIn = x[i]/LSB;
               if ((tempIn > threshold) | (tempIn < -threshold))
                    tempVal = floor(tempIn);
               else tempVal = sfloor(tempIn);
               if ((tempVal > maxVal) | (tempVal < minVal_clp))   
               {
                    qTypeWarn = 1;
                    if ((tempIn > threshold) | (tempIn < -threshold))
                         tempVal = clip(tempVal, minVal_clp, maxVal, signedIncr);
                    else
                         tempVal = sclip(tempVal, minVal_clp, maxVal, signedIncr);
               }
               y[i] = tempVal*LSB;         
          }
     }
     else if (qTypeMode == 1)
     /* WrpRnd */
     {
          for (i=0; i<noOfElements; i++)
          {
               tempVal = y[i];
               tempIn = x[i]/LSB+0.5;
               if ((tempIn > threshold) | (tempIn < -threshold))
                    tempVal = floor(tempIn);
               else tempVal = sfloor(tempIn);
               if ((tempVal > maxVal) | (tempVal < minVal_clp))
               {
                    qTypeWarn = 1;
                    if ((tempIn > threshold) | (tempIn < -threshold))
                         tempVal = clip(tempVal, minVal_clp, maxVal, signedIncr);
                    else
                         tempVal = sclip(tempVal, minVal_clp, maxVal, signedIncr);
               }
               y[i] = tempVal*LSB;
          }
     }
     else if (qTypeMode == 2)
     /* SatTrc */
     {          
          for (i=0; i<noOfElements; i++)
          {
               tempVal = y[i];
               tempIn = x[i]/LSB;
               if ((tempIn > threshold) | (tempIn < -threshold))
                    tempVal = floor(tempIn);            
               else tempVal = sfloor(tempIn);
               if ((tempVal > maxVal) | (tempVal < minVal_sat))
               {
                    qTypeWarn = 1;
                    tempVal = saturate(tempVal,minVal_sat,maxVal);
               }
               y[i] = tempVal*LSB; 
          }
     }
     else
     /* SatRnd */
     {
          for (i=0; i<noOfElements; i++)
          {
               tempVal = y[i];
               tempIn = x[i]/LSB+0.5;
               if ((tempIn > threshold) | (tempIn < -threshold))
                    tempVal = floor(tempIn);
               else tempVal = sfloor(tempIn);
               if ((tempVal > maxVal) | (tempVal < minVal_sat))
               {
                    qTypeWarn = 1;
                    tempVal = saturate(tempVal,minVal_sat,maxVal);
               }
               y[i] = tempVal*LSB;
          }
     }
     
     /* display Saturation or Overflow warnings */
     if (!qTypeWarnOverride) {
          if (qTypeWarn & ((qTypeMode==2) | (qTypeMode==3))) { mexWarnMsgIdAndTxt("CLS:RealARITH:Saturation","Saturation performed! [mex]"); }
          else if (qTypeWarn){ mexWarnMsgIdAndTxt("CLS:RealARITH:Overflow","Overflow performed! [mex]"); }
     }    
}

void DataBinner(const double x[], int inFixP[], int *bins, int noOfElements, int binDim)
{
     int i,k;
     double temp;
     int binIdx;
     double LSBShift;

     if (binDim != 0)
     {          
          LSBShift = pow(2,inFixP[1]);   
          for (i=0; i<noOfElements; i++)
          {
               temp = x[i];
               if (temp < 0) /* negative */
               {
                    temp = fabs(temp)*LSBShift;               
                    binIdx = binDim/2-1 - (int)(log(temp)/log(2));
                    /*mexPrintf("neg ; binDim: %d ; binIdx: %d ; val: %lf\n",binDim,binIdx,-temp);*/       
                    /* integrate (inverse cumulative distribution) */
                    for (k=binDim/2-1; k>=binIdx; k--)
                         *(bins+k) += 1;
               }
               else if (temp == 0) /* zero */
               {
                    binIdx = binDim/2+1; /* undefined for log, throw 0 into pos LSB bin */
                    *(bins+binIdx) += 1;
               }
               else /* positive */
               {
                    temp = temp*LSBShift;
                    binIdx = binDim/2 + (int)(log(temp)/log(2));

                    /*mexPrintf("pos ; binDim: %d ; binIdx: %d ; val: %lf\n",binDim,binIdx,temp);*/
                    /* integrate (inverse cumulative distribution) */
                    for (k=binDim/2; k<=binIdx; k++)
                         *(bins+k) += 1;
               }
               /* *(bins+binIdx) += 1; */
          }
     }     
}

void GetNoOfBins(const double x[], int noOfElements, int binDims[], int inFixP[])
{
     int i;
     int intw,fracw,fracwMax;
     double max,temp;
     int signBit = 0;
     
     binDims[0] = 1; /*constant => row vector*/
     max = fabs(x[0]);
     /* find max input value and at least one negative number for signbit */
     for (i=0; i < noOfElements; i++)
     {
          temp = x[i];
          if (temp < 0){
               /*mexPrintf("neg found: %lf\n",temp);*/
               signBit = 1;
          }          
          if (fabs(temp) > max)
          {
               max = fabs(temp);
          }
     }
     
     /*get int width*/    
     if ((max < 2) & (max > 0)) /* [0..1] 1bit */
          intw = 1;
     else if (max <= 0) /* fractional */
          intw = 0;
     else
          intw = (int)(log(max)/log(2))+1;

     /* find max frac value */
     fracwMax = 0;
     for (i=0; i < noOfElements; i++)
     {
          /*get frac width*/
          fracw = 0;
          temp = x[i];
          while( temp-floor(temp) != 0 ) {
               temp = temp*2;
               fracw++;
          }     
          if (fracw > fracwMax)
          {
               fracwMax = fracw;
          }
     }
     /* set bin dimension and input fixed-point config */
     binDims[1] = (intw + fracwMax)*2;
     inFixP[0] = intw;
     inFixP[1] = fracwMax;
     inFixP[2] = signBit;
     /*mexPrintf("intw: %d ; fracw: %d, binDim: %d\n",intw,fracw,binDims[1]);*/     
}

void MergeBins(int *binsOldInt, int inFixPOldInt[], int *binsInt, int inFixPInt[], int *binsMergedInt, int inFixPMergedInt[])
{
     int i;
     int fracOld, fracMerged, fracNew, intOld, intMerged, intNew;
     int intDiff, fracDiff, midIdx, targetIdx;
     
     /*mexPrintf("merging...\n");*/
     intOld = inFixPOldInt[0];
     intMerged = inFixPMergedInt[0];
     intNew = inFixPInt[0];

     /* same frac bits length */
     fracOld = inFixPOldInt[1];
     fracMerged = inFixPMergedInt[1];
     fracNew = inFixPInt[1];
     
     /*shift copy old*/
     midIdx = fracOld + intOld;
     intDiff = intMerged - intOld;
     fracDiff = fracMerged - fracOld;
     for (i=0; i<2*(midIdx);i++)
     {
          if (i<midIdx)
               targetIdx = i+intDiff;
          else
               targetIdx = i+intDiff+2*fracDiff;
/*          mexPrintf("si = %d ; ti = %d\n",i,targetIdx);*/
          binsMergedInt[targetIdx] = binsOldInt[i];
     }
     /*shift copy new*/
     midIdx = fracNew + intNew;
     intDiff = intMerged - intNew;
     fracDiff = fracMerged - fracNew;
     for (i=0; i<2*(midIdx);i++)
     {
          if (i<midIdx)
               targetIdx = i+intDiff;
          else
               targetIdx = i+intDiff+2*fracDiff;
/*          mexPrintf("si = %d ; ti = %d\n",i,targetIdx);*/
          binsMergedInt[targetIdx] += binsInt[i];
     }     
}

/* The mex Gateway routine */                       
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
     double *y;
     const double *x;
     int  WIDTH_INT, WIDTH_FRAC;
     char *SIG_TYPE;
     char *QType;
     int  mute = 0;
     int  noOfElements;
     int  ndims;
     const int  *dimSizes;
     
     /* LOGDATA Vars */
     mxArrayPtr LOGDATA_ptr, globalMute_ptr;
     int noOfFields,i;
     mxArrayPtr bins, binsOld, binsMerged;
     int *binsInt, *binsOldInt, *binsMergedInt;
     int binDims[2]; 
     mxArrayPtr inFixPCell;
     int inFixPInt[3], inFixPOldInt[2], inFixPMergedInt[2];
     char inFixPOldChar[2];
     char *IDstring;
     char *IDstringCut = NULL; /*init to avoid warning issued when flag -Wuninitialized is set"*/
     
     
     unsigned int hashNo, testHash;
     int duplicateID,duplicateStructIdx;
     mxArrayPtr IDDataStruct;
     mxArrayPtr tempStruct;
     
     int IDstringLength;
     int isComplex = 0;
     char *FixPString;     
     
     /* Examine input (right-hand-side) arguments. */ 
     userAssert(nrhs >= 3, "RealRESIZE wants at least 3 arguments!");
     userAssert(nlhs <= 1, "RealRESIZE wants at most 1 return values!");
     
     userAssertValidArgument(prhs, 0, 0, 0, mxDOUBLE_CLASS);  /* input data vector */
     userAssertValidArgument(prhs, 1, 0, 0, mxCELL_CLASS);    /* fixed point specs cell */
     userAssertValidArgument(prhs, 2, 0, 0, mxCHAR_CLASS);    /* quant type string */

     /* Get Input Data */
     x = mxGetPr(prhs[0]);
  
     /* Extract the fixed-point specs out of the cell array */
     WIDTH_INT = (int) mxGetScalar(mxGetCell(prhs[1],0));
     WIDTH_FRAC = (int) mxGetScalar(mxGetCell(prhs[1],1));
     SIG_TYPE = mxArrayToString(mxGetCell(prhs[1],2));

     /* Get Quantization Type */
     QType = mxArrayToString(prhs[2]);
  
     /* Extract number of elements in the input matrix */
     noOfElements = mxGetNumberOfElements(prhs[0]);
     
     /* Create output matrix and set its pointer to the return argument */
     ndims = mxGetNumberOfDimensions(prhs[0]);
     dimSizes = mxGetDimensions(prhs[0]);
     plhs[0] = mxCreateNumericArray(ndims,dimSizes,mxDOUBLE_CLASS,mxREAL);
     y = mxGetPr(plhs[0]);
    
     /* check whether global output mute variable is set */
     globalMute_ptr = mexGetVariable("global","ArithLibMute");  
     if (globalMute_ptr != NULL) {
       /* check if globalMute_ptr is a double */
       if(mxGetClassID(globalMute_ptr) != mxDOUBLE_CLASS) {
         mexErrMsgTxt("Wrong array class type for ArithLibMute (must be double)");
       } else {
         /* check whether globalMute is set to 1 */
         if(mxGetPr(globalMute_ptr)[0]==1) {
           mute = 1;
         }
       }
     }        
     
     /* call C subroutine */
     RealRESIZE(y, x, noOfElements, WIDTH_INT, WIDTH_FRAC, SIG_TYPE, QType, mute);
     
     /* clean up memory */
     mxFree(SIG_TYPE);
     mxFree(QType);
     
     /* LOGDATA */    
     if (nrhs > 3)
     {
          LOGDATA_ptr = mexGetVariable("global","ArithLibStatistics");  
          if (LOGDATA_ptr != NULL)
          {
               /* check if LOGDATA_ptr is a struct */
               if(mxGetClassID(LOGDATA_ptr) != mxSTRUCT_CLASS)
               {
                    mexErrMsgTxt("Wrong array class type for ArithLibStatistics");
               }
               
               /* ensure that the LogID arguments is a string */
               userAssertValidArgument(prhs, 3, 0, 0, mxCHAR_CLASS);    /* LogID string */
               IDstring = mxArrayToString(prhs[3]);             
               hashNo = hash(IDstring);
               /*mexPrintf("hashNo %d\n",hashNo);*/
               duplicateID = 0;
               /* get Number of fields in the current struct */
               noOfFields = mxGetNumberOfFields(LOGDATA_ptr);
               
               /* Calculate number of bins needed and extract input fixed point config */
               GetNoOfBins(x,noOfElements,binDims,inFixPInt);
               /* Calculate Hist Data */
               /*mexPrintf("%d\n",binDims[1]);*/
               /*mexPrintf("inFixPInt[0] = %d, inFixPInt[1] = %d\n",inFixPInt[0],inFixPInt[1]);*/
               
               if (binDims[1] == 0)
                    bins = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
               else
                    bins = mxCreateNumericMatrix(binDims[0],binDims[1],mxINT32_CLASS,mxREAL);
               binsInt = (int*)mxGetPr(bins);
               DataBinner(x,inFixPInt,binsInt,noOfElements,binDims[1]);
               /* Check whether calling function is real or complex */
               if((strstr(IDstring, "(REAL)")==NULL) & (strstr(IDstring, "(IMAG)")==NULL)) {
                    isComplex = 0;  
               }
               else {
                    isComplex = 1;
                    IDstringLength = strlen(IDstring);                    
                    IDstringCut = (char*)mxMalloc(IDstringLength-5);
                    /*IDstringCut = mxCalloc(IDstringLength-5, sizeof(char));*/
                    strncpy(IDstringCut, IDstring, IDstringLength-6);
                    IDstringCut[IDstringLength-6]= '\0';
                    hashNo = hash(IDstringCut);
               }
               /*mexPrintf("isComplex: %d\n",isComplex);*/
               
               /* Check for duplicates */
               i=0;
               /*mexPrintf("superstructsize %d\n",noOfFields);*/
               while (i<noOfFields) /*find duplicate*/
{
                    /*mexPrintf("searching...\n");*/
                    
                    tempStruct = mxGetFieldByNumber(LOGDATA_ptr,0,i); 
                    testHash = (unsigned int) mxGetScalar( mxGetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"Hash")) );
                    /*mexPrintf("testHash: %d ; hashNo: %d\n",testHash,hashNo);*/                       
                    if (hashNo == testHash)
                    {
                         duplicateID = 1;
                         duplicateStructIdx = i;
                         /*mexPrintf("duplicate found @ id: %d\n",duplicateStructIdx);*/
                         break;
                    }
                    i++;
               }
               /* If duplicate was found, then merge existing HistData with the new Data */
               if(duplicateID)
               {                    
                    /*mexPrintf("superimposing data\n");*/
                    /* get existing HistData from correct field */
                    tempStruct = mxGetFieldByNumber(LOGDATA_ptr,0,duplicateStructIdx);
                    if (!isComplex){
                         /*mexPrintf("getPure\n");*/
                         binsOld = mxGetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"HistData"));
                         FixPString = "InFixPt";
                    }                    
                    else if (strstr(IDstring, "(REAL)")!=NULL) {
                         /*mexPrintf("getREAL\n");*/
                         binsOld = mxGetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"HistDataREAL"));
                         FixPString = "InFixPtREAL";
                    }                    
                    else {                         
                         binsOld = mxGetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"HistDataIMAG"));
                         FixPString = "InFixPtIMAG";
                         /*mexPrintf("getIMAG\n");*/ 
                    }
                    if (binsOld != NULL) /*not empty*/ {
                         /*mexPrintf("merge\n");*/
                         binsOldInt = (int*)mxGetPr(binsOld);
                         inFixPOldInt[0] = mxGetScalar(mxGetCell(mxGetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,FixPString)),0));
                         inFixPOldInt[1] = mxGetScalar(mxGetCell(mxGetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,FixPString)),1));
                         mxGetString(mxGetCell(mxGetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,FixPString)),2),inFixPOldChar,2);
                         /*mexPrintf("old: %d, %d\n",inFixPOldInt[0],inFixPOldInt[1]);*/
                         /*mexPrintf("new: %d, %d\n",inFixPInt[0],inFixPInt[1]);*/
                         /* choose max(old,new) */
                         inFixPMergedInt[0] = MAX(inFixPOldInt[0],inFixPInt[0]);
                         inFixPMergedInt[1] = MAX(inFixPOldInt[1],inFixPInt[1]);
                         /* Set Merged Input Fixed-Point Specification */
                         inFixPCell = mxCreateCellMatrix(1,3);
                         mxSetCell(inFixPCell, 0, mxCreateDoubleScalar(inFixPMergedInt[0]));
                         mxSetCell(inFixPCell, 1, mxCreateDoubleScalar(inFixPMergedInt[1]));
                         /*mexPrintf("mgd: %d, %d\n",inFixPMergedInt[0],inFixPMergedInt[1]);*/
                    
                         if ((inFixPInt[2] == 0) & (!strcmp(inFixPOldChar,"u")))
                              mxSetCell(inFixPCell, 2, mxCreateString("u"));
                         else
                              mxSetCell(inFixPCell, 2, mxCreateString("s"));
                    
                         /*error line*/
                         mxSetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,FixPString),mxDuplicateArray(inFixPCell));
                         /* create merged bins */
                         /*mexPrintf("%d\n",inFixPMergedInt[0]+inFixPMergedInt[1]);*/
                         
                         if (inFixPMergedInt[0]+inFixPMergedInt[1] == 0)
                              binsMerged = mxCreateNumericMatrix(0,0,mxINT32_CLASS,mxREAL); /*1x1 matrix*/
                         else
                              binsMerged = mxCreateNumericMatrix(1,2*(inFixPMergedInt[0]+inFixPMergedInt[1]),mxINT32_CLASS,mxREAL);
                         binsMergedInt = (int*)mxGetPr(binsMerged);
                         MergeBins(binsOldInt,inFixPOldInt,binsInt,inFixPInt,binsMergedInt,inFixPMergedInt);
                         /* Put data into correct field */
                         if (!isComplex){                         
                              /*mexPrintf("setPure\n");*/                    
                              mxSetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"HistData"),mxDuplicateArray(binsMerged));
                         }                    
                         else if (strstr(IDstring, "(REAL)")!=NULL) {
                              /*mexPrintf("setREAL\n"); */
                              mxSetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"HistDataREAL"),mxDuplicateArray(binsMerged));
                         }                    
                         else {
                              /*mexPrintf("setIMAG\n");*/ 
                              mxSetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"HistDataIMAG"),mxDuplicateArray(binsMerged));
                         }
                    
                         mxDestroyArray(binsMerged);
                         mxDestroyArray(inFixPCell);
                    }
                    else /*empty IMAG field*/
                    {
                         /* Set Input Fixed-Point Specification */
                         inFixPCell = mxCreateCellMatrix(1,3);
                         mxSetCell(inFixPCell, 0, mxCreateDoubleScalar(inFixPInt[0]));
                         mxSetCell(inFixPCell, 1, mxCreateDoubleScalar(inFixPInt[1]));
                         if (inFixPInt[2] == 0)
                              mxSetCell(inFixPCell, 2, mxCreateString("u"));
                         else
                              mxSetCell(inFixPCell, 2, mxCreateString("s"));
                         /*mexPrintf("init IMAG fields\n");*/
                         mxSetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"InFixPtIMAG"),mxDuplicateArray(inFixPCell));
                         mxSetFieldByNumber(tempStruct,0,mxGetFieldNumber(tempStruct,"HistDataIMAG"),mxDuplicateArray(bins));
                         mxDestroyArray(inFixPCell);
                    }                  
               }
               else /*init/add struct!*/
               {
                    /* Set Input Fixed-Point Specification */
                    inFixPCell = mxCreateCellMatrix(1,3);
                    mxSetCell(inFixPCell, 0, mxCreateDoubleScalar(inFixPInt[0]));
                    mxSetCell(inFixPCell, 1, mxCreateDoubleScalar(inFixPInt[1]));
                    if (inFixPInt[2] == 0)
                         mxSetCell(inFixPCell, 2, mxCreateString("u"));
                    else
                         mxSetCell(inFixPCell, 2, mxCreateString("s"));
                    /* Build struct holding the ID specific data */               
                    /*if(strstr(IDstring, "(REAL)")==NULL & strstr(IDstring, "(IMAG)")==NULL) {
                      isComplex = 0;                   */
                    if (!isComplex) {                         
                         IDDataStruct = mxCreateStructMatrix(1,1,0,NULL);
                         userAssert(mxAddField(LOGDATA_ptr,IDstring) != -1, "Field could not be added!");                    
                         userAssert(mxAddField(IDDataStruct,"Hash") != -1, "Field 'Hash' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"IsComplex") != -1, "Field 'IsComplex' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"InFixPt") != -1, "Field 'InFixPt' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"OutFixPt") != -1, "Field 'OutFixPt' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"QuantType") != -1, "Field 'QuantType' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"HistData") != -1, "Field 'HistData' could not be added!");
                         /* set struct data */
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"Hash"),mxCreateDoubleScalar(hashNo));
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"IsComplex"),mxCreateDoubleScalar(0));
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"InFixPt"),mxDuplicateArray(inFixPCell));
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"OutFixPt"),mxDuplicateArray(prhs[1]));
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"QuantType"),mxDuplicateArray(prhs[2]));
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"HistData"),mxDuplicateArray(bins));
                         /* set struct into "super-struct" */
                         mxSetFieldByNumber(LOGDATA_ptr,0,mxGetFieldNumber(LOGDATA_ptr,IDstring),mxDuplicateArray(IDDataStruct));
                         mxDestroyArray(IDDataStruct);                    
                    }
                    else /*complex*/
                    {
                         IDDataStruct = mxCreateStructMatrix(1,1,0,NULL);
                         /*add only one field in ArithLibStatistics for complex arith ops*/
                         userAssert(mxAddField(LOGDATA_ptr,IDstringCut) != -1, "Field could not be added!");
                         userAssert(mxAddField(IDDataStruct,"Hash") != -1, "Field 'Hash' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"IsComplex") != -1, "Field 'IsComplex' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"InFixPtREAL") != -1, "Field 'InFixPtREAL' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"InFixPtIMAG") != -1, "Field 'InFixPtIMAG' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"OutFixPt") != -1, "Field 'OutFixPt' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"QuantType") != -1, "Field 'QuantType' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"HistDataREAL") != -1, "Field 'HistDataREAL' could not be added!");
                         userAssert(mxAddField(IDDataStruct,"HistDataIMAG") != -1, "Field 'HistDataIMAG' could not be added!");
                         /* set struct data REAL, IMAG data still NULL */
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"Hash"),mxCreateDoubleScalar(hashNo));
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"IsComplex"),mxCreateDoubleScalar(1));
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"InFixPtREAL"),mxDuplicateArray(inFixPCell));                         
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"OutFixPt"),mxDuplicateArray(prhs[1]));
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"QuantType"),mxDuplicateArray(prhs[2]));      
                         mxSetFieldByNumber(IDDataStruct,0,mxGetFieldNumber(IDDataStruct,"HistDataREAL"),mxDuplicateArray(bins));                           
                         /* set struct into "super-struct" */
                         mxSetFieldByNumber(LOGDATA_ptr,0,mxGetFieldNumber(LOGDATA_ptr,IDstringCut),mxDuplicateArray(IDDataStruct));
                         mxDestroyArray(IDDataStruct);
                         /*mxDestroyArray(binsZeros);*/
                         mxFree(IDstringCut);
                    }
                    mxDestroyArray(inFixPCell);                   
               }
               
               mxDestroyArray(bins);                             

               
/* ######################################### */

               /* Copy the structure back into the global workspace */
               mexPutVariable("global", "ArithLibStatistics", LOGDATA_ptr);

               
               /* clean up memory */              
               mxFree(IDstring);              
               mxDestroyArray(LOGDATA_ptr);   /* delete copied structure */
               
          }
          else mexPrintf("Global ArithLibStatistics variable has not been specified or has been cleared!\n");
     } /* end LOGDATA */   
}
