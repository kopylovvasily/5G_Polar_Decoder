/*
 * RealRESIZE.h
 *
 * Header file for the RealRESIZE.c function
 * containing frequently used functions
 *
 * Jeffrey Staehli <staehlij@iis.ee.ethz.ch>
 *
 * Updates:
 * - 04/07/08  comments added
 * - 04/04/08  initial version    
 */

#ifndef INLINE
# if __GNUC__
#  define INLINE extern inline
# else
#  define INLINE inline
# endif
#endif


/* "saturate" clamps values into the interval defined by min and max */
INLINE double saturate(double val, double min, double max)
{
     if (val < min) { val = min; }
     else if (val > max) { val = max; }
     return val;
}

/* "sfloor" calculates the floor of input value f (TYPECASTING!) */
INLINE double sfloor(double f)
{
     /*long long temp;*/
     if (f>=0)
     {
          return (double)(long long)f;
     }
     else
     {          
          if ((long long)f == f) { f = fabs(f); }
          else { f = fabs(f)+1.0; }     
          /*temp = (int64_t)f;*/    
          return -(double)(long long)f;
     }
     
}

/* "sclip" performs wrap of f value into interval specified by min and max (TYPECASTING!)*/ 
INLINE double sclip(double f,double min, double max, int signedIncr)
{
     return  (double) ( ((long long)(f - min)) & (((long long)(max+1) << signedIncr)-1) ) + min;    
}

/* "clip" performs wrap of f value into interval specified by min and max (double precision)*/
INLINE double clip(double f,double min, double max, int signedIncr)
{
     double numerator,denumerator;
     double temp, sub;
     
     numerator = f - min;   
     denumerator = (max+1) * (signedIncr+1.0); 
     temp = (floor(numerator/denumerator) * denumerator);
     sub = numerator - temp;
     temp = sub + min;
     mexPrintf("",sub); /* UGLY HACK! */
     return temp;   
     /*return numerator - (floor(numerator/denumerator) * denumerator) + min;*/
}

/* sdbm hash function */
INLINE unsigned int hash(char *str)
{
     unsigned int hash = 0;
        int c = 0;
        while ((c = *str++)) {
               hash = c + (hash << 6) + (hash << 16) - hash;
        }
        
        return hash;
}

