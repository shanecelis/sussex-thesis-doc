% frog.al
%
% Mathematical model of a frog in a simulated liquid environment.
%
% Implemented with Autolev

autorhs   on
autoz     off
body      a,b,c,d,e,f 
          % central body (a), tail (b), feet clockwise (c---f)
point     o,jb,jc,jd,je,jf 
          % origin and pin joint points for each body
newtonian n
variables        q1', q2', q3', q4', q5', q6', q7', q8'
motionvariables' u1', u2', u3', u4', u5', u6', u7', u8'

constants l, fl, ld, fld, r, rho, Cdcirc, Cdplate, TCdcirc
constants Tq4, Tq5, Tq6, Tq7, Tq8, Acirc, TAcirc, oq4, oq5, oq6, oq7, oq8

% Set mass and moments of inertia.
mass a = ma, b = mb, c = mc, d = mc, e = mc, f = mc
inertia a,       0, 0, Ia
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

% Define the translational acceleration.
a_ao_n> = dt(v_ao_n>, n)
a_bo_n> = dt(v_bo_n>, n)
a_co_n> = dt(v_co_n>, n)
a_do_n> = dt(v_do_n>, n)
a_eo_n> = dt(v_eo_n>, n)
a_fo_n> = dt(v_fo_n>, n)

% The units for torque_a> should be newton-meters (m/s)^2 kg.
torque_a> = -rho/2 * TCdcirc * w_a_n> * TAcirc * mag(w_a_n>)
torque(a/b, Tq4 * n3>)
torque(a/c, Tq5 * n3>)
torque(a/d, Tq6 * n3>)
torque(a/e, Tq7 * n3>)
torque(a/f, Tq8 * n3>)

% Set the drag force for each body.
% wikipedia drag force
% F_D = \frac{1}{2} \rho v^2 C_d A
force_ao> = -rho/2 * Cdcirc  * v_ao_n> * Acirc * mag(v_ao_n>)
force_bo> = -rho/2 * Cdplate * v_bo_n> * abs(dot(l * ld*b1>, v_bo_n>))
force_co> = -rho/2 * Cdplate * v_co_n> * abs(dot(fl*fld*c1>, v_co_n>))
force_do> = -rho/2 * Cdplate * v_do_n> * abs(dot(fl*fld*d1>, v_do_n>))
force_eo> = -rho/2 * Cdplate * v_eo_n> * abs(dot(fl*fld*e1>, v_eo_n>))
force_fo> = -rho/2 * Cdplate * v_fo_n> * abs(dot(fl*fld*f1>, v_fo_n>))
fr() + frstar()
