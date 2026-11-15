"""
TransistorModel - one ML model per case (NMOS ON/OFF, PMOS ON/OFF) that maps
(vdd, temp, w, vd, vs, vth0, toxe, ndep, u0, xj) -> (id, ig, is, ib).
Vg and Vb are not inputs: they are fixed multiples of VDD in each case.

Preprocessing (identical for all four model types)
--------------------------------------------------
1. Terminal frame. Id and Is change sign with Vd-Vs, so the drain/source pair is
   relabelled as the higher-voltage ("hi") and lower-voltage ("lo") terminal.
   One of the two always carries a single-signed current: channel current and
   gate tunnelling point the same way at
       the lo terminal when the gate is at VDD (NMOS ON, PMOS OFF)
       the hi terminal when the gate is at 0   (NMOS OFF, PMOS ON)
   That one is called `idef`, the other one `ioth`.
2. Targets. Each of idef, ioth, ig, ib is regressed as a signed log,
       t = asinh(I / 2s)   <->   I = 2s * sinh(t)
   which equals sign(I)*ln(|I|/s) for |I| >> s and is linear through zero.
   s is the 0.1 % quantile of |I| in the training set, but never below
   I_FLOOR = 1e-18 A (zero-bias edge samples have currents of exactly ~0).
3. Features. vdd, temp, w, 5 process parameters (rescaled to O(1)), vhi, vlo,
   vds = vhi-vlo, log10(vds), a 0/1 flag for vd<vs, and 1000/T[K].
"""
import numpy as np, pandas as pd
from sklearn.ensemble import RandomForestRegressor, ExtraTreesRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from xgboost import XGBRegressor
from config import CASES, I_FLOOR, PROC, SEED, TARGETS

MODEL_TYPES = ["XGBoost", "RandomForest", "ExtraTrees", "MLP"]
FRAME_TARGETS = ["idef", "ioth", "ig", "ib"]


def make_regressor(kind):
    if kind == "XGBoost":
        return XGBRegressor(n_estimators=1500, learning_rate=0.03, max_depth=6,
                            subsample=0.8, colsample_bytree=0.8,
                            random_state=SEED, n_jobs=-1)
    if kind == "RandomForest":
        return RandomForestRegressor(n_estimators=300, min_samples_leaf=1,
                                     max_features=0.5, random_state=SEED, n_jobs=-1)
    if kind == "ExtraTrees":
        return ExtraTreesRegressor(n_estimators=300, min_samples_leaf=1,
                                   max_features=1.0, random_state=SEED, n_jobs=-1)
    if kind == "MLP":
        return make_pipeline(
            StandardScaler(),
            MLPRegressor(hidden_layer_sizes=(64, 64), activation="tanh",
                         solver="lbfgs", alpha=1e-6, max_iter=4000,
                         max_fun=10**6, tol=1e-9, random_state=SEED))
    raise ValueError(kind)


class TransistorModel:
    def __init__(self, case, kind):
        self.case, self.kind = case, kind
        self.gate_high = CASES[case][1] == 1.0     # gate at VDD -> lo terminal is definite
        self.reg, self.scale = {}, {}

    # ---- preprocessing -------------------------------------------------
    @staticmethod
    def features(df):
        vhi, vlo = np.maximum(df.vd, df.vs), np.minimum(df.vd, df.vs)
        X = pd.DataFrame({
            "vdd": df.vdd, "temp": df.temp, "w_nm": df.w * 1e9,
            "vth0": df.vth0, "toxe_nm": df.toxe * 1e9, "ndep_e18": df.ndep / 1e18,
            "u0": df.u0, "xj_nm": df.xj * 1e9,
            "vhi": vhi, "vlo": vlo, "vds": vhi - vlo,
            "log_vds": np.log10(vhi - vlo + 1e-5),
            "swap": (df.vd < df.vs).astype(float),
            "inv_T": 1000.0 / (df.temp + 273.15)})
        return X

    def _to_frame(self, df):
        swap = (df.vd < df.vs).values
        ihi = np.where(swap, df["is"], df["id"])
        ilo = np.where(swap, df["id"], df["is"])
        idef, ioth = (ilo, ihi) if self.gate_high else (ihi, ilo)
        return {"idef": idef, "ioth": ioth, "ig": df["ig"].values, "ib": df["ib"].values}

    # ---- fit / predict -------------------------------------------------
    def fit(self, df):
        X, Y = self.features(df), self._to_frame(df)
        for t in FRAME_TARGETS:
            self.scale[t] = max(float(np.quantile(np.abs(Y[t]), 0.001)), I_FLOOR)
            self.reg[t] = make_regressor(self.kind).fit(
                X, np.arcsinh(Y[t] / (2 * self.scale[t])))
        return self

    def predict(self, df):
        """df needs columns vdd, temp, w, vd, vs, vth0, toxe, ndep, u0, xj (SI units, temp in C).
        Returns a DataFrame with id, ig, is, ib (A, positive = into the terminal)."""
        X = self.features(df)
        P = {t: 2 * self.scale[t] * np.sinh(self.reg[t].predict(X)) for t in FRAME_TARGETS}
        ihi, ilo = (P["ioth"], P["idef"]) if self.gate_high else (P["idef"], P["ioth"])
        swap = (df.vd < df.vs).values
        return pd.DataFrame({"id": np.where(swap, ilo, ihi), "ig": P["ig"],
                             "is": np.where(swap, ihi, ilo), "ib": P["ib"]},
                            index=df.index)[TARGETS]

    def out_scale(self, t):
        """asinh scale to use when scoring output current t on the signed-log axis."""
        return min(self.scale["idef"], self.scale["ioth"]) if t in ("id", "is") else self.scale[t]
