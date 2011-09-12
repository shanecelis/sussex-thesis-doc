% frog.al
%
% Mathematical model of a frog in a simulated liquid environment.
%
% Implemented with Autolev

%SetCompatible (AUTOLEV)
autorhs           on
autoz             off
body              a,b,c,d,e,f
                  % central body (a), tail (b), feet clockwise (c---f)
point             o,jb,jc,jd,je,jf,sr,sl
                  % origin and pin joint points for each body
newtonian         n
variables         q1', q2', q3', q4', q5', q6', q7', q8'
motionvariables'  u1', u2', u3', u4', u5', u6', u7', u8'

constants r, l, fl, oq4, oq5, oq6, oq7, oq8, Tq4, Tq5, Tq6, Tq7, Tq8
%         radius, tail length, foot length, offset for q_i, Torque for q_i
%constants ld, fld, rho, Cdcirc, Cdplate, TCdcirc, Acirc, TAcirc
%         tail depth, foot depth, ? coefficients, Area
constants kTa, kTb, kTc, kFa, kFb, kFc, krb, krc, wvx, wvy

% Set mass and moments of inertia.
mass a = ma, b = mb, c = mc, d = mc, e = mc, f = mc
inertia a_ao(n), 0, 0, Ia
inertia b_jb(a), 0, 0, Ib
inertia c_jc(a), 0, 0, Ic
inertia d_jd(a), 0, 0, Ic
inertia e_je(a), 0, 0, Ic
inertia f_jf(a), 0, 0, Ic

% Setup up the Reference Frames (RFs).
simprot(n,a,3,q3)
simprot(a,b,3,q4 + oq4)
simprot(a,c,3,q5 + oq5)
simprot(a,d,3,q6 + oq6)
simprot(a,e,3,q7 + oq7)
simprot(a,f,3,q8 + oq8)

% Set the motion variables.
q1' = u1
q2' = u2
q3' = u3
q4' = u4
q5' = u5
q6' = u6 
q7' = u7
q8' = u8

% Set the positions of the pin joints with respect to body A.
P_o_ao>  = q1 * n1> + q2 * n2>
P_ao_jb> = r * (-a2>)
P_ao_jc> = r * unitvec( a1> - a2>)
P_ao_jd> = r * unitvec( a1> + a2>)
P_ao_je> = r * unitvec(-a1> + a2>)
P_ao_jf> = r * unitvec(-a1> - a2>)
P_ao_sl> = r * (-a1>) 
P_ao_sr> = r * a1>

% Set the positions of the pin joints with respect to the bodies other than A.
P_jb_bo> = -l/2  * b2>
P_jc_co> = -fl/2 * c2>
P_jd_do> = -fl/2 * d2>
P_je_eo> = -fl/2 * e2>
P_jf_fo> = -fl/2 * f2>

% Set the angular velocities to their respective motion variables.
w_a_n> = u3 * a3>
w_b_a> = u4 * a3>
w_c_a> = u5 * a3>
w_d_a> = u6 * a3>
w_e_a> = u7 * a3>
w_f_a> = u8 * a3>

% Fix the pin joints in their respective RFs.
v_jb_a> = 0>
v_jb_b> = 0>
v_jc_a> = 0>
v_jd_a> = 0>
v_je_a> = 0>
v_jf_a> = 0>
v_jc_c> = 0>
v_jd_d> = 0>
v_je_e> = 0>
v_jf_f> = 0>

% Use the 2 point thereom to define velocity of each limb with respect to A.
v2pts(a,b,jb,bo)
v2pts(a,c,jc,co)
v2pts(a,d,jd,do)
v2pts(a,e,je,eo)
v2pts(a,f,jf,fo)

v_ao_n> = dt(p_o_ao>, n)
v2pts(n,a,ao,jb)

% Define the translational velocities.
v_bo_n> = dt(p_o_bo>, n)
v_co_n> = dt(p_o_co>, n)
v_do_n> = dt(p_o_do>, n)
v_eo_n> = dt(p_o_eo>, n)
v_fo_n> = dt(p_o_fo>, n)

% Define the translational accelerations.
a_ao_n> = dt(v_ao_n>, n)
a_bo_n> = dt(v_bo_n>, n)
a_co_n> = dt(v_co_n>, n)
a_do_n> = dt(v_do_n>, n)
a_eo_n> = dt(v_eo_n>, n)
a_fo_n> = dt(v_fo_n>, n)

% The units for torque_a> should be newton-meters (m/s)^2 kg.
% kTa = -rho/2 * TCdcirc * TAcirc
torque_a> = kTa * w_a_n> * mag(w_a_n>)
torque_b> = kTb * w_b_a> * mag(w_b_a>)
torque_c> = kTc * w_c_a> * mag(w_c_a>)
torque_d> = kTc * w_d_a> * mag(w_d_a>)
torque_e> = kTc * w_e_a> * mag(w_e_a>)
torque_f> = kTc * w_f_a> * mag(w_f_a>)
torque(a/b, Tq4 * n3>)
torque(a/c, Tq5 * n3>)
torque(a/d, Tq6 * n3>)
torque(a/e, Tq7 * n3>)
torque(a/f, Tq8 * n3>)

% velocity of the water current
wv> = wvx * n1> + wvy * n2>

% Set the drag force for each body.
% wikipedia drag force
% F_D = \frac{1}{2} \rho v^2 C_d A
% kFa = -rho/2 * Cdcirc  * Acirc 
force_ao> = kFa * (v_ao_n> - wv>) * mag(v_ao_n> - wv>)
krb = 0 
krc = 0
%wv> = 0>
% kFb = -rho/2 * Cdplate * ld 
 force_bo> = kFb * l * (v_bo_n> - wv>) * abs(dot(b1>, (v_bo_n> - wv>)) + krb * SIGN(u4) * mag(v_bo_n>))
%force_bo> = kFb * l * (v_bo_n> - wv>) * abs(dot(b1>, (v_bo_n> - wv>)) + krb * mag(v_bo_n>)) 
% kFc = -rho/2 * Cdplate * fld
force_co> = kFc * fl * (v_co_n> - wv>) * abs(dot(c1>, (v_co_n> - wv>)) + krc * mag(v_co_n>))
force_do> = kFc * fl * (v_do_n> - wv>) * abs(dot(d1>, (v_do_n> - wv>)) + krc * mag(v_do_n>))
force_eo> = kFc * fl * (v_eo_n> - wv>) * abs(dot(e1>, (v_eo_n> - wv>)) + krc * mag(v_eo_n>))
force_fo> = kFc * fl * (v_fo_n> - wv>) * abs(dot(f1>, (v_fo_n> - wv>)) + krc * mag(v_fo_n>))
i_b_bo>> = inertia(bo, b)
i_c_co>> = inertia(co, c)
i_d_do>> = inertia(do, d)
i_e_eo>> = inertia(eo, e)
i_f_fo>> = inertia(fo, f)
%eqns = fr() + frstar()
%eqns
fr() + frstar()
