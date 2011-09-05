(* ::Package:: *)

(* ::Title:: *)
(*Exporting to C Code*)


makeFrogMorphDiff[] := makeFrogMorphDiffHelper[makeDiffFuncWithConstantsC]
makeFrogMorphDiffNotC[] := makeFrogMorphDiffHelper[makeDiffFuncWithConstants]
makeFrogMorphDiffHelper[makeDiffFunc_] := 
    Module[{peqns, pvars, ceqns, cvars, ctrnn, eqns, target, sensors, 
            motorCoefficients, sensorCoefficients, ctrnnLength, tailPoints, 
            footPoints, tcons, fcons, subrules, diff, step, 
            collision, newstep, reqns, rvars, myPreParams, bc},

           tailPoints = Partition[tcons = Flatten[Array[tpts,{3,2}]],2];
           footPoints = Partition[fcons = Flatten[Array[fpts,{3,2}]],2];

           bc = -1.01;
           myPreParams = {
               oq4 -> 0,
               oq5 -> 1 Pi/4,
               oq6 -> 3 Pi/4,
               oq7 -> 5 Pi/4,
               oq8 -> 7 Pi/4,
               l     -> lg[t] lmax,
               fl    -> fg[t] flmax,
               Tq4   -> Tmax  (kys Clip[ys[1][t]] 
                               + Sin[(2 Pi f1) t + 2 Pi psi1]
                               + bc mySimpleBoundary[q4[t], {-Pi/2, Pi/2}]),
               Tq5   -> Tfmax (kys Clip[ys[2][t]] 
                               + Sin[(2 Pi f2) t + 2 Pi psi2]
                               + bc mySimpleBoundary[q5[t], {-Pi/2, Pi/2}]),
               Tq6   -> Tfmax (kys Clip[ys[3][t]] 
                               + Sin[(2 Pi f3) t + 2 Pi psi3]
                               + bc mySimpleBoundary[q6[t], {-Pi/2, Pi/2}]),
               Tq7   -> Tfmax (kys Clip[ys[4][t]] 
                               + Sin[(2 Pi f4) t + 2 Pi psi4]
                               + bc mySimpleBoundary[q7[t], {-Pi/2, Pi/2}]),
               Tq8   -> Tfmax (kys Clip[ys[5][t]] 
                               + Sin[(2 Pi f5) t + 2 Pi psi5]
                               + bc mySimpleBoundary[q8[t], {-Pi/2, Pi/2}]),
               m     -> 1, s -> 1, kg -> 1
                         };

           {peqns,pvars} = eqnsForFrog["params" -> myPreParams];
           target = {tx,ty};
           sensors = { (* 14 sensors (should length of tail be included?) *)
                       Norm[{u1[#], u2[#]}]/(m/s)&, (* current tranlational speed *)
                       u3[#]/(1/s)&, (* current rotational speed *)
                       Norm[target - {q1[#], q2[#]} ]/m&, (* distance to target *)
                       VectorAngle[  target - {q1[#], q2[#]}, 
                                   {-Sin[q3[#]], Cos[q3[#]]}]&, (* angle to target *)
                       q4[#]/(Pi/2)&, (* tail position *)
                       u4[#]/(1/s)&, (* tail speed *)

                       q5[#]/(Pi/2)&,
                       u5[#]/(1/s)&, 
                       q6[#]/(Pi/2)&,
                       u6[#]/(1/s)&, 
                       q7[#]/(Pi/2)&,
                       u7[#]/(1/s)&, 
                       q8[#]/(Pi/2)&,
                       u8[#]/(1/s)&
                     } //. myPreParams;

           ctrnn  = makeSymbolicCTRNNLinSensor[nodeCount,Length[sensors]];
           ctrnn[[3]] = makeLinSensorInputs[ctrnn, sensors];
           {ceqns, cvars} = eqnsForCTRNN[ctrnn];
           ctrnn[[3]] = {};
           geqns = {lg'[t] == makeDiffLinearPiecewise[tailPoints][t],
                    fg'[t] == makeDiffLinearPiecewise[footPoints][t]};
           gvars = {lg[t], fg[t]};

           reqns = {r[1]'[t] == Norm[target - {q1[t], q2[t]} ],
                    r[2]'[t] == u1[t], 
                    r[3]'[t] == u2[t],
                    r[4]'[t] == Total[Map[Abs[#[t]]&, {u4,u5,u6,u7,u8}]]
                   };
           rvars = {r[1][t], r[2][t], r[3][t], r[4][t]};

           eqns = peqns~Join~ceqns~Join~geqns~Join~reqns /. compilableSubs;
           diff = makeDiffFunc[eqns, 
                               Sow[joinFlat[pvars,cvars,gvars,rvars]],
                               t, 
                               Sow[joinFlat[ctrnn,target,tcons,fcons,physcons, periodLayout]]
                              ];
           diff]
