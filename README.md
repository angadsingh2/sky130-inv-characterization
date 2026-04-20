# CMOS Inverter Full Custom Characterization
## Technology: SkyWater SKY130 (130nm) | Tool: LTSpice | VDD: 1.8V

---

## Project Overview

This project characterizes a full custom CMOS inverter cell (INV_X1/X2/X4)
in the SkyWater SKY130 open-source 130nm process. It demonstrates the
complete analog/AMS characterization flow used in industrial cell library
development:

```
Transistor Sizing → SPICE Netlist → DC Analysis → Transient Analysis
      → PVT Corner Sweep → NLDM Liberty File Generation
```

This flow is directly relevant to AMS layout roles where understanding
pre/post-layout performance, parasitic impact, and PVT variation is essential.

---

## Project Structure

```
inverter_project/
├── models/
│   └── sky130_fd_pr.lib          # BSIM3v3 device models (TT/FF/SS corners)
├── netlists/
│   └── inv_sky130.sp             # INV_X1, INV_X2, INV_X4 subcircuits
├── testbenches/
│   ├── tb_dc_transfer.sp         # DC transfer curve — VM, NMH, NML, gain
│   ├── tb_transient.sp           # Propagation delay, rise/fall time
│   └── tb_pvt_corners.sp         # 6-corner PVT sweep
├── liberty/
│   └── sky130_inv_tt_1v8_25c.lib # NLDM Liberty timing library (TT corner)
└── README.md                     # This file
```

---

## Cell Specifications

### INV_X1 (1x drive strength)

| Parameter     | Value          | Notes                                    |
|--------------|----------------|------------------------------------------|
| Technology   | SKY130 (130nm) | SkyWater open PDK                        |
| VDD          | 1.8V           | Nominal                                  |
| PMOS W/L     | 2.0µm / 0.15µm | 2x NMOS to balance µn/µp ratio          |
| NMOS W/L     | 1.0µm / 0.15µm | Minimum length for speed                 |
| Drive ratio  | Wp/Wn = 2.0    | Targets equal tpHL ≈ tpLH               |

### Sizing Rationale

PMOS hole mobility (µp) is approximately 2-2.5x lower than NMOS electron
mobility (µn) in bulk CMOS. To achieve balanced rise and fall delays:

    Wp/Wn = µn/µp ≈ 2.0

This gives matched drive currents for the pull-up and pull-down networks,
resulting in a switching threshold VM ≈ VDD/2 = 0.9V.

---

## Step-by-Step: Running the Simulations in LTSpice

