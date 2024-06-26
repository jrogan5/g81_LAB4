# g81_LAB4: Booth Myultiplier Written in VHDL

## Overview
This project implements a Booth Multiplier in VHDL. The Booth algorithm is a powerful algorithm used for multiplication of two binary numbers. It reduces the number of intermediate addition operations required for multiplication.

## Files
- `booth_multiplier.vhd`: This is the main VHDL file that contains the implementation of the Booth Multiplier.
- `booth_multiplier_tb.vhd`: This is the testbench file used for simulating and verifying the functionality of the Booth Multiplier.

## Requirements
- VHDL Simulator (ModelSim, GHDL, etc.)
- FPGA Board (optional)

## Usage
1. Clone the repository: `git clone https://github.com/username/booth_multiplier_vhdl.git`
2. Navigate to the project directory: `cd booth_multiplier_vhdl`
3. Compile the VHDL files: `vcom booth_multiplier.vhd booth_multiplier_tb.vhd`
4. Simulate the design: `vsim booth_multiplier_tb`
5. Run the simulation and observe the results.

## Testing
The testbench file `booth_multiplier_tb.vhd` contains test vectors to verify the functionality of the Booth Multiplier. It tests the multiplier with different combinations of inputs and compares the output with the expected result.