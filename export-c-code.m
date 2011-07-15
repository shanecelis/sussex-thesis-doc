(* ::Package:: *)

(* ::Title:: *)
(*Exporting to C Code*)


Needs["CCodeGenerator`"]
Needs["CompiledFunctionTools`"]


makeEulerStepper = makeDiffFunc;
makeDiffFunc[eqns_, vars_, var_] := 
    Module[{dotvars, sol, justvars, body, n, newvars, a, newvarsrules, i},
           dotvars = vars /. a_[var] -> a'[var];
           justvars = vars /. a_[var] -> a;
           n = Length[vars];
           sol = First[Solve[Flatten[eqns],dotvars]];
           body = dotvars /. sol ;

           Function[{b},Evaluate[Module[{},{1}~Join~body /. MapThread[#1 :>  Hold[b[[#2]]]&, {{var}~Join~vars, Range[n + 1]}]]]]  // ReleaseHold
          ]

makeEulerStepperC = makeDiffFuncC;
makeDiffFuncC[eqns_, vars_, var_] := 
    Quiet[Compile[{{a, _Real, 1}},
                  Evaluate[makeDiffFunc[eqns, vars, var][a]]
                 ], {Part::partd}]


makeEulerStepperWithConstants = makeDiffFuncWithConstants;
makeDiffFuncWithConstants[eqns_, vars_, var_, constants_] := 
    Module[{dotvars, sol, justvars, body, n, newvars, a, newvarsrules, i},
           dotvars = vars /. a_[var] -> a'[var];
           justvars = vars /. a_[var] -> a;
           n = Length[vars];
           sol = First[Solve[Flatten[eqns],dotvars]];
           body = dotvars /. sol ;
           Function[{b, c},
                    Evaluate[
                        Module[{rules = substituteRules[constants, c]},
                               {1}~Join~body /. MapThread[#1 :>  b~Part~#2&, {{var}~Join~vars, Range[n + 1]}] /. rules]
                            ]
                   ]  
          ]

makeEulerStepperWithConstantsC = makeDiffWithFuncConstantsC;

makeDiffFuncWithConstantsC[eqns_, vars_, var_, constants_] := 
    Quiet[Compile[{{a, _Real, 1}, {c, _Real, 1}},
                  Evaluate[makeDiffFuncWithConstants[eqns, vars, var, constants][a, c]],
                  Evaluate[myCompileOptions]
                 ], {Part::partd}]


(* Hard to make this work since HoldAll is used *)
myCompileOptions = CompilationOptions -> {
    "InlineExternalDefinitions" -> True, 
    "InlineCompiledFunctions" -> True, 
    "ExpressionOptimization" -> False};


makeEulerStepWithConstants[stepper_] := 
    Quiet[Function[{a, c, h}, 
                   a + h stepper[a,c]],
                   (*Evaluate[Table[a~qpart~i, {i,nvars + 1}] + h stepper[a,c]]], *)

          {Part::partd}]


makeEulerStepWithConstantsC[stepper_] := 
    Quiet[Compile[{{a, _Real, 1}, {h, _Real, 0}, {c, _Real, 1}}, 
                  a + h stepper[a,c],
                  Evaluate[myCompileOptions]], 
          {Part::partd}]


makeIntegrator[onestep_, h_] := 
    Module[{solver},
           solver = 
           Quiet[Function[{s, time, c}, 
                          Evaluate[Nest[Function[{s2}, onestep[s2, h, c]], s, Ceiling[time/h]]]], 
                 {Nest::intnm, Part::partd}];
           solver]


makeIntegratorC[onestep_, h_] := 
    Quiet[Compile[{{s, _Real, 1}, {t, _Real, 0}, {c, _Real, 1}},
                  Evaluate[makeIntegrator[onestep, h][s,t,c]],
                  Evaluate[myCompileOptions]
                 ], {Part::partd, Nest::intnm}]


makeEulerSolver[eqns_, vars_,var_, h_] := 
    Module[{stepper, solver, deqns, doteqns},
           deqns = makeEulerStepper[eqns,vars, var];
           (*stepper = Function[{a}, a + h doteqns[a]] /. doteqns -> deqns /. h -> 0.2;*)
           stepper = Quiet[Function[{a}, Evaluate[Table[a[[i]], {i,Length[vars] + 1}] + h deqns[a]]] , {Part::partd}];
           solver = Quiet[Compile[{{s, _Real, 1},{n, _Integer}}, (*Evaluate[Nest[stepper, s, Ceiling[(max - min)/h]]]] // ReleaseHold;*)
                          Evaluate[Nest[stepper, s, n]]], {Nest::intnm, Part::partd}];
solver]


(* Doesn't work as just a function, the variable c is local to the function. *)
makeEulerSolverWithConstants[eqns_, vars_,var_, h_, opts: OptionsPattern[]] := 
    Module[{stepper, solver, deqns, doteqns, proc},
           proc = OptionValue[postProcess];
           deqns = makeEulerStepper[eqns,vars, var];
           (*stepper = Function[{a}, a + h doteqns[a]] /. doteqns -> deqns /. h -> 0.2;*)
           stepper = Quiet[Function[{a}, Evaluate[proc[Table[a[[i]], {i,Length[vars] + 1}] + h deqns[a]]]] , {Part::partd}];


           solver = Quiet[Function[{s, n, c},
                                   Evaluate[Nest[stepper, s, Ceiling[n/h]]]], {Nest::intnm, Part::partd}];
           (*With[{c = solver[[1,3]]},Evaluate[solver]]*)
           solver[[1,3]] = c; (* Weird, I know, but that's what we gotta do *)
           solver
          ]




joinFlat[x__] := Flatten[Join@@List[x]]


NVectorQ[x_] := VectorQ[x,NumericQ]


runSolver[solver_, init_, deltat_, c_, maxt_] :=NestList[solver[#, deltat, c]&, init, Ceiling[maxt/deltat]]


Options[makeEulerSolverWithConstantsC] = Options[makeEulerSolverWithConstants] = {postProcess -> Identity, externalFunctions -> {}};


makeEulerSolverWithConstantsC[eqns_, vars_,var_, h_, opts: OptionsPattern[]] := 
    Quiet[Compile[{{s, _Real, 1},{n, _Real}, {c,_Real, 1}},
                  Evaluate[makeEulerSolverWithConstants[eqns,vars,var,h, opts][s,n,c]]
                  , (*CompilationOptions -> {
                      "InlineExternalDefinitions" -> True, 
                      "InlineCompiledFunctions" -> True, 
                      "ExpressionOptimization" -> False}*)
                  Evaluate[myCompileOptions]
                  ,
                  
                  "RuntimeOptions" -> {"RuntimeErrorHandler" :> Throw[$Failed]}
                 ], {Nest::intnm}]


qpart[a_,i_] := Quiet[Part[a,i], {Part::partd}]


myClip[x_] := myClip[x, {-1, 1}]
    myClip[x_, {min_, max_}] := Piecewise[{{max,x > max},{min, x < min}, {x, True}}]


substituteRules[vars_, v_] := 
    Module[{},
           Quiet[MapThread[#1 -> #2&, {vars,Table[v[[i]], {i, Length[vars]}]}], {Part::partd}]] 


Needs["PlotLegends`"]


mapOnlyIndices[f_, a_, is_] := MapIndexed[If[MemberQ[is,#2[[1]]],
                                             f[#1], #1]&, a]


flatLength[x_] := Length[Flatten[x]]


(* ::Title:: *)
(*Frog*)


motorCount = 5;
sensorCount = 14;


makeFrogSolver[] := 
    Module[{peqns, pvars, ceqns, cvars, ctrnn, eqns, ctrnnLength, target},
           {peqns,pvars} =eqnsForFrog[(*, preParams -> {Tq4 ->  radialSpring +0 Tmax Clip[ys[5][t]]}*)];

           makeEulerSolverWithConstantsC[peqns, pvars, t, 0.02
                                         (*, postProcess -> (#[[1;;9]]~Join~Map[myClip[#,{-1, 1}]&,#[[10;;10 + ctrnnLength - 1]]]~Join~#[[10 + ctrnnLength;; -1]]&)*)]
           (*peqns*)
           (*makeEulerStepper[peqns,pvars,t]*)
          ]


makeCTRNNSolver[] := 
    Module[{peqns, pvars, ceqns, cvars, ctrnn, eqns, target, sensors, motorCoefficients, sensorCoefficients, ctrnnLength},


           sensors = { (* 10 + 4  = 14 *)
                       Norm[{ys[1][#], ys[2][#], ys[3][#],ys[4][#],ys[5][#]}]&, 
                       1&
                     };
           sensors = {};
           ctrnn  = makeSymbolicCTRNNLinSensor[nodeCount,Length[sensors]];
           ctrnn[[3]] = makeLinSensorInputs[ctrnn, sensors];
           {ceqns, cvars} = eqnsForCTRNN[ctrnn] /. Clip -> myClip;
           ctrnn[[3]] = {};
           ceqns = ceqns /. substituteRules[Flatten[ctrnn], c] ;

           makeEulerSolverWithConstantsC[ceqns, cvars, t, 0.002
                                         (*,postProcess -> postProcessFrog*)]
          ]


makeFrogCTRNNSolver[] := 
    Module[{peqns, pvars, ceqns, cvars, ctrnn, eqns, target, sensors, motorCoefficients, sensorCoefficients, ctrnnLength, diff, step},

           {peqns,pvars} =eqnsForFrog[preParams -> {
               (*Tq4 ->  0 alwaysKick +  legCollision  +   Tmax Clip[ys[nodeCount][t]]*)
               Tq4 ->  tailTorqueCTRNN [q4[t]]+ Tmax Clip[ys[1][t]],
               Tq5 ->  footTorqueCTRNN [q5[t]]+ Tmax Clip[ys[2][t]],
               Tq6 ->  footTorqueCTRNN [q6[t]]+ Tmax Clip[ys[3][t]],
               Tq7 ->  footTorqueCTRNN [q7[t]]+ Tmax Clip[ys[4][t]],
               Tq8 ->  footTorqueCTRNN [q8[t]]+ Tmax Clip[ys[5][t]]
                                                   }];
           target = {tx, ty};
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
           ctrnn  = makeSymbolicCTRNNLinSensor[nodeCount,Length[sensors]];
           ctrnn[[3]] = makeLinSensorInputs[ctrnn, sensors];
           {ceqns, cvars} = eqnsForCTRNN[ctrnn];
           ctrnn[[3]] = {};
           (*ceqns = ceqns /. substituteRules[Flatten[ctrnn], c] ;*)

           (*eqns = solveEqnsForDotVars[peqns~Join~ceqns /. Clip -> myClip, pvars~Join~cvars, t];*)
           eqns = peqns~Join~ceqns /. Clip -> myClip;

(*           makeEulerSolverWithConstantsC[eqns, pvars~Join~cvars, t, 0.02
                                         (*,postProcess -> postProcessFrog*)]*)

           diff = makeDiffFuncWithConstantsC[eqns, pvars~Join~cvars, t, joinFlat[ctrnn,target]];
           (*step = makeEulerStepWithConstantsC[diff];*)
           step = makeRungeKuttaStepWithConstantsC[diff];
           makeIntegratorC[step, 0.01]
          ]


morphPreParams[{tailPoints_, footPoints_}] := {
    l -> makeLinearPiecewise[tailPoints][t] lmax,
    fl -> makeLinearPiecewise[footPoints][t] flmax,
    (*Tq4 ->  0 alwaysKick +  legCollision  +   Tmax Clip[ys[nodeCount][t]]*)
    Tq4 ->  tailTorqueCTRNN [q4[t]]+ Tmax Clip[ys[1][t]],
    Tq5 ->  footTorqueCTRNN [q5[t]]+ Tmax Clip[ys[2][t]],
    Tq6 ->  footTorqueCTRNN [q6[t]]+ Tmax Clip[ys[3][t]],
    Tq7 ->  footTorqueCTRNN [q7[t]]+ Tmax Clip[ys[4][t]],
    Tq8 ->  footTorqueCTRNN [q8[t]]+ Tmax Clip[ys[5][t]]
                                                   };

(*morphPreParams[*)


makeFrogMorphSolver[] := 
    Module[{peqns, pvars, ceqns, cvars, ctrnn, eqns, target, sensors, motorCoefficients, sensorCoefficients, ctrnnLength, tailPoints, footPoints,tvars,fvars, tv,fv, tx,ty, subrules, diff, step},
           tailPoints = Partition[tvars = Array[tv,{3 * 2}],2];
           footPoints = Partition[fvars = Array[fv,{3 * 2}],2];

           {peqns,pvars} =eqnsForFrog[preParams -> morphPreParams[{tailPoints, footPoints}]];
           target = {tx,ty};
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
           ctrnn  = makeSymbolicCTRNNLinSensor[nodeCount,Length[sensors]];
           ctrnn[[3]] = makeLinSensorInputs[ctrnn, sensors];
           {ceqns, cvars} = eqnsForCTRNN[ctrnn];
           ctrnn[[3]] = {};
           

           (*eqns = solveEqnsForDotVars[peqns~Join~ceqns /. Clip -> myClip, pvars~Join~cvars, t];*)

           (*
           subrules = substituteRules[joinFlat[ctrnn,target,tvars,fvars], c];
           eqns = peqns~Join~ceqns /.  subrules /. Clip -> myClip;

              makeEulerSolverWithConstantsC[eqns, pvars~Join~cvars, t, 0.001
                                         (*,postProcess -> postProcessFrog*)]*)

           diff = makeDiffFuncWithConstantsC[peqns~Join~ceqns /. {Clip -> myClip, qpart -> Part}, pvars~Join~cvars, t, joinFlat[ctrnn,target,tvars,fvars]];
           (*step = makeEulerStepWithConstantsC[diff];*)
           step = makeRungeKuttaStepWithConstantsC[diff];
           makeIntegratorC[step, 0.01]
          ]


postProcessFrog[stateA_] := 
    Module[{fixNeurons, state},
           state = stateA;

           fixNeurons = mapOnlyIndices[myClip[#, {-2,2}]&, state, Range[pstateCount + 2, pstateCount + 2 + nodeCount - 1]];
           (*fixNeurons  = state;*)
           state Map[processCollision2[fixNeurons, #]&, Range[0,pstateCount + nodeCount]]
          ]


processCollision[state_, qlimb_] := If[(state[[qlimb]] > Pi/2 && state[[qlimb + 8]] > 0) || (state[[qlimb]] < -Pi/2 && state[[qlimb + 8]] < 0),

                                       Module[{s},
                                              s = state;
                                              s[[qlimb + 8]] = -.8 s[[qlimb + 8]];
                                              s],
                                       state]


processCollision2[state_List, qlimb_] := If[4<= qlimb - 8 <= 8 && ((state[[qlimb - 8]] > Pi/2 && state[[qlimb ]] > 0) || (state[[qlimb - 8]] < -Pi/2 && state[[qlimb ]] < 0)),
                                            -.8,
                                            1]


plotConfigurationData[data_] := 
    Module[{time,q1,q2,q3,q4,q5,q6,q7,q8, plotData, plots},
           {time, q1,q2,q3,q4,q5,q6,q7,q8} = Map[data[[All, #]]&, Range[9]];
           plotData = Map[Transpose[{time, #}]&, {q1 + 3,q2 + 3,q3,q4,q5,q6,q7,q8}];

           ListPlot[plotData, PlotStyle -> {bodyColour,bodyColour,bodyColour, tailColour,footColour,footColour,footColour,footColour}, (*PlotRange -> {Automatic, 7{-1, 1}},*) Joined -> True, PlotLegend -> {"q1", "q2","q3","q4", "q5","q6","q7","q8"}, LegendPosition->{1.1,-0.4}]
          ]


plotMotionData[data_] := 
    Module[{time,q1,q2,q3,q4,q5,q6,q7,q8, plotData, plots},
           {time, q1,q2,q3,q4,q5,q6,q7,q8} = Map[data[[All, #]]&, {1}~Join~Range[9,9 + 8 - 1]];
           plotData = Map[Transpose[{time, #}]&, {q1 ,q2 ,q3,q4,q5,q6,q7,q8}];

           ListPlot[plotData, PlotStyle -> {bodyColour,bodyColour,bodyColour, tailColour,footColour,footColour,footColour,footColour}, (*PlotRange -> {Automatic, 7{-1, 1}},*) Joined -> True, PlotLegend -> {"u1", "u2","u3","u4", "u5","u6","u7","u8"}, LegendPosition->{1.1,-0.4}]
          ]


plotNeuronData[data_] := 
    Module[{time,q1,q2,q3,q4, q5, q6,q7, plotData, plots},
           {time, q1,q2,q3,q4, q5} = Map[data[[All, #]]&, {1}~Join~Range[16,16 + 5 - 1]];
           plotData = Map[Transpose[{time, #}]&, {q1 ,q2 ,q3,q4, q5}];
           ListPlot[plotData, PlotStyle -> {tailColour,footColour,footColour,footColour,footColour}, (*PlotRange -> {Automatic, 7{-1, 1}},*) Joined -> True, PlotLegend -> {"ys[1]", "ys[2]","ys[3]","ys[4]", "ys[5]"}, LegendPosition->{1.1,-0.4}]
          ]


animateData[data_, OptionsPattern[preParams -> {}]] := 
    Module[{times, timePerFrame, myParams},
           myParams = OptionValue[preParams]~Join~params;
           times = data[[All, 1]];
           timePerFrame = (Max[times] - Min[times])/Length[times];
           ListAnimate[Map[drawFrog[#[[2;;2 + 8 - 1]],r //. myParams, l //. myParams, fl //. myParams] /. t -> #[[1]] &, data], 1/timePerFrame]]


showDataStats[data_] := 
    Module[{max, min, header},
           header = {t,q1,q2,q3,q4,q5,q6,q7,q8,
                     u1,u2,u3,u4,u5,u6,u7,u8,
                     ys1,ys2,ys3,ys4,ys5};
           max = Map[Max, Transpose[data]];
           min = Map[Min, Transpose[data]];
           {header, min, max} // TableForm]


(* ::Title:: *)
(*Export to C Frog*)


(* ::Input:: *)
(*frogSolver = makeFrogCTRNNSolver[];*)


(* ::Input:: *)
(*csource=CCodeGenerate[frogSolver,"frogSolver", "CodeTarget" -> "WolframRTL"]*)


(* ::Input:: *)
(*cheader=CCodeGenerate[frogSolver,"frogSolver", "CodeTarget" -> "WolframRTLHeader"]*)
