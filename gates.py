"""
Gate definitions, SPICE reference and ML leakage for Part B (reused by Part C).

Leakage definition (same in SPICE and ML)
    leakage = current delivered by every source that sits at VDD
            = I(VDD supply) + sum of I(input source) over the inputs held at 1
    Inputs at 0 only sink current that has already been counted.

ML evaluation
    Each transistor gets its terminal voltages from the SPICE-recorded node
    voltages and is evaluated with the ON or OFF model according to its gate.
    The leakage is the current crossing a cut between the "high" nodes (VDD,
    inputs at 1, every node tied to VDD through ON transistors) and the rest.
    For an ON transistor only Ig and Ib are taken from the model: its drain and
    source lie on the same side of the cut and Id+Is = -(Ig+Ib) by device KCL, so
    its channel current (set by microvolts of Vds) is never asked from the model.
    For an OFF transistor the terminal currents used are chosen per transistor
    from the Part A reliability ranking - see ml_leakage().
"""
import re, subprocess, tempfile
from itertools import product
from pathlib import Path
import joblib, numpy as np, pandas as pd
from config import *

# name, type, drain, gate, source, body, width
_INV = lambda i, o, tag="": [(f"MP{tag}", "pmos", o, i, "vdd", "vdd", WP),
                             (f"MN{tag}", "nmos", o, i, "0", "0", WN)]
_NAND = lambda o: [("MPA", "pmos", o, "a", "vdd", "vdd", WP),
                   ("MPB", "pmos", o, "b", "vdd", "vdd", WP),
                   ("MNB", "nmos", o, "b", "x", "0", 2 * WN),      # top of the stack
                   ("MNA", "nmos", "x", "a", "0", "0", 2 * WN)]    # bottom of the stack
_NOR = lambda o: [("MPA", "pmos", "y", "a", "vdd", "vdd", 2 * WP),  # top of the stack
                  ("MPB", "pmos", o, "b", "y", "vdd", 2 * WP),      # bottom of the stack
                  ("MNA", "nmos", o, "a", "0", "0", WN),
                  ("MNB", "nmos", o, "b", "0", "0", WN)]

GATES = {
    "INV":   dict(inputs=["a"],      internal=[],          fets=_INV("a", "out")),
    "NAND2": dict(inputs=["a", "b"], internal=["x"],       fets=_NAND("out")),
    "NOR2":  dict(inputs=["a", "b"], internal=["y"],       fets=_NOR("out")),
    "AND2":  dict(inputs=["a", "b"], internal=["x", "n1"], fets=_NAND("n1") + _INV("n1", "out", "I")),
    "OR2":   dict(inputs=["a", "b"], internal=["y", "n1"], fets=_NOR("n1") + _INV("n1", "out", "I")),
}
STACK_NODES = ("x", "y")            # nodes whose voltage is also solved with the ML models


def combos(gate):
    return ["".join(c) for c in product("01", repeat=len(GATES[gate]["inputs"]))]


# ---------------------------------------------------------------- corners
def draw_corners(n=N_CORNERS):
    """One corner = VDD, temperature, one process draw for all NMOS, one for all PMOS."""
    rng = np.random.default_rng(np.random.SeedSequence(SEED).spawn(5)[4])  # children 0-3: Part A
    c = pd.DataFrame({"corner": np.arange(n),
                      "vdd": rng.uniform(VDD_NOM * (1 - VDD_TOL), VDD_NOM * (1 + VDD_TOL), n),
                      "temp": rng.uniform(*T_RANGE, n)})
    for dev in ("nmos", "pmos"):
        for p in PROC:
            c[f"{dev[0]}_{p}"] = NOMINAL[dev][p] * rng.uniform(1 - P_TOL, 1 + P_TOL, n)
    return c


