"""
Step 3 - train 4 model types x 4 cases, compare on validation, pick the best per
case, score it on the test set, save it and plot predicted vs SPICE.

Split: 70 % train / 15 % validation / 15 % test, seed 42.
Error = |I_ml - I_spice| / |I_spice| * 100 %, pooled over id, ig, is, ib.
R2 is computed on the signed-log axis (asinh(I/2s)), averaged over the 4 currents.

Outputs
  results/model_comparison.csv              (4 x 4, validation)
  results/model_comparison_per_current.csv  (same, split by current)
  results/chosen_models_test.csv            (test metrics of the winners: all / uniform-only / edge-only rows)
  results/part_a_terminal_reliability.csv   (test error of each channel current; used in Part B)
  models/<case>.joblib                      (the four chosen models)
  plots/pred_vs_spice_<case>.png
Usage: python 03_train_models.py            (about 25 min on one core, MLP dominates)
"""
import time, warnings
import joblib, numpy as np, pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from sklearn.metrics import r2_score
from sklearn.model_selection import train_test_split
from config import *
from fetmodel import TransistorModel, MODEL_TYPES

warnings.filterwarnings("ignore")


def split(n):
    idx = np.arange(n)
    tr, rest = train_test_split(idx, test_size=0.30, random_state=SEED)
    va, te = train_test_split(rest, test_size=0.50, random_state=SEED)
    return tr, va, te


def score(model, df):
    """Per-current and pooled metrics of `model` on `df`.
    Percentage errors are only defined for |I_spice| >= I_FLOOR (1e-18 A): below that the
    reference itself is numerical zero (e.g. an OFF transistor with no voltage across it)."""
    P, rows, pooled = model.predict(df), [], []
    for t in TARGETS:
        y, p = df[t].values, P[t].values
        keep = np.abs(y) >= I_FLOOR
        e = np.abs(p[keep] - y[keep]) / np.abs(y[keep]) * 100
        s = model.out_scale(t)
        r2 = r2_score(np.arcsinh(y / (2 * s)), np.arcsinh(p / (2 * s)))
        rows.append(dict(current=t, r2=r2, median_err_pct=np.median(e),
                         p95_err_pct=np.percentile(e, 95)))
        pooled.append(e)
    pooled = np.concatenate(pooled)
    rows.append(dict(current="all", r2=np.mean([r["r2"] for r in rows]),
                     median_err_pct=np.median(pooled), p95_err_pct=np.percentile(pooled, 95)))
    return pd.DataFrame(rows), P


def parity_plot(case, kind, df, P, path):
    fig, axs = plt.subplots(1, 4, figsize=(17, 4.4))
    for ax, t in zip(axs, TARGETS):
        y, p = df[t].values, P[t].values
        keep = np.abs(y) >= I_FLOOR
        y, p = y[keep], p[keep]
        ok = np.sign(y) == np.sign(p)
        ax.loglog(np.abs(y[ok]), np.abs(p[ok]), ".", ms=3, alpha=0.5, label="same sign")
        if (~ok).any():
            ax.loglog(np.abs(y[~ok]), np.abs(p[~ok]), "x", ms=5, color="tab:red",
                      label=f"sign differs ({(~ok).sum()})")
        lim = [np.abs(y).min() * 0.5, np.abs(y).max() * 2]
        ax.plot(lim, lim, "k--", lw=0.8)
        e = np.abs(p - y) / np.abs(y) * 100
        ax.set(xlim=lim, ylim=lim, xlabel=f"SPICE |{t}| (A)", ylabel=f"ML |{t}| (A)",
               title=f"{t}: median {np.median(e):.2f} %, p95 {np.percentile(e, 95):.1f} %")
        ax.grid(alpha=0.3); ax.legend(loc="upper left", fontsize=8)
    fig.suptitle(f"{case.upper().replace('_', ' ')} - {kind} - test set (n={len(df)})")
    fig.tight_layout(); fig.savefig(path, dpi=140); plt.close(fig)


if __name__ == "__main__":
    summary, detail, chosen, reliab = [], [], [], []
    for case in CASES:
        d = pd.read_csv(DATA_DIR / f"{case}.csv")
        tr, va, te = split(len(d))
        best = None
        for kind in MODEL_TYPES:
            t0 = time.time()
            m = TransistorModel(case, kind).fit(d.iloc[tr])
            s, _ = score(m, d.iloc[va])
            a = s[s.current == "all"].iloc[0]
            print(f"{case:9s} {kind:13s} val: R2 {a.r2:.5f}  median {a.median_err_pct:6.2f} %  "
                  f"p95 {a.p95_err_pct:7.2f} %   ({time.time() - t0:.0f} s)", flush=True)
            summary.append(dict(case=case, model=kind, r2=a.r2,
                                median_err_pct=a.median_err_pct, p95_err_pct=a.p95_err_pct))
            detail.append(s.assign(case=case, model=kind))
            key = (a.median_err_pct, a.p95_err_pct)
            if best is None or key < best[0]:
                best = (key, m)
        m = best[1]
        s, P = score(m, d.iloc[te])
        a = s[s.current == "all"].iloc[0]
        print(f"{case:9s} -> chosen {m.kind}; TEST median {a.median_err_pct:.2f} %  "
              f"p95 {a.p95_err_pct:.2f} %", flush=True)
        chosen.append(s.assign(case=case, model=m.kind, subset="all"))
        for name, rows_ in (("uniform", te[te < N_SAMPLES]), ("edge", te[te >= N_SAMPLES])):
            chosen.append(score(m, d.iloc[rows_])[0].assign(case=case, model=m.kind, subset=name))
        # which channel current is more reliable (used by the gate calculation in Part B)
        dt = d.iloc[te]
        Y = m._to_frame(dt)
        Pf = m._to_frame(P.assign(vd=dt.vd.values, vs=dt.vs.values))
        for k in ("idef", "ioth", "ig", "ib"):
            keep = np.abs(Y[k]) >= I_FLOOR
            e = np.abs(Pf[k][keep] - Y[k][keep]) / np.abs(Y[k][keep]) * 100
            hi_def = not m.gate_high
            term = {"idef": "higher-V" if hi_def else "lower-V",
                    "ioth": "lower-V" if hi_def else "higher-V"}.get(k, "-")
            reliab.append(dict(case=case, current=k, channel_terminal=term,
                               median_err_pct=np.median(e), p95_err_pct=np.percentile(e, 95),
                               mean_err_pct=e.mean()))
        joblib.dump(m, MODEL_DIR / f"{case}.joblib", compress=3)
        parity_plot(case, m.kind, d.iloc[te], P, PLOT_DIR / f"pred_vs_spice_{case}.png")

    cols = ["case", "model", "current", "r2", "median_err_pct", "p95_err_pct"]
    pd.DataFrame(summary).to_csv(RES_DIR / "model_comparison.csv", index=False, float_format="%.5f")
    pd.concat(detail)[cols].to_csv(RES_DIR / "model_comparison_per_current.csv", index=False, float_format="%.5f")
    pd.concat(chosen)[cols + ["subset"]].to_csv(RES_DIR / "chosen_models_test.csv", index=False, float_format="%.5f")
    pd.DataFrame(reliab).to_csv(RES_DIR / "part_a_terminal_reliability.csv", index=False, float_format="%.4f")
    print("done")
