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

