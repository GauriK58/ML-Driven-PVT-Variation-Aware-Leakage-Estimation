"""
Step 1 - generate the four single-transistor datasets with ngspice.
"""
import re, subprocess, sys, tempfile
from pathlib import Path
import numpy as np, pandas as pd
from config import *

CHUNK = 500
NUM = re.compile(r"^(?:i\(v[dgsb]\)|@m1\[ig\w+\])\s*=\s*(\S+)", re.M)
NOUT = 9          # i(Vd) i(Vg) i(Vs) i(Vb) + 5 gate-current components


def draw_samples(case, n, rng):
    """Independent uniform draws, VDD first (Vd/Vs ranges depend on it)."""
    dev, kg, kb = CASES[case]
    vdd  = rng.uniform(VDD_NOM * (1 - VDD_TOL), VDD_NOM * (1 + VDD_TOL), n)
    temp = rng.uniform(*T_RANGE, n)
    w    = rng.uniform(*W_RANGE, n)
    vd   = rng.uniform(0, 1, n) * vdd
    vs   = rng.uniform(0, 1, n) * vdd
    df = pd.DataFrame(dict(vdd=vdd, temp=temp, w=w, vd=vd, vs=vs,
                           vg=kg * vdd, vb=kb * vdd))
    for p in PROC:                       # nominal +/-10 % (works for negative vth0 too)
        df[p] = NOMINAL[dev][p] * rng.uniform(1 - P_TOL, 1 + P_TOL, n)
    return df


def draw_edge_samples(case, n, rng):
    """Extra samples at the edges of the range, where transistors inside gates operate."""
    dev, kg, kb = CASES[case]
    vdd  = rng.uniform(VDD_NOM * (1 - VDD_TOL), VDD_NOM * (1 + VDD_TOL), n)
    temp = rng.uniform(*T_RANGE, n)
    u = rng.uniform(0, 1, n)
    w = np.where(u < 0.15, W_RANGE[0], np.where(u < 0.30, W_RANGE[1], rng.uniform(*W_RANGE, n)))

    def kinds(m):
        return rng.choice(5, m, p=[0.25, 0.25, 0.10, 0.10, 0.30])
    kd, ks = kinds(n), kinds(n)
    while True:
        both = (kd == 4) & (ks == 4)
        if not both.any():
            break
        kd[both], ks[both] = kinds(both.sum()), kinds(both.sum())

    def frac(kind):
        near, uni = rng.uniform(0, EDGE_BAND, n), rng.uniform(0, 1, n)
        return np.select([kind == 0, kind == 1, kind == 2, kind == 3], [0.0, 1.0, near, 1 - near], uni)
    df = pd.DataFrame(dict(vdd=vdd, temp=temp, w=w, vd=frac(kd) * vdd, vs=frac(ks) * vdd,
                           vg=kg * vdd, vb=kb * vdd))
    for p in PROC:
        df[p] = NOMINAL[dev][p] * rng.uniform(1 - P_TOL, 1 + P_TOL, n)
    return df


def deck(case, rows, title=None):
    """Build one ngspice deck that simulates all rows one after another."""
    dev = CASES[case][0]
    r0 = rows.iloc[0]
    L = [f"* {title or case}: single {dev.upper()}, every terminal on its own source",
         f'.include "{MODEL_FILE}"',
         SPICE_OPTIONS,
         f".temp {r0.temp:.6f}",
         f"Vd d 0 {r0.vd:.12f}", f"Vg g 0 {r0.vg:.12f}",
         f"Vs s 0 {r0.vs:.12f}", f"Vb b 0 {r0.vb:.12f}",
         f"M1 d g s b {dev} W={r0.w:.10e} L={LMIN:.3e}",
         ".control", "set numdgt=12"]
    for r in rows.itertuples():
        L += [f"alter Vd dc={r.vd:.12f}", f"alter Vg dc={r.vg:.12f}",
              f"alter Vs dc={r.vs:.12f}", f"alter Vb dc={r.vb:.12f}",
              f"alter M1 w={r.w:.10e}",
              *[f"altermod {dev} {p}={getattr(r, p):.10e}" for p in PROC],
              f"option temp={r.temp:.6f}",
              "op", "print i(Vd) i(Vg) i(Vs) i(Vb)",
              "print @m1[igs] @m1[igd] @m1[igcs] @m1[igcd] @m1[igb]"]
    L += [".endc", ".end", ""]
    return "\n".join(L)


def simulate(case, df):
    out = []
    with tempfile.TemporaryDirectory() as tmp:
        for k in range(0, len(df), CHUNK):
            rows = df.iloc[k:k + CHUNK]
            f = Path(tmp) / "deck.sp"
            f.write_text(deck(case, rows))
            res = subprocess.run(["ngspice", "-b", str(f)], capture_output=True, text=True)
            vals = np.array(NUM.findall(res.stdout), dtype=float)
            if vals.size != NOUT * len(rows):
                sys.exit(f"{case}: expected {NOUT*len(rows)} values, got {vals.size}\n"
                         + res.stdout[-2000:] + res.stderr[-2000:])
            out.append(vals.reshape(-1, NOUT))
            print(f"\r{case}: {k + len(rows)}/{len(df)}", end="", flush=True)
    print()
    raw = np.vstack(out)
    I = -raw[:, :4]                                   # into-terminal = -i(V)
    pol = 1.0 if CASES[case][0] == "nmos" else -1.0   # BSIM4 reports in device polarity
    ig_dev = pol * raw[:, 4:].sum(axis=1)
    clean = np.abs(I[:, 1]) > 1e-12                   # i(Vg) well above roundoff here
    if clean.any():
        mism = np.max(np.abs(ig_dev[clean] / I[clean, 1] - 1))
        print(f"   ig check: device vs i(Vg) max rel. mismatch = {mism:.1e} "
              f"({clean.sum()} pts > 1 pA)")
    if IG_FROM_DEVICE:
        I[:, 1] = ig_dev
    return I


if __name__ == "__main__":
    # SeedSequence children: 0-3 uniform samples, 4 gate corners (gates.py), 5-8 edge samples
    seeds = np.random.SeedSequence(SEED).spawn(9)
    for k, case in enumerate(CASES):
        df = pd.concat([draw_samples(case, N_SAMPLES, np.random.default_rng(seeds[k])),
                        draw_edge_samples(case, N_EDGE, np.random.default_rng(seeds[5 + k]))],
                       ignore_index=True)        # rows 0..N_SAMPLES-1 uniform, the rest edge
        df[TARGETS] = simulate(case, df)
        df[COLUMNS].to_csv(DATA_DIR / f"{case}.csv", index=False, float_format="%.10e")
        # example netlist = row 0 of the dataset, runnable on its own
        (NET_DIR / f"{case}_example.sp").write_text(
            deck(case, df.iloc[:1], f"{case} example (dataset row 0)")
            .replace(str(MODEL_FILE), "../22nm_HP.pm"))
    print("done ->", DATA_DIR)
