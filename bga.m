(* ::Package:: *)

(* ::Title:: *)
(*Bacterial GA*)


pop = 30;
len = 10;
rec = 0.5;
mut = 0.1;


end = 10^5;


minimize = False;


initPop[] := (genes = RandomInteger[{0, 1}, {pop, len}];
evaluationCache = Table[None, {pop}];
)


(* Minimizes fitness of an example card problem that attempts to arrange cards from [1,10] into sum and product piles of 36 and 360 respectively. *)


evaluate[n_] := Module[{sum, prod, fitness, g, cards},
cards = Range[1,10];
g = genes[[n]];
prod = Times@@Map[If[# === 0, 1, #]&,cards * g];
sum = cards . (Table[1,{len}] - g);
fitness = Abs[sum - sumtarg]/sumtarg  + Abs[prod - prodtarg]/prodtarg;
fitness
]


evaluateCached[n_] := Module[{},
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





runGA[] := Module[{t, a, b, W, L, i, temp},
(*initPop[];*)
temp = PrintTemporary[0];
For[t = 0, t < end, t++,
a = RandomInteger[{1, pop}];
b = RandomInteger[{1, pop}];
If[ evaluateCached[a] ~lessThan~ evaluateCached[b],
W = a; L = b,
W = b; L = a];
crossover[L, W];
mutate[L];
evaluationCache[[L]] = None;

(*If[Abs[evaluate[L]] < 0.01,
Print[L];
Break[]];*)
If[Mod[t, 100] === 0,
NotebookDelete[temp];
bestIndividual[];
temp = PrintTemporary[{t, bestFitness[], plotExpectedVsOutput[]}]];
];
bestIndividual[];
Print[{t, bestFitness[], plotExpectedVsOutput[]}];
t
]


bestIndividual[] := Module[{best},
sortedIndividuals = Sort[Range[1, pop], evaluateCached[#1] ~lessThan~ evaluateCached[#2]&];

best = sortedIndividuals[[1]];
evaluate[best];
best];


bestFitness[] := Sort[evaluationCache][[1]]


plotExpectedVsOutput[] := Null


(* ::Title:: *)
(*ALPS Integration*)


(* ::Input:: *)
(*valuesToCCode[values_] := StringJoin[MapIndexed[ToString[StringForm["data[``] = ``;\n", #2[[1]] - 1, CForm[#1 // N]]]&,Flatten[values]]]*)


(* ::Input:: *)
(*(* import the genes from from alps' file format *)*)
(*importGenes[filename_] := Import[filename, "Table"][[-1]]*)
