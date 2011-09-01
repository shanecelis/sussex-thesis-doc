/* rkqs.c */

#include <math.h> 
#include "rkqs.h"
#define SAFETY  0.9 
#define PGROW  -0.2 
#define PSHRNK -0.25 
#define ERRCON  1.89e-4 
//The value ERRCON equals (5/SAFETY) raised to the power (1/PGROW), see use below.

// XXX substitute these with macros instead of functions.
#define FMAX fmax
#define FMIN fmin

//void (*derivs)(double x, double y[], double dydx[]);

int rkqs(double y[], double dydx[], const int n, double *x, 
         double htry, double eps, double yscal[], 
         double *hdid, double *hnext, double yout[], int (*derivs)(double, double [], double [], void *), void *context)
/* Fifth-order Runge-Kutta step with monitoring of local truncation
 * error to ensure accuracy and adjuststepsize. Input are the
 * dependent variable vector y[1..n] and its derivative dydx[1..n] at
 * the starting value of the independent variable x. Also input are
 * the stepsize to be attempted htry, the required accuracy eps, and
 * the vector yscal[1..n] against which the error is scaled. On
 * output, y and x are replaced by their new values, hdid is the
 * stepsize that was actually accomplished, and hnext is the estimated
 * next stepsize. derivs is the user-supplied routine that computes
 * the right-hand side derivatives.*/
{
/*  int rkck(double y[], double dydx[], const int n, double x, double h, 
    double yout[], double yerr[], int (*derivs)(double, double [], double []));*/
  int i, err; 
  double errmax,h,htemp,xnew; //*yerr,*ytemp;
  double yerr[n],ytemp[n];
  h=htry;	
  //Set stepsize to the initial trial value. 
  for (;;) {
    err = rkck(y,dydx,n,*x,h,ytemp,yerr,derivs, context); //Take a step. 
    if (err) return err;
    errmax=0.0;                                  //Evaluate accuracy. 
    for (i=0;i<n;i++) 
      errmax=FMAX(errmax,fabs(yerr[i]/yscal[i])); 
    errmax /= eps;            //Scale relative to required tolerance. 
    if (errmax <= 1.0) break; //Step succeeded. 
    //Compute size of next step. 
    htemp=SAFETY*h*pow(errmax,PSHRNK); 
    //Truncation error too large, reduce stepsize. 
    h=(h >= 0.0 ? FMAX(htemp,0.1*h) : FMIN(htemp,0.1*h)); 
    //No more than a factor of 10. 
    xnew=(*x)+h; 
    if (xnew == *x) {
      //fprintf(stderr, "error: stepsize underflow in rkqs\n");
      return 1;
    }
  } 
  if (errmax > ERRCON) 
    *hnext=SAFETY*h*pow(errmax,PGROW);
  else 
    *hnext=5.0*h; 
  *x += (*hdid=h); 
  for (i=0;i<n;i++) 
    yout[i]=ytemp[i]; 

  return 0;
}

int rkck(double y[], double dydx[], const int n, double x, double h, 
         double yout[], double yerr[], int (*derivs)(double, double [], double [], void *), void *context) 
