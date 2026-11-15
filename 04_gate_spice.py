"""
Step 4 (Part B) - SPICE reference for INV, NAND2, NOR2, AND2, OR2 at 200 corners,
every input combination. Evaluation only: nothing here is used for training.

Outputs
  data/corners.csv            the 200 corners (also used in Part C)
  results/gate_spice.csv      leakage + node voltages, one row per gate/inputs/corner
  netlists/<gate>.sp          runnable example netlist (corner 0, all input combinations)
"""
import pandas as pd
from config import *
from gates import GATES, draw_corners, run_spice, deck

corners = draw_corners()
corners.to_csv(DATA_DIR / "corners.csv", index=False, float_format="%.10e")
out = []
for gate in GATES:
    df = run_spice(gate, corners)
    out.append(df)
    (NET_DIR / f"{gate.lower()}.sp").write_text(deck(gate, corners.iloc[:1], "../22nm_HP.pm"))
    print(f"{gate:6s} {len(df)} simulations")
out = pd.concat(out, ignore_index=True)
first = ["gate", "inputs", "corner", "leak_spice", "leak_spice_vddpin", "v_out"]
out[first + [c for c in out.columns if c not in first]].to_csv(
    RES_DIR / "gate_spice.csv", index=False, float_format="%.10e")
print("->", RES_DIR / "gate_spice.csv")
