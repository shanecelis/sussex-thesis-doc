(* ::Package:: *)

(* ::Title:: *)
(*Load All*)

(* AppendTo[$Path,ToFileName[{$HomeDirectory,"school","sussex", "thesis", "code"}]];*)


loadall[] := Module[{},
<< "ctrnn.m";
<< "bga.m";
<< "frog-ga.m";
<< "frog-simulation.m";
<< "runge-kutta.m";
<< "export-c-code.m";
<< "experiments.m";
"loaded."]


(*loadall[];*)
