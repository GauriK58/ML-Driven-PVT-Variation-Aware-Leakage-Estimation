* 3-bit carry-lookahead adder, transistor level (24 NAND2 + 9 AND2 + 6 OR2 = 186 FETs)
.include "../22nm_HP.pm"
.options gmin=1e-18 abstol=1e-18 reltol=1e-6 vntol=1e-9
.temp 122.891986
.subckt NAND2 a b out vdd
MPA out a vdd vdd pmos W=8.8000e-08 L=2.200e-08
MPB out b vdd vdd pmos W=8.8000e-08 L=2.200e-08
MNB out b x 0 nmos W=8.8000e-08 L=2.200e-08
MNA x a 0 0 nmos W=8.8000e-08 L=2.200e-08
.ends NAND2
.subckt AND2 a b out vdd
MPA n1 a vdd vdd pmos W=8.8000e-08 L=2.200e-08
MPB n1 b vdd vdd pmos W=8.8000e-08 L=2.200e-08
MNB n1 b x 0 nmos W=8.8000e-08 L=2.200e-08
MNA x a 0 0 nmos W=8.8000e-08 L=2.200e-08
MPI out n1 vdd vdd pmos W=8.8000e-08 L=2.200e-08
MNI out n1 0 0 nmos W=4.4000e-08 L=2.200e-08
.ends AND2
.subckt OR2 a b out vdd
MPA y a vdd vdd pmos W=1.7600e-07 L=2.200e-08
MPB n1 b y vdd pmos W=1.7600e-07 L=2.200e-08
MNA n1 a 0 0 nmos W=4.4000e-08 L=2.200e-08
MNB n1 b 0 0 nmos W=4.4000e-08 L=2.200e-08
MPI out n1 vdd vdd pmos W=8.8000e-08 L=2.200e-08
MNI out n1 0 0 nmos W=4.4000e-08 L=2.200e-08
.ends OR2
Vdd vdd 0 0.813162150380
Va0 a0 0 0
Va1 a1 0 0
Va2 a2 0 0
Vb0 b0 0 0
Vb1 b1 0 0
Vb2 b2 0 0
Vcin cin 0 0
X1 a0 b0 g0 vdd AND2
X2 a0 b0 xp0_1 vdd NAND2
X3 a0 xp0_1 xp0_2 vdd NAND2
X4 b0 xp0_1 xp0_3 vdd NAND2
X5 xp0_2 xp0_3 p0 vdd NAND2
X6 a1 b1 g1 vdd AND2
X7 a1 b1 xp1_1 vdd NAND2
X8 a1 xp1_1 xp1_2 vdd NAND2
X9 b1 xp1_1 xp1_3 vdd NAND2
X10 xp1_2 xp1_3 p1 vdd NAND2
X11 a2 b2 g2 vdd AND2
X12 a2 b2 xp2_1 vdd NAND2
X13 a2 xp2_1 xp2_2 vdd NAND2
X14 b2 xp2_1 xp2_3 vdd NAND2
X15 xp2_2 xp2_3 p2 vdd NAND2
X16 p0 cin t0 vdd AND2
X17 g0 t0 c1 vdd OR2
X18 p1 g0 t1 vdd AND2
X19 p1 t0 t2 vdd AND2
X20 t1 t2 u1 vdd OR2
X21 g1 u1 c2 vdd OR2
X22 p2 g1 t3 vdd AND2
X23 p2 t1 t4 vdd AND2
X24 p2 t2 t5 vdd AND2
X25 t3 t4 u2 vdd OR2
X26 u2 t5 u3 vdd OR2
X27 g2 u3 c3 vdd OR2
X28 p0 cin xs0_1 vdd NAND2
X29 p0 xs0_1 xs0_2 vdd NAND2
X30 cin xs0_1 xs0_3 vdd NAND2
X31 xs0_2 xs0_3 s0 vdd NAND2
X32 p1 c1 xs1_1 vdd NAND2
X33 p1 xs1_1 xs1_2 vdd NAND2
X34 c1 xs1_1 xs1_3 vdd NAND2
X35 xs1_2 xs1_3 s1 vdd NAND2
X36 p2 c2 xs2_1 vdd NAND2
X37 p2 xs2_1 xs2_2 vdd NAND2
X38 c2 xs2_1 xs2_3 vdd NAND2
X39 xs2_2 xs2_3 s2 vdd NAND2
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
alter Vdd dc=0.813162150380
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.000000000000
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.000000000000
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.000000000000
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.000000000000
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.000000000000
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.000000000000
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.000000000000
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
alter Va0 dc=0.813162150380
alter Va1 dc=0.813162150380
alter Va2 dc=0.813162150380
alter Vb0 dc=0.813162150380
alter Vb1 dc=0.813162150380
alter Vb2 dc=0.813162150380
alter Vcin dc=0.813162150380
op
print i(Vdd) i(Va0) i(Va1) i(Va2) i(Vb0) i(Vb1) i(Vb2) i(Vcin) v(s0) v(s1) v(s2) v(c3)
destroy all
.endc
.end
