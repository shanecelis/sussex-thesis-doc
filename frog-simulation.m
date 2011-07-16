(* ::Package:: *)

(* ::Title:: *)
(*Code*)


SetDirectory["/Users/shane/School/sussex/thesis/code"];


pstateCount = 16;


rectangle[x_, y_, w_, h_, angle_] := 
    Rotate[Rectangle[{x - w/2, y - h/2},{x + w/2, y + h/2}], angle]


srt[graphic_, scaleBy_, rotateBy_, rotateAt_, translateTo_] := 
    Translate[Rotate[Scale[graphic, scaleBy], rotateBy, rotateAt], translateTo];


tailColour = Pink;
footColour = Nest[Lighter,Blue,2];
bodyColour = LightGray;


drawTadpole = drawFrog;


drawFrog[{q1_,q2_,q3_,q4_, q5_, q6_, q7_, q8_}, r_,l_, fl_, OptionsPattern[{showDistance -> True, plotRange -> None}]] := 
    Module[{body, tail, limb, foot5, foot6, foot7, foot8, distanceLine, range},
           body = Disk[{q1,q2},r 1.05 ];
           limb = Rotate[rectangle[0, 0 , 0.2 r , 1, 0],0,{0,0}];
           tail = Translate[Rotate[Scale[limb, {1, l}], q4, {0, l/2}], {q1, q2 - r -l/2 }];
           tail = srt[limb, {1, l}, q4, {0, l/2}, {q1, q2 - r - l/2}];
           foot5 = Rotate[srt[limb, {1, fl}, q5, {0, fl/2}, {q1, q2 - r - fl/2}], Pi/4, {q1, q2}];
           foot6 = Rotate[srt[limb, {1, fl}, q6, {0, fl/2}, {q1, q2 - r - fl/2}], 3Pi/4, {q1, q2}];
           foot7 = Rotate[srt[limb, {1, fl}, q7, {0, fl/2}, {q1, q2 - r - fl/2}], 5Pi/4, {q1, q2}];
           foot8 = Rotate[srt[limb, {1, fl}, q8, {0, fl/2}, {q1, q2 - r - fl/2}], 7Pi/4, {q1, q2}];
           If[OptionValue[showDistance],
              distanceLine = {Black, Line[{{0,0},{q1,q2}}]},
              distanceLine = {}];
           If[OptionValue[plotRange] === None,
              range =  7(r ){{-1,1},{-1,1}},
              range = OptionValue[plotRange]];
           Graphics[{{FaceForm[bodyColour], {FaceForm[bodyColour],body}, EdgeForm[None],Rotate[{{FaceForm[tailColour],tail},{FaceForm[footColour],foot5, foot6, foot7, foot8}}, q3, {q1, q2}] }, 
                     distanceLine
                    }, PlotRange -> range]]



params = {r -> 0.025 m, 
          l -> lmax,
          lmax -> 0.06 m,
          Ia -> ma r^2/2 kg m^2,
          Ib -> mb l^2/3 kg m^2,
          ma -> 0.0195 kg,
          mb ->   0.1 ma,
          d -> 2 r,
          Cdcirc -> 0.3,
          Cdplate -> 1.98,
          rho -> 999.1026 kg/m^3 (d),
          P -> 1/freq,
          freq -> .5/(2 Pi (lmax/(.1g))^.5),
          g -> 9.8 m/s^2,
          Tmax -> (l/lmax)^2 .02 kg m/s^2,
          Tfmax -> (fl/flmax)^2 .02 kg m/s^2,
          Fr -> 0.01,
	
          Tq4 ->  tailTorque[q4[t]],

          Ic -> mc fl^2/3 kg m^2,
          mc -> mb,
          fl -> flmax,
          flmax -> lmax,
          Tq5 -> footTorque[q5[t]], 
          Tq6 -> footTorque[q6[t]], 
          Tq7 -> footTorque[q7[t]], 
          Tq8 -> footTorque[q8[t]],

          m -> 10, kg -> 1, s -> 1};


footTorque[angle_] := radialSpring2[angle] + periodicSwing


tailTorque[angle_] := radialSpring2[angle] + periodicSwing


tailTorqueCTRNN[angle_] := radialSpring2[angle] 


footTorqueCTRNN[angle_] := radialSpring2[angle] 


q4mod[t_] := pimod[q4[t]]


pimod[theta_] := Mod[theta + Pi, 2 Pi] - Pi


