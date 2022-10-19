# Reference Design for a modified version of ASAP7nm 
This repository contains a reference block design for a modified version of the ASAP7nm library. The ASAP7nm library/PDK was developed by ASU and all credits go to them. 

Here we provide a modified version of their 7nm technology. The differences are many:
* layers M4/M5/M6/M7 are colored in the tech lef.
* density rules are introduced, for max and min cases.


A reference design is provided as well (SHA256). The design is synthesized in Genus at 1.66GHz and it is possible to close timing on Innovus also at 1.66GHz.
A reference implementation script is also provided for Cadence Innovus. The script is *complete*, in the sente that it provides:
* power ring in M6-M7
* follow pin routing in stapled style (M2-VIA-M1)
* vertical stripes in M3
* horizontal stripes in M4
* signal routing in M2-M7
* placement of tap cells
* traditional Place->CTS->Route flow


| Innovus version | Floorplan     | DRCs          | Setup         | Hold          | Density |
|-----------------|---------------|---------------|---------------|---------------|---------|
| 17.11 |         {194.04 194.04} | FAIL (12)     | PASS (+0.002) | PASS (+0.029) | 76.88%  |
| 18.10 | 	  {194.04 194.04} | FAIL (3)      | PASS (+0.012) | PASS (+0.024) | 76.46%  |
| 19.11 |	  {194.04 194.04} | PASS (0/24\*) | PASS (+0.015) | PASS (+0.021) | 75.86%  | 
| 20.11 |	  {194.04 194.04} | FAIL (6)      | PASS (+0.016) | PASS (+0.018) | 77.01%  | 
| 21.11 | 	  {194.04 194.04} | FAIL (9)      | PASS (+0.002) | PASS (+0.023) | 77.25%  | 
|-|-|-|-|-|-|
| 21.11 | 	  {183.24 183.24} | FAIL (15)     | PASS (+0.004) | PASS (+0.023) | 85.15%  |
| 21.11 | 	  {172.44 172.44} | FAIL (33)     | FAIL (-0.066) | PASS (+0.021) | 94.40%  |


\* False positive color violations on power grid

The designs above often fail to route due to pin access issues. All DRCs have the same "pattern" and can be fixed with *some* manual effort. 
This repository also includes two Innovus databases of the same SHA design implemented in version 19.11 and 20.11. Both databases are DRC clean. Check the folder /db/


> - FP box of {0.0 0.0 172.44 172.44} means 150 std cell rows.
> - FP box of {0.0 0.0 183.24 183.24} means 160 std cell rows.
> - FP box of {0.0 0.0 194.04 194.04} means 170 std cell rows.
