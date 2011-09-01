(* ::Package:: *)

(* ::Title:: *)
(*Code*)

params = {r       -> 0.025 m, 
          l       -> lmax,
          lmax    -> 0.06 m,
          negl    -> 0.00001m, (* negligible length *)
          Ia      -> ma (r^2)/2, (* where did I get these formulas? *)
          Ib      -> mb (lmax^2)/3,
          ma      -> 0.025 kg, (*0.0195 kg,*)
          mb      -> 0.00195 kg,
          d       -> 2 r,
          Cdcirc  -> 0.3,
          TCdcirc -> 2.9,
          Cdplate -> 0.98,
          rho     -> 999.1026 kg/m^3,
          g       -> 9.8 m/s^2,
          
(*        Fr    -> 0.01,
          P       -> 1/freq,
          freq    -> .5/(2 Pi (lmax/(.1g))^.5),
 *)
          Tq4     -> tailTorque[q4[t]],

          Ic      -> mc ((flmax)^2)/3,
          mc      -> mb,
          fl      -> flmax,
          flmax   -> lmax,
          Tq5     -> footTorque[q5[t]], 
          Tq6     -> footTorque[q6[t]], 
          Tq7     -> footTorque[q7[t]], 
          Tq8     -> footTorque[q8[t]],

          m -> 1, kg -> 1, s -> 1,
          (*m     -> 10, kg -> 1, s -> 1*)
          (*m     -> 32, kg -> 20, s -> 1*)
          (*m       -> 100, kg -> 100, s -> 1*)
          depth -> 0.2 r,
          ld -> depth,
          fld -> depth,

          Acirc -> 2 r depth,
          TAcirc -> Pi 2 r^2 depth (r^2),
          oq4 -> 0,
          oq5 -> 1 Pi/4,
          oq6 -> 3 Pi/4,
          oq7 -> 5 Pi/4,
          oq8 -> 7 Pi/4,
(*        originally it was:  
          Tmax    ->   0.000001 kg (m/s)^2,
          Tfmax   -> 0 0.00001 kg (m/s)^2,

          kTa -> -1.8*^-5,
          kTb -> 0,
          kTc -> 0,
          kFa -> -0.04,
          kFb -> -2.5,
          kFc -> -2.5  *)

          Tmax  ->  0.00001 1.0, (*5,*)
          Tfmax ->  0.00001,
          kTa   -> -0.018,
          kTb   -> -0.0001 0,
          kTc   -> 0,
          kFa   -> -0.04 0.8,
          kFb   -> -2.5 1.4,
          kFc   -> -2.5,
          krb   -> 0.0,
          krc   -> 0,
          wvx   -> 0,
          wvy   -> 0,
          P     -> 1,
          dummy -> None
         };
Protect@@keys[params];

gaParams = {
    target -> {0, 0.01},
    tmax -> 20,
    expName -> Ap,
    phase -> 1,
    deltat -> 0.01,
    dataDeltat -> 0.5,

    fitnessFunc -> fitnessForSpeed,
    fitnessDataFunc -> fitnessForSpeedData,
    minimise -> False,


(*    fitnessFunc -> fitnessToTarget,
    fitnessDataFunc -> fitnessToTargetData,
    minimise -> True, *)

    runSimulationGAFunc -> Hold[runSimulation],
    
    dummy -> None
           };
Protect@@keys[gaParams];
minimize = minimise /. gaParams;

physcons = {lmax, flmax, Tmax, Tfmax, r,
            (* Tq4, Tq5, Tq6, Tq7, Tq8 -- these are substituted for *)
            (*ld, fld, rho, Cdcirc, Cdplate, TCdcirc, Acirc, TAcirc,*)
            kTa, kTb, kTc, kFa, kFb, kFc, krb, krc,

            ma, mb, mc, Ia, Ib, Ic, wvx, wvy, 
            (* , m, s, kg -- these wouldn't be used within
               the numerical simulation.  They'd be used to
               setup the values. *)
            P (* period P, not really a physics value *)
           };

stateLayout = {t, 
               q1, q2, q3, q4, q5, q6, q7, q8, 
               u1, u2, u3, u4, u5, u6, u7, u8, 
               ys[1], ys[2], ys[3], ys[4], ys[5], 
               lg, fg, 
               r[1], r[2]};
Protect@@justSymbol[stateLayout];

stateToRules[state_] := MapThread[Rule, {stateLayout, state}]

