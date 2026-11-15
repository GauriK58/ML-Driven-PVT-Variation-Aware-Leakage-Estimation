"""
Part C test circuit: 3-bit carry-lookahead adder (CLA), built only from the Part B gates.

    Gi = Ai.Bi            Pi = Ai xor Bi           Si = Pi xor Ci      (C0 = Cin)
    C1 = G0 + P0.C0
    C2 = G1 + P1.G0 + P1.P0.C0
    C3 = G2 + P2.G1 + P2.P1.G0 + P2.P1.P0.C0

Each XOR is four NAND2; multi-input AND/OR terms are trees of AND2/OR2 with shared
sub-terms. Total: 24 NAND2 + 9 AND2 + 6 OR2 = 39 gates, 186 transistors.
Inputs: a0 a1 a2 b0 b1 b2 cin (7 -> 128 input vectors). Outputs: s0 s1 s2 c3.
"""
import re, subprocess, tempfile
from itertools import product
from pathlib import Path
import numpy as np, pandas as pd
from config import *
from gates import GATES

INPUTS = ["a0", "a1", "a2", "b0", "b1", "b2", "cin"]
OUTPUTS = ["s0", "s1", "s2", "c3"]


def build():
    """Returns the gate list: (instance name, gate type, output net, input a, input b)."""
    G = []
    def add(typ, out, a, b):
        G.append((f"X{len(G) + 1}", typ, out, a, b))
    def xor(out, a, b, tag):
        add("NAND2", f"{tag}_1", a, b)
        add("NAND2", f"{tag}_2", a, f"{tag}_1")
        add("NAND2", f"{tag}_3", b, f"{tag}_1")
        add("NAND2", out, f"{tag}_2", f"{tag}_3")
    for i in range(3):
        add("AND2", f"g{i}", f"a{i}", f"b{i}")
        xor(f"p{i}", f"a{i}", f"b{i}", f"xp{i}")
    add("AND2", "t0", "p0", "cin");  add("OR2", "c1", "g0", "t0")
    add("AND2", "t1", "p1", "g0");   add("AND2", "t2", "p1", "t0")
    add("OR2", "u1", "t1", "t2");    add("OR2", "c2", "g1", "u1")
    add("AND2", "t3", "p2", "g1");   add("AND2", "t4", "p2", "t1");  add("AND2", "t5", "p2", "t2")
    add("OR2", "u2", "t3", "t4");    add("OR2", "u3", "u2", "t5");   add("OR2", "c3", "g2", "u3")
    for i, c in enumerate(["cin", "c1", "c2"]):
        xor(f"s{i}", f"p{i}", c, f"xs{i}")
    return G

CLA = build()
VECTORS = ["".join(v) for v in product("01", repeat=len(INPUTS))]      # order: a0 a1 a2 b0 b1 b2 cin
_FN = {"NAND2": lambda a, b: 1 - (a & b), "AND2": lambda a, b: a & b, "OR2": lambda a, b: a | b}


def simulate_logic(vec):
    """Logic value of every net for one input vector, and each gate's input combination."""
    net = {n: int(b) for n, b in zip(INPUTS, vec)}
    combos = []
    for name, typ, out, a, b in CLA:
        net[out] = _FN[typ](net[a], net[b])
        combos.append((typ, f"{net[a]}{net[b]}"))
    return net, combos


# ---------------------------------------------------------------- SPICE
def _subckt(typ):
    L = [f".subckt {typ} a b out vdd"]
    L += [f"{n} {d} {g} {s} {b} {t} W={w:.4e} L={LMIN:.3e}" for n, t, d, g, s, b, w in GATES[typ]["fets"]]
    return L + [f".ends {typ}"]


def deck(corners, vectors=VECTORS, model_path=MODEL_FILE):
    c0 = corners.iloc[0]
    L = ["* 3-bit carry-lookahead adder, transistor level (24 NAND2 + 9 AND2 + 6 OR2 = 186 FETs)",
         f'.include "{model_path}"', SPICE_OPTIONS, f".temp {c0.temp:.6f}"]
    for t in ("NAND2", "AND2", "OR2"):
        L += _subckt(t)
    L += [f"Vdd vdd 0 {c0.vdd:.12f}"] + [f"V{i} {i} 0 0" for i in INPUTS]
    L += [f"{name} {a} {b} {out} vdd {typ}" for name, typ, out, a, b in CLA]
    probes = " ".join(["i(Vdd)"] + [f"i(V{i})" for i in INPUTS] + [f"v({o})" for o in OUTPUTS])
    L += [".control", "set numdgt=12"]
    for c in corners.itertuples():
        L += [f"altermod nmos {p}={getattr(c, 'n_' + p):.10e}" for p in PROC]
        L += [f"altermod pmos {p}={getattr(c, 'p_' + p):.10e}" for p in PROC]
        L += [f"option temp={c.temp:.6f}", f"alter Vdd dc={c.vdd:.12f}"]
        for vec in vectors:
            L += [f"alter V{i} dc={c.vdd * int(bit):.12f}" for i, bit in zip(INPUTS, vec)]
            L += ["op", f"print {probes}", "destroy all"]
    return "\n".join(L + [".endc", ".end", ""])


_NUM = re.compile(r"^(?:i\(v\w+\)|v\(\w+\))\s*=\s*(\S+)", re.M)


def run_spice(corners, vectors=VECTORS):
    cols = ["i_vdd"] + [f"i_{i}" for i in INPUTS] + [f"v_{o}" for o in OUTPUTS]
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "deck.sp"
        f.write_text(deck(corners, vectors))
        res = subprocess.run(["ngspice", "-b", str(f)], capture_output=True, text=True)
    vals = np.array(_NUM.findall(res.stdout), dtype=float)
    if vals.size != len(corners) * len(vectors) * len(cols):
        raise RuntimeError(f"CLA: SPICE output incomplete\n{res.stdout[-1500:]}{res.stderr[-1500:]}")
    df = pd.DataFrame(vals.reshape(-1, len(cols)), columns=cols)
    df.insert(0, "inputs", np.tile(vectors, len(corners)))
    df.insert(0, "corner", np.repeat(corners.corner.values, len(vectors)))
    df["leak_spice_vddpin"] = -df.i_vdd
    df["leak_spice"] = -df.i_vdd
    for k, i in enumerate(INPUTS):
        high = df.inputs.str[k] == "1"
        df.loc[high, "leak_spice"] -= df.loc[high, f"i_{i}"]
    return df.drop(columns=["i_vdd"] + [f"i_{i}" for i in INPUTS])
