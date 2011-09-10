(* ::Package:: *)

(* ::Title:: *)
(*Code*)


keys[a_] := a /. Rule[k_, v_] -> k


values[a_] := a /. Rule[k_, v_] -> v

justSymbol[s_Symbol] := s
justSymbol[s_] := justSymbol[Head[s]]
SetAttributes[justSymbol, Listable];

fib[n_] := Drop[Table[Fibonacci[i], {i, n + 1}], 1] 

install[num_] := link = Install[ToString[num], LinkMode -> Connect]

On[Assert];

default[this_, that_] := If[this === None, that, this]

SetAttributes[setMaybe, HoldFirst]
setMaybe[var_, value_] := 
    If[Unevaluated[var] === var,
       (* It has not been set. *)
       Set[var,value],
       (* It has a value. *)
       var]

SetAttributes[or, HoldFirst]
or[var_, value_] := 
    If[Unevaluated[var] === var,
       (* It has not been set. *)
       value,
       (* It has a value. *)
       var]


replicate[list_, num_] := PadRight[{}, Length[list] * num, list]


pbpaste[] := RunThrough["pbpaste", ""]
pbcopy[expr_] := RunThrough["pbcopy", expr]
exec[command_] := ReadList["!"<>command, String]

(* paste and strip :m: prefixes *)

processMstrip[list_] := Select[list, # =!= Null&]
mstripp[phase_] := resultsList[mstripp[], phase]
mstripp[] := processMstrip[ReadList["! /Users/shane/sc/thesis/src/mstrip -p"]]
mstrip[file_] := processMStrip[ReadList["! /Users/shane/sc/thesis/src/mstrip "<>file]]
resultsList[list_, phaseArg_] := First[Select[list, (phase /. #) === phaseArg&]]

(*RunThrough[command, expr]*)