# ---------------------------------------------------------------- SPICE
def deck(gate, corners, model_path=MODEL_FILE):
    g = GATES[gate]
    c0 = corners.iloc[0]
    L = [f"* {gate}: static CMOS, leakage at every input combination",
         f'.include "{model_path}"', SPICE_OPTIONS, f".temp {c0.temp:.6f}",
         f"Vdd vdd 0 {c0.vdd:.12f}"]
    L += [f"V{i} {i} 0 0" for i in g["inputs"]]
    L += [f"{n} {d} {gt} {s} {b} {typ} W={w:.4e} L={LMIN:.3e}" for n, typ, d, gt, s, b, w in g["fets"]]
    probes = " ".join(["i(Vdd)"] + [f"i(V{i})" for i in g["inputs"]]
                      + ["v(out)"] + [f"v({n})" for n in g["internal"]])
    L += [".control", "set numdgt=12"]
    for c in corners.itertuples():
        L += [f"altermod nmos {p}={getattr(c, 'n_' + p):.10e}" for p in PROC]
        L += [f"altermod pmos {p}={getattr(c, 'p_' + p):.10e}" for p in PROC]
        L += [f"option temp={c.temp:.6f}", f"alter Vdd dc={c.vdd:.12f}"]
        for cb in combos(gate):
            L += [f"alter V{i} dc={c.vdd * int(bit):.12f}" for i, bit in zip(g["inputs"], cb)]
            L += ["op", f"print {probes}"]
    return "\n".join(L + [".endc", ".end", ""])


_NUM = re.compile(r"^(?:i\(v\w+\)|v\(\w+\))\s*=\s*(\S+)", re.M)


def run_spice(gate, corners):
    """Returns a long DataFrame: one row per (corner, input combination)."""
    g = GATES[gate]
    cols = ["i_vdd"] + [f"i_{i}" for i in g["inputs"]] + ["v_out"] + [f"v_{n}" for n in g["internal"]]
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "deck.sp"
        f.write_text(deck(gate, corners))
        res = subprocess.run(["ngspice", "-b", str(f)], capture_output=True, text=True)
    vals = np.array(_NUM.findall(res.stdout), dtype=float)
    cbs = combos(gate)
    if vals.size != len(corners) * len(cbs) * len(cols):
        raise RuntimeError(f"{gate}: SPICE output incomplete\n{res.stdout[-1500:]}{res.stderr[-1500:]}")
    df = pd.DataFrame(vals.reshape(-1, len(cols)), columns=cols)
    df.insert(0, "inputs", np.tile(cbs, len(corners)))
    df.insert(0, "corner", np.repeat(corners.corner.values, len(cbs)))
    df.insert(0, "gate", gate)
    # current delivered by a source = -i(V)
    df["leak_spice_vddpin"] = -df.i_vdd
    df["leak_spice"] = -df.i_vdd
    for k, i in enumerate(g["inputs"]):
        high = df.inputs.str[k] == "1"
        df.loc[high, "leak_spice"] -= df.loc[high, f"i_{i}"]
    return df.drop(columns=["i_vdd"] + [f"i_{i}" for i in g["inputs"]])


# ---------------------------------------------------------------- ML
_models = {}
def model(case):
    if case not in _models:
        _models[case] = joblib.load(MODEL_DIR / f"{case}.joblib")
    return _models[case]


def _fet_currents(typ, on, w, vd, vs, corners):
    """ML terminal currents (into the device) of one transistor at all corners."""
    df = pd.DataFrame({"vdd": corners.vdd.values, "temp": corners.temp.values, "w": w,
                       "vd": vd, "vs": vs})
    for p in PROC:
        df[p] = corners[f"{typ[0]}_{p}"].values
    return model(f"{typ}_{'on' if on else 'off'}").predict(df)


def _structure(gate, logic):
    """ON/OFF state of each transistor and the set of 'high' nodes for one input state.
    logic: dict node -> 0/1 for vdd, 0, inputs and gate-driving internal nodes."""
    fets = GATES[gate]["fets"]
    on = {n: (logic[gt] == 1) if typ == "nmos" else (logic[gt] == 0)
          for n, typ, d, gt, s, b, w in fets}
    parent = {}
    def find(a):
        parent.setdefault(a, a)
        while parent[a] != a:
            a = parent[a]
        return a
    for n, typ, d, gt, s, b, w in fets:
        find(d); find(s)
        if on[n]:
            parent[find(d)] = find(s)
    nodes = set(parent) | {"vdd", "0"} | set(GATES[gate]["inputs"])
    high = {n for n in nodes if find(n) == find("vdd")}
    low = {n for n in nodes if find(n) == find("0")}
    for i in GATES[gate]["inputs"]:
        (high if logic[i] else low).add(i)
    return on, high, low


