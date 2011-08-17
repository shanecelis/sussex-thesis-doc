/* rkqs.h */

int rkqs(double y[], double dydx[], const int n, double *x, 
         double htry, double eps, double yscal[], 
         double *hdid, double *hnext, int (*derivs)(double, double [], double []));

int rkck(double y[], double dydx[], const int n, double x, double h, 
         double yout[], double yerr[], int (*derivs)(double, double [], double []));
