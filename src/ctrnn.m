(* ::Package:: *)

(* ::Title:: *)
(*CTRNN*)


(* Requirements to specify a CTRNN:
   W (nxn) matrix
   theta (nx1) vector
   input (t -> nx1) function
   time constant (nx1) vector *)


sigma[x_] := 1/(1 + E^(-x))


makeSymbolicCTRNN[n_]:= 
    Module[{range, Ws, thetas, inputs, Ts},
           Ws = Array[W, {n,n}];
           thetas =Array[theta, {n}];
           inputs= Map[Function[{a},input[a][#]&],Range[n]]; (* has constant inputs *)
           Ts = Array[tc, {n}];
           {Ws,thetas,inputs, Ts}]


makeRandomCTRNN[n_] := 
    Module[{range, W, theta, input, Ts},
           range = {-1, 1};
           W = RandomReal[range, {n,n}];
           theta = RandomReal[range, {n}];
           input= Map[Function[{t}, #]&,RandomReal[range, {n}]]; (* has constant inputs *)
           Ts = RandomReal[10^range, {n}];
           {W,theta,input, Ts}]


makeRandomCTRNNLinSensor[n_, sensorCount_] := 
    Module[{ctrnn, range, sensorMat},
           range = {-1,1};
           sensorMat = RandomReal[range, {n, sensorCount}];
           ctrnn = makeRandomCTRNN[n];
           (*ctrnn[[3]] = makeLinSensorInputs[n,ctrnn[[3]]];*)
           ctrnn~Join~{sensorMat}]


makeSymbolicCTRNNLinSensor[n_, sensorCount_] := 
    Module[{ctrnn, sensorMat,s},
           ctrnn = makeSymbolicCTRNN[n];
           sensorMat = Array[nij,{nodeCountCTRNN[ctrnn], sensorCount}];
           (*sensorMat = sensorMat /. substituteRules[Flatten[sensorMat], sc];*)
           ctrnn = ctrnn~Join~{sensorMat};
           ctrnn[[3]] = makeLinSensorInputs[nodeCountCTRNN[ctrnn], 
                                            Array[sensor, sensorCount]];
           ctrnn
          ]


makeZeroCTRNNLinSensor[n_, sensorCount_] := 
    Module[{ctrnn, range, sensorMat},
           range = {-1,1};
           sensorMat = 0 RandomReal[range, {n, sensorCount}];
           ctrnn = makeZeroCTRNN[n];
           ctrnn~Join~{sensorMat}]


makeZeroCTRNN[n_] := 
    Module[{ctrnn},
           ctrnn= makeSymbolicCTRNN[n];
           ctrnn = 0. ctrnn;
           ctrnn[[4]] = Table[1., {n}];
           ctrnn[[3]] = Table[0.&, {n}];
           ctrnn]


nodeCountCTRNN[ctrnn_] :=Length[First[ctrnn]]


Options[eqnsForCTRNN] = {otherEqns -> {}};


eqnsForCTRNN[ctrnn_List,state_List, OptionsPattern[]] := 
    Module[{W,theta,input, eqns, ICs, sols, Tinv, y, dy, n, gain},
           n = nodeCountCTRNN[ctrnn];
           y = Table[ys[i][0], {i, n}];
           ICs = MapThread[#1 == #2&, {y, state}];
           eqnsForCTRNN[ctrnn, otherEqns -> ICs~Join~OptionValue[otherEqns]]]


eqnsForCTRNN[ctrnn_List,OptionsPattern[]] := 
    Module[{W,theta,input, Ts, eqns, ICs, sols, Tinv, y, dy, n, gain},
           {W,theta,input,Ts} = Take[ctrnn, 4];
           gain =1;
           n =nodeCountCTRNN[ctrnn];
           y = Table[ys[i][t], {i, n}];
           dy = Table[ys[i]'[t], {i,n}];
           (*Tinv = DiagonalMatrix[Ts^-1];*)
           Tinv = DiagonalMatrix[Ts];
           eqns = MapThread[#1 == #2&, 
                            {dy, Tinv . (W . sigma[y + theta] -y + gain Map[#[t]&,input]) }];
           {eqns~Join~OptionValue[otherEqns], y}]


eqnsForCTRNN[ctrnn_List,OptionsPattern[]] := 
    Module[{W,theta,input, Ts, eqns, ICs, sols, Tinv, y, dy, n, gain, bound},
           {W,theta,input,Ts} = Take[ctrnn, 4];
           gain =1;
           n =nodeCountCTRNN[ctrnn];
           y = Table[ys[i][t], {i, n}];
           dy = Table[ys[i]'[t], {i,n}];
           Tinv = DiagonalMatrix[Ts^-1];
           bound = IdentityMatrix[n];
           bound = DiagonalMatrix[Map[1 - Abs[boundaries[#, {-2,2}]]&, y]];
           eqns = MapThread[#1 == #2&, {dy, Tinv . (-y +bound . ( W . sigma[y + theta] + gain Map[#[t]&,input]))
                                        (* try to keep it bounded *)
                                        (*- 100 y  Map[Abs[boundaries[#, {-2,2}]]&}, y]*)
                            }];
(*sols = NDSolve[{eqns, ICs},y, {t,0, 5}];
  sols*)
{eqns~Join~OptionValue[otherEqns], y}]


substituteRules[vars_, v_] := 
    Module[{},
           Quiet[MapThread[#1 -> #2&, {vars,Table[v[[i]], {i, Length[vars]}]}], 
                 {Part::partd}]] 


(* sensors :: [Real -> Real] 
   time to sensor value *)
makeLinSensorInputs[nodeCount_, sensors_] := 
    Module[{mat, s, inputs, sensors2},
           mat = Array[nij,{nodeCount, Length[sensors]}];
           sensors2 = Map[Function[{a}, a[#]], sensors];
           inputs = Map[Function[{a},Function[Evaluate[a]]],mat . sensors2];
           (*inputs  /. substituteRules[Flatten[mat], sc]*)
           inputs
          ]


(* sensors :: [Real -> Real] 
   time to sensor value *)
makeLinSensorInputs[ctrnn_List, sensors_] := 
    Module[{mat, s, inputs, sensors2, nodeCount},
           nodeCount = nodeCountCTRNN[ctrnn];
           mat = ctrnn[[5]];
           sensors2 = Map[Function[{a}, a[#]], sensors];
           Map[Function[{a},Function[Evaluate[a]]],mat . sensors2]
          ]


solveCTRNN[ctrnn_, state_] := 
    Module[{eqns, vars},
           {eqns, vars} = eqnsForCTRNN[ctrnn, state];
           NDSolve[eqns, vars, {t, 0, 100}(*, Method -> "ExplicitEuler",StartingStepSize ->0.02*)] //First]


makeRandomCTRNNState[n_] := RandomReal[.1 {-1,1}, {n}]


makeZeroCTRNNState[n_] := Table[0, {n}]


onesForTimeCs[ctrnnArg_] := 
    Module[{n, ctrnn},
           ctrnn = ctrnnArg;
           n = nodeCountCTRNN[ctrnn];
           ctrnn[[4]] = Table[1, {n}];
           ctrnn]



