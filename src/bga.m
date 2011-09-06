(* ::Package:: *)

(* ::Title:: *)
(*Bacterial GA*)


setMaybe[pop, 30];
setMaybe[len, 10];
setMaybe[rec, 0.5];
setMaybe[mut, 0.1];
setMaybe[evalutions, 0];

setMaybe[end, 10^6];
 
setMaybe[useEvaluationCache, True];
setMaybe[minimize, False];


initGA[] := (genes = RandomInteger[{0, 1}, {pop, len}];
             clearCacheGA[];
             evaluations = 0;
             )


clearCacheGA[] := (evaluationCache = Table[None, {pop}];)


seedPop[init_] := (genes = Table[init, {pop}];
                   Map[mutate, Range[pop]];
                   Map[mutate, Range[pop]];
                   Map[mutate, Range[pop]];)


(* Minimizes fitness of an example card problem that attempts to arrange cards from [1,10] into sum and product piles of 36 and 360 respectively. *)

(*
evaluate[n_] := 
    Module[{sum, prod, fitness, g, cards},
           cards = Range[1,10];
           g = genes[[n]];
           prod = Times@@Map[If[# === 0, 1, #]&,cards * g];
           sum = cards . (Table[1,{len}] - g);
           fitness = Abs[sum - sumtarg]/sumtarg  + Abs[prod - prodtarg]/prodtarg;
           fitness
          ]
*)

evaluateCached[n_] := 
    Module[{},
           If[evaluationCache[[n]] === None || useEvaluationCache === False,
              evaluationCache[[n]] = evaluate[n]];
           evaluationCache[[n]]]


mutate[L_] := For[i = 1, i < len, i++,
                  If[RandomReal[{0,1}] < mut,
                     genes[[L,i]] = (1 - genes[[L,i]])]];


crossover[L_,W_] :=  For[i = 1, i < len, i++,
                         If[RandomReal[{0,1}] < rec,
                            genes[[L,i]] = genes[[W,i]]]];


lessThan[a_?NumberQ, b_?NumberQ] := If[minimize,
                                       a < b,
                                       a > b];

(* if lessThan -> True, then a is the winner *)
lessThan[a_?NumberQ, b_] := True

lessThan[a_, b_?NumberQ] := False

lessThan[a_, b_] := (Message[lessThan::nocmp];
                     True)
                               

beginTournament[] := Null

runGA[howMany_:None] := 
    Module[{a, b, W, L, temp},
           If[howMany === None,
              myend = end,
              myend = evaluations + howMany];
           (*temp = PrintTemporary[0];*)
           For[Null, evaluations < myend, evaluations++,
               a = RandomInteger[{1, pop}];
               b = RandomInteger[{1, pop}];
               beginTournament[];
               If[Quiet[evaluateCached[a] ~lessThan~ evaluateCached[b], 
                         {CompiledFunction::cfn}],
                   W = a; L = b,
                   W = b; L = a];
               crossover[L, W];
               mutate[L];
               evaluationCache[[L]] = None;

               (*If[evaluate[L] ~lessThan~ 0.01,
                 Print[L];
                 Break[]];*)
               (*
                  If[Mod[evaluations,1000] == 0,
                  Print[genes[[bestIndividual[]]]]
                 ];*)
              ];
           bestIndividual[];
           evaluations
          ]


bestIndividual[] := 
    Module[{best, list},
           list = Quiet[Sort[Range[1, pop], 
                       evaluateCached[#1] ~lessThan~ evaluateCached[#2]&]];

           best = list[[1]];
           evaluate[best];
           best];


bestFitness[] := Sort[evaluationCache, #1 ~lessThan~ #2&][[1]]


plotExpectedVsOutput[] := Null


(* ::Title:: *)
(*ALPS Integration*)


(* ::Input:: *)
(*valuesToCCode[values_] := StringJoin[MapIndexed[ToString[StringForm["data[``] = ``;\n", #2[[1]] - 1, CForm[#1 // N]]]&,Flatten[values]]]*)


(* ::Input:: *)
(*(* import the genes from from alps' file format *)*)
    (*importGenes[filename_] := Import[filename, "Table"][[-1]]*)
