(* ::Package:: *)

(* ::Title:: *)
(*Load All*)

(* AppendTo[$Path,ToFileName[{$HomeDirectory,"school","sussex", "thesis", "code"}]];*)


loadall[] := Module[{},
<< "util.m";
<< "ctrnn.m";
<< "bga.m";
<< "params.m";
<< "frog-ga.m";
<< "frog-simulation.m";
<< "runge-kutta.m";
<< "frog-morph-diff.m";
<< "export-c-code.m";
<< "experiments.m";
"loaded."]


