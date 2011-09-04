(* ::Package:: *)

(* ::Title:: *)
(*Code*)

units = {cm      -> 0.01 m,          
         m -> 1, kg -> 1, s -> 1};



params = Join[
          units,
          {r       -> 0.025 m, 
          l       -> lmax,
          lmax    -> 0.06 m,
          negl    -> 0.00001m, (* negligible length *)
          Ia      -> ma (r^2)/2, (* where did I get these formulas? *)
          Ib      -> mb (lmax^2)/3,
          ma      -> 0.025 kg, (*0.0195 kg,*)
          mb      -> 0.00195 kg,
          d       -> 2 r,
          w       -> 0.6 cm,
          Va      -> Pi r^2 depth,
          Vb      -> l w depth,
          Cdcirc  -> 0.3,
          TCdcirc -> 2.9,
          rhoCork -> 260 kg/m^3,
          rhoPlastic -> 1400 kg/m^3,
          rhoMahogany -> 5000 kg/m^3,
          rhoOak  -> 7000 kg/m^3,
          Cdplate -> 0.98,
          rho     -> 999.1026 kg/m^3,
          g       -> 9.8 m/s^2,
          Tq4     -> tailTorque[q4[t]],

          Ic      -> mc ((flmax)^2)/3,
          mc      -> mb,
          fl      -> flmax,
          flmax   -> lmax,
          Tq5     -> footTorque[q5[t]], 
          Tq6     -> footTorque[q6[t]], 
          Tq7     -> footTorque[q7[t]], 
          Tq8     -> footTorque[q8[t]],

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
          (* What the constants used to be:
             kFa-> -rho/2 * Cdcirc  * Acirc 
             kFb -> -rho/2 * Cdplate * depth 
             kTa -> -rho/2 * TCdcirc * TAcirc 

             What has wiggle room?  
             Cdcirc \in [0.42, 0.47]
             Cdplate \in [1.28] (3D)
             Cdplate \in [1.98, 2.05] (2D)
             
             
             *)

(*        originally it was:  
          Tmax    ->   0.000001 kg (m/s)^2,
          Tfmax   -> 0 0.00001 kg (m/s)^2,

          kTa -> -1.8*^-5,
          kTb -> 0,
          kTc -> 0,
          kFa -> -0.04,
          kFb -> -2.5,
          kFc -> -2.5  *)

          (*Tmax  ->  0.00001,
          kTa   -> -0.018,
          kTb   -> -0.0001 0,
          kFa   -> -0.04,
          kFb   -> -2.5,
          krb   -> 0.0,
          P     -> 1,*)

          Tmax -> 0.000833414, 
          kTa  -> -0.00515681, 
          kTb  -> -0.0000335441, 
          kFa  -> -0.5,
          kFb  -> -75, (*-75., *)
          krb  -> -0.554415, 
          (*P    -> 1.90515,*)
          (* f1 = psi1 = 0, no periodic controller torque *)
          (*f1   -> 0.524893,*)


          Tfmax -> Tmax,
          kTc   -> kTb 10,
          kFc   -> kFb,
          krc   -> 0,

          wvx   -> 0,
          wvy   -> 0,
          dummy -> None
         }];
Protect@@keys[params];

RK4StepSize = 0.01;

stateInit = 
    {t -> 0, 
     q1 -> 0, q2 -> 0, q3 -> 0, q4 -> 0, q5 -> 0, q6 -> 0, q7 -> 0, q8 -> 0, 
     u1 -> 0, u2 -> 0, u3 -> 0, u4 -> 0, u5 -> 0, u6 -> 0, u7 -> 0, u8 -> 0,    
     ys[1] -> 0,  ys[2] -> 0,  ys[3] -> 0,  ys[4] -> 0,  ys[5] -> 0,  
     lg -> 1,  fg -> 0,  
     r[1] -> 0,  r[2] -> 0};

stateLayout = keys[stateInit];

Protect@@justSymbol[stateLayout];
stateToRules[state_] := MapThread[Rule, {stateLayout, state}]


ctrnnConstantsInit = {
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
    nij[5, 11] -> 0, nij[5, 12] -> 0, nij[5, 13] -> 0, nij[5, 14] -> 0};

physconsConstantsInit = {
            (* Tq4, Tq5, Tq6, Tq7, Tq8 -- these are substituted for *)
            (*ld, fld, rho, Cdcirc, Cdplate, TCdcirc, Acirc, TAcirc,*)
    lmax -> 0, flmax -> 0, Tmax -> 0, Tfmax -> 0, r -> 0, 

    kTa -> 0, kTb -> 0, kTc -> 0, kFa -> 0, kFb -> 0, kFc -> 0, 
    krb -> 0, krc -> 0,
    ma -> 0, mb -> 0, mc -> 0, Ia -> 0, Ib -> 0, Ic -> 0, wvx -> 0, wvy -> 0
            (* , m, s, kg -- these wouldn't be used within
               the numerical simulation.  They'd be used to
               setup the values. *)
                        };
