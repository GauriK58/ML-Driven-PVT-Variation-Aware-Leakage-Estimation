* pmos_off example (dataset row 0): single PMOS, every terminal on its own source
.include "../22nm_HP.pm"
.options gmin=1e-18 abstol=1e-18 reltol=1e-6 vntol=1e-9
.temp 100.546619
Vd d 0 0.367949716424
Vg g 0 0.947507916177
Vs s 0 0.805569318436
Vb b 0 0.947507916177
M1 d g s b pmos W=6.1506887636e-08 L=2.200e-08
.control
set numdgt=12
alter Vd dc=0.367949716424
alter Vg dc=0.947507916177
alter Vs dc=0.805569318436
alter Vb dc=0.947507916177
alter M1 w=6.1506887636e-08
altermod pmos vth0=-4.2066384015e-01
altermod pmos toxe=1.0533753539e-09
altermod pmos ndep=4.5103389612e+18
altermod pmos u0=9.1258295415e-03
altermod pmos xj=7.4356633857e-09
option temp=100.546619
op
print i(Vd) i(Vg) i(Vs) i(Vb)
print @m1[igs] @m1[igd] @m1[igcs] @m1[igcd] @m1[igb]
.endc
.end
