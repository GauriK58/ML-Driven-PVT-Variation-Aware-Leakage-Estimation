* nmos_on example (dataset row 0): single NMOS, every terminal on its own source
.include "../22nm_HP.pm"
.options gmin=1e-18 abstol=1e-18 reltol=1e-6 vntol=1e-9
.temp 117.628980
Vd d 0 0.774451114467
Vg g 0 0.975013948360
Vs s 0 0.423015525906
Vb b 0 0.000000000000
M1 d g s b nmos W=1.3822921228e-07 L=2.200e-08
.control
set numdgt=12
alter Vd dc=0.774451114467
alter Vg dc=0.975013948360
alter Vs dc=0.423015525906
alter Vb dc=0.000000000000
alter M1 w=1.3822921228e-07
altermod nmos vth0=5.1134876360e-01
altermod nmos toxe=9.7024360260e-10
altermod nmos ndep=5.9137394857e+18
altermod nmos u0=3.7829897775e-02
altermod nmos xj=6.5736494223e-09
option temp=117.628980
op
print i(Vd) i(Vg) i(Vs) i(Vb)
print @m1[igs] @m1[igd] @m1[igcs] @m1[igcd] @m1[igb]
.endc
.end
