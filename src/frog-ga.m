(* ::Package:: *)

(* ::Title:: *)
(*Frog GA*)


(* ::Subtitle:: *)
(*Direct Gene Encoding*)


 

getGene[i_Integer] := genes[[i]]
getGene[i_List] := i



(* ::Subtitle:: *)
(*Real Number Mutation*)


mutationSigma = 1;


mutationVector[] :=Map[Evaluate,RandomChoice[{mutationRate, 1 - mutationRate} -> {Unevaluated[RandomReal[NormalDistribution[0,mutationSigma]]], 0}, len]]


mutationVector[] :=Map[Evaluate,RandomChoice[{mutationRate, 1 - mutationRate} -> {Unevaluated[RandomReal[UniformDistribution[{-.2, .2}]]], 0}, len]]


(* Do I need to clip these values? *)


(* ::Subtitle:: *)
(*BGA Functions*)


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


gscale[gi_, range_] := Rescale[gi, {0, 1}, range]
gunscale[gi_, range_] := Rescale[gi, range, {0, 1}]

physicsGeneLayout = { Tmax, kTa, kTb, kFa, kFb, krb };


physicsGeneToRules[i_] := 
    Module[{g},
           g = getGene[i];
    (* Tmax, kTa, kTb, kFa, kFb, krb *)
    {Tmax -> 10^gscale[g[[1]], {-6, -2}],
     kTa  ->    gscale[g[[2]], {-0.1, -0.0001}],
     kTb  ->    gscale[g[[3]], {-0.000001, -0.0001}], 
     kFa  ->    gscale[g[[4]], {-0.001, -1}], (* 4 *)
     kFb  ->    gscale[g[[5]], {-0.001, -100}], (* 5 *)
     krb  ->    gscale[g[[6]], {-1, 1}],
     kTc  ->    gscale[g[[3]], {-0.000001, -0.0001}], 
     kFc  ->    gscale[g[[5]], {-0.001, -100}], 
     krc  ->    gscale[g[[6]], {-1, 1}]
    } ]

