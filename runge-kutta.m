(* ::Package:: *)

(* runge-kutta solver *)
makeRungeKuttaFunc[eqns_, vars_, var_] := 
    Module[{dotvars, sol, justvars, body, n, a, i},
           dotvars = vars /. a_[var] -> a'[var];
           justvars = vars /. a_[var] -> a;
           n = Length[vars];
           sol = First[Solve[Flatten[eqns],dotvars]];
           body = dotvars /. sol ;

           Function[{b},Evaluate[Module[{},{1}~Join~body /. MapThread[#1 :>  Hold[b[[#2]]]&, {{var}~Join~vars, Range[n + 1]}]]]]  // ReleaseHold
          ]

makeRungeKuttaFuncWithConstants[eqns_, vars_, var_, constants_] := 
    Module[{dotvars, sol, justvars, body, n, a},
           dotvars = vars /. a_[var] -> a'[var];
           justvars = vars /. a_[var] -> a;
           n = Length[vars];
           sol = First[Solve[Flatten[eqns],dotvars]];
           body = dotvars /. sol ;
           Function[{b, c},
                    Evaluate[
                        Module[{rules = substituteRules[constants, c]},
                               {1}~Join~body /. MapThread[#1 :>  b~qpart~#2&, {{var}~Join~vars, Range[n + 1]}] /. rules]
                            ]
                   ]  
          ]


makeRungeKuttaStep[funcArg_] := 
    With[{func = funcArg},
         Function[{state, h},
             Module[{k1,k2,k3,k4},
                    k1 = h func[state];
                    k2 = h func[state + 1/2 k1];
                    k3 = h func[state + 1/2 k2];
                    k4 = h func[state + k3];
                    state + 1/6 (k1 + 2 k2 + 2 k3 + k4)]]] 


makeRungeKuttaWithConstants[funcArg_] := 
    With[{func = funcArg},
         Function[{state, h, c},
             Module[{k1,k2,k3,k4},
                    k1 = h func[state, c];
                    k2 = h func[state + 1/2 k1, c];
                    k3 = h func[state + 1/2 k2, c];
                    k4 = h func[state + k3, c];
                    state + 1/6 (k1 + 2 k2 + 2 k3 + k4)]]] 


makeRungeKuttaStepC[func_] :=
    Compile[{{state, _Real, 1}, {h, _Real, 0}},
             Module[{k1,k2,k3,k4},
                    k1 = h func[state];
                    k2 = h func[state + 1/2 k1];
                    k3 = h func[state + 1/2 k2];
                    k4 = h func[state + k3];
                    state + 1/6 (k1 + 2 k2 + 2 k3 + k4)],
            Evaluate[myCompileOptions]] 


makeRungeKuttaStepWithConstantsC[func_] :=
    Compile[{{state, _Real, 1}, {h, _Real, 0}, {c, _Real, 1}},
             Module[{k1,k2,k3,k4},
                    k1 = h func[state, c];
                    k2 = h func[state + 1/2 k1, c];
                    k3 = h func[state + 1/2 k2, c];
                    k4 = h func[state + k3, c];
                    state + 1/6 (k1 + 2 k2 + 2 k3 + k4)],
           Evaluate[myCompileOptions]] 


makeRungeKuttaStepWithError[funcArg_] := 
    With[{func = funcArg},
         Function[{state, h},
                  Module[{k1,k2,k3,k4,k5,k6,yout,yerr},
                         k1 = h func[state];
                         k2 = h func[k1/5 + state];
                         k3 = h func[(3 k1)/40 + (9 k2)/40 + state];
                         k4 = h func[(3 k1)/10 - (9 k2)/10 + (6 k3)/5 + state];
                         k5 = h func[-((11 k1)/54) + (5 k2)/2 - (70 k3)/27 + (35 k4)/27 + 
                                  state];
                         k6 = h func[(1631 k1)/55296 + (175 k2)/512 + (575 k3)/13824 + (44275 k4)/110592 + (253 k5)/4096 + state];
                         
                         yout = (37 k1)/378 + (250 k3)/621 + (125 k4)/594 + (512 k6)/1771 + state;

                         yerr = h(-((277 k1)/64512) + (6925 k3)/370944 - (6925 k4)/202752 - (277 k5)/14336 + (277 k6)/7084);
                         {yout, yerr}]]] 

makeRungeKuttaStepWithErrorC[func_] := 
    With[{func2 = funcArg},
         Compile[{{state, _Real, 1}, {h, _Real, 0}},
                  Module[{k1,k2,k3,k4,k5,k6,yout,yerr},
                         k1 = h func[state];
                         k2 = h func[k1/5 + state];
                         k3 = h func[(3 k1)/40 + (9 k2)/40 + state];
                         k4 = h func[(3 k1)/10 - (9 k2)/10 + (6 k3)/5 + state];
                         k5 = h func[-((11 k1)/54) + (5 k2)/2 - (70 k3)/27 + (35 k4)/27 + 
                                  state];
                         k6 = h func[(1631 k1)/55296 + (175 k2)/512 + (575 k3)/13824 + (44275 k4)/110592 + (253 k5)/4096 + state];
                         
                         yout = (37 k1)/378 + (250 k3)/621 + (125 k4)/594 + (512 k6)/1771 + state;

                         yerr = h(-((277 k1)/64512) + (6925 k3)/370944 - (6925 k4)/202752 - (277 k5)/14336 + (277 k6)/7084);
                         {yout, yerr}],
                 Evaluate[myCompileOptions]
                ]
        ] 



makeRungeKuttaAdaptiveStep[funcArg_,yScale_] :=
    With[{step = makeRungeKuttaStepWithError[funcArg],
          safety = 0.9,
          pGrow = -0.2,
          pShrink = -0.25,
          eps = 1*^-6,
          errCon = 1.89*^-4 (*(5/safety)^(1/pGrow)*)},
         Function[{state, hArg},
                  Module[{yout, yerr, errmax, h, htemp},
                         h = hArg;
                         While[True,
                         {yout,yerr} = step[state, h];
                         errmax = Max[Abs[yerr/yScale]];
                         errmax/eps;
                         If[errmax <= 1.0,
                            (* It's good let's use it.*)
                            Break[],
                            (* Truncation error too large, reduce stepsize. *)
                            htemp = safety h errmax^pShrink;
                            h = If[h >= 0, 
                                   Max[htemp, 0.1 h],
                                   Min[htemp, 0.1 h]]]];
                            If[errmax > errCon,
                               hnext = safety h errmax^pGrow,
                               hnext = 5 h];
                         {yout, hnext, h}]]]


makeRungeKuttaAdaptiveStepC[funcArg_, yScaleArg_] :=
    Module[{step = makeRungeKuttaStepWithErrorC[funcArg]},
    With[{
          yScale = yScaleArg,
          safety = 0.9,
          pGrow = -0.2,
          pShrink = -0.25,
          eps = 1*^-6,
          errCon = 1.89*^-4 (*(5/safety)^(1/pGrow)*)},
         Compile[{{state, _Real, 1}, {hArg, _Real, 0}},
                  Module[{yout = {}, yerr = {}, errmax = 0., h = 0., htemp = 0., hnext = 0., result = {{}}},
                         h = hArg;
                         While[True,
                               result = step[state, h];
                               yout = result[[1]];
                               yerr = result[[2]];
                               errmax = Max[Abs[yerr/yScale]];
                               errmax/eps;
                               If[errmax <= 1.0,
                                  (* It's good let's use it.*)
                                  Break[],
                                  (* Truncation error too large, reduce stepsize. *)
                                  htemp = safety h errmax^pShrink;
                                  h = If[h >= 0, 
                                         Max[htemp, 0.1 h],
                                         Min[htemp, 0.1 h]]]];
                         hnext = If[errmax > errCon,
                                    safety h errmax^pGrow,
                                    5 h];
                         yout~Join~{hnext, h}
                         (* Must return a vector or matrix here; no irregularly
                            shaped lists. *)
                        ],
                 Evaluate[myCompileOptions]]]]


makeAdaptiveIntegrator[step_] :=
    With[{mystep = step},
         Function[{sArg, hArg, time},
                  Module[{initTime, s, h, hdid},
                         s = sArg;
                         h = hArg;
                         initTime = s[[1]];
                         While[(s[[1]] - initTime) < time,
                               {s, h (*hnext*), hdid} = mystep[s, h];
                               h = Min[time - s[[1]] - initTime, h];
                              ];
                         s
                        ]]]


makeAdaptiveIntegratorC[step_] :=
    With[{mystep = step},
         Compile[{{sArg, _Real, 1}, {hArg, _Real, 0}, {time, _Real, 0}},
                  Module[{initTime, s, h, hdid, result},
                         s = sArg;
                         h = hArg;
                         initTime = s[[1]];
                         While[(s[[1]] - initTime) < time,
                               result = mystep[s, h];
                               s = result[[1;;-3]];
                               h = result[[-2]];
                               hdid = result[[-1]];
                               h = Min[time - s[[1]] - initTime, h];
                              ];
                         s
                        ],
                Evaluate[myCompileOptions]]]