stateInit = {t     -> 0,                   ys[1] -> 0, 
             q1    -> 0,    u1    -> 0,    ys[2] -> 0, 
             q2    -> 0,    u2    -> 0,    ys[3] -> 0, 
             q3    -> 0,    u3    -> 0,    ys[4] -> 0, 
             q4    -> 0,    u4    -> 0,    ys[5] -> 0, 
             q5    -> 0,    u5    -> 0,    lg    -> 1, 
             q6    -> 0,    u6    -> 0,    fg    -> 0, 
             q7    -> 0,    u7    -> 0,    r[1]  -> 0, 
             q8    -> 0,    u8    -> 0,    r[2]  -> 0};


constantsLayout = {
    W[1, 1], W[1, 2], W[1, 3], W[1, 4], W[1, 5], W[2, 1], W[2, 2], 
    W[2, 3], W[2, 4], W[2, 5], W[3, 1], W[3, 2], W[3, 3], W[3, 4], 
    W[3, 5], W[4, 1], W[4, 2], W[4, 3], W[4, 4], W[4, 5], W[5, 1], 
    W[5, 2], W[5, 3], W[5, 4], W[5, 5], theta[1], theta[2], theta[3], 
    theta[4], theta[5], tc[1], tc[2], tc[3], tc[4], tc[5], nij[1, 1], 
    nij[1, 2], nij[1, 3], nij[1, 4], nij[1, 5], nij[1, 6], nij[1, 7], 
    nij[1, 8], nij[1, 9], nij[1, 10], nij[1, 11], nij[1, 12], nij[1, 13],
    nij[1, 14], nij[2, 1], nij[2, 2], nij[2, 3], nij[2, 4], nij[2, 5], 
    nij[2, 6], nij[2, 7], nij[2, 8], nij[2, 9], nij[2, 10], nij[2, 11], 
    nij[2, 12], nij[2, 13], nij[2, 14], nij[3, 1], nij[3, 2], nij[3, 3], 
    nij[3, 4], nij[3, 5], nij[3, 6], nij[3, 7], nij[3, 8], nij[3, 9], 
    nij[3, 10], nij[3, 11], nij[3, 12], nij[3, 13], nij[3, 14], 
    nij[4, 1], nij[4, 2], nij[4, 3], nij[4, 4], nij[4, 5], nij[4, 6], 
    nij[4, 7], nij[4, 8], nij[4, 9], nij[4, 10], nij[4, 11], nij[4, 12], 
    nij[4, 13], nij[4, 14], nij[5, 1], nij[5, 2], nij[5, 3], nij[5, 4], 
    nij[5, 5], nij[5, 6], nij[5, 7], nij[5, 8], nij[5, 9], nij[5, 10], 
    nij[5, 11], nij[5, 12], nij[5, 13], nij[5, 14], tx, ty, tpts[1, 1], 
    tpts[1, 2], tpts[2, 1], tpts[2, 2], tpts[3, 1], tpts[3, 2], 
    fpts[1, 1], fpts[1, 2], fpts[2, 1], fpts[2, 2], fpts[3, 1], 
    fpts[3, 2], lmax, flmax, Tmax, Tfmax, r, kTa, kTb, kTc, kFa, kFb, 
    kFc, krb, krc, ma, mb, mc, Ia, Ib, Ic, wvx, wvy, P};

