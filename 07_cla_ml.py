"""
Step 7 (Part C) - hierarchical ML prediction of the 3-bit CLA leakage and comparison
with the SPICE simulation of the complete netlist.

For each input vector the logic value at the inputs of every gate is found by logic
simulation; the gate model of Part B is called for that gate type / input combination /
corner, and the 39 gate leakages are summed. Every gate input is assumed to sit at exactly
0 or VDD and loading between gates is ignored.

Three sums are reported per corner and input vector:
  leak_ml          Part B gate models (transistor models + node voltages recorded from the
                   stand-alone gate simulations of Part B) - the reported ML leakage
  leak_ml_noSPICE  same, but the gate models use no SPICE voltages at all: outputs at the
                   ideal rail, stack nodes solved with the ML models
  leak_gate_spice  sum of the stand-alone SPICE gate leakages of Part B. Not an ML result:
                   it shows how much error comes from adding gates up (loading) alone.

Outputs
  results/cla_results_all.csv, results/cla_results_table.csv (128 input vectors + ALL),
  plots/cla_parity.png
"""
import warnings
import numpy as np, pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from config import *
from gates import GATES, STACK_NODES, combos, ml_leakage, ml_node_voltage
from circuit import CLA, VECTORS, simulate_logic

warnings.filterwarnings("ignore")
corners = pd.read_csv(DATA_DIR / "corners.csv")
spice = pd.read_csv(RES_DIR / "cla_spice.csv", dtype={"inputs": str})
gate = pd.read_csv(RES_DIR / "gate_results_all.csv", dtype={"inputs": str})
corners = corners[corners.corner.isin(spice.corner.unique())].reset_index(drop=True)
vdd = corners.vdd.values

# ---- gate models: leakage of each (gate type, input combination) at every corner ----
KEYS = [(g, cb) for g in ("NAND2", "AND2", "OR2") for cb in combos(g)]
table = {"leak_ml": {}, "leak_ml_noSPICE": {}, "leak_gate_spice": {}}
for g, cb in KEYS:
    s = gate[(gate.gate == g) & (gate.inputs == cb)].set_index("corner").loc[corners.corner]
    table["leak_ml"][(g, cb)] = s.leak_ml.values
    table["leak_gate_spice"][(g, cb)] = s.leak_spice.values
    # SPICE-free gate model: ideal rails + ML-solved stack node
    volt = {n: np.where(s[f"v_{n}"].values > vdd / 2, vdd, 0.0)
            for n in ["out"] + GATES[g]["internal"]}
    for n in GATES[g]["internal"]:
        if n in STACK_NODES:
            volt[n] = ml_node_voltage(g, cb, n, corners, volt)
    table["leak_ml_noSPICE"][(g, cb)] = ml_leakage(g, cb, corners, volt)[0]

# ---- compose the circuit: count how often each gate state occurs for each input vector ----
rows = []
for vec in VECTORS:
    _, states = simulate_logic(vec)
    r = pd.DataFrame({"corner": corners.corner, "inputs": vec})
    for name, tab in table.items():
        r[name] = sum(tab[st] for st in states)
    rows.append(r)
res = pd.concat(rows, ignore_index=True).merge(spice, on=["corner", "inputs"]) \
        .merge(corners[["corner", "vdd", "temp"]], on="corner")
res["err_pct"] = (res.leak_ml - res.leak_spice) / res.leak_spice * 100
res.to_csv(RES_DIR / "cla_results_all.csv", index=False, float_format="%.8e")


def summary(g):
    e = g.err_pct
    rel = lambda col: ((g[col] - g.leak_spice) / g.leak_spice * 100).abs()
    return pd.Series({"spice_median_A": g.leak_spice.median(), "ml_median_A": g.leak_ml.median(),
                      "bias_pct": e.mean(), "median_err_pct": e.abs().median(),
                      "p95_err_pct": np.percentile(e.abs(), 95), "mean_err_pct": e.abs().mean(),
                      "median_err_pct_noSPICE": rel("leak_ml_noSPICE").median(),
                      "median_err_pct_gate_spice_sum": rel("leak_gate_spice").median()})

tab = res.groupby("inputs", sort=True).apply(summary).reset_index()
allrow = summary(res); allrow["inputs"] = "ALL"
tab = pd.concat([tab, pd.DataFrame([allrow])], ignore_index=True)
tab.to_csv(RES_DIR / "cla_results_table.csv", index=False, float_format="%.4e")
print("input order: a0 a1 a2 b0 b1 b2 cin")
print(tab.tail(1).T.to_string(header=False, float_format=lambda v: f"{v:.4g}"))
per = tab.iloc[:-1]
print(f"per input vector: median error ranges {per.median_err_pct.min():.2f} - {per.median_err_pct.max():.2f} %"
      f" (best {per.loc[per.median_err_pct.idxmin(), 'inputs']}, worst {per.loc[per.median_err_pct.idxmax(), 'inputs']});"
      f" bias ranges {per.bias_pct.min():+.2f} to {per.bias_pct.max():+.2f} %")

fig, ax = plt.subplots(figsize=(6.6, 6.2))
sc = ax.scatter(res.leak_spice, res.leak_ml, c=res.temp, s=2, alpha=0.4, cmap="coolwarm", rasterized=True)
lim = [res.leak_spice.min() * 0.7, res.leak_spice.max() * 1.4]
ax.plot(lim, lim, "k--", lw=0.8)
ax.set(xscale="log", yscale="log", xlim=lim, ylim=lim, xlabel="SPICE leakage (A)",
       ylabel="ML leakage (A)",
       title=f"3-bit CLA, {res.inputs.nunique()} input vectors x {res.corner.nunique()} corners\n"
             f"median error {res.err_pct.abs().median():.2f} %, "
             f"95th percentile {np.percentile(res.err_pct.abs(), 95):.2f} %")
fig.colorbar(sc, label="Temperature (°C)"); ax.grid(alpha=0.3, which="both")
fig.tight_layout(); fig.savefig(PLOT_DIR / "cla_parity.png", dpi=150)
