(* ::Package:: *)

(* ::Title:: *)
(*Experiments Code*)


makeLinearPiecewise[points_] :=
    Function[{x},Evaluate[Piecewise[Map[{linearFit[#1, {1,x}, x] // Chop, #[[1,1]]<= x< #[[2,1]]}&,Partition[points,2,1]], 0.1] ]
            ]

makeDiffLinearPiecewise[points_] :=
    Function[{x},Evaluate[Piecewise[Map[{diffLinearFit[#1, {1,x}, x] // Chop, #[[1,1]]<= x< #[[2,1]]}&,Partition[points,2,1]], 0] ]
            ]


minimumLimbLength = 0.0;


linearFit[{{a_,b_},{c_,d_}}, fun_, var_] := If[a == c,
                                               d,
                                               (d - b)/(c - a) (var - a) + b ]


(* need to know the step size in order to actually do this right. *)
diffLinearFit[{{a_,b_},{c_,d_}}, fun_, var_] := 
    If[a == c,
       d,
       (d - b)/(c - a)]


Options[showExperiment] = Options[Plot];


showExperiment[phases_, timeShift_:1, opts:OptionsPattern[]] := 
    Module[{tailGrowths, feetGrowths, tlpw,maxtime, flpw, phaseLines, visualSeparation},
           tailGrowths = tailGrowth /. phases;
           feetGrowths = feetGrowth /. phases;
           visualSeparation = 0.01;
           tlpw = Join@@MapIndexed[Function[{a,b},
                                            Map[{timeShift, 1}(# + {b[[1]] - 1, .01})&, a]], 
                                   tailGrowths];
           flpw = Join@@MapIndexed[Function[{a,b},
                                            Map[{timeShift, 1}(# + {b[[1]] - 1, -.01 })&, a]], 
                                   feetGrowths];

           maxtime =  Transpose[tlpw][[1]] //Max;
           phaseLines = Map[{Text["p" <> ToString[#], 
                                  {(# -.5)timeShift, 0}], 
                             Line[{{# timeShift, -0.1}, 
                                   {# timeShift, 1.1}}]}&, 
                            Range[Length[phases]]];
           Plot[{makeLinearPiecewise[tlpw][x], 
                 makeLinearPiecewise[flpw][x]}, 
                {x, 0, maxtime}, 
                PlotStyle -> {{Thick, tailColour}, {Thick,footColour}}, 
                (*PlotRange -> {Automatic, {-.1, 1.1}},*)
                AxesOrigin -> {0,-.1},
                Epilog -> {Dashed, phaseLines}, 
                opts
                (*PlotLegend -> {"tail", "foot"}, LegendPosition -> {1.1, -0.4}*)]
          ]


experimentNames = {An, Bn, Ap, Bp, Ao, Bo};


experimentIdeal[Bn] := {{tailGrowth -> {{0,0}, {1,0}}, feetGrowth -> {{0,1}, {1,1}}}}


experimentIdeal[An] := {{tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,1}, {1,1}}}}


experimentIdeal[Ap] := {
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0},   {1,0}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,1/3}, {1,1/3}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,2/3}, {1,2/3}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,3/3}, {1,3/3}}}
                  }


experimentIdeal[Bp] := {
    {tailGrowth -> {{0,1},   {1,1}},   feetGrowth -> {{0,0},   {1,0}}},
    {tailGrowth -> {{0,2/3}, {1,2/3}}, feetGrowth -> {{0,1/3}, {1,1/3}}},
    {tailGrowth -> {{0,1/3}, {1,1/3}}, feetGrowth -> {{0,2/3}, {1,2/3}}},
    {tailGrowth -> {{0,0},   {1,0}},   feetGrowth -> {{0,3/3}, {1,3/3}}}
                  }


experimentIdeal[Ao] := {
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0}, {1,1}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0}, {2/3,1}, {1,1}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,0}, {1/3,1} {1,1}}},
    {tailGrowth -> {{0,1}, {1,1}}, feetGrowth -> {{0,1}, {1,1}}}
                  }


experimentIdeal[Bo] := {
    {tailGrowth -> {{0,1}, {1,1}},          feetGrowth -> {{0,0}, {1,1}}},
    {tailGrowth -> {{0,1}, {2/3,1}, {1,0}}, feetGrowth -> {{0,0}, {2/3,1}, {1,1}}},
    {tailGrowth -> {{0,1}, {1/3,1}, {1,0}}, feetGrowth -> {{0,0}, {1/3,1}, {1,1}}},
    {tailGrowth -> {{0,0}, {1,0}},          feetGrowth -> {{0,1}, {1,1}}}
                  }


rescaleYPoints[points_, {min_, max_}] := 
    Module[{xs, ys},
           {xs, ys} = Transpose[points];
           Transpose[{xs, Map[Rescale[#, {0, 1}, {min, max}] &, ys]}]]


rescaleYPoint[point_, {min_, max_}] := 
    {point[[1]], Rescale[point[[2]], {0, 1}, {min, max}]}


adjustExperiments[{minLimb_, maxLimb_}] := 
    Map[Function[{exp}, 
                 experiment[exp] = Map[rescaleYPoint[#, {minLimb, maxLimb}] &, 
                                       experimentIdeal[exp], {4}]], 
        experimentNames]


adjustExperiments[{minimumLimbLength, 1}]


experimentPoints[a_, timeShift_] := 
    Module[{tpts, fpts, points},
           tpts = Map[PadRight[#,3,{#[[-1]]}]&,tailGrowth /. experiment[a]];
           fpts = Map[PadRight[#,3,{#[[-1]]}]&,feetGrowth /. experiment[a]];
           tpts = Map[{timeShift,1} #&, tpts, {2}];
           fpts = Map[{timeShift,1}#&, fpts, {2}];
           points = Map[Identity,MapThread[{#1,#2}&, {tpts, fpts}]]]


experimentPoints[a_, timeShift_, phase_] := 
    Module[{points},
           points = experimentPoints[a,timeShift];
           Assert[phase >= 0 && phase <= Length[points]];
           If[phase == 0,
              {Length[points]},
              points[[phase]]]
          ]


experimentInit[a_] := 
    Module[{tinits, finits},
           tinits = Map[#[[1,2]]&,(tailGrowth /. experiment[a])];
           finits = Map[#[[1,2]]&,(feetGrowth /. experiment[a])];
           MapThread[{#1,#2}&, {tinits, finits}]]


experimentInit[a_, phase_] :=
    experimentInit[a][[phase]]


experimentFuncs[a_, timeShift_] := 
    Map[makeLinearPiecewise, experimentPoints[a, timeShift],{2}]


experimentDiffFuncs[a_, timeShift_] := 
    Map[makeDiffLinearPiecewise, experimentPoints[a, timeShift],{2}]


showAllExperiments[] := 
    Module[{plots},
           plots = Map[showExperiment[experiment[#], 
                                      1, 
                                      PlotLabel -> ToString[#], 
                                      ImageSize -> 300]&, 
                       experimentNames];
           Grid [Partition[plots,2,2, {1,1}, ""]]]


makeExperiments[] := 
    Block[{tmax, phase, x},
           Function[{x, tmax, phase}, 
             Evaluate[
                 Piecewise[(MapIndexed[{makeExperimentPointsWhich[#, tmax, phase], 
                                        x == First[#2]} &, experimentNames]), {-2.}]]]]


makeExperimentsC[] := 
    Block[{tmax, phase, x},
          Compile[{{x, _Integer, 0}, {tmax, _Real, 0}, {phase, _Integer, 0}},
                  Evaluate[makeExperiments[][x, tmax, phase]]]]


makeExperimentPointsWhich[a_, timeShift_, phase_] := 
    Piecewise[
        Map[{N[Flatten[experimentPoints[a, timeShift, #]]], phase == #} &, 
            Range[0, Length[experimentPoints[a, timeShift]]]], {-1.}]