constantsInit = {
    (* NN params *)
    W[1, 1] -> 0, W[1, 2] -> 0, W[1, 3] -> 0, W[1, 4] -> 0, W[1, 5] -> 0,
    W[2, 1] -> 0, W[2, 2] -> 0, W[2, 3] -> 0, W[2, 4] -> 0, W[2, 5] -> 0, 
    W[3, 1] -> 0, W[3, 2] -> 0, W[3, 3] -> 0, W[3, 4] -> 0, W[3, 5] -> 0, 
    W[4, 1] -> 0, W[4, 2] -> 0, W[4, 3] -> 0, W[4, 4] -> 0, W[4, 5] -> 0, 
    W[5, 1] -> 0, W[5, 2] -> 0, W[5, 3] -> 0, W[5, 4] -> 0, W[5, 5] -> 0, 
    
    theta[1] -> 0, theta[2] -> 0, theta[3] -> 0, theta[4] -> 0, theta[5] -> 0, 

    tc[1] -> 0, tc[2] -> 0, tc[3] -> 0, tc[4] -> 0, tc[5] -> 0, 

    nij[1, 1] -> 0, nij[1, 2] -> 0, nij[1, 3] -> 0, nij[1, 4] -> 0, 
    nij[1, 5] -> 0, nij[1, 6] -> 0, nij[1, 7] -> 0, nij[1, 8] -> 0, 
    nij[1, 9] -> 0, nij[1, 10] -> 0, nij[1, 11] -> 0, nij[1, 12] -> 0, 
    nij[1, 13] -> 0, nij[1, 14] -> 0, nij[2, 1] -> 0, nij[2, 2] -> 0, 
    nij[2, 3] -> 0, nij[2, 4] -> 0, nij[2, 5] -> 0, nij[2, 6] -> 0, 
    nij[2, 7] -> 0, nij[2, 8] -> 0, nij[2, 9] -> 0, nij[2, 10] -> 0, 
    nij[2, 11] -> 0, nij[2, 12] -> 0, nij[2, 13] -> 0, nij[2, 14] -> 0, 
    nij[3, 1] -> 0, nij[3, 2] -> 0, nij[3, 3] -> 0, nij[3, 4] -> 0, 
    nij[3, 5] -> 0, nij[3, 6] -> 0, nij[3, 7] -> 0, nij[3, 8] -> 0, 
    nij[3, 9] -> 0, nij[3, 10] -> 0, nij[3, 11] -> 0, nij[3, 12] -> 0, 
    nij[3, 13] -> 0, nij[3, 14] -> 0, nij[4, 1] -> 0, nij[4, 2] -> 0, 
    nij[4, 3] -> 0, nij[4, 4] -> 0, nij[4, 5] -> 0, nij[4, 6] -> 0, 
    nij[4, 7] -> 0, nij[4, 8] -> 0, 
    nij[4, 9] -> 0, nij[4, 10] -> 0, nij[4, 11] -> 0, nij[4, 12] -> 0, 
    nij[4, 13] -> 0, nij[4, 14] -> 0, nij[5, 1] -> 0, nij[5, 2] -> 0, 
    nij[5, 3] -> 0, nij[5, 4] -> 0, nij[5, 5] -> 0, nij[5, 6] -> 0, 
    nij[5, 7] -> 0, nij[5, 8] -> 0, nij[5, 9] -> 0, nij[5, 10] -> 0, 
    nij[5, 11] -> 0, nij[5, 12] -> 0, nij[5, 13] -> 0, nij[5, 14] -> 0, 
    
    (* target params *)
    tx -> 0, ty -> 0, 

    (* growth points *)
    tpts[1, 1] -> 0, tpts[1, 2] -> 0, 
    tpts[2, 1] -> 0, tpts[2, 2] -> 0, 
    tpts[3, 1] -> 0, tpts[3, 2] -> 0, 

    fpts[1, 1] -> 0, fpts[1, 2] -> 0, 
    fpts[2, 1] -> 0, fpts[2, 2] -> 0, 
    fpts[3, 1] -> 0, fpts[3, 2] -> 0, 

    (* physcons params *)
    lmax -> 0, flmax -> 0, Tmax -> 0, Tfmax -> 0,  r -> 0, 
    kTa -> 0, kTb -> 0, kTc -> 0, kFa -> 0, kFb -> 0, kFc -> 0, 
    krb -> 0, krc -> 0,
    ma -> 0, mb -> 0, mc -> 0, Ia -> 0, Ib -> 0, Ic -> 0, wvx -> 0, wvy -> 0, 

    P -> 1}
Protect@@justSymbol[constantsLayout];

nodeCount        = 5;
motorCount       = 5;
sensorCount      = 14;

(* state info *)
limbLengthsCount = 2;
stateCount       = 1 + pstateCount + nodeCount + limbLengthsCount + recordCount;
recordCount      = 2;
recordBegin      = 25;
tailstateBegin   = 23;
qstateBegin      = 2;
ustateBegin      = 10;
nodeBegin        = ustateBegin + 8;

(* constants info *)
ctrnnParamCount  = nodeCount^2 + 2 nodeCount + sensorCount * motorCount;
targetCount      = 2;
pointsCount      = 2 * 3 * 2;
physCount        = 22; 
constantsCount   = ctrnnParamCount + targetCount + pointsCount + physCount;
targetBegin      = ctrnnParamCount + 1;
pointsBegin      = ctrnnParamCount + targetCount + 1;
physBegin        = ctrnnParamCount + targetCount + pointsCount + 1;

qindex[num_] := qstateBegin + num - 1
uindex[num_] := ustateBegin + num - 1