def ml_leakage(gate, cb, corners, volt):
    """volt: dict node -> array of node voltages (one per corner) for 'out' and internal nodes.
    Returns (leak, leak_high, leak_low):
      leak_high  total counted where current leaves the high side
      leak_low   total counted where current arrives at the low side
      leak       per-transistor choice between the two (see below) - the reported ML leakage

    Every node is on the high or the low side of the cut (nodes not tied to a rail through
    ON transistors are put on the low side). For one transistor, device KCL says the current
    it takes from high-side nodes equals the current it hands to low-side nodes, so either
    set of terminal currents can be used. The choice follows the Part A test-set ranking
    (results/part_a_terminal_reliability.csv):  Ig, Ib  >  single-signed channel current
    >  the other channel current.
      ON  transistor              : Ig and Ib only (as before)
      OFF, drain & source same side: use the side holding only gate/body terminals
      OFF, drain & source split   : NMOS -> high-side terminals (its higher-V terminal
                                     carries the single-signed current)
                                     PMOS -> low-side terminals (its lower-V terminal does)
    """
    g = GATES[gate]
    vdd = corners.vdd.values
    V = {"vdd": vdd, "0": np.zeros_like(vdd), **volt}
    logic = {"vdd": 1, "0": 0}
    for i, bit in zip(g["inputs"], cb):
        V[i] = vdd * int(bit); logic[i] = int(bit)
    for n in ["out"] + g["internal"]:
        lv = V[n] > vdd / 2
        if n not in STACK_NODES:
            assert lv.all() or (~lv).all(), f"{gate} {cb}: node {n} is not a clean logic level"
        logic[n] = int(np.median(lv))
    on, high, low = _structure(gate, logic)
    is_high = lambda node: node in high            # everything else counts as low side
    leak, hi_sum, lo_sum = (np.zeros_like(vdd) for _ in range(3))
    for n, typ, d, gt, s, b, w in g["fets"]:
        I = _fet_currents(typ, on[n], w, V[d], V[s], corners)
        if on[n]:
            terms = [(gt, I["ig"].values), (b, I["ib"].values), (d, -(I["ig"] + I["ib"]).values)]
        else:
            terms = [(d, I["id"].values), (gt, I["ig"].values), (s, I["is"].values), (b, I["ib"].values)]
        from_high = sum(cur for node, cur in terms if is_high(node)) + np.zeros_like(vdd)
        to_low = -sum(cur for node, cur in terms if not is_high(node)) + np.zeros_like(vdd)
        hi_sum += from_high
        lo_sum += to_low
        if on[n]:
            leak += from_high                      # identical to to_low by construction
        elif is_high(d) == is_high(s):
            leak += to_low if is_high(d) else from_high
        else:
            leak += from_high if typ == "nmos" else to_low
    return leak, hi_sum, lo_sum


def ml_node_voltage(gate, cb, node, corners, volt, iters=45):
    """Solve KCL at `node` with the ML models (all other nodes at their SPICE voltage):
    find V in [0, VDD] where the currents drawn from the node by the attached transistors
    sum to zero. Vectorised bisection over all corners."""
    g = GATES[gate]
    vdd = corners.vdd.values
    base = {"vdd": vdd, "0": np.zeros_like(vdd), **volt}
    logic = {"vdd": 1, "0": 0}
    for i, bit in zip(g["inputs"], cb):
        base[i] = vdd * int(bit); logic[i] = int(bit)
    for n in g["internal"]:
        if n not in STACK_NODES:
            logic[n] = int(np.median(base[n] > vdd / 2))
    att = [f for f in g["fets"] if node in (f[2], f[4])]

    def f(v):
        V = {**base, node: v}
        tot = np.zeros_like(vdd)
        for n, typ, d, gt, s, b, w in att:
            on = (logic[gt] == 1) if typ == "nmos" else (logic[gt] == 0)
            I = _fet_currents(typ, on, w, V[d], V[s], corners)
            if d == node: tot += I["id"].values
            if s == node: tot += I["is"].values
        return tot          # current leaving the node into the devices; rises with v

    lo, hi = np.zeros_like(vdd), vdd.copy()
    flo, fhi = f(lo), f(hi)
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        fm = f(mid)
        up = fm < 0
        lo, hi = np.where(up, mid, lo), np.where(up, hi, mid)
    v = 0.5 * (lo + hi)
    v = np.where(flo > 0, 0.0, v)        # no sign change: node is pinned to a rail
    v = np.where(fhi < 0, vdd, v)
    return v
