"""Shared settings for the whole project (Part A)."""
from pathlib import Path

ROOT       = Path(__file__).resolve().parent
MODEL_FILE = ROOT / "22nm_HP.pm"

SEED     = 42
VDD_NOM  = 0.9            # assigned nominal supply (V)
VDD_TOL  = 0.10           # +/-10 %
LMIN     = 22e-9          # channel length = feature size (m)
W_RANGE  = (1 * LMIN, 8 * LMIN)
T_RANGE  = (-40.0, 125.0) # deg C
P_TOL    = 0.10           # +/-10 % on each process parameter
N_SAMPLES = 10_000       # uniform samples per case, drawn exactly as in Section 4
N_EDGE    = 5_000        # extra samples per case at the edges of the Vd/Vs (and W) range
EDGE_BAND = 0.05         # "near a rail" = within 5 % of VDD of 0 or VDD
I_FLOOR   = 1e-18        # A: gmin * 1 V, the simulator's own resolution. Used as the minimum
                         # asinh scale and as the cut-off below which % errors are not scored

IG_FROM_DEVICE = True   # see 01_generate_data.py docstring (i(Vg) roundoff floor ~2e-16 A)

SPICE_OPTIONS = ".options gmin=1e-18 abstol=1e-18 reltol=1e-6 vntol=1e-9"

# Nominal process parameters, copied from 22nm_HP.pm
NOMINAL = {
    "nmos": dict(vth0=0.50308, toxe=1.05e-9, ndep=5.5e18, u0=0.04,   xj=7.2e-9),
    "pmos": dict(vth0=-0.4606, toxe=1.10e-9, ndep=4.4e18, u0=0.0095, xj=7.2e-9),
}
PROC = ["vth0", "toxe", "ndep", "u0", "xj"]

# case -> (device, gate voltage as multiple of VDD, body voltage as multiple of VDD)
CASES = {
    "nmos_on":  ("nmos", 1.0, 0.0),
    "nmos_off": ("nmos", 0.0, 0.0),
    "pmos_on":  ("pmos", 0.0, 1.0),
    "pmos_off": ("pmos", 1.0, 1.0),
}

COLUMNS = ["vdd", "temp", "w", "vd", "vs", "vg", "vb",
           "vth0", "toxe", "ndep", "u0", "xj", "id", "ig", "is", "ib"]
TARGETS = ["id", "ig", "is", "ib"]

DATA_DIR, NET_DIR, MODEL_DIR, RES_DIR, PLOT_DIR = (
    ROOT / d for d in ("data", "netlists", "models", "results", "plots"))
for _d in (DATA_DIR, NET_DIR, MODEL_DIR, RES_DIR, PLOT_DIR):
    _d.mkdir(exist_ok=True)

# ---------------- Part B / C: gates ----------------
N_CORNERS = 200
WN = 2 * LMIN            # NMOS unit width  (44 nm)
WP = 4 * LMIN            # PMOS unit width  (88 nm); series stacks use 2x the unit width