rand[{a_, b_}] := RandomReal[{a, b} //. units];


randomStateRules[] :=
    Module[{rules, rev, a, gpts},
           rev = 2 Pi/s;
           a = 0.25;
           gpts = experimentInit@@({expName, phase} /. gaParams);
           rules =
   { t -> 0,
     q1 -> rand[10cm {-1, 1}],
     q2 -> rand[10cm {-1, 1}],
     q3 -> rand[Pi {-1, 1}],
     q4 -> rand[Pi/2 {-1, 1}],
     q5 -> rand[Pi/2 {-1, 1}],
     q6 -> rand[Pi/2 {-1, 1}],
     q7 -> rand[Pi/2 {-1, 1}],
     q8 -> rand[Pi/2 {-1, 1}],
     u1 -> rand[{-1 cm/s, 1 cm/s}],
     u2 -> rand[{-1 cm/s, 1 cm/s}],
     u3 -> rand[a rev {-1, 1}],
     u4 -> rand[a rev {-1, 1}],
     u5 -> rand[a rev {-1, 1}],
     u6 -> rand[a rev {-1, 1}],
     u7 -> rand[a rev {-1, 1}],
     u8 -> rand[a rev {-1, 1}],
     ys[1] -> 0,  ys[2] -> 0,  ys[3] -> 0,  ys[4] -> 0,  ys[5] -> 0,  
     lg -> gpts[[1]],  fg -> gpts[[2]],
     r[1] -> 0,  r[2] -> 0, r[3] -> 0, r[4] -> 0
   }]

randomState[] := stateLayout /. randomStateRules[]



physicsValuesToGenes[vArg_] := 
    Block[{gscale = gunscale},
          Module[{v},
                 v = vArg;
                 v[[1]] = Log[10, v[[1]]];
                 v = physicsGeneLayout /. physicsGeneToRules[v];
                 v[[1]] = Log[10, v[[1]]];
                 v]]

physicsPreRules = {};

physicsGeneToConstants[i_] := 
    Module[{myctrnn, myphyscons},
           myctrnn = makeZeroCTRNNLinSensor[nodeCount, sensorCount];
           myctrnn[[3]] = {};
           myphyscons = physcons //. physicsPreRules~Join~physicsGeneToRules[i]~Join~params;
           (*myphyscons = physcons //. params;*)
           joinFlat[myctrnn,
                    target /. gaParams, 
                    experimentPoints@@({expName, tmax, phase} /. gaParams),
                    myphyscons,
                    tourPeriods[[1]]]]


(*
fitnessForPhysics[i_] := 
    Mean[{fitnessForSpeed[i]}~Join~Map[runSpeedForPeriod[i,#]&, {1, 2, 4}]]

fitnessForPhysicsData[i_] := 
    {fitnessForSpeedData[i]}~Join~Map[runSpeedForPeriodData[i,#]&, {1, 2, 4}]
*)

getTimeAndSpeedWithState[i_, state_, period_, tmax_] :=
    Module[{args, time, res},
           args = argsForRun[i];
           args[[1]] = state;
           args[[3]] = Drop[args[[3]], -periodCount]~Join~period;
           args[[4]] = tmax;
           res = Catch[Check[endState = runSimulationGA@@args;
                       If[endState === $Failed,
                          $Failed,
                          (* it worked! *)
                          {endState[[1]],
                           Norm[{endState[[recordBegin + 1]], 
                                 endState[[recordBegin + 2]]}/endState[[1]]],
                           endState[[recordBegin + 3]]/endState[[1]]
                          }],
                       {endState[[1]], -0.0001, -0.0001}, 
                       {runSimulationMlink::errnan,
                        runSimulationMlink::errsim}]];
           If[res === $Failed,
              {0.0001, -0.0001, -0.0001},
              res]
          ]

getTimeAndSpeedWithStateData[i_, state_, period_, tmax_] :=
    Module[{args, time, res},
           args = argsForRun[i];
           args[[1]] = state;
           args[[2]] = dataDeltat /. gaParams;
           args[[3]] = Drop[args[[3]], -periodCount]~Join~period;
           args[[4]] = tmax;
           runSolver3[runSimulationGA, Sequence@@args]
          ]


noControllerPeriod = periodLayout /. 
    {f1 -> 0, psi1 -> 0, f2 -> 0, psi2 -> 0,
     f3 -> 0, psi3 -> 0, f4 -> 0, psi4 -> 0,
     f5 -> 0, psi5 -> 0, kys -> 0};

beginTournament[] :=
    Module[{ind},
           (* Setup some random state and controllers *)
           If[True && (Mod[evaluations, 1000] == 0 || Head[tourStates] =!= List),
              If[evaluations > 50,
                 ind = bestIndividual[];
                 Print[{genes[[ind]], evaluate[ind], physicsGeneToRules[ind]}];
                ];
              clearCacheGA[];

              newPhysicsTournament[];
             ]
          ]

newPhysicsTournament[] := 
    Module[{},
           tourStates = Table[randomState[], {3}];
           tourPeriods = Table[randomPeriod[], {3}];
          ]
           
fitnessForPhysics[i_] := 
    Quiet[Module[{res, res2, mytmax, f1, f2},
           mytmax = tmax /. gaParams;
           If[Head[tourStates] === Symbol, 
              newPhysicsTournament[]];
           res = MapThread[getTimeAndSpeedWithState[i, #1, #2, mytmax]&, 
                                 {tourStates, tourPeriods}];
           res2 = MapThread[getTimeAndSpeedWithState[i, #1, noControllerPeriod, mytmax (*#2[[1]]*)]&, 
                                 {tourStates, res}];
                 f1 = Mean[MapThread[Times,Transpose[res]]];
                 f2 = Mean[MapThread[Times,Transpose[res2]]];
                 Abs[f1^2/f2]
          ], {runSimulationMlink::errnan, runSimulationMlink::errsim}]

fitnessForPhysicsData[i_] := 
    Quiet[
        Module[{res, res2, mytmax, f1, f2, tmp},
               mytmax = tmax /. gaParams;
               res = Flatten[Outer[{
                   tmp = getTimeAndSpeedWithState[i, #1, #2, mytmax],
                   getTimeAndSpeedWithState[i, #1, noControllerPeriod, tmp[[1]]]}&, 
                           tourStates, tourPeriods, 1],1];
               res
               (*  Print[res];
                 *)
                 (*
                 Join[
                     MapThread[getTimeAndSpeedWithStateData[i, #1, #2, mytmax]&, 
                                 {tourStates, tourPeriods}],
                     MapThread[getTimeAndSpeedWithStateData[i, #1, noControllerPeriod, #2[[1]]]&, 
                                 {tourStates, res}]]*)
          ], {runSimulationMlink::errnan, runSimulationMlink::errsim}]

    
periodGeneToValues[i_] :=
    Module[{startAt},
           startAt = 5;
           startAt = 7;
           (periodLayout /. periodGeneToRules[i]) Table[1, {startAt - 1}]~Join~Table[0, {periodCount - startAt + 1}]
          ]

makeZeroPeriodValues[] :=
    periodLayout /. {f1 -> 0, psi1 -> 0, f2 -> 0, psi2 -> 0,
                       f3 -> 0, psi3 -> 0, f4 -> 0, psi4 -> 0,
                       f5 -> 0, psi5 -> 0, kys -> 1};

randomPeriodRules[] :=
    periodGeneToRules[RandomReal[{0,1}, {geneCountGA /. periodGaParams}]]

randomPeriod[] := periodLayout /. randomPeriodRules[]

periodGeneToRules[i_] := 
    Module[{g, res},
           g = getGene[i];
           res = Join[
               Map[Symbol["f" <> ToString[#]] -> gscale[g[[2 # - 1]], {0, 2}]&, Range[5]],
               Map[Symbol["psi" <> ToString[#]] -> gscale[g[[2 #]], {0, 1}]&, Range[5]],
               (* Ignore what the last gene says and turn off the CTRNN. *)
               {kys -> 0}];
           res 
          ]


periodGeneToConstants[i_] := 
    Module[{myctrnn},
           myctrnn = makeZeroCTRNNLinSensor[nodeCount, sensorCount];
           myctrnn[[3]] = {};
           joinFlat[Flatten[myctrnn],
                    target /. gaParams, 
                    experimentPoints@@({expName, tmax, phase} /. gaParams),
                    physcons //. params,
                    periodGeneToValues[i]]]
    

ctrnnGeneToConstants[i_] := 
    Module[{gene},
           gene = getGene[i];
           Assert[Length[gene] == ctrnnParamCount];
           joinFlat[geneToCTRNNLinSensor[gene],
                    target //. gaParams, 
                    experimentPoints@@({expName, tmax, phase} //. gaParams),
                    physcons //. params,
                    makeZeroPeriodValues[]]]


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
                              $Failed,
                              endState[[recordBegin + 1]]/endState[[1]]]];
           If[fitness === $Failed,
              -1.0,
              fitness]
          ]

runSpeedForPeriod[i_, p_] := Block[{physicsPreRules = {P -> p}~Join~physicsPreRules},
                               fitnessForSpeed[i]]

runSpeedForPeriodData[i_, p_] := Block[{physicsPreRules = {P -> p}~Join~physicsPreRules},
                               fitnessForSpeedData[i]]


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