physconsLayout = physcons = keys[physconsConstantsInit];

periodConstantsInit = {
    (* periodic params *)
    f1   -> 0,                 psi1 -> 0,
    f2   -> 0,                 psi2 -> 0,
    f3   -> 0,                 psi3 -> 0,
    f4   -> 0,                 psi4 -> 0,
    f5   -> 0,                 psi5 -> 0,
    kys  -> 1 (* kys = 0, no CTRNN torques. 
                 kys = 1, enable CTRNN torques. *)
                        };
periodLayout = keys[periodConstantsInit];

constantsInit = Join[
    (* NN params *)
    ctrnnConstantsInit,
    {
    
    (* target params *)
    tx -> 0, ty -> 0, 

    (* tail growth params *)
    tpts[1, 1] -> 0, tpts[1, 2] -> 0, 
    tpts[2, 1] -> 0, tpts[2, 2] -> 0, 
    tpts[3, 1] -> 0, tpts[3, 2] -> 0, 

    fpts[1, 1] -> 0, fpts[1, 2] -> 0, 
    fpts[2, 1] -> 0, fpts[2, 2] -> 0, 
    fpts[3, 1] -> 0, fpts[3, 2] -> 0
    }, 
    (* physcons params *)
    physconsConstantsInit,
    (* periodic controller params *)
    periodConstantsInit];

constantsLayout = keys[constantsInit];
Protect@@justSymbol[constantsLayout];

motorCount       = 5;
sensorCount      = 14;

(* state info *)
recordCount      = 2;
qstateCount      = 8;
ustateCount      = 8;
tailStateCount   = 2;
nodeCount        = 5;
pstateCount      = qstateCount + ustateCount;
stateCount       = 1 + pstateCount + nodeCount + tailStateCount + recordCount;
qstateBegin      = 1 + 1;
ustateBegin      = 1 + qstateCount + 1;
nodeBegin        = 1 + pstateCount + 1;
tailstateBegin   = 1 + pstateCount + nodeCount + 1;
recordBegin      = 1 + pstateCount + nodeCount + tailStateCount + 1;


(* constants info *)
ctrnnParamCount  = nodeCount^2 + 2 nodeCount + sensorCount * motorCount;
targetCount      = 2;
pointsCount      = 2 * 3 * 2;
physCount        = 21; 
periodCount      = 11;
constantsCount   = ctrnnParamCount + targetCount + pointsCount + physCount + periodCount;
targetBegin      = ctrnnParamCount + 1;
pointsBegin      = ctrnnParamCount + targetCount + 1;
physBegin        = ctrnnParamCount + targetCount + pointsCount + 1;
periodBegin      = ctrnnParamCount + targetCount + pointsCount + physCount + 1;

qindex[num_] := qstateBegin + num - 1
uindex[num_] := ustateBegin + num - 1


ctrnnGaParams = {
    geneCountGA -> ctrnnParamCount,
    geneToConstantsFunc -> ctrnnGeneToConstants
                };
physicsGaParams = {
    geneCountGA -> 6,
    geneToConstantsFunc -> physicsGeneToConstants,
    fitnessFunc -> fitnessForPhysics,
    fitnessDataFunc -> fitnessForPhysicsData
                  };
periodGaParams = {
    geneCountGA -> periodCount, 
    geneToConstantsFunc -> periodGeneToConstants
                  };

(* fitness params *)
speedGaParams = {
    fitnessFunc -> fitnessForSpeed,
    fitnessDataFunc -> fitnessForSpeedData,
    minimise -> False
                };
targetGaParams = {
    fitnessFunc -> fitnessToTarget,
    fitnessDataFunc -> fitnessToTargetData,
    minimise -> True 
                 };


gaParams = Join[
    physicsGaParams,
    speedGaParams,
    {
    target -> {0, 0.01},
    tmax -> 10,
    expName -> Ap,
    phase -> 1,
    deltat -> 0.01,
    dataDeltat -> 0.1,

    runSimulationGAFunc -> Hold[runSimulationMlink],
    
    dummy -> None
    }];

Protect@@keys[gaParams];
geneCount = geneCountGA /. gaParams;
minimize  = minimise /. gaParams; (* The spellings are different.  EVIL.  *)
pop = 30;
len = geneCount;
mut = mutationRate = 1/geneCount;
rec = 0.5; (* recombination *)
end = 10^6;



               

