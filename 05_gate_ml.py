"""
Step 5 (Part B) - ML prediction of gate leakage and comparison with SPICE.

For every gate, input combination and corner of 04_gate_spice.py:
  * leak_ml      : leakage from the four transistor models, using the SPICE-recorded
                   output and internal node voltages; per transistor, the terminal
                   currents Part A found most reliable are used (see gates.ml_leakage)
  * leak_ml_high : the same total counted purely on the VDD side   (cross-check)
  * leak_ml_low  : the same total counted purely on the ground side (cross-check)
  * v_x_ml/v_y_ml: stack node voltage solved with the ML models (KCL at the node)
  * v_n1_ml      : NAND/NOR output inside AND2/OR2, taken as the ideal rail (0 or VDD)

Outputs
  results/gate_results_all.csv   every simulation
  results/gate_results_table.csv 18 rows: SPICE median, ML median, bias, median and p95 error
  plots/gate_parity.png          all gates together
  plots/gate_parity_<gate>.png   one plot per gate
Error = |ML - SPICE| / SPICE * 100 %.  Bias = mean of (ML - SPICE) / SPICE * 100 %.
"""
import warnings
import numpy as np, pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from config import *
from gates import GATES, STACK_NODES, combos, ml_leakage, ml_node_voltage

warnings.filterwarnings("ignore")
corners = pd.read_csv(DATA_DIR / "corners.csv")
spice = pd.read_csv(RES_DIR / "gate_spice.csv", dtype={"inputs": str})

rows = []
for gate in GATES:
    for cb in combos(gate):
        s = spice[(spice.gate == gate) & (spice.inputs == cb)].sort_values("corner").copy()
        volt = {n: s[f"v_{n}"].values for n in ["out"] + GATES[gate]["internal"]}
        s["leak_ml"], s["leak_ml_high"], s["leak_ml_low"] = ml_leakage(gate, cb, corners, volt)
        for n in GATES[gate]["internal"]:
            if n in STACK_NODES:
                s[f"v_{n}_ml"] = ml_node_voltage(gate, cb, n, corners, volt)
            else:
                s[f"v_{n}_ml"] = np.where(volt[n] > corners.vdd.values / 2, corners.vdd.values, 0.0)
        rows.append(s)
        print(f"{gate:6s} {cb}", flush=True)
res = pd.concat(rows, ignore_index=True).merge(corners[["corner", "vdd", "temp"]], on="corner")
res["err_pct"] = (res.leak_ml - res.leak_spice) / res.leak_spice * 100
res.to_csv(RES_DIR / "gate_results_all.csv", index=False, float_format="%.8e")


def summary(g):
    e = g.err_pct
    eh = (g.leak_ml_high - g.leak_spice) / g.leak_spice * 100
    el = (g.leak_ml_low - g.leak_spice) / g.leak_spice * 100
    return pd.Series({"spice_median_A": g.leak_spice.median(), "ml_median_A": g.leak_ml.median(),
                      "bias_pct": e.mean(), "median_err_pct": e.abs().median(),
                      "p95_err_pct": np.percentile(e.abs(), 95), "mean_err_pct": e.abs().mean(),
                      "median_err_pct_highside": eh.abs().median(),
                      "median_err_pct_lowside": el.abs().median()})

tab = res.groupby(["gate", "inputs"], sort=False).apply(summary).reset_index()
allrow = summary(res); allrow["gate"], allrow["inputs"] = "ALL", "-"
tab = pd.concat([tab, pd.DataFrame([allrow])], ignore_index=True)
tab.to_csv(RES_DIR / "gate_results_table.csv", index=False, float_format="%.4e")
print(tab.to_string(index=False, float_format=lambda v: f"{v:.3g}"))

# ---- parity plot --------------------------------------------------------------
fig, ax = plt.subplots(figsize=(6.6, 6.2))
for gate, col in zip(GATES, ["tab:blue", "tab:orange", "tab:green", "tab:red", "tab:purple"]):
    g = res[res.gate == gate]
    ax.loglog(g.leak_spice, g.leak_ml, ".", ms=3, alpha=0.5, color=col, label=gate)
lim = [res.leak_spice.min() * 0.5, res.leak_spice.max() * 2]
ax.plot(lim, lim, "k--", lw=0.8)
ax.set(xlim=lim, ylim=lim, xlabel="SPICE leakage (A)", ylabel="ML leakage (A)",
       title=f"Gate leakage, 18 cases x {len(corners)} corners\n"
             f"median error {res.err_pct.abs().median():.2f} %, "
             f"95th percentile {np.percentile(res.err_pct.abs(), 95):.1f} %")
ax.grid(alpha=0.3, which="both"); ax.legend(markerscale=4)
fig.tight_layout(); fig.savefig(PLOT_DIR / "gate_parity.png", dpi=150)

# ---- one parity plot per gate, coloured by input combination --------------------
for gate in GATES:
    g = res[res.gate == gate]
    fig, ax = plt.subplots(figsize=(6.2, 5.8))
    for cb, col in zip(combos(gate), ["tab:blue", "tab:orange", "tab:green", "tab:red"]):
        c = g[g.inputs == cb]
        label = ("A=" + cb) if len(cb) == 1 else ("AB=" + cb)
        ax.loglog(c.leak_spice, c.leak_ml, ".", ms=5, alpha=0.6, color=col,
                  label=f"{label}  (median error {c.err_pct.abs().median():.2f} %)")
    lim = [g.leak_spice.min() * 0.5, g.leak_spice.max() * 2]
    ax.plot(lim, lim, "k--", lw=0.8, label="ML = SPICE")
    ax.set(xlim=lim, ylim=lim, xlabel="SPICE leakage (A)", ylabel="ML leakage (A)",
           title=f"{gate}: ML vs SPICE leakage, {len(corners)} corners per input combination\n"
                 f"median error {g.err_pct.abs().median():.2f} %, "
                 f"95th percentile {np.percentile(g.err_pct.abs(), 95):.1f} %")
    ax.grid(alpha=0.3, which="both"); ax.legend(fontsize=9, loc="upper left")
    fig.tight_layout(); fig.savefig(PLOT_DIR / f"gate_parity_{gate.lower()}.png", dpi=150); plt.close(fig)

# ---- node voltage check -------------------------------------------------------
for n in STACK_NODES:
    if f"v_{n}_ml" in res:
        d = res.dropna(subset=[f"v_{n}_ml"])
        dv = (d[f"v_{n}_ml"] - d[f"v_{n}"]).abs() * 1e3
        print(f"node {n}: |V_ml - V_spice| median {dv.median():.2f} mV, p95 {np.percentile(dv, 95):.1f} mV, max {dv.max():.0f} mV")
        print(d.assign(dv=dv).groupby(["gate", "inputs"], sort=False).dv.agg(["median", "max"]).round(2).to_string())
