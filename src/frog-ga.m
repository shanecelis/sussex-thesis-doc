(* ::Package:: *)

(* ::Title:: *)
(*Frog GA*)

(* ::Subtitle:: *)
(*Direct Gene Encoding*)


usePeriodicController = True;


(* regular geneCount *)
(*geneCount = nodeCount^2 + 2 nodeCount + 1; (* number of gene elements *)*)


(* LinSensor geneCount *)
geneCount = If[usePeriodicController,
               1,
               ctrnnParamCount];
               

getGene[i_Integer] := genes[[i]]
getGene[i_List] := i
 
geneToCTRNN[i_] := geneToCTRNN[genes[[i]]]
    geneToCTRNN[gene_List] := 
    Module[{W, theta,Ts,gain, n},
           n = nodeCount;
           W = Partition[Map[Rescale[#, {0, 1}, 4{-1, 1}]&,gene[[1;;n^2]]],n];
           theta = Map[Rescale[#, {0, 1},2{-1,1}]&,gene[[n^2 + 1;;n^2 + n]]];
           Ts =Map[10.^Rescale[#,{0, 1},{-2, 2}]&,gene[[n^2 + n + 1;; n^2 + 2n ]]]; (* change this from [-1, 2] -> [-2, 2] *)
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


pop = 30;
len = geneCount;
mut = 1/geneCount;
rec = 0.5; (* recombination *)


minimize = minimise /. gaParams;


end = 10^6;


mutate[L_] := 
    (genes[[L]] = Map[Clip[#, {0, 1}]&,genes[[L]] + mutationVector[] ])


initGA[] := 
    (genes = RandomReal[{0, 1}, {pop, len}];
     evaluationCache = Table[None, {pop}];
     evaluations = 0;)

initGene[] := RandomReal[{0,1}, {len}];

argsForRun[gene_] := 
    argsForTarget@@({gene, target, tmax, expName, phase, deltat} /. gaParams)

argsForTarget[i_, target_, tmax_, expName_, phaseArg_, stepSize_] :=     
    Module[{experiment, phase, args, myctrnn},
           experiment = expName;
           phase = phaseArg; 
           args = {
               joinFlat[{0} (* time *), 
                        Table[0.0,{pstateCount}] (* pvars *),
                        makeZeroCTRNNState[nodeCount] (* cvars *), 
                        experimentInit[experiment, phase] (* gvars: 
                                                             tail and feet sizes *),
                        Table[0., {recordCount}] (* rvars: initial recording variables *)],
               stepSize,
               If[usePeriodicController,
                  myctrnn = makeZeroCTRNNLinSensor[nodeCount, sensorCount];
                  myctrnn[[3]] = {};
                  joinFlat[myctrnn,
                           target, 
                           experimentPoints[experiment, tmax, phase],
                           Drop[physcons //. params,-1],
                           20.0 getGene[i]],
                  joinFlat[getGene[i], 
                           target, 
                           experimentPoints[experiment, tmax, phase],
                           physcons //. params]
                       ],
               tmax};
           args]


keepGoodChance = 0.01;
keepFailedChance = 1.;

goodArgs = {};
failedArgs = {};

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
fitnessToTarget[i_] :=
    Module[{ (*endState,*) n, tmax, fitness, args},
           args = argsForRun[i];
           fitness = Catch[endState = runSimulationGA@@args;
                           If[endState === $Failed,
                              Throw[$Failed],
                              endState[[recordBegin]]/(endState[[1]] * Norm[target /. gaParams])]];
           If[fitness === $Failed,
              666.6,
              fitness]
          ] 


fitnessToTargetData[i_] :=
    Module[{ (*endState,*) n, tmax, fitness, args, data},
           args = argsForRun[i];
           args[[2]] = dataDeltat /. gaParams;
           data = runSolver3[runSimulationGA, Sequence@@args];
           data
          ] 


fitnessForSpeed[i_] := 
    Module[{ (*endState,*) n, fitness},
           args = argsForRun[i];
           fitness = Catch[endState = runSimulationGA@@args;
                           If[endState === $Failed,
                              Throw[$Failed],
                              endState[[recordBegin + 1]]/(tmax /. gaParams)]];
           If[fitness === $Failed,
              -1.0,
              fitness]
          ]

default[this_, that_] := If[this === None, that, this]

fitnessForSpeedData[i_] := fitnessForSpeedData[i, expName, phase] /. gaParams

fitnessForSpeedData[i_] := 
    Module[{ (*endState,*) n, tmax, fitness, target},
           args = argsForRun[i];
           args[[2]] = dataDeltat /. gaParams;
           runSolver3[runSimulationGA, Sequence@@args]
          ]




fitnessToMultipleTargets[iOrGene_] := 
    Module[{initTarget, targets},
           initTarget = {0, 1} (.2m) //. params;
           targets = NestList[RotationMatrix[Pi/4]. #&, initTarget, 3];
           Max[Map[evaluateToTarget[iOrGene, #]&, targets]]]


(*Clear[evaluate,evaluateToTarget,runSimulationGA];*)
(*evaluate = fitnessToMultipleTargets;*)
(*evaluate = fitnessToTopTarget;
evaluate = fitnessForSpeed;
evaluateToTarget = fitnessToTarget;
runSimulationGA = runSimulation;*)

evaluate[i_] := (fitnessFunc /. gaParams)[i]
evaluateData[i_] := (fitnessDataFunc /. gaParams)[i]
runSimulationGA[args___] := (runSimulationGAFunc /. gaParams // ReleaseHold)@@List[args]

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


showPopDynamic[] := Dynamic[Column[{evaluations, NumberForm[Min[Select[evaluationCache, NumberQ]], 3], NumberForm[Max[Select[evaluationCache, NumberQ]], 3], Partition[Map[NumberForm[#, 2] &, evaluationCache], 9, 9, {1, 1}, 
  " "] // TableForm}]]
