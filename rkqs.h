/* rkqs.h */

int rkqs(float y[], float dydx[], const int n, float *x, 
         float htry, float eps, float yscal[], 
         float *hdid, float *hnext, void (*derivs)(float, float [], float []));
