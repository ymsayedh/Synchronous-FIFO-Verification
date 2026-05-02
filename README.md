# Synchronous FIFO Verification — SystemVerilog

> A structured SystemVerilog testbench for verifying a parameterizable synchronous FIFO, featuring constrained-random stimulus, a reference model scoreboard, functional coverage, and SVA assertions.
---

## Overview

This project verifies a synchronous FIFO design using a UVM-inspired layered testbench written in SystemVerilog. The testbench applies constrained-random stimulus, checks output correctness through a golden reference model, collects functional coverage, and monitors design behavior through SystemVerilog assertions embedded in the DUT.

---

## Features

- Parameterizable FIFO: configurable width (default: 16-bit) and depth (default: 8 entries)
- Constrained-random stimulus with configurable read/write enable distributions
- Layered testbench: transaction class, monitor, scoreboard, coverage collector, and top module
- Reference model to verify data_out correctness
- SVA assertions covering all output flags and internal counters
- Cross functional coverage across write enable, read enable, and all 7 output control signals
- 100% code coverage, functional coverage, and assertion coverage achieved
- RTL bugs detected and fixed — before/after documented

---

## Testbench Architecture

```
Top Module
├── DUT (FIFO)
├── TB (driver — resets DUT, randomizes inputs)
└── Monitor
    ├── FIFO_transaction  (captures inputs & outputs)
    ├── FIFO_scoreboard   (reference model + checker)
    └── FIFO_coverage     (functional coverage collection)
```

---

## FIFO Ports

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| clk | Input | — | Clock signal |
| rst_n | Input | — | Active-low asynchronous reset |
| data_in | Input | Sequential | Write data bus |
| wr_en | Input | — | Write enable |
| rd_en | Input | — | Read enable |
| data_out | Output | Sequential | Read data bus |
| full | Output | Combinational | FIFO is full |
| almostfull | Output | Combinational | One write away from full |
| empty | Output | Combinational | FIFO is empty |
| almostempty | Output | Combinational | One read away from empty |
| overflow | Output | Sequential | Write rejected — FIFO full |
| underflow | Output | Sequential | Read rejected — FIFO empty |
| wr_ack | Output | Sequential | Write request succeeded |

---

## Assertions Coverage

SVA assertions verify the following inside the DUT:

- Reset behavior — pointers and counters clear to 0 on rst_n
- Write acknowledge — wr_ack asserts on successful write
- Overflow — asserts when write attempted on full FIFO
- Underflow — asserts when read attempted on empty FIFO
- Empty / Full flags — tied to internal count
- Almost empty / Almost full thresholds
- Pointer wraparound and threshold bounds

---

## Simulation

Simulated using **Questa Sim**. A `.do` file automates compilation, simulation, and coverage report generation.

To run:
```
vsim -do run.do
```

Coverage reports verify 100% code, functional, and assertion coverage.
