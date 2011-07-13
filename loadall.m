(* ::Package:: *)

(* ::Title:: *)
(*Load All*)

(* AppendTo[$Path,ToFileName[{$HomeDirectory,"school","sussex", "thesis", "code"}]];*)


loadall[] := Module[{},
<< "bga.m";
<< "ctrnn.m";
<< "frog-simulation.m";
<< "export-c-code.m";
<< "experiments.m";
"loaded."]


(*loadall[];*)
