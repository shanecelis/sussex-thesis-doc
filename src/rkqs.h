/* rkqs.h */

#define TINY  1.e-6

int rkqs(double y[], double dydx[], const int n, double *x, 
         double htry, double eps, double yscal[], 
         double *hdid, double *hnext, double yout[], int (*derivs)(double, double [], double [], void *), void *context);

int rkck(double y[], double dydx[], const int n, double x, double h, 
         double yout[], double yerr[], int (*derivs)(double, double [], double [], void *), void *context);

int rk4(double y[], double dydx[], const int n, double x,
        double h, double yout[], int (*derivs)(double, double [], double [], void *), void *context);
