# 64-bit IEEE 754 Floating Point Unit (FPU) in Verilog

This project implements a **64-bit IEEE 754-compliant Floating Point Unit (FPU)** in Verilog. It supports modular arithmetic operations (addition, subtraction, multiplication, division), a simple instruction set, program counter control, and memory interaction for instructions and data.

---

## Overview

The FPU supports:
- **Double-precision floating point arithmetic** (64-bit IEEE 754 format)
- **Modular Verilog design** — separate units for add/sub, multiply, and divide, combined behind one top-level mux
- Handling of **special cases**: zero, infinity, NaN, and denormalized numbers
- A tiny fetch–decode–execute pipeline (`ProgramCounter` → `InstructionMemory` → `DataMemory` → `FPU`)
- **Three Verilog testbenches** covering direct arithmetic, edge cases, and full-system integration

---

## Architecture

```text
                     ┌──────────────┐
   a[63:0] ─────────▶│              │
   b[63:0] ─────────▶│   FPU_ADD_SUB│───▶ add_sub_result
                     │              │
                     └──────────────┘
                     ┌──────────────┐
   a[63:0] ─────────▶│   FPU_MUL    │───▶ mul_result ──┐
   b[63:0] ─────────▶│              │                  │
                     └──────────────┘                  ├──▶ [op mux] ──▶ result
                     ┌──────────────┐                  │
   a[63:0] ─────────▶│   FPU_DIV    │───▶ div_result ──┘
   b[63:0] ─────────▶│              │
                     └──────────────┘
```

All three units compute combinationally and in parallel on every input change; the `op` code only selects which result reaches the output — it does not gate or power down the unused units.

---

## 🧠 Instruction Format (16-bit)

| Bits      | Description                          |
|-----------|---------------------------------------|
| [15:3]    | Data Memory Address (13 bits)         |
| [2]       | Reserved for future use               |
| [1:0]     | Operation Code (`op`)                 |

## Supported Operations

| Operation      | `op` value |
|----------------|------------|
| Addition       | `2'b00`    |
| Subtraction    | `2'b01`    |
| Multiplication | `2'b10`    |
| Division       | `2'b11`    |

---

## 🧱 Memory Architecture

- **Instruction Memory**
  - 256 words (16-bit each), addressed by an 8-bit `ProgramCounter`
  - Each word encodes a data-memory address + opcode (see format above)
- **Data Memory**
  - 8192 words (128-bit each), addressed by the 13-bit field pulled from the instruction
  - Each word packs two 64-bit operands: `[127:64]` = Operand A, `[63:0]` = Operand B
- **Program Counter (PC)**
  - 8-bit counter, increments once per clock, synchronous reset

---

## 📁 Project Structure

```bash
.
├── fpu.v                   # Top-level FPU module (ADD, SUB, MUL, DIV logic)
├── data_memory.v           # 128-bit-wide data memory (stores 64-bit operand pairs)
├── instruction_memory.v    # 16-bit-wide instruction memory (13+1+2 format)
├── program_counter.v       # 8-bit PC with synchronous reset
├── fpu_tb1.v               # Testbench 1 – basic arithmetic with real-valued output
├── fpu_tb2.v               # Testbench 2 – extended tests with edge cases (NaN, div-by-zero, negatives)
├── fpu_tb3.v               # Testbench 3 – full-system test (PC + instruction/data memory + FPU)
└── README.md               # This file
```

---

## 🧩 Module Reference

### `FPU` (top level)
Instantiates `FPU_ADD_SUB`, `FPU_MUL`, and `FPU_DIV` in parallel and muxes the correct result to `result` based on `op`. Does not currently expose any of the internal `invalid` / `Exception` / `Overflow` / `Underflow` flags at the top level.

### `FPU_ADD_SUB`
Unpacks both operands (with denormal-aware hidden-bit handling), flips `b`'s sign for subtraction, detects NaN and Infinity inputs, aligns mantissas by shifting on the exponent difference, adds or subtracts magnitudes based on sign comparison, then renormalizes (handling both mantissa-overflow-by-one and leading-zero cancellation cases) before repacking the result. No guard/round/sticky rounding is implemented — alignment shifts truncate rather than round.

### `FPU_MUL`
Unpacks operands, multiplies 53-bit significands into a 106-bit product, normalizes by checking the top bit, rounds using a guard-bit + sticky-bit ("round half up when a nonzero remainder exists") scheme, computes the combined exponent with bias correction, and flags overflow/underflow using the sign bits of an intentionally oversized 12-bit exponent register. NaN/Infinity inputs currently collapse to a `0` result rather than propagating.

### `FPU_DIV`
Unpacks operands, scales the dividend by `2^53` before integer division to preserve 53 fractional bits, computes an initial exponent estimate, normalizes the quotient by shifting until the leading bit is found, and extracts the 52 post-normalization bits as the stored fraction. Divide-by-zero and zero-dividend are special-cased directly to hardcoded `+Infinity` / `+0` patterns (see [Known limitations](#known-limitations) — the sign bit is not applied in either case, and there's no separate NaN/Infinity input handling or exponent overflow/underflow check).

### `DataMemory` / `InstructionMemory` / `ProgramCounter`
Simple combinational-read memories and a free-running synchronous counter, described in [Memory Architecture](#-memory-architecture) above.

### Testbenches
- **`FPU_TB1`** — direct stimulus, one pair per operation, prints real-valued results via `$bitstoreal`.
- **`FPU_TB2`** — direct stimulus with a `print_result` task, extended to negative operands, divide-by-zero, zero-numerator division, and one NaN case.
- **`FPU_TB3`** — full integration test driving the PC/instruction-memory/data-memory pipeline into the FPU over 4 clock cycles.

---

## 🚀 Running the Testbenches

With Icarus Verilog:
```bash
iverilog -o fpu_sim fpu.v fpu_tb1.v
vvp fpu_sim
```
Swap in `fpu_tb2.v` or (`fpu_tb3.v` plus `data_memory.v`, `instruction_memory.v`, `program_counter.v`) as needed. `FPU_TB1` and `FPU_TB3` also emit a `.vcd` waveform file for viewing in GTKWave.

---
