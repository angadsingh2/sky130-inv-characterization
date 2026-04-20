* ============================================================
* Testbench 1: DC Transfer Curve
* Extracts: VM (switching threshold), NMH, NML, DC Gain
*
* HOW TO RUN IN LTSpice:
*   File > Open > tb_dc_transfer.sp
*   Run simulation (green play button)
*   View V(Y) vs V(A) on waveform viewer
*
* WHAT TO MEASURE FROM WAVEFORM:
*   VM  = input voltage where V(Y) = V(A) (crossing point)
*   VOH = output high = VDD = 1.8V
*   VOL = output low  = 0V
*   VIH = input where dVout/dVin = -1 on high side
*   VIL = input where dVout/dVin = -1 on low side
*   NMH = VOH - VIH
*   NML = VIL - VOL
*   Gain = max |dVout/dVin| in transition region
* ============================================================

.TITLE DC Transfer Curve INV_X1 Sky130

.lib 'sky130_fd_pr.lib'
.inc 'inv_sky130.sp'

VDD VDD 0 DC 1.8
VSS VSS 0 DC 0

VIN A 0 DC 0

CL Y 0 4f

XINV A Y VDD VSS INV_X1

.DC VIN 0 1.8 0.001

.MEAS DC VM FIND V(A) WHEN V(Y)=V(A) CROSS=1
.MEAS DC GAIN_AT_VM FIND DERIV(V(Y)) WHEN V(A)=VM
.MEAS DC VIL FIND V(A) WHEN DERIV(V(Y))=-1 CROSS=1
.MEAS DC VIH FIND V(A) WHEN DERIV(V(Y))=-1 CROSS=2
.MEAS DC NMH PARAM='1.8 - VIH'
.MEAS DC NML PARAM='VIL - 0'

.END
