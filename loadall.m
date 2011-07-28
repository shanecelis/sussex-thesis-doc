(* ::Package:: *)

(* ::Title:: *)
(*Load All*)

(* AppendTo[$Path,ToFileName[{$HomeDirectory,"school","sussex", "thesis", "code"}]];*)


loadall[] := Module[{},
<< "bga.m";
<< "ctrnn.m";
<< "frog-ga.m";
<< "frog-simulation.m";
<< "export-c-code.m";
<< "runge-kutta.m";
<< "experiments.m";
"loaded."]


(*loadall[];*)
