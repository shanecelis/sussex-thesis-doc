(* ::Package:: *)

(* ::Title:: *)
(*Frog GA*)

(* ::Subtitle:: *)
(*Direct Gene Encoding*)
 

getGene[i_Integer] := genes[[i]]
getGene[i_List] := i
 
geneToCTRNN[i_] := 
    Module[{W, theta,Ts,gain, n, gene},
           gene = getGene[i];
           n = nodeCount;
           W = Partition[Map[Rescale[#, {0, 1}, 4{-1, 1}]&,gene[[1;;n^2]]],n];
           theta = Map[Rescale[#, {0, 1},2{-1,1}]&,gene[[n^2 + 1;;n^2 + n]]];
           Ts = Map[10.^Rescale[#,{0, 1},{-2, 2}]&,gene[[n^2 + n + 1;; n^2 + 2n ]]]; (* change this from [-1, 2] -> [-2, 2] *)
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
           res[[3]] = {};
           res]



(* ::Subtitle:: *)
(*Real Number Mutation*)

mutationSigma = 1;


mutationVector[] :=Map[Evaluate,RandomChoice[{mutationRate, 1 - mutationRate} -> {Unevaluated[RandomReal[NormalDistribution[0,mutationSigma]]], 0}, len]]


mutationVector[] :=Map[Evaluate,RandomChoice[{mutationRate, 1 - mutationRate} -> {Unevaluated[RandomReal[UniformDistribution[{-.2, .2}]]], 0}, len]]


(* Do I need to clip these values? *)


(* ::Subtitle:: *)
(*BGA Functions*)


pop = 30;
len = geneCount;
mut = mutationRate = 1/geneCount;
rec = 0.5; (* recombination *)
end = 10^6;

minimize = minimise /. gaParams;


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
    Module[{experiment, phase, args, myctrnn, myphyscons},
           experiment = expName;
           phase = phaseArg; 
           
           args = {
               joinFlat[{0} (* time *), 
                        Table[0.0, {pstateCount}] (* pvars *),
                        makeZeroCTRNNState[nodeCount] (* cvars *), 
                        experimentInit[experiment, phase] (* gvars: 
                                                             tail and feet sizes *),
                        Table[0., {recordCount}] (* rvars: initial recording variables *)],
               stepSize,
               geneToConstants[i],
               tmax};
           args]

On[Assert];

gscale[gi_, range_] := Rescale[gi, {0, 1}, range]

physicsGeneToRules[i_] := 
    Module[{g},
           g = getGene[i];
    (* Tmax, kTa, kTb, kFa, kFb, krb *)
    {Tmax -> 10^gscale[g[[1]], {-6, -3}],
     kTa  ->    gscale[g[[2]], {-0.1, -0.001}],
     kTb  ->    gscale[g[[3]], {-0.000001, -0.0001}],
     kFa  ->    gscale[g[[4]], {-0.0001, -1}],
     kFb  ->    gscale[g[[5]], {-0.001, -20}],
     krb  ->    gscale[g[[6]], {-1, 1}],
     P    ->    gscale[g[[7]], {1, 6}]
    } ]
                           


physicsGeneToConstants[i_] := 
    Module[{myctrnn, myphyscons},
           myctrnn = makeZeroCTRNNLinSensor[nodeCount, sensorCount];
           myctrnn[[3]] = {};
           myphyscons = physcons //. physicsGeneToRules[i]~Join~params;
           (*myphyscons = physcons //. params;*)
           joinFlat[myctrnn,
                    target /. gaParams, 
                    experimentPoints@@({expName, tmax, phase} /. gaParams),
                    myphyscons ]]


fitnessForPhysics[i_] := 
    Mean[{fitnessForSpeed[i]}~Join~Map[runSpeedForPeriod[i,#]&, {1, 2, 4}]]

fitnessForPhysicsData[i_] := 
    {fitnessForSpeedData[i]}~Join~Map[runSpeedForPeriodData[i,#]&, {1, 2, 4}]
    

periodGeneToConstants[i_] := 
    Module[{myctrnn},
           myctrnn = makeZeroCTRNNLinSensor[nodeCount, sensorCount];
           myctrnn[[3]] = {};
           joinFlat[Flatten[myctrnn] + .1,
                    target /. gaParams, 
                    experimentPoints@@({expName, tmax, phase} /. gaParams),
                    Drop[physcons //. params, -1],
                    20.0 getGene[i]]]
    

ctrnnGeneToConstants[i_] := 
    Module[{gene},
           gene = getGene[i];
           Assert[Length[gene] == ctrnnParamCount];
           joinFlat[geneToCTRNNLinSensor[gene],
                    target //. gaParams, 
                    experimentPoints@@({expName, tmax, phase} //. gaParams),
                    physcons //. params]]


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
    Module[{ (*endState,*) fitness, args},
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
    Module[{ (*endState,*) args},
           args = argsForRun[i];
           args[[2]] = dataDeltat /. gaParams;
           runSolver3[runSimulationGA, Sequence@@args];
          ] 


fitnessForSpeed[i_] := 
    Module[{ (*endState,*) fitness},
           args = argsForRun[i];
           fitness = Catch[endState = runSimulationGA@@args;
                           If[endState === $Failed,
                              Throw[$Failed],
                              endState[[recordBegin + 1]]/(tmax /. gaParams)]];
           If[fitness === $Failed,
              -1.0,
              fitness]
          ]

runSpeedForPeriod[i_, p_] := Block[{params = {P -> p}~Join~params},
                               fitnessForSpeed[i]]

runSpeedForPeriodData[i_, p_] := Block[{params = {P -> p}~Join~params},
                               fitnessForSpeedData[i]]


default[this_, that_] := If[this === None, that, this]

fitnessForSpeedData[i_] := 
    Module[{},
           args = argsForRun[i];
           args[[2]] = dataDeltat /. gaParams;
           runSolver3[runSimulationGA, Sequence@@args]
          ]

fitnessToMultipleTargets[iOrGene_] := 
    Module[{initTarget, targets},
           initTarget = {0, 1} (.2m) //. params;
           targets = NestList[RotationMatrix[Pi/4]. #&, initTarget, 3];
           Max[Map[evaluateToTarget[iOrGene, #]&, targets]]]


evaluate[i_] := (fitnessFunc /. gaParams)[i]
evaluateData[i_] := (fitnessDataFunc /. gaParams)[i]
geneToConstants[i_] := (geneToConstantsFunc /. gaParams)[i]

animateEvaluate[i_] := 
    Module[{},
           data = evaluateData[i];
           animateMorph[data]]

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


showPopDynamic[] := 
    Dynamic[Column[{evaluations, 
                    NumberForm[Min[Select[evaluationCache, NumberQ]], 3], 
                    NumberForm[Max[Select[evaluationCache, NumberQ]], 3], 
                    Partition[Map[NumberForm[#, 2] &, evaluationCache], 9, 9, {1, 1}, 
  " "] // TableForm}]]
