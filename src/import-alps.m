(* ::Package:: *)

(* ::Title:: *)
(*Code*)

expNameIndex = 1;
taskIndex = 2;
lobotomiseIndex = 3;
bodyTypeIndex = 4;
morphTypeIndex = 5;

plotImageSize = 5 72; (* 5 inches *)

maxEvaluations = {0, 30000};
maxEvaluations = Automatic;
(*maxEvaluations = {20000, 28000};*)
statFunc = Median;
statFunc = Mean;


chartStyle = "DarkRainbow";

noChangeColour = Nest[Lighter, Gray, 2];
phyloChangeColour = Gray;
ontoChangeColour = Nest[Darker, Gray, 2];

chartColourRules = 
    {An -> noChangeColour, Ap -> phyloChangeColour, Ao -> ontoChangeColour,
     Bn -> noChangeColour, Bp -> phyloChangeColour, Bo -> ontoChangeColour,
     Bq -> phyloChangeColour};


importALPSGenes[filename_] := 
 Select[Import[lookupFile[filename], "Table"], Length[#] == geneCount &]

importALPSOut[filename_] := 
 Select[Import[filename, "Table"], Length[#] == 3 &]

importGenesFromRun[resultName_, expName_, runNo_] := Module[{file},
  file = Last[
    FileNames[
     resultName <> "/" <> ToString[expName] <> "/" <> 
      ToString[runNo] <> "-*.pop"]];
  importALPSGenes[file]]

importResultsOld[directoryName_] := Module[{files},
  files = FileNames["output.txt", {directoryName}, 3];
  combineResults[
   Map[{FileBaseName[DirectoryName[#, 2]] , importALPSOut[#]} &, 
    files]]]

importResults[directoryName_] := Module[{files},
  files = FileNames["table.txt", {directoryName}, 3];
  combineResults[
   Map[{FileBaseName[DirectoryName[#, 2]] , Import[#, "Table"]} &, 
    files]]]


boxChartOfResults[res_String] := boxChartOfResults[importResults[res]]

boxChartOfResults[res_List] := 
 BoxWhiskerChart[values[res], "Median", ChartLegends -> keys[res], 
  ChartStyle -> keys[res] /. chartColourRules]

SetAttributes[parseDirName, Listable];


NPorO[filename_] := parseDirName[filename, 5]

AorB[filename_] := parseDirName[filename, 4]


parseDirName[filename_String] := 
 Module[{strs},
  strs = StringCases[filename, 
    RegularExpression["([AB])(.)-t(\\d)-l(\\d)"] -> {"$1", "$2", "$3", 
      "$4"}];
  {Symbol[strs[[1, 1]] <> strs[[1,2]]], ToExpression[strs[[1, 3]]], 
   ToExpression[strs[[1, 4]]], strs[[1,1]], strs[[1,2]]}]
parseDirName[filename_String, index_Integer] := parseDirName[filename][[index]]

chartOfResults[directoryName_String] := 
    chartOfResults[importResults[directoryName]]

chunk[x_, chunkSize_] := Floor[x/chunkSize] chunkSize

barWithStandardError[{{xmin_, xmax_}, {ymin_, ymax_}}, y_, data_] := 
    Module[{xmed, SE, maxMean},
           xmed = Mean[{xmin, xmax}];
           
           SE = data[[1,1]];
           maxMean = data[[1,3]];
           {{Black, 
             Line[{{xmin, ymax + SE}, {xmax, ymax + SE}}],
             Line[{{xmed, ymax}, {xmed, ymax + SE}}],
             Text[Style[data[[1,2]], Large], {xmed, 
                                              chunk[ymax + SE + .13 maxMean, 1000]}]
            }, 
            Rectangle[{xmin, ymin}, {xmax, ymax}]}]

chartLabelsHelper[dirnames_] :=
    Module[{expkeys},
           expkeys = parseDirName[dirnames];
           Map[If[NPorO[#] == "p",
                  AorB[#],
                  ""]&, dirnames]];

Options[chartOfResults] = {computeSigs -> True};

chartOfResults[resArg_List, opt:OptionsPattern[]] := 
    Module[{means, SEs, fn, btypes, bsubtypes, sigs, data, res, maxMean},
           res = maxEvalsOfResults[resArg];
           fn = Partition[#, 3]&;
           means = N[Map[statFunc,values[res]]];
           maxMean = Max[means];
           SEs = N[Map[standardErrorOfMean,values[res]]];
           sigs = If[OptionValue[computeSigs],
                     Sow[Map[computeSignificance, fn[res], {1}]],
                     {}];
           stars = sigToStars[Flatten[sigs]];
           btypes = Union[Map[AorB, keys[res]]];
           bsubtypes = Take[Map[NPorO, keys[res]], Min[Length[keys[res]],3]];
           data = MapThread[List[#1,#2, maxMean]&, {SEs, stars}];
           BarChart[fn[MapThread[Rule, {means, data}]], 
                    PlotRange -> {Automatic, maxEvaluations},
                    ChartLegends -> label[bsubtypes /. labels],
                    ChartStyle -> parseDirName[keys[res], 1] /. chartColourRules, 
                    ChartLabels -> 
                    (*{None, None, label[parseDirName[keys[res],1]]] },*)
                        (*chartLabelsHelper[keys[res]], *)
           {label[btypes], label[bsubtypes,12] },
           PlotLabel ->  titleLabel["Median Evaluations for" <> resultTitle[res]], 
                    BarSpacing -> {0, 0.3},
                    ChartElementFunction -> barWithStandardError,
                    ImageSize -> plotImageSize,
           
                    myAxesLabel[{"Morphological Variation", "Evaluations" }]
                   ]]



chartStepsOfResults[resArg_List] := 
    Module[{means, SEs, fn, btypes, bsubtypes, sigs, data, res},
           res = evalsForPhasesOfResults[Flatten[reorderResults[resArg]]];
           res = mapValues[Map[cumulativeToNon,#]&,res];
           myres = res;
           res = mapValues[N[statFunc[#]]&, res];
           fn = Partition[#, 3]&;
           means = values[res];
           maxPhases = Max[Map[Length, means]];
           (*means[[2;;3,3]] = 0;
           means[[5;;6,3]] = 0;*)
           BarChart[means, 
                    PlotRange -> {Automatic, maxEvaluations},
                    ChartLabels -> {label[parseDirName[keys[res],1]], None},
                    ChartStyle -> "GrayTones",
                    ChartLegends -> label[Map[p, Range[maxPhases]] /. labels],
                    ChartLayout -> "Stacked",
                    (*PlotLabel ->  
                    titleLabel["Median Evaluations by Phase for" <> resultTitle[res]], *)
                    BarSpacing -> {0.0, 0.3}
                    (*AxesLabel -> {"Morphological Variation", "Evaluations"}*)
                    ,myAxesLabel[{"Morphological Variation", "Evaluations" }, {0, 0.07}],
                    ImageSize -> plotImageSize
                   ]]

   
myAxesLabel[{labelx_, labely_}, offset_:{0,0}] := 
    Sequence[PlotRangeClipping -> False,
             ImagePadding -> {{Scaled[.11 - .5 offset[[2]]], Automatic}, 
                              {Scaled[.09 - offset[[1]]], Automatic}},
             Epilog -> {Text[Rotate[axesLabel[labelx],0], 
                             Scaled[{.5, -.20 + offset[[1]]}]],
                        Text[Rotate[axesLabel[labely],Pi/2], 
                             Scaled[{-.15 + offset[[2]], .5}]]
                       }]
                    



axesLabel[str_] := label[str, 15];
titleLabel[str_] := label[str, 18];
label[str_, size_:13] := Style[str, size]; 
SetAttributes[label, Listable];
    
combineResultsHelper[splitResult_] := Module[{name, justData},
  name = splitResult[[1, 1]];
  justData = Map[#[[2]] &, splitResult];
  name ->  Map[#(*[[-1, -1]]*) &, justData]]

combineResults[results_] := Module[{},
  Map[combineResultsHelper, SplitBy[results, #[[1]] &]]]

indexOfMinimum[fun_, inputs_] := Module[{outputs, min},
  outputs = Map[fun, inputs];
  min = Min[outputs];
  Flatten[Position[outputs, min]]]

indexOfMaximum[fun_, inputs_] := Module[{outputs, min},
  outputs = Map[fun, inputs];
  min = Max[outputs];
  Flatten[Position[outputs, min]]]

importMinGene[filename_, fitnessForGene_] := 
 Module[{genes, index,  indexes},
  genes = importALPSGenes[filename];
  indexes = indexOfMinimum[fitnessForGene, genes];
  If[Length[indexes] > 1,
   Message[importMinGene::notuniq]];
  index = First[indexes];
  genes[[index]]]

importMaxGene[filename_, fitnessForGene_] := 
 Module[{genes, index,  indexes},
  genes = importALPSGenes[filename];
  indexes = indexOfMaximum[fitnessForGene, genes];
  If[Length[indexes] > 1,
   Message[importMaxGene::notuniq]];
  index = First[indexes];
  genes[[index]]]


sampleStandardDeviation[list_] := StandardDeviation[list]
                                        

standardErrorOfMean[list_] :=
    Module[{n, s},
           s = sampleStandardDeviation[list];
           n = Length[list];
           s/n^(1/2)]


reorderRules[rules_] := Module[{ordering},
  ordering = {An, Ap, Ao, Bq, Bn, Bp, Bo};
  SortBy[rules, 
   Position[ordering, parseDirName[#[[1]]][[1]]][[1, 1]] &]]

(* Reorder by lobotomise. *)
reorderResults[results_] := 
    reorderResults[results, lobotomiseIndex];

reorderResults[results_, by_] := 
 Map[reorderRules,  GatherBy[results, parseDirName[#[[1]]][[by]] &]]

whatChangesInExperiment[res_] := 
    Module[{rules, exps, s, pre},
  exps = parseDirName[keys[res]][[All, 2 ;; 5]];
  rules = {"A" -> 1, "B" -> 2, "n" -> 1, "p" -> 2, "o" -> 3};
  s  = StandardDeviation[exps /. rules];
  pre = Map[Sign, s];
  {pre[[3]]~BitOr~ pre[[4]]}~Join~pre
  ]

whatDoesNotChangeInExperiment[res_] := 1 - whatChangesInExperiment[res]

resultTitle[res_] := 
    Module[{nochange, ks, titlePieces},
  nochange = whatDoesNotChangeInExperiment[res];
  ks = parseDirName[First[keys[res]]];
  
  titlePieces = {(*"",*)
    " Task " <> ToString[ks[[2]]],
    If[ks[[3]] == 1, " \nLobotomised CTRNN", " \nFully Connected CTRNN"],
    " Body Type " <> ks[[4]],
    " Morphological Var. " <> ks[[5]]};
  StringJoin[Riffle[Pick[titlePieces, Drop[nochange, 1], 1], ","]]]

computeSignificance[res_List] := Module[{v, mtypes},
  	Assert[Length[res] === 3];
  	mtypes = parseDirName[keys[res]][[All, morphTypeIndex]];
  	Assert[mtypes == {"n", "p", "o"}];
  	v = values[res];
  	{1, MannWhitneyTest[{v[[1]], v[[2]]}],
   	MannWhitneyTest[{v[[1]], v[[3]]}]}
  	]

sigToStars[sig_] := 
 Which[sig  < 0.001, "***", sig < 0.01, "**", sig < 0.05, "*", True, 
  ""]

sigsToStars = sigToStars;
SetAttributes[sigToStars, Listable]

maxEvalsOfResults[res_] := Flatten[reorderResults[mapValues[ #[[All, -1, -1]] &, res]]]

evalsForPhasesOfResults[res_] := mapValues[ #[[All, All, -1]] &, res]

byRow[fn_, matrix_] := Transpose[fn[Transpose[matrix]]]

cumulativeToNon[list_] := Module[{rlist},
  rlist = RotateRight[list];
  rlist[[1]] = 0;
  list - rlist]
