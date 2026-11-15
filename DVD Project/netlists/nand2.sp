* NAND2: static CMOS, leakage at every input combination
.include "../22nm_HP.pm"
.options gmin=1e-18 abstol=1e-18 reltol=1e-6 vntol=1e-9
.temp 122.891986
Vdd vdd 0 0.813162150376
Va a 0 0
Vb b 0 0
MPA out a vdd vdd pmos W=8.8000e-08 L=2.200e-08
MPB out b vdd vdd pmos W=8.8000e-08 L=2.200e-08
MNB out b x 0 nmos W=8.8000e-08 L=2.200e-08
MNA x a 0 0 nmos W=8.8000e-08 L=2.200e-08
.control
set numdgt=12
altermod nmos vth0=5.2370282453e-01
altermod nmos toxe=1.0517050762e-09
altermod nmos ndep=5.1334005185e+18
altermod nmos u0=4.3274811161e-02
altermod nmos xj=7.1285181138e-09
altermod pmos vth0=-4.9123706062e-01
altermod pmos toxe=9.9049929101e-10
altermod pmos ndep=4.5296708008e+18
altermod pmos u0=9.9892623017e-03
altermod pmos xj=6.9202843889e-09
option temp=122.891986
alter Vdd dc=0.813162150376
alter Va dc=0.000000000000
alter Vb dc=0.000000000000
op
print i(Vdd) i(Va) i(Vb) v(out) v(x)
alter Va dc=0.000000000000
alter Vb dc=0.813162150376
op
print i(Vdd) i(Va) i(Vb) v(out) v(x)
alter Va dc=0.813162150376
alter Vb dc=0.000000000000
op
print i(Vdd) i(Va) i(Vb) v(out) v(x)
alter Va dc=0.813162150376
alter Vb dc=0.813162150376
op
print i(Vdd) i(Va) i(Vb) v(out) v(x)
.endc
.end
