(* ::Package:: *)

(* ::Title:: *)
(*Code*)
unitsMatrix = DiagonalMatrix[{(* time *) s,
    (* configuration variables: *)  m, m, 1, 1, 
    							    1, 1, 1, 1,
    (* motion variables *) m/s, m/s, 1/s, 1/s,
                                                      1/s, 1/s, 1/s, 
    1/s,
    (* neuron states *) 1, 1, 1, 1, 1,
    (* tail and feet growth *)1, 1,
    (* record variables: *) m}];

showUnits[params_] := Module[{ks},
  ks = keys[params];
  Map[# == (# //. params) &, ks]]

toStandardUnits[state_, OptionsPattern[preParams -> {}]] := 
 state . Inverse[unitsMatrix //. OptionValue[preParams]~Join~params]

 varsToUnits = 
  MapThread[#1[_] -> #2 &, {{q1, q2, q3, q4, q5, q6, q7, q8,
     u1, u2, u3, u4, u5, u6, u7, u8,
     u1', u2', u3', u4', u5', u6', u7', u8'}, {m, m, 1, 1, 
     							    1, 1, 1, 1,
     (* motion variables *) m/s, m/s, 1/s, 1/s,
                                                       1/s, 1/s, 1/s, 
     1/s,
     m/s^2, m/s^2, 1/s^2, 1/s^2,
                                                       1/s^2, 1/s^2, 
     1/s^2, 1/s^2
     }}];

showUnits[params_] := Module[{ks}, ks = keys[params];
  Map[# == (# //. params) &, ks]]

examineEqnUnits[unumber_] := Module[{sym, eqn},
  sym = Symbol["u" <> ToString[unumber]];
  eqn = First[sym'[t] /. Solve[rhseqns[[unumber]] == 0, sym'[t]]];
  eqn //. {ma2 -> MA, mb2 -> MB, Ic2 -> IC}~Join~varsToUnits~Join~
      unitParams /. Abs[a_] -> a // 
   Simplify[#, {M > 0, S > 0, KG > 0}] &
  ]

unitParams = {m -> M, kg -> KG, s -> S}~Join~params;
