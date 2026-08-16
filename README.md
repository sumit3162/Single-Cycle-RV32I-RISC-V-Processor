# Single-Cycle RV32I RISC-V Processor

A clean, modular, single-cycle RV32I processor implemented in Verilog for learning, simulation, and portfolio use.

![RISC-V Processor](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/RISC-V_logo.svg/640px-RISC-V_logo.svg.png)

## Processor Block Diagram

![RV32I Single-Cycle Processor](https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/RISC-V_32bit_Instruction_Format.svg/1280px-RISC-V_32bit_Instruction_Format.svg.png)

### Image 1: RV32I instruction format

![Image 1](https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/RISC-V_32bit_Instruction_Format.svg/1280px-RISC-V_32bit_Instruction_Format.svg.png)

### Image 2: RISC-V architecture overview

![Image 2](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/RISC-V_logo.svg/640px-RISC-V_logo.svg.png)

## Overview

This project contains a minimal but educational single-cycle RISC-V core built from scratch in Verilog. It includes:

- 32-bit ALU
- 32x32 register file
- program counter
- opcode-based control decoder
- top-level CPU wiring with instruction memory and data memory
- waveform-capable testbench

The design targets the RV32I instruction subset and is intended as a foundation for further CPU development, including pipeline extensions, branch prediction, and advanced hazard handling.

## Project Structure

```text
riscv_single_cycle/
├── alu.v
├── regfile.v
├── pc.v
├── control.v
├── riscv_top.v
├── riscv_tb.v
├── README.md
└── riscv_waveform.vcd   (generated after simulation)
```

## What This Project Uses

This project uses:

- Verilog HDL
- Icarus Verilog for compilation and simulation
- GTKWave for waveform visualization
- A simple self-contained testbench for functional verification

## Requirements

### Windows

Install these tools:

1. Icarus Verilog
2. GTKWave

Run PowerShell as Administrator for package installation.

### Install on Windows (Chocolatey)

```powershell
choco install iverilog -y --no-progress
choco install gtkwave -y --no-progress
```

If Chocolatey is not available, install them using your preferred package manager or from official project pages.

## Run the Simulation

From the project folder:

```powershell
cd "C:\Users\shing\Downloads\elctronic\riscv_single_cycle"
iverilog -g2012 -Wall -o riscv_sim alu.v regfile.v pc.v control.v riscv_top.v riscv_tb.v
vvp riscv_sim
```

The testbench dumps waveforms automatically:

```verilog
$dumpfile("riscv_waveform.vcd");
$dumpvars(0, riscv_tb);
```

To open the waveform:

```powershell
gtkwave riscv_waveform.vcd
```

## Notes

- The current testbench is intentionally simple and acts as a starter environment for simulation.
- Register x0 is hard-wired to zero, as required by the RISC-V ABI.
- The processor is structured as a single-cycle architecture, so each instruction executes in one clock cycle (ignoring memory and control simplifications).

## Useful Resources

- RISC-V Foundation: https://riscv.org/
- RISC-V Instruction Set Manual: https://riscv.org/technical/specifications/
- Icarus Verilog: https://github.com/steveicarus/iverilog
- GTKWave: https://gtkwave.sourceforge.net/
- RISC-V Wikipedia: https://en.wikipedia.org/wiki/RISC-V

## Portfolio Notes

This design is suitable for:

- undergraduate digital design portfolios
- CPU architecture learning projects
- RTL design practice
- HDL verification demonstrations
- discussion of single-cycle datapath architecture

## License

This project is provided for educational and portfolio use. You may adapt and expand it freely for learning and demonstration purposes.
