# ML-Driven PVT Variation Aware Leakage Estimation

Machine-learning models of a single transistor are trained on SPICE data and then used, instead of SPICE, to predict the leakage current of logic gates and then of a 3-bit carry-lookahead adder under process, voltage and temperature (PVT) variation.

- **Model file:** PTM 22 nm HP (`22nm_HP.pm`), nominal VDD = 0.9 V, L = 22 nm
- **Test circuit:** 3-bit carry-lookahead adder
- **Simulator:** ngspice-42
- **Result:** about 99.2 % mean accuracy against SPICE, for both the gates and the adder

## Files

### Scripts

| File | What it contains |
|---|---|
| `config.py` | All settings: VDD, channel length, sampling ranges, nominal process values, gate widths, seed. |
| `01_generate_data.py` | Part A: draws the uniform and edge samples and simulates a single transistor for each in ngspice. |
| `02_data_check.py` | Part A: Kirchhoff check of the four terminal currents and the three trend plots. |
| `03_train_models.py` | Part A: trains XGBoost, Random Forest, Extra Trees and MLP for each case, compares them and saves the best. |
| `fetmodel.py` | The transistor model class: preprocessing (terminal relabelling, asinh transform, features) and the four model types. |
| `04_gate_spice.py` | Part B: SPICE reference for INV, NAND2, NOR2, AND2 and OR2 at 200 corners. |
| `05_gate_ml.py` | Part B: ML prediction of gate leakage, comparison with SPICE, results table and parity plots. |
| `gates.py` | Gate definitions, the gate SPICE runner, the ML leakage calculation and the ML node-voltage solver. |
| `06_cla_spice.py` | Part C: SPICE reference for the complete adder, 128 input combinations at 200 corners. |
| `07_cla_ml.py` | Part C: ML prediction of the adder leakage by summing gate models, and comparison with SPICE. |
| `circuit.py` | The adder as a list of 39 gates, its logic simulator and its SPICE runner. |

### Inputs and report

| File | What it contains |
|---|---|
| `22nm_HP.pm` | The assigned PTM 22 nm high-performance transistor model file (BSIM4). |
| `report.pdf` | Project report PDF document. |

### `data/`

| File | What it contains |
|---|---|
| `nmos_on.csv`, `nmos_off.csv`, `pmos_on.csv`, `pmos_off.csv` | The four single-transistor datasets: 15,000 rows each (10,000 uniform + 5,000 edge samples) with inputs and the currents id, ig, is, ib. |
| `corners.csv` | The 200 random PVT corners used for the gates and the adder. |

### `netlists/`

| File | What it contains |
|---|---|
| `nmos_on_example.sp`, `nmos_off_example.sp`, `pmos_on_example.sp`, `pmos_off_example.sp` | One example single-transistor netlist per case, with a separate voltage source on every terminal. |
| `inv.sp`, `nand2.sp`, `nor2.sp`, `and2.sp`, `or2.sp` | Transistor-level netlist of each gate. |
| `cla3.sp` | Complete transistor-level netlist of the 3-bit carry-lookahead adder (186 transistors). |

### `models/`

| File | What it contains |
|---|---|
| `nmos_on.joblib`, `nmos_off.joblib`, `pmos_on.joblib`, `pmos_off.joblib` | The four chosen (MLP) transistor models, one per case. |

### `results/`

| File | What it contains |
|---|---|
| `kirchhoff_check.csv` | Sum of the four terminal currents for each dataset. |
| `model_comparison.csv` | Validation R², median and 95th-percentile error for 4 model types × 4 cases. |
| `model_comparison_per_current.csv` | The same comparison, split by current. |
| `chosen_models_test.csv` | Test-set error of the four chosen models (all, uniform-only and edge-only rows). |
| `part_a_terminal_reliability.csv` | Test-set error of each channel current, used to choose between Id and Is in Part B. |
| `gate_spice.csv` | SPICE leakage and node voltages for every gate, input combination and corner. |
| `gate_results_all.csv` | SPICE and ML leakage and node voltages side by side for every gate simulation. |
| `gate_results_table.csv` | Summary for the 18 gate and input cases: SPICE median, ML median, bias and errors. |
| `cla_spice.csv` | SPICE leakage and output voltages of the adder for all 25,600 simulations. |
| `cla_results_all.csv` | SPICE and ML leakage of the adder side by side for every simulation. |
| `cla_results_table.csv` | Summary for each of the 128 input combinations, plus an overall row. |

### `plots/`

| File | What it contains |
|---|---|
| `trend_off_current_vs_temperature.png` | OFF current against temperature. |
| `trend_off_current_vs_vth0.png` | OFF current against threshold voltage. |
| `trend_gate_current_vs_toxe.png` | Gate current against oxide thickness. |
| `pred_vs_spice_<case>.png` | Predicted against SPICE currents on the test set, one plot per case (4 files). |
| `gate_parity.png` | ML against SPICE leakage for all gate simulations together. |
| `gate_parity_<gate>.png` | ML against SPICE leakage for each gate separately (5 files). |
| `cla_parity.png` | ML against SPICE leakage for the adder. |

## File structure

```
.
├── README.md
├── 22nm_HP.pm
├── config.py
├── fetmodel.py
├── gates.py
├── circuit.py
├── 01_generate_data.py
├── 02_data_check.py
├── 03_train_models.py
├── 04_gate_spice.py
├── 05_gate_ml.py
├── 06_cla_spice.py
├── 07_cla_ml.py
├── data/
│   ├── nmos_on.csv
│   ├── nmos_off.csv
│   ├── pmos_on.csv
│   ├── pmos_off.csv
│   └── corners.csv
├── netlists/
│   ├── nmos_on_example.sp
│   ├── nmos_off_example.sp
│   ├── pmos_on_example.sp
│   ├── pmos_off_example.sp
│   ├── inv.sp
│   ├── nand2.sp
│   ├── nor2.sp
│   ├── and2.sp
│   ├── or2.sp
│   └── cla3.sp
├── models/
│   ├── nmos_on.joblib
│   ├── nmos_off.joblib
│   ├── pmos_on.joblib
│   └── pmos_off.joblib
├── results/
│   ├── kirchhoff_check.csv
│   ├── model_comparison.csv
│   ├── model_comparison_per_current.csv
│   ├── chosen_models_test.csv
│   ├── part_a_terminal_reliability.csv
│   ├── gate_spice.csv
│   ├── gate_results_all.csv
│   ├── gate_results_table.csv
│   ├── cla_spice.csv
│   ├── cla_results_all.csv
│   └── cla_results_table.csv
└── plots/
    ├── trend_off_current_vs_temperature.png
    ├── trend_off_current_vs_vth0.png
    ├── trend_gate_current_vs_toxe.png
    ├── pred_vs_spice_nmos_on.png
    ├── pred_vs_spice_nmos_off.png
    ├── pred_vs_spice_pmos_on.png
    ├── pred_vs_spice_pmos_off.png
    ├── gate_parity.png
    ├── gate_parity_inv.png
    ├── gate_parity_nand2.png
    ├── gate_parity_nor2.png
    ├── gate_parity_and2.png
    ├── gate_parity_or2.png
    └── cla_parity.png
└── report/
    ├── Report.pdf
```

## Team

- Gauri Krishnan (2024102073)
- Sukeerthi Kattamuri (2024102074)
- Padmanjali Nethi (2024102047)
