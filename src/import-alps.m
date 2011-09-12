(* ::Package:: *)

(* ::Title:: *)
(*Code*)
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

chartStyle = "DarkRainbow";

importResults[directoryName_] := Module[{files},
  files = FileNames["output.txt", {directoryName}, 3];
  combineResults[
   Map[{FileBaseName[DirectoryName[#, 2]] , importALPSOut[#]} &, 
    files]]]

noChangeColour = Nest[Lighter, Gray, 2];
phyloChangeColour = Gray;
ontoChangeColour = Nest[Darker, Gray, 1];

chartColourRules = 
    {An -> noChangeColour, Ap -> phyloChangeColour, Ao -> ontoChangeColour,
     Bn -> noChangeColour, Bp -> phyloChangeColour, Bo -> ontoChangeColour};


boxChartOfResults[res_String] := boxChartOfResults[importResults[res]]

boxChartOfResults[res_List] := 
 BoxWhiskerChart[values[res], "Median", ChartLegends -> keys[res], 
  ChartStyle -> keys[res] /. chartColourRules]

SetAttributes[parseDirName, Listable];

parseDirName[filename_, index_] := parseDirName[filename][[index]]

NPorO[filename_] := Characters[ToString[parseDirName[filename][[1]]]][[2]]

AorB[filename_] := Characters[ToString[parseDirName[filename][[1]]]][[1]]

parseDirName[filename_] := 
 Module[{strs},
  strs = StringCases[filename, 
    RegularExpression["([AB].)-t(\\d)-l(\\d)"] -> {"$1", "$2", 
      "$3"}];
  {Symbol[strs[[1, 1]]], ToExpression[strs[[1, 2]]], 
   ToExpression[strs[[1, 3]]]}]

chartOfResults[directoryName_String] := 
    chartOfResults[importResults[directoryName]]


barWithStandardError[{{xmin_, xmax_}, {ymin_, ymax_}}, y_, SEArg_] := 
    Module[{xmed, SE},
           xmed = Mean[{xmin, xmax}];
           SE = SEArg[[1]];
           {{Black, 
             Line[{{xmin, ymax + SE}, {xmax, ymax + SE}}],
             Line[{{xmed, ymax}, {xmed, ymax + SE}}]
            }, 
            Rectangle[{xmin, ymin}, {xmax, ymax}]}]

chartLabelsHelper[dirnames_] :=
    Module[{expkeys},
           expkeys = parseDirName[dirnames];
           Map[If[NPorO[#] == "p",
                  AorB[#],
                  ""]&, dirnames]];

chartOfResults[res_List] := 
    Module[{means, SEs, fn},
           fn = Partition[#, 3]&;
           means = N[Map[Mean,values[res]]];
           SEs = N[Map[standardErrorOfMean,values[res]]];
           BarChart[fn[MapThread[Rule, {means, SEs}]], 
                    ChartLegends -> {"n", "p", "o"},
                    ChartStyle -> parseDirName[keys[res], 1] /. chartColourRules, 
                    ChartLabels -> 
                        (*chartLabelsHelper[keys[res]], *)
                        {{"A", "B"}, None},
                    BarSpacing -> {0, 0.3},
                    ChartElementFunction -> barWithStandardError]]
    
combineResultsHelper[splitResult_] := Module[{name, justData},
  name = splitResult[[1, 1]];
  justData = Map[#[[2]] &, splitResult];
  name ->  Map[#[[-1, -1]] &, justData]]

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
  ordering = {An, Ap, Ao, Bn, Bp, Bo};
  SortBy[rules, 
   Position[ordering, parseDirName[#[[1]]][[1]]][[1, 1]] &]]

reorderResults[results_] := 
 Map[reorderRules,  GatherBy[results, parseDirName[#[[1]]][[3]] &]]
