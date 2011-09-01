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
