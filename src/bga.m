(* ::Package:: *)

(* ::Title:: *)
(*Bacterial GA*)


pop = 30;
len = 10;
rec = 0.5;
mut = 0.1;
evaluations = 0;

end = 10^6;
 

minimize = False;


initGA[] := (genes = RandomInteger[{0, 1}, {pop, len}];
             clearCacheGA[];
             evaluations = 0;
             )
clearCacheGA[] := evaluationCache = Table[None, {pop}];


(* Minimizes fitness of an example card problem that attempts to arrange cards from [1,10] into sum and product piles of 36 and 360 respectively. *)


evaluate[n_] := 
    Module[{sum, prod, fitness, g, cards},
           cards = Range[1,10];
           g = genes[[n]];
           prod = Times@@Map[If[# === 0, 1, #]&,cards * g];
           sum = cards . (Table[1,{len}] - g);
           fitness = Abs[sum - sumtarg]/sumtarg  + Abs[prod - prodtarg]/prodtarg;
           fitness
          ]


evaluateCached[n_] := 
    Module[{},
           If[evaluationCache[[n]] === None,
              evaluationCache[[n]] = evaluate[n]];
           evaluationCache[[n]]]


mutate[L_] := For[i = 1, i < len, i++,
                  If[RandomReal[{0,1}] < mut,
                     genes[[L,i]] = (1 - genes[[L,i]])]];


crossover[L_,W_] :=  For[i = 1, i < len, i++,
                         If[RandomReal[{0,1}] < rec,
                            genes[[L,i]] = genes[[W,i]]]];


lessThan[a_, b_] := If[minimize,
                       a < b,
                       a > b];


runGA[] := 
    Module[{a, b, W, L, temp},
           (*temp = PrintTemporary[0];*)
           For[Null, evaluations < end, evaluations++,
               a = RandomInteger[{1, pop}];
               b = RandomInteger[{1, pop}];
               If[ evaluateCached[a] ~lessThan~ evaluateCached[b],
                   W = a; L = b,
                   W = b; L = a];
               crossover[L, W];
               mutate[L];
               evaluationCache[[L]] = None;

               (*If[evaluate[L] ~lessThan~ 0.01,
                 Print[L];
                 Break[]];*)
               If[Mod[evaluations,1000] == 0,
                  Print[genes[[bestIndividual[]]]]
                 ];
              ];
           bestIndividual[];
           evaluations
          ]


bestIndividual[] := 
    Module[{best},
           sortedIndividuals = Sort[Range[1, pop], 
                                    evaluateCached[#1] ~lessThan~ evaluateCached[#2]&];

           best = sortedIndividuals[[1]];
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
