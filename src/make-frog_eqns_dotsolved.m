SetDirectory["/Users/shane/School/sussex/thesis/code/src"];
Import["frog_eqns.m"]; eqns0 = Map[# == 0&, rhseqns]; 
eqns = solveEqnsForDotVars[eqns0, {u1[t], u2[t], u3[t], u4[t], u5[t], u6[t], u7[t], u8[t]}, t];
Export["frog_eqns_dotsolved.m", eqns]
ResetDirectory[];