/*Given values for n variables y[1..n] and their derivatives
 * dydx[1..n] known at x, use the fifth-order Cash-Karp Runge-Kutta
 * method to advance the solution over an interval h and return the
 * incremented variables as yout[1..n]. Also return an estimate of the
 * local truncation error in yout using the embedded fourth-order
 * method. The user supplies the routine derivs(x,y,dydx), which
 * returns derivatives dydx at x.*/
{
  int i, err;
  static double a2=0.2,a3=0.3,a4=0.6,a5=1.0,a6=0.875,b21=0.2, b31=3.0/40.0,b32=9.0/40.0,b41=0.3,b42 = -0.9,b43=1.2, b51 = -11.0/54.0, b52=2.5,b53 = -70.0/27.0,b54=35.0/27.0, b61=1631.0/55296.0,b62=175.0/512.0,b63=575.0/13824.0, b64=44275.0/110592.0,b65=253.0/4096.0,c1=37.0/378.0, c3=250.0/621.0,c4=125.0/594.0,c6=512.0/1771.0,
    dc5 = -277.00/14336.0;
  double dc1=c1-2825.0/27648.0,dc3=c3-18575.0/48384.0,
    dc4=c4-13525.0/55296.0,dc6=c6-0.25;
  double ak2[n],ak3[n],ak4[n],ak5[n],ak6[n],ytemp[n];

  for (i=0; i<n; i++)           //First step.
    ytemp[i]=y[i]+b21*h*dydx[i];
  err = (*derivs)(x+a2*h,ytemp,ak2,context);
  if (err) return err;
  for (i=0;i<n;i++)             //Second step.
    ytemp[i]=y[i]+h*(b31*dydx[i]+b32*ak2[i]);
  err = (*derivs)(x+a3*h,ytemp,ak3,context);
  if (err) return err;
  for (i=0; i<n; i++)           //Third step.
    ytemp[i]=y[i]+h*(b41*dydx[i]+b42*ak2[i]+b43*ak3[i]);
  err = (*derivs)(x+a4*h,ytemp,ak4,context);
  if (err) return err;
  for (i=0; i<n; i++)           // Fourth step. 
    ytemp[i]=y[i]+h*(b51*dydx[i]+b52*ak2[i]+b53*ak3[i]+b54*ak4[i]);
  err = (*derivs)(x+a5*h,ytemp,ak5,context);
  if (err) return err;
  for (i=0; i<n; i++)           //Fifth step. 
    ytemp[i]=y[i]+h*(b61*dydx[i]+b62*ak2[i]+b63*ak3[i]+b64*ak4[i]+b65*ak5[i]);
  err = (*derivs)(x+a6*h,ytemp,ak6,context);   //Sixth step. 
  if (err) return err;
  for (i=0; i<n; i++)     //Accumulate increments with proper weights.
    yout[i]=y[i]+h*(c1*dydx[i]+c3*ak3[i]+c4*ak4[i]+c6*ak6[i]);
  for (i=0;i<n;i++)
    yerr[i]=h*(dc1*dydx[i]+dc3*ak3[i]+dc4*ak4[i]+dc5*ak5[i]+dc6*ak6[i]);

  //Estimate error as difference between fourth and fifth order methods.
  return 0;
}

int rk4(double y[], double dydx[], const int n, double x, double h, double yout[], int (*derivs)(double, double [], double [], void *), void *context) 
/*Given values for n variables y[1..n] and their derivatives
 * dydx[1..n] known at x, use the RK4 method to advance the solution
 * over an interval h and return the incremented variables as
 * yout[1..n]. */
{
  int i, err;
  double ak2[n],ak3[n],ak4[n],ytemp[n];

  for (i=0; i<n; i++)           //First step.
    ytemp[i]=y[i]+ h*dydx[i]; // ak1[i] = h dydx[i]
  err = (*derivs)(x+0.5*h,ytemp,ak2,context);
  if (err) return err;
  for (i=0;i<n;i++)             //Second step.
    ytemp[i]=y[i]+h*(0.5 *ak2[i]);
  err = (*derivs)(x+0.5*h,ytemp,ak3,context);
  if (err) return err;
  for (i=0; i<n; i++)           //Third step.
    ytemp[i]=y[i]+h*(ak3[i]);
  err = (*derivs)(x+h,ytemp,ak4,context);
  if (err) return err;
  for (i=0; i<n; i++)     //Accumulate increments with proper weights.
    yout[i]=y[i]+(h/6.)*(dydx[i] + 2.* ak2[i] + 2.*ak3[i]+ak4[i]);
  //Estimate error as difference between fourth and fifth order methods.
  return 0;
}
