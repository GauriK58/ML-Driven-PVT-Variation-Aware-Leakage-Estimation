"""
Step 2 - data check: Kirchhoff sum for each case + three trend plots.
Outputs: results/kirchhoff_check.csv, plots/trend_*.png
"""
import numpy as np, pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from config import *

D = {c: pd.read_csv(DATA_DIR / f"{c}.csv") for c in CASES}

# ---- Kirchhoff: id + ig + is + ib should be 0 --------------------------------
rows = []
for c, d in D.items():
    s = d[TARGETS].sum(axis=1).abs()
    big = d[TARGETS].abs().max(axis=1).clip(lower=I_FLOOR)   # zero-bias edge rows have I ~ 0
    rows.append(dict(case=c, n=len(d), max_abs_sum_A=s.max(), median_abs_sum_A=s.median(),
                     max_sum_over_largest_current=(s / big).max(),
                     median_sum_over_largest_current=(s / big).median()))
k = pd.DataFrame(rows)
k.to_csv(RES_DIR / "kirchhoff_check.csv", index=False, float_format="%.3e")
print(k.to_string(index=False, float_format=lambda v: f"{v:.2e}"))


D = {c: d.iloc[:N_SAMPLES] for c, d in D.items()}     # trends: uniform samples only

# ---- trend plots: raw samples + bin medians ----------------------------------
# Temperature moves leakage by orders of magnitude, so for the vth0 and toxe
# plots the medians are drawn separately for cold / mid / hot samples.
T_BANDS = [(-40, 15, "tab:blue"), (15, 70, "tab:green"), (70, 125, "tab:red")]


def med_line(ax, x, y, edges, **kw):
    mid = 0.5 * (edges[1:] + edges[:-1])
    med = [np.median(y[(x >= a) & (x <= b)]) if ((x >= a) & (x <= b)).any() else np.nan
           for a, b in zip(edges[:-1], edges[1:])]
    ax.plot(mid, med, "o-", lw=2, **kw)


def trend(ax, x, y, temp, xlabel, ylabel, title, by_temp=True):
    ax.scatter(x, y, s=3, alpha=0.15, color="gray", rasterized=True)
    edges = np.linspace(x.min(), x.max(), 9)
    if by_temp:
        for lo, hi, col in T_BANDS:
            m = (temp >= lo) & (temp <= hi)
            med_line(ax, x[m], y[m], edges, color=col, label=f"median, {lo} to {hi} °C")
    else:
        med_line(ax, x, y, edges, color="black", label="bin median")
    ax.set(yscale="log", xlabel=xlabel, ylabel=ylabel, title=title)
    ax.grid(alpha=0.3, which="both"); ax.legend(fontsize=8)


def off_current(c):
    """OFF-state channel leakage: drain current magnitude with |Vds| > VDD/2."""
    d = D[c]
    m = (d.vd - d.vs > 0.5 * d.vdd) if c.startswith("nmos") else (d.vs - d.vd > 0.5 * d.vdd)
    return d[m]

for name, col, xlabel in [("off_current_vs_temperature", "temp", "Temperature (°C)"),
                          ("off_current_vs_vth0", "vth0", "vth0 (V)")]:
    fig, axs = plt.subplots(1, 2, figsize=(11, 4.2))
    for ax, c in zip(axs, ["nmos_off", "pmos_off"]):
        d = off_current(c)
        trend(ax, d[col].values, d["id"].abs().values, d.temp.values, xlabel, "|Id| (A)",
              f"{c.upper().replace('_', ' ')}: |Id| for |Vds| > VDD/2  (n={len(d)})",
              by_temp=(col != "temp"))
    fig.tight_layout(); fig.savefig(PLOT_DIR / f"trend_{name}.png", dpi=150); plt.close(fig)

fig, axs = plt.subplots(1, 2, figsize=(11, 4.2))
for ax, c in zip(axs, ["nmos_on", "pmos_on"]):
    d = D[c]
    trend(ax, d.toxe.values * 1e9, d["ig"].abs().values, d.temp.values, "toxe (nm)", "|Ig| (A)",
          f"{c.upper().replace('_', ' ')}: gate current, all samples")
fig.tight_layout(); fig.savefig(PLOT_DIR / "trend_gate_current_vs_toxe.png", dpi=150); plt.close(fig)
print("plots ->", PLOT_DIR)
