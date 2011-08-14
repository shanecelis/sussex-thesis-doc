(* ::Package:: *)

(* ::Title:: *)
(*Frog GA*)

(* ::Subtitle:: *)
(*Direct Gene Encoding*)


nodeCount = 5; (* number of CTRNN nodes *)


(* regular geneCount *)
(*geneCount = nodeCount^2 + 2 nodeCount + 1; (* number of gene elements *)*)


(* LinSensor geneCount *)
geneCount = nodeCount^2 + 2 nodeCount + sensorCount * motorCount;

getGene[i_Integer] := genes[[i]]
getGene[i_List] := i

geneToCTRNN[i_] := geneToCTRNN[genes[[i]]]
    geneToCTRNN[gene_List] := 
    Module[{W, theta,Ts,gain, n},
           n = nodeCount;
           W = Partition[Map[Rescale[#, {0, 1}, 4{-1, 1}]&,gene[[1;;n^2]]],n];
           theta = Map[Rescale[#, {0, 1},2{-1,1}]&,gene[[n^2 + 1;;n^2 + n]]];
           Ts =Map[10.^Rescale[#,{0, 1},{-1, 2}]&,gene[[n^2 + n + 1;; n^2 + 2n ]]];
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


argsForTarget[gene_, target_, tmax_, expName_, phaseArg_] :=     
    Module[{experiment, phase, args},
           experiment = expName;
           phase = phaseArg; 
           args = {
               joinFlat[{0} (* time *), 
                        Table[0.0,{pstateCount}] (* pvars *),
                        makeZeroCTRNNState[nodeCount] (* cvars *), 
                        experimentInit[experiment, phase] (* gvars: 
                                                             tail and feet sizes *),
                        Table[0., {recordCount}] (* rvars: initial recording variables *)],
               RK4StepSize,
               joinFlat[gene, 
                        target, 
                        experimentPoints[experiment, tmax, phase]],
               tmax};
           args]


keepGoodChance = 0.01;
keepFailedChance = 1.;


fitnessToTargetRecordGoodAndBad[i_, target_, experiment_, phase_] := 
    Module[{fitness},
           fitness = fitnessToTarget[i, target, experiment, phase];
           If[fitness == 666.6,
              If[RandomReal[{0,1}] < keepFailedChance,
                 failedArgs = Join[{args}, failedArgs]],
              If[RandomReal[{0,1}] < keepGoodChance,
                 goodArgs = Join[{args}, goodArgs]]];
           fitness]

(*
   Calculate the mean distance using the diff 
*)
fitnessToTarget[i_, target_, experiment_, phase_] := 
    Module[{ (*endState,*) n, tmax, fitness, args},
           tmax = 10.0;
           args = argsForTarget[getGene[i], target, tmax, experiment, phase];
           fitness = Catch[endState = runSimulation@@args;
                           endState[[recordBegin]]/(tmax * Norm[target])];
           If[fitness === $Failed,
              666.6,
              fitness]
          ] 

fitnessForSpeed[i_, experiment_, phase_] := 
    Module[{ (*endState,*) n, tmax, fitness, args, target},
           tmax = 10.0;
           target = {0,0.1};
           args = argsForTarget[getGene[i], target, tmax, experiment, phase];
           fitness = Catch[endState = runSimulation@@args;
                           endState[[recordBegin + 1]]/tmax];
           If[fitness === $Failed,
              666.6,
              fitness]
          ]

fitnessForSpeedData[i_, experiment_, phase_] := 
    Module[{ (*endState,*) n, tmax, fitness, args, target},
           tmax = 10.0;
           target = {0,0.1};
           args = argsForTarget[getGene[i], target, tmax, experiment, phase];
           args[[2]] = 0.1;
           runSolver3[runSimulation, Sequence@@args]
          ]


fitnessToTargetData[i_, target_, experiment_, phase_] := 
    Module[{ (*endState,*) n, tmax, fitness, args, data},
           tmax = 10.0;
           args = argsForTarget[getGene[i], target, tmax, experiment, phase];
           args[[2]] = 0.1;
           data = runSolver3[runSimulation, Sequence@@args];
           data
          ] 


fitnessToTopTarget[i_] := evaluateToTarget[i, {0, 1} (.1m) //. params, expName, phase]


fitnessToMultipleTargets[iOrGene_] := 
    Module[{initTarget, targets},
           initTarget = {0, 1} (.2m) //. params;
           targets = NestList[RotationMatrix[Pi/4]. #&, initTarget, 3];
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
