* ============================================================
* CMOS Inverter — Full Custom Cell
* Technology : SkyWater SKY130 (130nm)
* VDD        : 1.8V
* Cell Name  : INV_X1
*
* Sizing rationale:
*   NMOS: W=1.0um / L=0.15um  (minimum length, 1x drive)
*   PMOS: W=2.0um / L=0.15um  (2x NMOS to balance rise/fall,
*         compensates for lower hole mobility ~2x lower than electron)
*
* Finger count: 1 finger each (expandable for drive strength)
* ============================================================

.SUBCKT INV_X1 A Y VDD VSS
* PMOS pull-up network
MP1 Y A VDD VDD sky130_fd_pr__pfet_01v8__tt W=2.0u L=0.15u

* NMOS pull-down network  
MN1 Y A VSS VSS sky130_fd_pr__nfet_01v8__tt W=1.0u L=0.15u
.ENDS INV_X1

* ============================================================
* INV_X2 — 2x drive strength (double fingers)
* ============================================================
.SUBCKT INV_X2 A Y VDD VSS
MP1 Y A VDD VDD sky130_fd_pr__pfet_01v8__tt W=4.0u L=0.15u
MN1 Y A VSS VSS sky130_fd_pr__nfet_01v8__tt W=2.0u L=0.15u
.ENDS INV_X2

* ============================================================
* INV_X4 — 4x drive strength
* ============================================================
.SUBCKT INV_X4 A Y VDD VSS
MP1 Y A VDD VDD sky130_fd_pr__pfet_01v8__tt W=8.0u L=0.15u
MN1 Y A VSS VSS sky130_fd_pr__nfet_01v8__tt W=4.0u L=0.15u
.ENDS INV_X4
