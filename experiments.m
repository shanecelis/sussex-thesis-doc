(* ::Package:: *)

(* ::Title:: *)
(*Experiments Code*)


makeLinearPiecewise[points_] :=
    Function[{x},Evaluate[Piecewise[Map[{linearFit[#1, {1,x}, x] // Chop, #[[1,1]]<= x< #[[2,1]]}&,Partition[points,2,1]]] ]
            ]


linearFit[{{a_,b_},{c_,d_}}, fun_, var_] := If[a == c,d,
                                               (d - b)/(c - a) (var - a) + b ]


Options[showExperiment] = Options[Plot];


showExperiment[phases_,timeShift_:1, opts:OptionsPattern[]] := 
    Module[{tailGrowths, feetGrowths, tlpw,maxtime, flpw, phaseLines},
           tailGrowths = tailGrowth /. phases;
           feetGrowths = feetGrowth /. phases;

           tlpw = Join@@MapIndexed[Function[{a,b},Map[{timeShift, 1}(# + {b[[1]] - 1, .02})&, a]], tailGrowths];
           flpw = Join@@MapIndexed[Function[{a,b},Map[{timeShift,1}(# + {b[[1]] - 1, 0})&, a]], feetGrowths];

           maxtime =  Transpose[tlpw][[1]] //Max;
           phaseLines = Map[{Text["p" <> ToString[#], {(# -.5)timeShift, 0}],Line[{{# timeShift, -0.1}, {# timeShift,1.1}}]}&, Range[Length[phases]]];
           Plot[{makeLinearPiecewise[tlpw][x], 
                 makeLinearPiecewise[flpw][x]}, {x, 0,maxtime}, PlotStyle -> {tailColour, footColour}, AxesOrigin -> {0,-.1} ,
                Epilog -> {Dashed, phaseLines}, opts
                (*PlotLegend -> {"tail", "foot"}, LegendPosition -> {1.1, -0.4}*)]
          ]


experiment[0] := {{tailGrowth -> {{0,0}, {1,0}}, feetGrowth -> {{0,1}, {1,1}}}}


experiment[1] := {{tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,1}, {1,1}}}}


experiment[Ap] := {
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0}, {1,0}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,1/3}, {1,1/3}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,2/3}, {1,2/3}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,3/3}, {1,3/3}}}
                  }


experiment[Bp] := {
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0}, {1,0}}},
    {tailGrowth -> {{0,2/3}, {1,2/3}}, feetGrowth -> {{0,1/3}, {1,1/3}}},
    {tailGrowth -> {{0,1/3}, {1,1/3}}, feetGrowth -> {{0,2/3}, {1,2/3}}},
    {tailGrowth -> {{0,0}, {1,0}}, feetGrowth -> {{0,3/3}, {1,3/3}}}
                  }


experiment[Ao] := {
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0}, {1,1}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0},{2/3,1}, {1,1}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0},{1/3,1} {1,1}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,1}, {1,1}}}
                  }


experiment[Bo] := {
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0}, {1,1}}},
    {tailGrowth -> {{0,1},{2/3,1}, {1,0}}, feetGrowth -> {{0,0},{2/3,1}, {1,1}}},
    {tailGrowth -> {{0,1}, {1/3,1},{1,0}}, feetGrowth -> {{0,0},{1/3,1} {1,1}}},
    {tailGrowth -> {{0,0}, {1,0}}, feetGrowth -> {{0,1}, {1,1}}}
                  }


experimentPoints[a_, timeShift_] := 
    Module[{tpts, fpts},
           tpts = Map[PadRight[#,3,{{1.1,0}}]&,tailGrowth /. experiment[a]];
           fpts = Map[PadRight[#,3,{{1.1,0}}]&,feetGrowth /. experiment[a]];
           tpts = Map[{timeShift,1} #&, tpts, {2}];
           fpts = Map[{timeShift,1}#&, fpts, {2}];
           Map[Identity,MapThread[{#1,#2}&, {tpts, fpts}]]]


showAllExperiments[] := 
    Module[{experiments,plots},
           experiments = {0,1,Ap,Bp,Ao,Bo};
           plots = Map[showExperiment[experiment[#], PlotLabel -> ToString[#]]&, experiments];
           Grid [Partition[plots,3,3, {1,1}, ""]]]

