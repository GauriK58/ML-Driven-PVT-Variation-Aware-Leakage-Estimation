# ML leakage estimation - Parts A, B and C (22nm HP, VDD = 0.9 V)

Simulator: ngspice-42. Python: numpy, pandas, scikit-learn, xgboost, matplotlib, joblib.

Run in order from this folder (all seeds fixed at 42):

    python 01_generate_data.py     # ~30 s   -> data/*.csv, netlists/*_example.sp
    python 02_data_check.py        # ~5 s    -> results/kirchhoff_check.csv, plots/trend_*.png
    python 03_train_models.py      # ~25 min -> results/*.csv, models/*.joblib, plots/pred_vs_spice_*.png
    python 04_gate_spice.py        # ~10 s   -> data/corners.csv, results/gate_spice.csv, netlists/<gate>.sp
    python 05_gate_ml.py           # ~1 min  -> results/gate_results_*.csv, plots/gate_parity.png
    python 06_cla_spice.py         # ~45 min -> results/cla_spice.csv, netlists/cla3.sp
    python 07_cla_ml.py            # ~10 s   -> results/cla_results_*.csv, plots/cla_parity.png

| File | What it is |
|---|---|
| `config.py` | all settings: VDD, L, ranges, nominal process values, cases |
| `fetmodel.py` | `TransistorModel` class: preprocessing + the four model types |
| `data/<case>.csv` | 15,000 rows (0-9,999 uniform as in Section 4, 10,000-14,999 edge samples): vdd, temp, w, vd, vs, vg, vb, vth0, toxe, ndep, u0, xj, id, ig, is, ib |
| `netlists/<case>_example.sp` | runnable single-transistor netlist (row 0 of each dataset) |
| `results/model_comparison.csv` | 4 model types x 4 cases on the validation set |
| `results/chosen_models_test.csv` | test-set metrics of the chosen model per case |
| `models/<case>.joblib` | the four chosen models |

Units: SI throughout (w in m, currents in A), temp in deg C.
Sign: every current is positive when it flows INTO the device terminal.

Using a saved model (this is what Part B will call):

    import joblib, pandas as pd
    m = joblib.load("models/nmos_off.joblib")        # needs fetmodel.py + config.py importable
    df = pd.DataFrame([dict(vdd=0.9, temp=25, w=44e-9, vd=0.9, vs=0.0,
                            vth0=0.50308, toxe=1.05e-9, ndep=5.5e18, u0=0.04, xj=7.2e-9)])
    print(m.predict(df))                             # columns id, ig, is, ib

Edge samples (deviation from Section 4, to be stated in the report)
- Inside a gate every transistor has its drain/source exactly at 0 or VDD, i.e. at the edge of
  the sampled range, where uniform sampling leaves almost no training points.
- So 5,000 extra samples per case are added with Vd and/or Vs at or within 5 % of a rail, and
  W sometimes at 1x or 8x Lmin (`draw_edge_samples` in 01_generate_data.py). VDD, temperature
  and process parameters are drawn exactly as before. The 10,000 uniform rows are unchanged.
- The 70/15/15 split is taken over all 15,000 rows; `results/chosen_models_test.csv` also
  reports the test error on the uniform rows and the edge rows separately.
- Currents below 1e-18 A (numerical zero, e.g. an OFF transistor with no voltage across it)
  are left out of percentage-error statistics.

Choices to state in the report
- `ig` is the sum of the BSIM4 gate-current components reported by ngspice
  (igs+igd+igcs+igcd+igb), not the current through Vg: rgatemod=1 in the model
  file limits i(Vg) to ~2e-16 A resolution, above PMOS-OFF gate leakage.
  Set IG_FROM_DEVICE=False in config.py to use i(Vg) instead.
- Only toxe is varied; toxp keeps its file value (ngspice then ignores dtox).
- No AS/AD/PS/PD are given on the transistor, as the assignment does not specify them.

## Part B - gates

- `gates.py`: gate netlists (INV, NAND2, NOR2, AND2, OR2), SPICE runner, ML leakage and ML node-voltage solver.
- Sizing: NMOS 44 nm, PMOS 88 nm, doubled in series stacks (set by WN, WP in config.py). L = 22 nm.
- Corner: one draw of VDD, temperature, 5 NMOS and 5 PMOS parameters; 200 corners, seed 42, shared by all gates.
- Leakage = current delivered by the VDD source plus by every input source held at VDD
  (`leak_spice`). The VDD-pin-only current is kept as `leak_spice_vddpin`.
- `leak_ml` uses the SPICE-recorded node voltages and, per transistor, the terminal currents
  Part A found most reliable (`results/part_a_terminal_reliability.csv`, from the Part A test set).
  `leak_ml_high` / `leak_ml_low` are the same total counted purely on the VDD / ground side.
  `v_x_ml` / `v_y_ml` are the stack node voltages solved with the ML models.
- Every netlist carries `.options gmin=1e-18 abstol=1e-18 reltol=1e-6 vntol=1e-9`.

## Part C - 3-bit carry-lookahead adder

- `circuit.py`: the CLA as a list of Part B gates (24 NAND2 + 9 AND2 + 6 OR2 = 39 gates,
  186 transistors; each XOR is four NAND2), its logic simulator and the SPICE runner.
  Inputs a0 a1 a2 b0 b1 b2 cin (input vectors are written in that order), outputs s0 s1 s2 c3.
- SPICE: one complete transistor-level netlist, all 128 input vectors at the 200 Part B corners.
  Leakage is defined as in Part B (VDD source + the primary-input sources held at VDD).
- ML: for each input vector, logic simulation gives every gate's input combination; the Part B
  gate model for that gate / combination / corner is called and the 39 leakages are summed.
  A gate's own input current is part of its gate model, so current drawn from a driving gate's
  output is counted once, in the gate that receives it.
- `leak_ml_noSPICE` repeats the sum with gate models that use no SPICE voltages (ideal rails,
  ML-solved stack nodes); `leak_gate_spice` is the sum of stand-alone SPICE gate leakages and
  isolates the error of adding gates up.
