* ============================================================
* Testbench 3: PVT Corner Sweep
*
* Run this file THREE times in LTSpice by editing 2 things each time:
*
* RUN 1 — FF corner:
*   Step A: In inv_sky130.sp, change model names to __ff
*   Step B: Change .TEMP below to -40 (then re-run at 125)
*   Step C: Change VDD to 1.98
*
* RUN 2 — TT corner (default, no changes needed):
*   .TEMP 25, VDD=1.8, models=__tt
*
* RUN 3 — SS corner:
*   Step A: In inv_sky130.sp, change model names to __ss
*   Step B: Change .TEMP to 125 (then re-run at 25, then -40)
*   Step C: Change VDD to 1.62
*
* Record tpHL, tpLH, tpd from View > SPICE Error Log after each run.
*
* TARGET TABLE TO FILL IN (replace ?? with your values):
*
* Corner          | VDD  | Temp  | tpHL(ps) | tpLH(ps) | tpd(ps)
* FF 1.98V -40C   | 1.98 | -40   |    ??    |    ??    |   ??
* FF 1.98V 125C   | 1.98 | 125   |    ??    |    ??    |   ??
* TT 1.80V  25C   | 1.80 |  25   |    ??    |    ??    |   ??
* SS 1.62V 125C   | 1.62 | 125   |    ??    |    ??    |   ??
* SS 1.62V  25C   | 1.62 |  25   |    ??    |    ??    |   ??
* SS 1.62V -40C   | 1.62 | -40   |    ??    |    ??    |   ??
* ============================================================

.TITLE PVT Corner Sweep INV_X1 Sky130

* ---- STEP 1: Include models (change __tt to __ff or __ss per run) ----
.lib 'sky130_fd_pr.lib'
.inc 'inv_sky130.sp'

* ---- STEP 2: Set VDD for corner (1.98=FF, 1.80=TT, 1.62=SS) ----
VDD VDD 0 DC 1.8

VSS VSS 0 DC 0

* ---- STEP 3: Input pulse referenced to VDD ----
VIN A 0 PULSE(0 1.8 0.1n 50p 50p 1n 2n)

CL Y 0 4f

XINV A Y VDD VSS INV_X1

* ---- STEP 4: Set temperature (-40, 25, or 125) ----
.TEMP 25

.TRAN 1p 6n

* Measurements - threshold at VDD/2 = 0.9V (update to 0.99 for FF, 0.81 for SS)
.MEAS TRAN tpHL TRIG V(A) VAL=0.9 RISE=1 TARG V(Y) VAL=0.9 FALL=1
.MEAS TRAN tpLH TRIG V(A) VAL=0.9 FALL=1 TARG V(Y) VAL=0.9 RISE=1
.MEAS TRAN tpd  PARAM='(tpHL + tpLH)/2'
.MEAS TRAN tfall TRIG V(Y) VAL=1.44 FALL=1 TARG V(Y) VAL=0.36 FALL=1
.MEAS TRAN trise TRIG V(Y) VAL=0.36 RISE=1 TARG V(Y) VAL=1.44 RISE=1

.END
