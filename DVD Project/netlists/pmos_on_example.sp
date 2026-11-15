* pmos_on example (dataset row 0): single PMOS, every terminal on its own source
.include "../22nm_HP.pm"
.options gmin=1e-18 abstol=1e-18 reltol=1e-6 vntol=1e-9
.temp 41.016398
Vd d 0 0.127723228853
Vg g 0 0.000000000000
Vs s 0 0.227643904564
Vb b 0 0.822823056524
M1 d g s b pmos W=1.4806184510e-07 L=2.200e-08
.control
set numdgt=12
alter Vd dc=0.127723228853
alter Vg dc=0.000000000000
alter Vs dc=0.227643904564
alter Vb dc=0.822823056524
alter M1 w=1.4806184510e-07
altermod pmos vth0=-4.3662267190e-01
altermod pmos toxe=1.0010107426e-09
altermod pmos ndep=4.1598469445e+18
altermod pmos u0=8.9712888689e-03
altermod pmos xj=7.8620426049e-09
option temp=41.016398
op
print i(Vd) i(Vg) i(Vs) i(Vb)
print @m1[igs] @m1[igd] @m1[igcs] @m1[igcd] @m1[igb]
.endc
.end
