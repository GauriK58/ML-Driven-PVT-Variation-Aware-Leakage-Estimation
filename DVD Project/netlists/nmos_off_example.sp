* nmos_off example (dataset row 0): single NMOS, every terminal on its own source
.include "../22nm_HP.pm"
.options gmin=1e-18 abstol=1e-18 reltol=1e-6 vntol=1e-9
.temp -3.837554
Vd d 0 0.091924859915
Vg g 0 0.000000000000
Vs s 0 0.780526713019
Vb b 0 0.000000000000
M1 d g s b nmos W=1.0691886503e-07 L=2.200e-08
.control
set numdgt=12
alter Vd dc=0.091924859915
alter Vg dc=0.000000000000
alter Vs dc=0.780526713019
alter Vb dc=0.000000000000
alter M1 w=1.0691886503e-07
altermod nmos vth0=5.1391694702e-01
altermod nmos toxe=1.0465260637e-09
altermod nmos ndep=5.1221306049e+18
altermod nmos u0=4.0993295493e-02
altermod nmos xj=7.6017315975e-09
option temp=-3.837554
op
print i(Vd) i(Vg) i(Vs) i(Vb)
print @m1[igs] @m1[igd] @m1[igcs] @m1[igcd] @m1[igb]
.endc
.end
