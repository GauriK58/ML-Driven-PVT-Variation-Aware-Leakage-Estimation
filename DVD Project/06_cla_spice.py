"""
Step 6 (Part C) - SPICE reference for the 3-bit CLA as one complete transistor-level
netlist: all 128 input vectors at the same 200 corners as Part B (25,600 operating points,
about 45 min on one core). Evaluation only.

The run is done in blocks of 10 corners saved under results/cla_parts/, so it can be
interrupted and restarted; delete that folder to force a full re-run.

Outputs
  results/cla_spice.csv   leakage and output voltages, one row per corner / input vector
  netlists/cla3.sp        runnable netlist (corner 0, all 128 input vectors)
"""
import time
import pandas as pd
from config import *
from circuit import run_spice, deck, simulate_logic, OUTPUTS

corners = pd.read_csv(DATA_DIR / "corners.csv")
(NET_DIR / "cla3.sp").write_text(deck(corners.iloc[:1], model_path="../22nm_HP.pm"))
parts = RES_DIR / "cla_parts"
parts.mkdir(exist_ok=True)
BLOCK, t0 = 10, time.time()
for k in range(0, len(corners), BLOCK):
    f = parts / f"corners_{k:03d}.csv"
    if not f.exists():
        run_spice(corners.iloc[k:k + BLOCK]).to_csv(f, index=False, float_format="%.10e")
        print(f"corners {k}-{k + BLOCK - 1} done ({time.time() - t0:.0f} s)", flush=True)
df = pd.concat([pd.read_csv(f, dtype={"inputs": str}) for f in sorted(parts.glob("*.csv"))],
               ignore_index=True)

# sanity: every output must sit at the logic level the adder should produce
df = df.merge(corners[["corner", "vdd"]], on="corner")
for vec, g in df.groupby("inputs"):
    net, _ = simulate_logic(vec)
    for o in OUTPUTS:
        assert ((g[f"v_{o}"] > g.vdd / 2) == bool(net[o])).all(), f"wrong logic at {vec} {o}"
first = ["corner", "inputs", "leak_spice", "leak_spice_vddpin"]
df[first + [f"v_{o}" for o in OUTPUTS]].to_csv(RES_DIR / "cla_spice.csv", index=False,
                                               float_format="%.10e")
print(len(df), "operating points ->", RES_DIR / "cla_spice.csv")
