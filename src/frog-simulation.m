(* ::Package:: *)

(* ::Title:: *)
(*Code*)


SetDirectory["/Users/shane/School/sussex/thesis/code/src"];

rectangle[x_, y_, w_, h_, angle_] := 
    Rotate[Rectangle[{x - w/2, y - h/2},{x + w/2, y + h/2}], angle]


srt[graphic_, scaleBy_, rotateBy_, rotateAt_, translateTo_] := 
    Translate[Rotate[Scale[graphic, scaleBy], rotateBy, rotateAt], translateTo];




isWithinRange[{a_, b_}, x_] := 
    IntervalMemberQ[Interval[{a, b}], x]


pointWithinRanges[{xs_, ys_}, pt_] := 
    And @@ MapThread[isWithinRange, {{xs, ys}, pt}]


chooseRange[range_, points_, nextRangeFunc_] := 
    If[And @@ Map[pointWithinRanges[range, #] &, points],
       range,
       chooseRange[nextRangeFunc[range], points, nextRangeFunc]]


Options[drawFrog] = Join[{showDistance -> False, 
                     plotRange    -> Automatic,
                     toTarget     -> None,
                     showStart    -> False,
                     showTarget   -> None},
                         Options[Graphics]];

drawFrog[{t_, q1_,q2_,q3_,q4_, q5_, q6_, q7_, q8_}, r_, l_, fl_, 
         opts:OptionsPattern[]] := 
    Module[{body, tail, limb, foot5, foot6, foot7, foot8, distanceLine, 
            range, target, diskSize},
           body = Disk[{q1,q2},r 1.05 ];
           limb = Rotate[rectangle[0, 0 , 0.2 r , 1, 0],0,{0,0}];
           tail = Translate[Rotate[Scale[limb, {1, l}], q4, {0, l/2}], {q1, q2 - r -l/2 }];
           tail = srt[limb, {1, l}, q4, {0, l/2}, {q1, q2 - r - l/2}];
           foot5 = Rotate[srt[limb, {1, fl}, q5, {0, fl/2}, {q1, q2 - r - fl/2}], Pi/4, {q1, q2}];
           foot6 = Rotate[srt[limb, {1, fl}, q6, {0, fl/2}, {q1, q2 - r - fl/2}], 3Pi/4, {q1, q2}];
           foot7 = Rotate[srt[limb, {1, fl}, q7, {0, fl/2}, {q1, q2 - r - fl/2}], 5Pi/4, {q1, q2}];
           foot8 = Rotate[srt[limb, {1, fl}, q8, {0, fl/2}, {q1, q2 - r - fl/2}], 7Pi/4, {q1, q2}];
           target = {0,0};
           distanceLine = If[OptionValue[showDistance] === True,
                             {Black, Line[{{0,0},{q1,q2}}]},
                             {}];
           targetLine = If[OptionValue[toTarget] === None,
                           {},
                           target = OptionValue[toTarget];
                           {Black, Line[{{q1,q2},target}]}];
           diskSize = 0.1 r;
           startDisk = If[OptionValue[showStart] === False,
                          {},
                          {Point[{0,0}], Disk[{0,0}, diskSize]}];

           targetDisk = If[OptionValue[showTarget] === None,
                           {},
                           target = OptionValue[showTarget];
                           {Point[target], Disk[target, diskSize]}];
                            
           range = If[OptionValue[plotRange] === Automatic,
                      chooseRange[7(r ){{-.5,.5},{-.1,1}}, 
                                  {{q1,q2}, {0,0}, target}, 
                                  2#&],
                      OptionValue[plotRange]];

           Graphics[{
               {FaceForm[bodyColour], 
                EdgeForm[None],
                Rotate[{{FaceForm[tailColour],tail},
                        {FaceForm[footColour],foot5, foot6, foot7, foot8}}, 
                       q3, {q1, q2}],
                {FaceForm[bodyColour],body}
               }, 
               distanceLine,
               targetLine,
               startDisk,
               targetDisk
                    }, FilterRules[{opts}, Options[Graphics]], PlotRange -> range, ImageSize -> imageSize]]


(* Draw a wireframe frog. *)
Options[drawFrogCheap] = 
    {showDistance -> False, plotRange -> Automatic, toTarget -> None, 
     showStart -> False, showTarget -> None, showTime -> False, 
     showDistanceToTarget -> False, passState -> None, 
     showMeanDistanceToTarget -> False};

myNumberToString[t_Real] := 
    ToString[PaddedForm[t, {3, 1}, 
                        NumberPadding -> {" ", "0"}]]

myNumberToString[t_Real, {a_, b_}] := 
    ToString[PaddedForm[t, {a, b}, 
                        NumberPadding -> {" ", "0"}]]



drawFrogCheap[{t_, q1_, q2_, q3_, q4_, q5_, q6_, q7_, q8_}, r_, l_, fl_, 
              OptionsPattern[]] :=
Module[{M3, R, T, O, T1, T4j, T5j, T6j, T7j, T8j, pt, p4j, T4l, T5l, 
        T6l, T7l, T8l, p5j, p6j, p7j, p8j, oq5, oq6, oq7, oq8,
        (* options *)
        state, target, range, distanceLine, targetLine, 
        startDisk, targetDisk, timeLine, distanceText, meanDistanceText},
       (* Options code *)
       target = {0, 0};
       state = OptionValue[passState];
       distanceLine = 
       If[OptionValue[showDistance] === True, 
          {Black, 
           Line[{{0, 0}, {q1, q2}}]},
          {}];
       
       timeLine = 
       If[OptionValue[showTime] === True, 
          {Black, 
           Text["t = " <> 
                ToString[PaddedForm[t, {3, 1}, 
                                    NumberPadding -> {" ", "0"}]], {.2,-.2}]},
          {}];
 
       targetLine = If[OptionValue[toTarget] === None,
                       {}, target = OptionValue[toTarget];
                       {Black, Line[{{q1, q2}, target}]}];
       
       startDisk = 
       If[OptionValue[showStart] === False, {}, {Point[{0, 0}]}];
       
       targetDisk = 
       If[OptionValue[showTarget] === None, {}, 
          target = OptionValue[showTarget];
          {Point[target]}];

       distanceText = 
       If[OptionValue[showDistanceToTarget] === True, 
          {Black, 
           Text["d = " <> myNumberToString[Norm[ {q1, q2} - target], {3,2}], {.2,-.25}]},
          {}];

       meanDistanceText = 
       If[OptionValue[showMeanDistanceToTarget] === True, 
          {Black, 
           Text["<d> = " <> 
                myNumberToString[state[[recordBegin]]/(t Norm[target] + 0.000001), {3,2}], 
                {.2,-.3}]},
          {}];


       
       range = 
       If[OptionValue[plotRange] === Automatic, 
          chooseRange[
              7 (r) {{-.5, .5}, {-.5, .5}}, {{q1, q2}, {0, 0}, target}, 2 # &],
          OptionValue[plotRange]];  
       
       T = TranslationTransform;
       R  = RotationTransform;
       oq5 = Pi/4;
       oq6 = 3 Pi/4;
       oq7 = 5 Pi/4;
       oq8 = 7 Pi/4;
       T1 = T[{q1, q2}];
       O = T1[{0, 0}];
       M3 = R[q3];
       (*T4j =R[q3] .  T[{0, -r}];*)
       T4j = R[q3] [{0, -r}]  ;
       T5j = (R[oq5] . R[q3])[{0, -r}];
       T6j = (R[oq6] . R[q3] )[{0, -r}];
       T7j = (R[oq7] . R[q3] )[{0, -r}];
       T8j = (R[oq8] . R[q3] )[{0, -r}];
       T4l =  T[(M3 . R[q4])[{0, -l}]];
       T5l =  T[(M3 . R[q5] . R[oq5])[{0, -fl}]];
       T6l =  T[(M3 . R[q6] . R[oq6])[{0, -fl}]];
       T7l =  T[(M3 . R[q7] . R[oq7])[{0, -fl}]];
       T8l =  T[(M3 . R[q8] . R[oq8])[{0, -fl}]];
       
       Graphics[{{Circle[O, r],
                  Line[{p4j = T1[T4j], T4l[p4j]}],
                  Line[{p5j = T1[T5j], T5l[p5j]}],
                  Line[{p6j = T1[T6j], T6l[p6j]}],
                  Line[{p7j = T1[T7j], T7l[p7j]}],
                  Line[{p8j = T1[T8j], T8l[p8j]}]
                 },
                 distanceLine, targetLine, startDisk, targetDisk, timeLine, distanceText, meanDistanceText
                }, PlotRange -> range, ImageSize -> imageSize, GridLines -> cmgrid]]

cmgrid[min_, max_] :=
    Module[{cm1},
           cm1 = 10 cm //. units;
    Table[If[Mod[i, 10] == 0, i cm1, {i cm1, Opacity[0.3]}], {i, Ceiling[min /cm1], Floor[max /cm1], 1}]]


(* Given some large array of {{t_1, x_1, ...}, {t_2, x_2, ...}, ...}
values, arbitrarily interpolate for any t value *)
interpolateData[data_, t_] := 
 	Module[{sparse, l , u, p, dt},
           dt = data[[2, 1]] - data[[1, 1]];
           l = Floor[t/dt];
           p = (t - l * dt)/dt;
           l = l + 1;
           u = l + 1;
           sparse = 
           SparseArray[{l  -> 1 - p, u ->  p}, {Dimensions[data][[1]]}];
           sparse . data]

Options[animateData] = 
    Join[{drawFunc -> drawFrogCheap},
         Options[Animate], 
         Options[drawFrog], 
         Options[drawFrogCheap]];

animateData[data_, opts:OptionsPattern[]] := 
    Module[{r1, lmax1, flmax1, tmax, state},
           {r1, lmax1, flmax1} = {r, lmax, flmax} //. params;
           tmax = Max[data[[All,1]]];
           Animate[
               Function[{t0},
                        state =interpolateData[data, t0];
                        OptionValue[drawFunc][
                            state[[timeBegin ;; timeBegin  + qstateCount]], 
                            r1, 
                            lmax1 state[[tailstateBegin]], 
                            flmax1 state[[tailstateBegin + 1]], 
                            passState -> state,
                            Sequence@@FilterRules[{opts}, 
                                        Options[OptionValue[drawFunc]]]]][t], 
               {t, 0, tmax},
               AnimationRepetitions -> 1, 
               Evaluate[Sequence@@FilterRules[{opts}, Options[Animate]]]
                  ]]


footTorque[angle_] := radialSpring2[angle] + periodicSwing


tailTorque[angle_] := radialSpring2[angle] + periodicSwing


tailTorqueCTRNN[angle_] := radialSpring2[angle] 


footTorqueCTRNN[angle_] := radialSpring2[angle] 


q4mod[t_] := pimod[q4[t]]


pimod[theta_] := Mod[theta + Pi, 2 Pi] - Pi


radialSpring[theta_] := -Tmax (pimod[theta]/(Pi/2))^3;


radialSpring2[theta_] := -Tmax (theta/(Pi/2))^3;


legCollision[theta_]  := -Tmax(sigma[20(theta - Pi/2)] - sigma[20(-theta - Pi/2)]);


boundaries[x_,{a_,b_},k_:20]  :=(sigma[k(x - a)] - sigma[k(-x + b)])


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


Options[eqnsForFrog] = {preParams -> {}, otherEqns -> {}, "params" -> None};


eqnsForFrog[OptionsPattern[]] := 
    Module[{useParams},
           useParams = OptionValue["params"];
           If[useParams === None, useParams = params];
    {(eqns //. OptionValue[preParams]~Join~useParams)~Join~
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
      u1[t],u2[t],u3[t],u4[t], u5[t], u6[t], u7[t], u8[t]}}]


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


eqns = Import["frog_eqns_dotsolved.m"];


cross2d[v_List, w_List] := 
    Module[{va, wa},
           va = v~Join~{0};
           wa = w~Join~{0};
           (va~Cross~wa)[[3]]]
