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
           sensorMat = Array[s,{nodeCountCTRNN[ctrnn], sensorCount}];
           sensorMat = sensorMat /. substituteRules[Flatten[sensorMat], sc];
           ctrnn = ctrnn~Join~{sensorMat};
           ctrnn[[3]] = makeLinSensorInputs[nodeCountCTRNN[ctrnn], Array[sensor, sensorCount]];
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


Clear[eqnsForCTRNN]


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
           eqns = MapThread[#1 == #2&, {dy, Tinv . (W . sigma[y + theta] -y + gain Map[#[t]&,input]) }];
           (*sols = NDSolve[{eqns, ICs},y, {t,0, 5}];
             sols*)
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
           Quiet[MapThread[#1 -> #2&, {vars,Table[v[[i]], {i, Length[vars]}]}], {Part::partd}]] 


(* sensors :: [Real -> Real] 
   time to sensor value *)
makeLinSensorInputs[nodeCount_, sensors_] := 
    Module[{mat, s, inputs, sensors2},
           mat = Array[s,{nodeCount, Length[sensors]}];
           sensors2 = Map[Function[{a}, a[#]], sensors];
           inputs = Map[Function[{a},Function[Evaluate[a]]],mat . sensors2];
           inputs  /. substituteRules[Flatten[mat], sc]
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


(* ::Subtitle:: *)
(*Direct Gene Encoding*)


nodeCount = 5; (* number of CTRNN nodes *)


(* regular geneCount *)
geneCount = nodeCount^2 + 2 nodeCount + 1; (* number of gene elements *)


(* LinSensor geneCount *)
geneCount = nodeCount^2 + 2 nodeCount  + sensorCount * motorCount;


geneToCTRNN[i_] := geneToCTRNN[genes[[i]]]
    geneToCTRNN[gene_List] := 
    Module[{W, theta,Ts,gain, n},
           n = nodeCount;
           W = Partition[Map[Rescale[#, {0, 1}, 4{-1, 1}]&,gene[[1;;n^2]]],n];
           theta = Map[Rescale[#, {0, 1},2{-1,1}]&,gene[[n^2 + 1;;n^2 + n]]];
           Ts =Map[10^Rescale[#,{0, 1},{-1, 2}]&,gene[[n^2 + n + 1;; n^2 + 2n ]]];
           (* gain = Rescale[gene[[n^2 + 2n + 1]], {0, 1}, {1, 7}];*)
           (* not providing gain or inputs *)
           {W,theta,None, Ts}
          ]


geneToSensorCoefficients[i_] := geneToSensorCoefficients[genes[[i]]]
    geneToSensorCoefficients[gene_List] := 
    Module[{geneCountNeurons},
           geneCountNeurons = nodeCount^2 + 2 nodeCount ;
           Partition[Map[Rescale[#, {0, 1}, 4{-1,1}]&,gene[[geneCountNeurons + 1;; -1]]], sensorCount]
          ]


geneToCTRNNLinSensor[i_] := geneToCTRNNLinSensor[genes[[i]]]
    geneToCTRNNLinSensor[gene_List] := 
    Module[{ctrnn, sensCoeff, res},
           ctrnn = geneToCTRNN[gene];
           sensCoeff = geneToSensorCoefficients[gene];
           res = ctrnn~Join~{sensCoeff};
           res[[3]] = {};(*Table[0, {nodeCount}];*)
           res]


onesForTimeCs[ctrnnArg_] := 
    Module[{n, ctrnn},
           ctrnn = ctrnnArg;
           n = nodeCountCTRNN[ctrnn];
           ctrnn[[4]] = Table[1, {n}];
           ctrnn]



(* ::Subtitle:: *)
(*Real Number Mutation*)


mutationSigma = 1;


mutationRate = 1/geneCount;


mutationVector[] :=Map[Evaluate,RandomChoice[{mutationRate, 1 - mutationRate} -> {Unevaluated[RandomReal[NormalDistribution[0,mutationSigma]]], 0}, geneCount]]


mutationVector[] :=Map[Evaluate,RandomChoice[{mutationRate, 1 - mutationRate} -> {Unevaluated[RandomReal[UniformDistribution[{-.2, .2}]]], 0}, geneCount]]


(* Do I need to clip these values? *)


(* ::Subtitle:: *)
(*BGA Functions*)


pop = 10;
len = geneCount;
mut = 1/geneCount;
rec = 0.5; (* recombination *)


minimize = True;


end = 10^4;


mutate[L_] := (genes[[L]] = Map[Clip[#, {0, 1}]&,genes[[L]] + mutationVector[] ])


initPop[] := (genes = RandomReal[{0, 1}, {pop, len}];evaluationCache = Table[None, {pop}];)


(*evaluate[i_] := 
  Module[{ctrnn, state,n, range, tmax},
  ctrnn = geneToCTRNN[i];
  tmax = 20;
  (* need to give the initial state *)
         state = makeRandomCTRNNState[nodeCount];
         sol = runWithCTRNN[ctrnn, state,{0,0,0,0,  0,0,.01,.01}, tmax];
         (*Quiet[solveCTRNN[ctrnn,state]];
           calcFitness[]*)
         Norm[{q1[tmax], q2[tmax]}] /. sol 
        ]*)


(*evaluate[iOrGene_,target_] := 
  Module[{ctrnn, endState,n, range, tmax, q1,q2, q3, q4, sensorCoeff},
  ctrnn = geneToCTRNNLinSensor[iOrGene];
  Print[ctrnn];
  (*sensorCoeff = geneToSensorCoefficients[i];*)
         tmax = 20.;
         (* need to give the initial state *)
         ctrnn[[3]] = Table[0, {nodeCount}];
         (*target = {0, -2};*)
         endState = tadpoleSolver[Table[0.01,{10}](*~Join~makeZeroCTRNNState[nodeCount]*), tmax, Flatten[ctrnn]~Join~target];
         Print[endState];
         q1 = endState[[2]];
         q2 = endState[[3]];
         q3 = endState[[4]];
         q4 = endState[[5]];
         Norm[target - {q1,q2}]
        ]*)


evaluate[iOrGene_,target_] := 
    Module[{ctrnn, (*endState,*)n, range, tmax, q1s,q2s, q3s, q4s, sensorCoeff, fitness(*, sol*)},
           ctrnn = geneToCTRNNLinSensor[iOrGene];
           (*sensorCoeff = geneToSensorCoefficients[i];*)
           tmax = 20.;
           (* need to give the initial state *)
           (*ctrnn[[3]] = Table[0, {nodeCount}];*)
           (*target = {0, -2};*)
           fitness = Catch[endState = frogSolver[Table[0.01,{pstateCount + 1}]~Join~makeZeroCTRNNState[nodeCount], tmax, Flatten[ctrnn]~Join~target];
                           (*sol = runWithCTRNN[ctrnn, Table[0.,{nodeCount}],
                             Table[0.01, {pstateCount}], tmax];
                             {q1s, q2s} = {q1[t], q2[t]} /. sol /. t -> tmax;*)
                           q1s = endState[[2]];
                           q2s = endState[[3]];
                           q3s = endState[[4]];
                           q4s = endState[[5]];
                           Norm[target - {q1s,q2s}]];
           If[fitness === $Failed,
              1000,
              fitness]
          ]


runTadpole = evaluate;


evaluate[iOrGene_] := 
    Module[{initTarget, targets},
           initTarget = {0, 1} (.1m) //. params;
           targets = {{0,0}}~Join~NestList[RotationMatrix[Pi/2]. #&, initTarget, 3];
           Max[Map[evaluate[iOrGene, #]&, targets]]]


showEvaluations[iOrGene_] := 
    Module[{initTarget, targets},
           initTarget = {0, 1} (.1m) //. params;
           targets = {{0,0}}~Join~NestList[RotationMatrix[Pi/2]. #&, initTarget, 3];
           Map[(Print[#];evaluate[iOrGene, #])&, targets]
          ]


saveIndividual[gene_List] := 
    Module[{ctrnn},
           ctrnn = geneToCTRNNLinSensor[gene];
           {"ctrnn" -> ctrnn, "params" -> params, "note" -> ""}]


saveIndividual[gene_List, file_] := (Put[saveIndividual[gene], file])