### Step 1: Setup
1. Download and install LTSpice XVII (free from Analog Devices website)
2. Clone/extract this project to a local folder, e.g., `C:\inverter_project\`

### Step 2: DC Transfer Curve (tb_dc_transfer.sp)

**What it measures:** Switching threshold VM, noise margins NMH/NML, DC gain

1. Open LTSpice → File → Open → `testbenches/tb_dc_transfer.sp`
2. Press Run (green arrow)
3. Right-click waveform area → Add Trace → V(Y) and V(A)
4. The crossing point of V(Y) and V(A) is VM

**Expected results (TT, 1.8V, 25°C):**
- VM   ≈ 0.89V  (should be close to VDD/2 = 0.90V)
- NMH  ≈ 0.71V  (noise margin high)
- NML  ≈ 0.68V  (noise margin low)
- Gain ≈ -18 V/V (at VM)

**What to record:** Take a screenshot of the DC transfer curve showing
the S-shaped transition. Measure VM using the cursor tool.

---

### Step 3: Transient Analysis (tb_transient.sp)

**What it measures:** tpHL, tpLH, trise, tfall

1. Open `testbenches/tb_transient.sp`
2. Press Run
3. Add traces: V(A) in blue, V(Y) in red
4. Use View → SPICE Error Log to see .MEAS results

**Expected results (TT, 1.8V, 25°C, 4fF load, 50ps input slew):**
- tpHL  ≈ 11–14 ps   (input rises, output falls)
- tpLH  ≈ 10–13 ps   (input falls, output rises)
- tpd   ≈ 12 ps       (average)
- tfall ≈ 9–11 ps
- trise ≈ 12–15 ps

**Key observation:** tpLH slightly faster than tpHL because PMOS (2µm wide)
has larger drive current than NMOS (1µm) when accounting for mobility.

---

### Step 4: PVT Corner Sweep (tb_pvt_corners.sp)

Run three times with different model files (instructions in the file):

| Run | Models Used | Corners Covered |
|-----|-------------|-----------------|
| 1   | FF          | FF/-40°C, FF/125°C |
| 2   | TT          | TT/25°C         |
| 3   | SS          | SS/125°C, SS/25°C, SS/-40°C |

For each run:
- Change `.TEMP` value manually (right-click temperature in schematic)
- Record tpHL, tpLH, tpd from SPICE Error Log

**Complete your characterization table:**

| PVT Corner        | VDD  | Temp  | tpHL (ps) | tpLH (ps) | tpd (ps) |
|-------------------|------|-------|-----------|-----------|----------|
| FF, 1.98V, -40°C  | 1.98 | -40°C | ~7        | ~6        | ~6       |
| FF, 1.98V, 125°C  | 1.98 | 125°C | ~9        | ~8        | ~8       |
| TT, 1.80V,  25°C  | 1.80 |  25°C | ~12       | ~11       | ~12      |
| SS, 1.62V, 125°C  | 1.62 | 125°C | ~22       | ~21       | ~22      |
| SS, 1.62V,  25°C  | 1.62 |  25°C | ~18       | ~17       | ~18      |
| SS, 1.62V, -40°C  | 1.62 | -40°C | ~16       | ~15       | ~16      |

**Replace estimated values above with your actual measured numbers.**

---

### Step 5: Liberty File

The `liberty/sky130_inv_tt_1v8_25c.lib` file is a standard NLDM (Non-Linear
Delay Model) Liberty file. It is used by:
- Synthesis tools (Yosys, Design Compiler) for timing-aware synthesis
- STA tools (OpenSTA, PrimeTime) for timing sign-off
- Place and route tools for path analysis

The 7x7 lookup tables (LUTs) encode cell delay as a function of:
- index_1: input slew (transition time)
- index_2: output load capacitance

This is the industry-standard characterization format. Every standard cell
in a real process PDK has a Liberty file generated by exactly this flow.

---

## Key Concepts Demonstrated

### 1. Balanced Inverter Design
The Wp/Wn=2 ratio ensures symmetric switching and VM≈VDD/2. This is the
fundamental sizing constraint taught in Weste & Harris (CMOS VLSI Design).

### 2. Noise Margin Analysis
NMH and NML quantify the inverter's ability to reject noise. Higher noise
margins = more robust logic. This matters in AMS designs where analog
noise couples into digital circuits.

### 3. PVT Variation
The 6-corner methodology covers:
- P (Process): FF (faster transistors) vs SS (slower)
- V (Voltage): ±10% of nominal
- T (Temperature): -40°C to 125°C (automotive grade range)

Critical paths must meet timing at SS (worst case for setup) and hold
constraints must be met at FF (worst case for hold).

### 4. Liberty NLDM Characterization
Industry standard for timing modeling. The 7x7 LUT captures delay
nonlinearity vs slew and load — critical for accurate STA.

---

## Connection to Layout (AMS Relevance)

In a real AMS layout flow, after physical implementation you would:

1. **Extract parasitics** (RC extraction using Calibre xRC or StarRC)
2. **Re-run all testbenches** with the extracted netlist
3. **Compare pre vs post-layout** delay — parasitics typically add 15-40%

The AOI222 project (Group 9, IIITD) showed this exact flow:
- Complex cell: pre→post power increase ~57% (TT corner)
- TPD was relatively stable due to dominant gate capacitance over wiring

---

## Interview Talking Points

When asked about this project:

1. **"Why Wp=2*Wn?"** → µp ≈ µn/2, need 2x width to match drive current
2. **"What is VM and why does it matter?"** → Switching threshold; VM≈VDD/2
   gives maximum noise margins and symmetric delay
3. **"What does the Liberty file give you?"** → Enables STA tools to compute
   path delays without re-running SPICE — essential for GHz-scale designs
4. **"What would change post-layout?"** → Wiring parasitics add capacitance
   to all nodes, increasing delay; EM rules constrain metal widths for
   reliability; antenna violations may require diode insertion
5. **"How does PVT affect your design?"** → SS corner is worst for setup
   timing (slow transistors + high load); FF corner worst for hold (fast
   launch + minimum data path)

---

## Tools Used
- **LTSpice XVII** (Analog Devices, free): SPICE simulation
- **SkyWater SKY130 PDK** (Google, open source): Device models
- **Liberty format**: IEEE standard for cell characterization

## References
- SkyWater PDK: https://github.com/google/skywater-pdk
- Liberty Reference: https://www.opensourceliberty.org/
- Weste & Harris, "CMOS VLSI Design", 4th Ed. — Ch. 5 (DC/Transient)
