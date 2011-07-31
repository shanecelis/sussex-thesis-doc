(* ::Package:: *)

(* ::Title:: *)
(*Frog GA*)

(* ::Subtitle:: *)
(*Direct Gene Encoding*)


nodeCount = 5; (* number of CTRNN nodes *)


(* regular geneCount *)
geneCount = nodeCount^2 + 2 nodeCount + 1; (* number of gene elements *)


(* LinSensor geneCount *)
geneCount = nodeCount^2 + 2 nodeCount + sensorCount * motorCount;


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



(* ::Subtitle:: *)
(*Real Number Mutation*)


mutationSigma = 1;


mutationRate = 1/geneCount;


mutationVector[] :=Map[Evaluate,RandomChoice[{mutationRate, 1 - mutationRate} -> {Unevaluated[RandomReal[NormalDistribution[0,mutationSigma]]], 0}, len]]


mutationVector[] :=Map[Evaluate,RandomChoice[{mutationRate, 1 - mutationRate} -> {Unevaluated[RandomReal[UniformDistribution[{-.2, .2}]]], 0}, len]]


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


fitnessToTarget[iOrGene_,target_] := 
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

argsForTarget[gene_, target_, tmax_] :=     
    Module[{experiment, phase, args},
           experiment = Bp;
           phase = 1; 
           args = {
               joinFlat[{0} (* time *), 
                        Table[0.01,{pstateCount}] (* pvars *),
                        makeZeroCTRNNState[nodeCount] (* cvars *), 
                        experimentInit[experiment, phase] (* gvars: 
                                                             tail and feet sizes *),
                        {0.} (* rvars: initial recording variables *)],
               tmax, 
               joinFlat[gene, 
                        target, 
                        experimentPoints[experiment, tmax, phase]]};
           args]


keepGoodChance = 0.01;
keepFailedChance = 1.;

(*
   Calculate the mean distance using the diff 
*)
fitnessToTarget2[i_, target_] := 
    Module[{ (*endState,*) n, tmax, fitness, experiment, phase, args},
           tmax = 20.0;
           args = argsForTarget[genes[[i]], target, tmax];
           fitness = Catch[endState = runSimulation@@args;
                           endState[[-1]]/(tmax * Norm[target])];
           If[fitness === $Failed,
              If[RandomReal[{0,1}] < keepFailedChance,
                 failedArgs = Join[{args}, failedArgs]];
              1000,
              If[RandomReal[{0,1}] < keepGoodChance,
                 goodArgs = Join[{args}, goodArgs]];
              fitness]
          ] 

fitnessToTopTarget[i_] := evaluateToTarget[i, {0, 1} (.1m) //. params]


fitnessToMultipleTargets[iOrGene_] := 
    Module[{initTarget, targets},
           initTarget = {0, 1} (.1m) //. params;
           targets = {{0,0}}~Join~NestList[RotationMatrix[Pi/4]. #&, initTarget, 3];
           Max[Map[evaluateToTarget[iOrGene, #]&, targets]]]


Clear[evaluate,evaluateToTarget];
(*evaluate = fitnessToMultipleTargets;*)
evaluate = fitnessToTopTarget;
evaluateToTarget = fitnessToTarget2;


showEvaluations[iOrGene_] := 
    Module[{initTarget, targets},
           initTarget = {0, 1} (.1m) //. params;
           targets = {{0,0}}~Join~NestList[RotationMatrix[Pi/2]. #&, initTarget, 3];
           Map[(Print[#];evaluateToTarget[iOrGene, #])&, targets]
          ]


saveIndividual[gene_List] := 
    Module[{ctrnn},
           ctrnn = geneToCTRNNLinSensor[gene];
           {"ctrnn" -> ctrnn, "params" -> params, "note" -> ""}]


saveIndividual[gene_List, file_] := (Put[saveIndividual[gene], file])
