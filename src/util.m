(* ::Package:: *)

(* ::Title:: *)
(*Code*)

System`SetSystemOptions[
 "CompileOptions" -> "CompileReportExternal" -> True]

System`SetSystemOptions[
 "CompileOptions" -> "CompileReportFailure" -> True]


keys[a_] := a /. Rule[k_, v_] -> k


values[a_] := a /. Rule[k_, v_] -> v

mapThreadValues[fn_, {rules1_, rules2_}] := (
  Assert[Complement[keys[rules1], keys[rules2]] === {}];
  Assert[Complement[keys[rules2], keys[rules1]] === {}];
  Map[# -> fn[# /. rules1, # /. rules2] &, keys[rules1]])

mapValues[fn_, rules_] := rules /. Rule[k_, v_] :> Rule[k, fn[v]]

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
mstrip[file_] := processMstrip[ReadList["! /Users/shane/sc/thesis/src/mstrip "<>lookupFile[file]]]
mstrip[file_, phase_] := resultsList[mstrip[file], phase]
resultsList[list_, phaseArg_] := First[Select[list, (phase /. #) === phaseArg&]]
pbmstrip = mstripp;

lookupPath = {".", "../results/" };

fileExists[file_] :=
    FileType[file] =!= None

getFile::notuniq = "Found this list of files: ``";
lookupFile[file_] :=
    Module[{filenames, res},
           filenames = Map[ToFileName[#, file]&, lookupPath];
           res = Select[filenames, fileExists];
           (*If[Length[res] > 1,
              Message[getFile::notuniq, filenames]];*)
           First[res]]

(*RunThrough[command, expr]*)
