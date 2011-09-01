 rhseqns = { 0.5*fl*mc*Sin[oq5+q3[t]+q5[t]]*(u3[t]+u5[t])^2 + 0.5*fl*mc*Sin[oq6+q3[t]+q6[t]]*(u3[t]+u6[t])^2 + 0.5*fl*mc*Sin[oq7+q3[t]+q7[t]]*(u3[t]+u7[t])^2 + 0.5*fl*mc*Sin[oq8+q3[t]+q8[t]]*(u3[t]+u8[t])^2 + 0.5*mb*(2*r*Sin[q3[t]]*u3[t]^2+l*Sin[oq4+q3[t]+q4[t]]*(u3[t]+u4[t])^2) + 0.5*kFb*l*(2*u1[t]+2*r*Cos[q3[t]]*u3[t]+l*Cos[oq4+q3[t]+q4[t]]*(u3[t]+u4[t]))*Abs[0.5*l*(u3[t]+u4[t])+Sin[oq4+q3[t]+q4[t]]*u2[t]+Cos[oq4+q3[t]+q4[t]]*u1[t]+r*Cos[oq4+q4[t]]*u3[t]] + 0.5*fl*kFc*(2*u1[t]+1.414214*r*Sin[q3[t]]*u3[t]+1.414214*r*Cos[q3[t]]*u3[t]+fl*Cos[oq8+q3[t]+q8[t]]*(u3[t]+u8[t]))*Abs[0.5*fl*(u3[t]+u8[t])+Sin[oq8+q3[t]+q8[t]]*u2[t]+Cos[oq8+q3[t]+q8[t]]*u1[t]+0.7071068*r*Cos[oq8+q8[t]]*u3[t]-0.7071068*r*Sin[oq8+q8[t]]*u3[t]] - kFa*(wvx-u1[t])*((wvx-u1[t])^2+(wvy-u2[t])^2)^0.5 - 0.5*fl*kFc*(1.414214*r*Sin[q3[t]]*u3[t]-2*u1[t]-1.414214*r*Cos[q3[t]]*u3[t]-fl*Cos[oq5+q3[t]+q5[t]]*(u3[t]+u5[t]))*Abs[0.5*fl*(u3[t]+u5[t])+Sin[oq5+q3[t]+q5[t]]*u2[t]+Cos[oq5+q3[t]+q5[t]]*u1[t]+0.7071068*r*Sin[oq5+q5[t]]*u3[t]+0.7071068*r*Cos[oq5+q5[t]]*u3[t]] - 0.5*fl*kFc*(1.414214*r*Sin[q3[t]]*u3[t]+1.414214*r*Cos[q3[t]]*u3[t]-2*u1[t]-fl*Cos[oq6+q3[t]+q6[t]]*(u3[t]+u6[t]))*Abs[0.5*fl*(u3[t]+u6[t])+Sin[oq6+q3[t]+q6[t]]*u2[t]+Cos[oq6+q3[t]+q6[t]]*u1[t]+0.7071068*r*Sin[oq6+q6[t]]*u3[t]-0.7071068*r*Cos[oq6+q6[t]]*u3[t]] - 0.5*fl*kFc*(1.414214*r*Cos[q3[t]]*u3[t]-2*u1[t]-1.414214*r*Sin[q3[t]]*u3[t]-fl*Cos[oq7+q3[t]+q7[t]]*(u3[t]+u7[t]))*Abs[0.5*fl*(u3[t]+u7[t])+Sin[oq7+q3[t]+q7[t]]*u2[t]+Cos[oq7+q3[t]+q7[t]]*u1[t]-0.7071068*r*Sin[oq7+q7[t]]*u3[t]-0.7071068*r*Cos[oq7+q7[t]]*u3[t]] - (ma+mb+4*mc)*u1'[t] - 0.5*fl*mc*Cos[oq5+q3[t]+q5[t]]*u5'[t] - 0.5*fl*mc*Cos[oq6+q3[t]+q6[t]]*u6'[t] - 0.5*fl*mc*Cos[oq7+q3[t]+q7[t]]*u7'[t] - 0.5*fl*mc*Cos[oq8+q3[t]+q8[t]]*u8'[t] - 0.5*l*mb*Cos[oq4+q3[t]+q4[t]]*u4'[t] - 0.5*(fl*mc*Cos[oq5+q3[t]+q5[t]]+fl*mc*Cos[oq6+q3[t]+q6[t]]+fl*mc*Cos[oq7+q3[t]+q7[t]]+fl*mc*Cos[oq8+q3[t]+q8[t]]+mb*(2*r*Cos[q3[t]]+l*Cos[oq4+q3[t]+q4[t]]))*u3'[t]
, 0.5*kFb*l*(2*u2[t]+2*r*Sin[q3[t]]*u3[t]+l*Sin[oq4+q3[t]+q4[t]]*(u3[t]+u4[t]))*Abs[0.5*l*(u3[t]+u4[t])+Sin[oq4+q3[t]+q4[t]]*u2[t]+Cos[oq4+q3[t]+q4[t]]*u1[t]+r*Cos[oq4+q4[t]]*u3[t]] + 0.5*fl*kFc*(2*u2[t]+1.414214*r*Sin[q3[t]]*u3[t]+1.414214*r*Cos[q3[t]]*u3[t]+fl*Sin[oq5+q3[t]+q5[t]]*(u3[t]+u5[t]))*Abs[0.5*fl*(u3[t]+u5[t])+Sin[oq5+q3[t]+q5[t]]*u2[t]+Cos[oq5+q3[t]+q5[t]]*u1[t]+0.7071068*r*Sin[oq5+q5[t]]*u3[t]+0.7071068*r*Cos[oq5+q5[t]]*u3[t]] - 0.5*fl*mc*Cos[oq5+q3[t]+q5[t]]*(u3[t]+u5[t])^2 - 0.5*fl*mc*Cos[oq6+q3[t]+q6[t]]*(u3[t]+u6[t])^2 - 0.5*fl*mc*Cos[oq7+q3[t]+q7[t]]*(u3[t]+u7[t])^2 - 0.5*fl*mc*Cos[oq8+q3[t]+q8[t]]*(u3[t]+u8[t])^2 - kFa*(wvy-u2[t])*((wvx-u1[t])^2+(wvy-u2[t])^2)^0.5 - 0.5*mb*(2*r*Cos[q3[t]]*u3[t]^2+l*Cos[oq4+q3[t]+q4[t]]*(u3[t]+u4[t])^2) - 0.5*fl*kFc*(1.414214*r*Sin[q3[t]]*u3[t]-2*u2[t]-1.414214*r*Cos[q3[t]]*u3[t]-fl*Sin[oq6+q3[t]+q6[t]]*(u3[t]+u6[t]))*Abs[0.5*fl*(u3[t]+u6[t])+Sin[oq6+q3[t]+q6[t]]*u2[t]+Cos[oq6+q3[t]+q6[t]]*u1[t]+0.7071068*r*Sin[oq6+q6[t]]*u3[t]-0.7071068*r*Cos[oq6+q6[t]]*u3[t]] - 0.5*fl*kFc*(1.414214*r*Sin[q3[t]]*u3[t]+1.414214*r*Cos[q3[t]]*u3[t]-2*u2[t]-fl*Sin[oq7+q3[t]+q7[t]]*(u3[t]+u7[t]))*Abs[0.5*fl*(u3[t]+u7[t])+Sin[oq7+q3[t]+q7[t]]*u2[t]+Cos[oq7+q3[t]+q7[t]]*u1[t]-0.7071068*r*Sin[oq7+q7[t]]*u3[t]-0.7071068*r*Cos[oq7+q7[t]]*u3[t]] - 0.5*fl*kFc*(1.414214*r*Cos[q3[t]]*u3[t]-2*u2[t]-1.414214*r*Sin[q3[t]]*u3[t]-fl*Sin[oq8+q3[t]+q8[t]]*(u3[t]+u8[t]))*Abs[0.5*fl*(u3[t]+u8[t])+Sin[oq8+q3[t]+q8[t]]*u2[t]+Cos[oq8+q3[t]+q8[t]]*u1[t]+0.7071068*r*Cos[oq8+q8[t]]*u3[t]-0.7071068*r*Sin[oq8+q8[t]]*u3[t]] - (ma+mb+4*mc)*u2'[t] - 0.5*fl*mc*Sin[oq5+q3[t]+q5[t]]*u5'[t] - 0.5*fl*mc*Sin[oq6+q3[t]+q6[t]]*u6'[t] - 0.5*fl*mc*Sin[oq7+q3[t]+q7[t]]*u7'[t] - 0.5*fl*mc*Sin[oq8+q3[t]+q8[t]]*u8'[t] - 0.5*l*mb*Sin[oq4+q3[t]+q4[t]]*u4'[t] - 0.5*(fl*mc*Sin[oq5+q3[t]+q5[t]]+fl*mc*Sin[oq6+q3[t]+q6[t]]+fl*mc*Sin[oq7+q3[t]+q7[t]]+fl*mc*Sin[oq8+q3[t]+q8[t]]+mb*(2*r*Sin[q3[t]]+l*Sin[oq4+q3[t]+q4[t]]))*u3'[t]
, kTa*u3[t]*Abs[u3[t]] + kTb*u4[t]*Abs[u4[t]] + kTc*u5[t]*Abs[u5[t]] + kTc*u6[t]*Abs[u6[t]] + kTc*u7[t]*Abs[u7[t]] + kTc*u8[t]*Abs[u8[t]] + 0.25*kFb*l*Abs[0.5*l*(u3[t]+u4[t])+Sin[oq4+q3[t]+q4[t]]*u2[t]+Cos[oq4+q3[t]+q4[t]]*u1[t]+r*Cos[oq4+q4[t]]*u3[t]]*(4*r^2*u3[t]+l^2*(u3[t]+u4[t])+4*r*Sin[q3[t]]*u2[t]+4*r*Cos[q3[t]]*u1[t]+2*l*Sin[oq4+q3[t]+q4[t]]*u2[t]+2*l*Cos[oq4+q3[t]+q4[t]]*u1[t]+2*l*r*Cos[oq4+q4[t]]*u4[t]+4*l*r*Cos[oq4+q4[t]]*u3[t]) + 0.25*fl*kFc*Abs[0.5*fl*(u3[t]+u6[t])+Sin[oq6+q3[t]+q6[t]]*u2[t]+Cos[oq6+q3[t]+q6[t]]*u1[t]+0.7071068*r*Sin[oq6+q6[t]]*u3[t]-0.7071068*r*Cos[oq6+q6[t]]*u3[t]]*(4*r^2*u3[t]+fl^2*(u3[t]+u6[t])+2.828427*r*Cos[q3[t]]*u2[t]+1.414214*fl*r*Sin[oq6+q6[t]]*u6[t]+2*fl*Sin[oq6+q3[t]+q6[t]]*u2[t]+2*fl*Cos[oq6+q3[t]+q6[t]]*u1[t]+2.828427*fl*r*Sin[oq6+q6[t]]*u3[t]-2.828427*r*Sin[q3[t]]*u1[t]-2.828427*r*Sin[q3[t]]*u2[t]-2.828427*r*Cos[q3[t]]*u1[t]-2.828427*fl*r*Cos[oq6+q6[t]]*u3[t]-1.414214*fl*r*Cos[oq6+q6[t]]*u6[t]) + 0.25*fl*kFc*Abs[0.5*fl*(u3[t]+u7[t])+Sin[oq7+q3[t]+q7[t]]*u2[t]+Cos[oq7+q3[t]+q7[t]]*u1[t]-0.7071068*r*Sin[oq7+q7[t]]*u3[t]-0.7071068*r*Cos[oq7+q7[t]]*u3[t]]*(4*r^2*u3[t]+fl^2*(u3[t]+u7[t])+2.828427*r*Sin[q3[t]]*u1[t]+2*fl*Sin[oq7+q3[t]+q7[t]]*u2[t]+2*fl*Cos[oq7+q3[t]+q7[t]]*u1[t]-2.828427*r*Sin[q3[t]]*u2[t]-2.828427*r*Cos[q3[t]]*u1[t]-2.828427*r*Cos[q3[t]]*u2[t]-2.828427*fl*r*Sin[oq7+q7[t]]*u3[t]-2.828427*fl*r*Cos[oq7+q7[t]]*u3[t]-1.414214*fl*r*Sin[oq7+q7[t]]*u7[t]-1.414214*fl*r*Cos[oq7+q7[t]]*u7[t]) + 0.3535534*r*(fl*mc*(Sin[oq6+q6[t]]*u3[t]^2+Cos[oq6+q6[t]]*u3[t]^2-Sin[oq6+q6[t]]*(u3[t]+u6[t])^2-Cos[oq6+q6[t]]*(u3[t]+u6[t])^2)+fl*mc*(Cos[oq5+q5[t]]*u3[t]^2+Sin[oq5+q5[t]]*(u3[t]+u5[t])^2-Sin[oq5+q5[t]]*u3[t]^2-Cos[oq5+q5[t]]*(u3[t]+u5[t])^2)-1.414214*l*mb*Sin[oq4+q4[t]]*(u3[t]^2-(u3[t]+u4[t])^2)-fl*mc*(Sin[oq8+q8[t]]*u3[t]^2+Cos[oq8+q8[t]]*u3[t]^2-Sin[oq8+q8[t]]*(u3[t]+u8[t])^2-Cos[oq8+q8[t]]*(u3[t]+u8[t])^2)-fl*mc*(Cos[oq7+q7[t]]*u3[t]^2+Sin[oq7+q7[t]]*(u3[t]+u7[t])^2-Sin[oq7+q7[t]]*u3[t]^2-Cos[oq7+q7[t]]*(u3[t]+u7[t])^2)) + 0.7071068*(fl*mc*r*(Sin[oq7+q7[t]]+Cos[oq7+q7[t]])+fl*mc*r*(Sin[oq8+q8[t]]-Cos[oq8+q8[t]])-5.656854*Ic-1.414214*Ia-1.414214*Ib-1.414214*mb*r*(r+l*Cos[oq4+q4[t]])-fl*mc*r*(Sin[oq6+q6[t]]-Cos[oq6+q6[t]])-mc*r*(5.656854*r+fl*Sin[oq5+q5[t]]+fl*Cos[oq5+q5[t]]))*u3'[t] - 0.25*fl*kFc*Abs[0.5*fl*(u3[t]+u5[t])+Sin[oq5+q3[t]+q5[t]]*u2[t]+Cos[oq5+q3[t]+q5[t]]*u1[t]+0.7071068*r*Sin[oq5+q5[t]]*u3[t]+0.7071068*r*Cos[oq5+q5[t]]*u3[t]]*(2.828427*r*Sin[q3[t]]*u1[t]-4*r^2*u3[t]-2.828427*r*Sin[q3[t]]*u2[t]-2.828427*r*Cos[q3[t]]*u1[t]-2.828427*r*Cos[q3[t]]*u2[t]-fl^2*(u3[t]+u5[t])-2.828427*fl*r*Sin[oq5+q5[t]]*u3[t]-2.828427*fl*r*Cos[oq5+q5[t]]*u3[t]-2*fl*Sin[oq5+q3[t]+q5[t]]*u2[t]-2*fl*Cos[oq5+q3[t]+q5[t]]*u1[t]-1.414214*fl*r*Sin[oq5+q5[t]]*u5[t]-1.414214*fl*r*Cos[oq5+q5[t]]*u5[t]) - 0.25*fl*kFc*Abs[0.5*fl*(u3[t]+u8[t])+Sin[oq8+q3[t]+q8[t]]*u2[t]+Cos[oq8+q3[t]+q8[t]]*u1[t]+0.7071068*r*Cos[oq8+q8[t]]*u3[t]-0.7071068*r*Sin[oq8+q8[t]]*u3[t]]*(2.828427*r*Cos[q3[t]]*u2[t]+1.414214*fl*r*Sin[oq8+q8[t]]*u8[t]+2.828427*fl*r*Sin[oq8+q8[t]]*u3[t]-4*r^2*u3[t]-2.828427*r*Sin[q3[t]]*u1[t]-2.828427*r*Sin[q3[t]]*u2[t]-2.828427*r*Cos[q3[t]]*u1[t]-fl^2*(u3[t]+u8[t])-2.828427*fl*r*Cos[oq8+q8[t]]*u3[t]-2*fl*Sin[oq8+q3[t]+q8[t]]*u2[t]-2*fl*Cos[oq8+q3[t]+q8[t]]*u1[t]-1.414214*fl*r*Cos[oq8+q8[t]]*u8[t]) - 0.5*(2*Ib+l*mb*r*Cos[oq4+q4[t]])*u4'[t] - 0.3535534*(2.828427*Ic+fl*mc*r*(Sin[oq5+q5[t]]+Cos[oq5+q5[t]]))*u5'[t] - 0.3535534*(2.828427*Ic-fl*mc*r*(Sin[oq7+q7[t]]+Cos[oq7+q7[t]]))*u7'[t] - 0.3535534*(2.828427*Ic+fl*mc*r*(Sin[oq6+q6[t]]-Cos[oq6+q6[t]]))*u6'[t] - 0.3535534*(2.828427*Ic-fl*mc*r*(Sin[oq8+q8[t]]-Cos[oq8+q8[t]]))*u8'[t] - 0.5*(fl*mc*Sin[oq5+q3[t]+q5[t]]+fl*mc*Sin[oq6+q3[t]+q6[t]]+fl*mc*Sin[oq7+q3[t]+q7[t]]+fl*mc*Sin[oq8+q3[t]+q8[t]]+mb*(2*r*Sin[q3[t]]+l*Sin[oq4+q3[t]+q4[t]]))*u2'[t] - 0.5*(fl*mc*Cos[oq5+q3[t]+q5[t]]+fl*mc*Cos[oq6+q3[t]+q6[t]]+fl*mc*Cos[oq7+q3[t]+q7[t]]+fl*mc*Cos[oq8+q3[t]+q8[t]]+mb*(2*r*Cos[q3[t]]+l*Cos[oq4+q3[t]+q4[t]]))*u1'[t]
, Tq4 + kTb*u4[t]*Abs[u4[t]] + 0.25*kFb*l^2*Abs[0.5*l*(u3[t]+u4[t])+Sin[oq4+q3[t]+q4[t]]*u2[t]+Cos[oq4+q3[t]+q4[t]]*u1[t]+r*Cos[oq4+q4[t]]*u3[t]]*(l*(u3[t]+u4[t])+2*Sin[oq4+q3[t]+q4[t]]*u2[t]+2*Cos[oq4+q3[t]+q4[t]]*u1[t]+2*r*Cos[oq4+q4[t]]*u3[t]) - 0.5*l*mb*r*Sin[oq4+q4[t]]*u3[t]^2 - Ib*u4'[t] - 0.5*l*mb*Sin[oq4+q3[t]+q4[t]]*u2'[t] - 0.5*l*mb*Cos[oq4+q3[t]+q4[t]]*u1'[t] - 0.5*(2*Ib+l*mb*r*Cos[oq4+q4[t]])*u3'[t]
, Tq5 + kTc*u5[t]*Abs[u5[t]] + 0.25*kFc*fl^2*Abs[0.5*fl*(u3[t]+u5[t])+Sin[oq5+q3[t]+q5[t]]*u2[t]+Cos[oq5+q3[t]+q5[t]]*u1[t]+0.7071068*r*Sin[oq5+q5[t]]*u3[t]+0.7071068*r*Cos[oq5+q5[t]]*u3[t]]*(fl*(u3[t]+u5[t])+1.414214*r*Sin[oq5+q5[t]]*u3[t]+1.414214*r*Cos[oq5+q5[t]]*u3[t]+2*Sin[oq5+q3[t]+q5[t]]*u2[t]+2*Cos[oq5+q3[t]+q5[t]]*u1[t]) - 0.3535534*fl*mc*r*(Sin[oq5+q5[t]]-Cos[oq5+q5[t]])*u3[t]^2 - Ic*u5'[t] - 0.5*fl*mc*Sin[oq5+q3[t]+q5[t]]*u2'[t] - 0.5*fl*mc*Cos[oq5+q3[t]+q5[t]]*u1'[t] - 0.3535534*(2.828427*Ic+fl*mc*r*(Sin[oq5+q5[t]]+Cos[oq5+q5[t]]))*u3'[t]
, Tq6 + kTc*u6[t]*Abs[u6[t]] + 0.3535534*fl*mc*r*(Sin[oq6+q6[t]]+Cos[oq6+q6[t]])*u3[t]^2 + 0.25*kFc*fl^2*Abs[0.5*fl*(u3[t]+u6[t])+Sin[oq6+q3[t]+q6[t]]*u2[t]+Cos[oq6+q3[t]+q6[t]]*u1[t]+0.7071068*r*Sin[oq6+q6[t]]*u3[t]-0.7071068*r*Cos[oq6+q6[t]]*u3[t]]*(fl*(u3[t]+u6[t])+1.414214*r*Sin[oq6+q6[t]]*u3[t]+2*Sin[oq6+q3[t]+q6[t]]*u2[t]+2*Cos[oq6+q3[t]+q6[t]]*u1[t]-1.414214*r*Cos[oq6+q6[t]]*u3[t]) - Ic*u6'[t] - 0.5*fl*mc*Sin[oq6+q3[t]+q6[t]]*u2'[t] - 0.5*fl*mc*Cos[oq6+q3[t]+q6[t]]*u1'[t] - 0.3535534*(2.828427*Ic+fl*mc*r*(Sin[oq6+q6[t]]-Cos[oq6+q6[t]]))*u3'[t]
, Tq7 + kTc*u7[t]*Abs[u7[t]] + 0.3535534*fl*mc*r*(Sin[oq7+q7[t]]-Cos[oq7+q7[t]])*u3[t]^2 + 0.25*kFc*fl^2*Abs[0.5*fl*(u3[t]+u7[t])+Sin[oq7+q3[t]+q7[t]]*u2[t]+Cos[oq7+q3[t]+q7[t]]*u1[t]-0.7071068*r*Sin[oq7+q7[t]]*u3[t]-0.7071068*r*Cos[oq7+q7[t]]*u3[t]]*(fl*(u3[t]+u7[t])+2*Sin[oq7+q3[t]+q7[t]]*u2[t]+2*Cos[oq7+q3[t]+q7[t]]*u1[t]-1.414214*r*Sin[oq7+q7[t]]*u3[t]-1.414214*r*Cos[oq7+q7[t]]*u3[t]) - Ic*u7'[t] - 0.5*fl*mc*Sin[oq7+q3[t]+q7[t]]*u2'[t] - 0.5*fl*mc*Cos[oq7+q3[t]+q7[t]]*u1'[t] - 0.3535534*(2.828427*Ic-fl*mc*r*(Sin[oq7+q7[t]]+Cos[oq7+q7[t]]))*u3'[t]
, Tq8 + kTc*u8[t]*Abs[u8[t]] - 0.3535534*fl*mc*r*(Sin[oq8+q8[t]]+Cos[oq8+q8[t]])*u3[t]^2 - 0.25*kFc*fl^2*Abs[0.5*fl*(u3[t]+u8[t])+Sin[oq8+q3[t]+q8[t]]*u2[t]+Cos[oq8+q3[t]+q8[t]]*u1[t]+0.7071068*r*Cos[oq8+q8[t]]*u3[t]-0.7071068*r*Sin[oq8+q8[t]]*u3[t]]*(1.414214*r*Sin[oq8+q8[t]]*u3[t]-fl*(u3[t]+u8[t])-2*Sin[oq8+q3[t]+q8[t]]*u2[t]-2*Cos[oq8+q3[t]+q8[t]]*u1[t]-1.414214*r*Cos[oq8+q8[t]]*u3[t]) - Ic*u8'[t] - 0.5*fl*mc*Sin[oq8+q3[t]+q8[t]]*u2'[t] - 0.5*fl*mc*Cos[oq8+q3[t]+q8[t]]*u1'[t] - 0.3535534*(2.828427*Ic-fl*mc*r*(Sin[oq8+q8[t]]-Cos[oq8+q8[t]]))*u3'[t]
};
