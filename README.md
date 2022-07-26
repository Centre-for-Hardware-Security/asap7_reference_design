# asap7_reference_design
This repository contains a reference block design for a modified version of the ASAP7nm library.



The ASAP7NM library/PDK was developed by ASU and all credits go to them. Here we provide a modified version of that technology, where the technology LEF file has been modified.
A reference design is provided as well (SHA256).
A reference implementation script is also provided for Cadence Innovus.

The results look like this:

| Innovus version | Floorplan | DRCs | 	Setup | Hold | Density |
|-----------------|-----------|------|--------|------|---------|
| 17.11 | {0.0 0.0 170.28 170.28} | FAIL (77*) | PASS (0.012) | PASS (0.020) | 90.82% |
| 18.10 | {0.0 0.0 170.28 170.28} | FAIL (44) | PASS (0.015) | PASS (0.022) | 89.98% |

