autorhs on
autoz off
body a,b,c,d,e,f
point o,q, jc, jd, je, jf
% points p -> ao, r -> bo
newtonian n
variables q1', q2', q3', q4', q5', q6', q7', q8'
motionvariables' u1', u2', u3', u4', u5', u6', u7', u8'
constants l, d, Tq4, rho, Cdcirc, Cdplate, Tq5, Tq6, Tq7, Tq8, fl, ld, fld, Acirc
mass a = ma, b = mb, c = mc, d = mc, e = mc, f = mc
inertia a, 0, 0, Ia
inertia b_q(a), 0, 0, Ib
inertia c_jc(a), 0, 0, Ic
inertia d_jd(a), 0, 0, Ic
inertia e_je(a), 0, 0, Ic
inertia f_jf(a), 0, 0, Ic
simprot(n,a, 3, q3)
simprot(a,b, 3, q4)
simprot(a,c, 3, q5 + pi/4)
simprot(a,d, 3, q6 + 3 * pi/4)
simprot(a,e, 3, q7 + 5 * pi/4)
simprot(a,f, 3, q8 + 7 * pi/4)
q1' = u1
q2' = u2
q3' = u3
q4' = u4
q5' = u5
q6' = u6
q7' = u7
q8' = u8
P_o_ao> = q1 * n1> + q2 * n2>
%P_o_ao> = q1 *(cos(q2)* n1> + sin(q2) * n2>)
P_ao_q> = -d/2 * a2>
P_ao_jc> = d/2 * unitvec(a1> - a2>)
P_ao_jd> = d/2 * unitvec(a1> + a2>)
P_ao_je> = d/2 * unitvec(-a1> + a2>)
P_ao_jf> = d/2 * unitvec(-a1> -a2>)
P_q_bo> = -l/2 * b2>
P_jc_co> = -fl/2 * c2>
P_jd_do> = -fl/2 * d2>
P_je_eo> = -fl/2 * e2>
P_jf_fo> = -fl/2 * f2>
w_a_n> = u3 * a3>
w_b_a> = u4 * a3>
w_c_a> = u5 * a3>
w_d_a> = u6 * a3>
w_e_a> = u7 * a3>
w_f_a> = u8 * a3>
%v_ao_n> = u1 * n1> + u2 * n2>
v_q_a> = 0>
v_q_b> = 0>
v_jc_a> = 0>
v_jd_a> = 0>
v_je_a> = 0>
v_jf_a> = 0>
v_jc_c> = 0>
v_jd_d> = 0>
v_je_e> = 0>
v_jf_f> = 0>
v2pts(a,b,q,bo)
v2pts(a,c,jc,co)
v2pts(a,d,jd,do)
v2pts(a,e,je,eo)
v2pts(a,f,jf,fo)
alf_a_n> = u3' * a3>
alf_b_a> = u4' * a3>
v_ao_n> = dt(p_o_ao>, n)
v2pts(n,a,ao,q)

v_bo_n> = dt(p_o_bo>, n)
v_co_n> = dt(p_o_co>, n)
v_do_n> = dt(p_o_do>, n)
v_eo_n> = dt(p_o_eo>, n)
v_fo_n> = dt(p_o_fo>, n)
a_ao_n> = dt(v_ao_n>, n)
a_bo_n> = dt(v_bo_n>, n)
a_co_n> = dt(v_co_n>, n)
a_do_n> = dt(v_do_n>, n)
a_eo_n> = dt(v_eo_n>, n)
a_fo_n> = dt(v_fo_n>, n)
% The units for torque_a> are not correct.  It results in kg/(m s), which is 
% incorrect.  It should be Newton-meters (m/s)^2 kg.
torque_a> = - rho/2 * Cdcirc * mag(w_a_n>) * w_a_n> * pi * 2 * (d/2)^4
torque(a/b, Tq4 * n3>)
torque(a/c, Tq5 * n3>)
torque(a/d, Tq6 * n3>)
torque(a/e, Tq7 * n3>)
torque(a/f, Tq8 * n3>)
vbom = mag(v_bo_n>)
% F_D = \frac{1}{2} \rho v^2 C_d A
% wikipedia
force_ao> = -rho/2 * mag(v_ao_n>) * Cdcirc * v_ao_n> * Acirc
force_bo> = -rho/2 * Cdplate * v_bo_n> * abs(dot(l * ld*b1>, v_bo_n>))
force_co> = -rho/2 * Cdplate * v_co_n> * abs(dot(fl*fld*c1>, v_co_n>))
force_do> = -rho/2 * Cdplate * v_do_n> * abs(dot(fl*fld*d1>, v_do_n>))
force_eo> = -rho/2 * Cdplate * v_eo_n> * abs(dot(fl*fld*e1>, v_eo_n>))
force_fo> = -rho/2 * Cdplate * v_fo_n> * abs(dot(fl*fld*f1>, v_fo_n>))
%force_bo> = -rho/2 * dot(v_bo_n>, v_bo_n>) * Cdplate * Unitvec(v_bo_n>) * l
fr() + frstar()
%quit
