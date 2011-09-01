int frog_deriv_al(double t, double state[], double dstatedt[], void *context)
{
  //constants is a global variable.
  // complication: the sensors are not available.  a ctrnn is not available.
  int i;
  double *constants = (double *) context;
  double 
    // constants
    Ia,Ib,Ic,kFa,kFb,kFc,krb,krc,kTa,kTb,kTc,ma,mb,mc,r,wvx,wvy,oq4,oq5,oq6,oq7,oq8,
    //physcons

    // inputs
    Tq4,Tq5,Tq6,Tq7,Tq8,

    // state
    q1,q2,q3,q4,q5,q6,q7,q8,u1,u2,u3,u4,u5,u6,u7,u8,
    fl,l,
    // I'm solving for these ones.  Right?
    u1p,u2p,u3p,u4p,u5p,u6p,u7p,u8p;


  double lg, fg, lmax, flmax, r1, r2;

  double Tmax;
  double *qstate[] = {&q1, &q2, &q3, &q4, &q5, &q6, &q7, &q8};
  double *ustate[] = {&u1, &u2, &u3, &u4, &u5, &u6, &u7, &u8};
  double *tailstate[] = {&lg, &fg};
  double *record[] = {&r1, &r2};

  
  double *physcons[] = {lmax, flmax, Tmax, Tfmax, r, kTa, kTb, 
                        kTc, kFa, kFb, kFc, krb, krc, ma, mb, mc, 
                        Ia, Ib, Ic, wvx, wvy};

  // state
  for (i = 0; i < QSTATE_COUNT; i++)
    *(qstate[i]) = state[QSTATE_BEGIN + i];

  for (i = 0; i < USTATE_COUNT; i++)
    *(ustate[i]) = state[USTATE_BEGIN + i];


// constants
  for (i = 0; i < PHYS_COUNT; i++) 
    *(physcons[i]) = constants[PHYS_BEGIN + i];

  Tmax = constants[];
  r = constants[];
  l = lg * lmax;
  fl = fg * flmax;
  Tq4 = Tmax * clip(state[ys1i]);
  wvx = state[wvxi];
  q3 = q[2];
  q4 = q[3];

  #include "eqns-fixed.c"
}