radialSpring[theta_] := -Tmax (pimod[theta]/(Pi/2))^3;


radialSpring2[theta_] := -Tmax (theta/(Pi/2))^3;


legCollision[theta_]  := -Tmax(sigma[20(theta - Pi/2)] - sigma[20(-theta - Pi/2)]);


boundaries[x_,{a_,b_}, k_:20]  :=(sigma[k(x - a)] - sigma[k(-x + b)])


periodicSwing =   Tmax Cos[2 Pi/ P t];


radialFriction = -Fr q4mod[t];


(*tailGrowth = lmax (.9 Min[t/50 , 1] + .1 );
  tailShrink =  lmax (-.9 Min[t/50 , 1] + 1 );*)


periodicSwingBounded = 
    If[-Pi/2 <=  Mod[q4[t], 2Pi] <=  Pi/2, periodicSwing, -Sign[q4[t]] Tmax 4];


offsetByA[x_, a_] := x + -a(1 - x^2)


linearSweep = -Tmax q4[t] Sign[u4[t]];


curvedSweep = Tmax offsetByA[q4[t] Sign[u4'[t]] 2/Pi,1/2];


Needs["DifferentialEquations`NDSolveUtilities`"];


Needs["DifferentialEquations`NDSolveProblems`"];


Options[eqnsForFrog] = {preParams -> {}, otherEqns -> {}};


eqnsForFrog[OptionsPattern[]] := 
    {(eqns //. OptionValue[preParams]~Join~params)~Join~
     {
         q1'[t] == u1[t],
         q2'[t] == u2[t],
         q3'[t] == u3[t],
         q4'[t] == u4[t],
         q5'[t] == u5[t],
         q6'[t] == u6[t],
         q7'[t] == u7[t],
         q8'[t] == u8[t]}~Join~OptionValue[otherEqns], 
     {q1[t],q2[t],q3[t],q4[t], q5[t],q6[t],q7[t],q8[t],
      u1[t],u2[t],u3[t],u4[t], u5[t], u6[t], u7[t], u8[t]}}


eqnsForFrog[ICs_List, OptionsPattern[]] := 
    eqnsForFrog[otherEqns -> 
                ({q1[0] == ICs[[1]],
                  q2[0] == ICs[[2]],
                  q3[0] == ICs[[3]],
                  q4[0] == ICs[[4]],
                  q5[0] == ICs[[5]],
                  q6[0] == ICs[[6]],
                  q7[0] == ICs[[7]],
                  q8[0] == ICs[[8]],

                  u1[0] == ICs[[9]],
                  u2[0] == ICs[[10]],
                  u3[0] == ICs[[11]],
                  u4[0] == ICs[[12]],
                  u5[0] == ICs[[13]],
                  u6[0] == ICs[[14]],
                  u7[0] == ICs[[15]],
                  u8[0] == ICs[[16]]}(*~Join~OptionValue[otherEqns]*)),
                preParams -> OptionValue[preParams]]


run[ICs_, tmax_,  opts : OptionsPattern[preParams -> {}]] := 
    Module[{eqns, vars},
           {eqns, vars} = eqnsForFrog[ICs, opts];
           NDSolve[eqns, vars, {t, .1, tmax}, Method -> "ExplicitEuler", StartingStepSize -> 0.02][[1]]]


runWithCTRNN[ctrnnArg_, ctrnnState_, ICs_, tmax_, opts :OptionsPattern[{preParams -> {}}]] := 
    Module[{peqns, pvars, ceqns, cvars, ctrnn, sensors},
           ctrnn  = ctrnnArg;
           {peqns,pvars} =eqnsForFrog[ICs, preParams -> {
               Tq4 ->  tailTorqueCTRNN [q4[t]]+ Tmax Clip[ys[1][t]],
               Tq5 ->  footTorqueCTRNN [q5[t]]+ Tfmax Clip[ys[2][t]],
               Tq6 ->  footTorqueCTRNN [q6[t]]+ Tfmax Clip[ys[3][t]],
               Tq7 ->  footTorqueCTRNN [q7[t]]+ Tfmax Clip[ys[4][t]],
               Tq8 ->  footTorqueCTRNN [q8[t]]+ Tfmax Clip[ys[5][t]]
                                                        }];
           (*target = {1,0};*)
           sensors = { (* 10 + 4  = 14 *)
                       Norm[{u1[#], u2[#]}]&, 
                       u3[#]&, 
                       Norm[target - {q1[#], q2[#]} ]&, VectorAngle[target - {q1[#], q2[#]}, {-Sin[q3[#]],Cos[q3[#]]}]&,
                       q4[#]/(Pi/2)&,
                       u4[#]&,
                       q5[#]/(Pi/2)&,
                       u5[#]&, 
                       q6[#]/(Pi/2)&,
                       u6[#]&, 
                       q7[#]/(Pi/2)&,
                       u7[#]&, 
                       q8[#]/(Pi/2)&,
                       u8[#]&
                     };
           ctrnn[[3]] = makeLinSensorInputs[ctrnn, sensors];
           {ceqns, cvars} = eqnsForCTRNN[ctrnn, ctrnnState];

           First[NDSolve[peqns~Join~ceqns, pvars~Join~cvars, {t, 0.1, tmax}, Method -> "ExplicitEuler", StartingStepSize -> 0.02]]]


combineInterpolatingFunctions[interps_] := 
    Function[{arg},
             Module[{domains, conds, t, min, max, func},
                    (*min = Min[interps[[All,1,1,1]]];
                      max = Max[interps[[All,1,1,2]]];*)
                    conds = Map[#[[1,1,1]] <= t <= # [[1,1,2]]&, interps];
                    func = Which[Evaluate[Sequence@@Riffle[conds,interps]], True, First[interps]];
                    (*FunctionInterpolation[func[t], {t, min, max}]*)
                    (func /. t -> arg)[arg]
                   ]] 


getDomain[sol_] := sol[[1,2,0,1,1]]


plotConfiguration[mysol_ ] := 
    Module[{domain},
           domain = getDomain[mysol];
           Plot[Evaluate[{q1[t] + 3, q2[t] + 3, q3[t] ,q4[t], q5[t], q6[t], q7[t], q8[t]} /. mysol], Evaluate[{t}~Join~domain], PlotStyle -> {bodyColour, bodyColour, bodyColour, tailColour,footColour, footColour,footColour,footColour}, PlotRange -> All]]


plotMotionVariables[mysol_ ] := 
    Module[{domain},
           domain = getDomain[mysol];
           Plot[Evaluate[{u1[t] + 3, u2[t] + 3, u3[t] ,u4[t], u5[t], u6[t], u7[t], u8[t]} /. mysol], Evaluate[{t}~Join~domain], PlotStyle -> {bodyColour, bodyColour, bodyColour, tailColour,footColour, footColour,footColour,footColour}, PlotRange -> All]]


plotCTRNN[mysol_ , fun_:Clip] := 
    Module[{domain},
           domain = getDomain[mysol];
           Plot[Evaluate[Map[fun,{ys[1][t], ys[2][t], ys[3][t] ,ys[4][t], ys[5][t]}] /. mysol], Evaluate[{t}~Join~domain], PlotStyle -> {tailColour, footColour, footColour,footColour,footColour}, PlotRange -> All]]


plotDistance[sol_] := 
    Module[{domain},
           domain = getDomain[sol];
           Plot[Evaluate[Norm[{q1[t],  q2[t]}] /. sol], Evaluate[{t}~Join~domain], PlotStyle -> Gray]]


animateRun[sol_] := 
    Module[{domain},
           domain = getDomain[sol];
           Animate[Evaluate[drawFrog[{q1[t], q2[t], q3[t], q4[t],q5[t],q6[t],q7[t],q8[t]}/.sol,r //. params,  l //. params, fl //. params]], Evaluate[Join[{t}, domain]], AnimationRate -> 1, AnimationRepetitions -> 1]]


solveEqnsForDotVars[eqns_,vars_,var_] := 
    Module[{dotvars, sol},
           dotvars = vars /. a_[var] -> a'[var];
           (*newvars = Table[Symbol["a" <> ToString[i]], {i,n}];*)
           (*newvars = Table[Unevaluated[a[[i]]], {i,n}];*)
           (*newvarsrules = MapThread[Rule[#1, #2]&, {vars, newvars}];*)
           sol = First[Solve[Flatten[eqns],dotvars]];
           Map[# == (# /. sol)&, dotvars]
          ]


(*

   Import["tadpole_eqns4.m"]; eqns = Map[# == 0&, rhseqns]; 
   eqns = solveEqnsForDotVars[eqns, {u1[t], u2[t], u3[t], u4[t], u5[t], u6[t], u7[t], u8[t]}, t];

 *)

eqns = Import["tadpole_eqns4_dotsolved.m"];
