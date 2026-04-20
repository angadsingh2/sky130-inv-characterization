* ============================================================
* Testbench 2: Transient Analysis — Propagation Delay & Slew
*
* Extracts:
*   tpHL = propagation delay high-to-low
*   tpLH = propagation delay low-to-high
*   trise = output rise time (20% to 80% of VDD)
*   tfall = output fall time (80% to 20% of VDD)
*   tpd   = average propagation delay
*
* HOW TO RUN:
*   Open in LTSpice, press Run
*   Add traces: V(A) and V(Y)
*   Use cursors at 50% of VDD = 0.9V to measure delays
*   Check View > SPICE Error Log for .MEAS results
* ============================================================

.TITLE Transient Characterization INV_X1 Sky130 TT 25C

.lib 'sky130_fd_pr.lib'
.inc 'inv_sky130.sp'

VDD VDD 0 DC 1.8
VSS VSS 0 DC 0

VIN A 0 PULSE(0 1.8 0.1n 50p 50p 1n 2n)

CL Y 0 4f

XINV A Y VDD VSS INV_X1

.TEMP 25

.TRAN 1p 6n

.MEAS TRAN tpHL TRIG V(A) VAL=0.9 RISE=1 TARG V(Y) VAL=0.9 FALL=1
.MEAS TRAN tpLH TRIG V(A) VAL=0.9 FALL=1 TARG V(Y) VAL=0.9 RISE=1
.MEAS TRAN tpd  PARAM='(tpHL + tpLH) / 2'
.MEAS TRAN tfall TRIG V(Y) VAL=1.44 FALL=1 TARG V(Y) VAL=0.36 FALL=1
.MEAS TRAN trise TRIG V(Y) VAL=0.36 RISE=1 TARG V(Y) VAL=1.44 RISE=1

.END
