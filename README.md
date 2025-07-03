# 64-bit IEEE 754 Floating Point Unit (FPU) in Verilog

This project implements a **64-bit IEEE 754-compliant Floating Point Unit (FPU)** in Verilog. It supports modular arithmetic operations (addition, subtraction, multiplication, division), a simple instruction set, program counter control, and memory interaction for instruction and data.
---

## Overview

The FPU supports:
- **Double-precision floating point arithmetic** (64-bit IEEE 754 format)
- Modular Verilog design
- Handling of **special cases**: zero, infinity, NaN, and denormalized numbers
- **Two Verilog testbenches** for functionality and edge-case validation

---

## 🧠 Instruction Format (16-bit)

| Bits      | Description                          |
|-----------|--------------------------------------|
| [15:3]    | Data Memory Address (13 bits)        |
| [2]       | Reserved for future operations       |
| [1:0]     | Operation Code (`op`)                |

## Supported Operations

| Operation      | `op` value |
|----------------|------------|
| Addition       | `2'b00`    |
| Subtraction    | `2'b01`    |
| Multiplication | `2'b10`    |
| Division       | `2'b11`    |

## 🧱 Memory Architecture

- **Instruction Memory**  
  - 256 words (16-bit each)
  - Contains instructions for FPU operation

- **Data Memory**  
  - 8192 words (128-bit each)
  - Each word contains two operands:  
    `[127:64]` → Operand A  
    `[63:0]`   → Operand B

- **Program Counter (PC)**  
  - 8-bit counter  
  - Increments every instruction cycle  
  - Resets synchronously on `reset` signal

---

## 📁 Project Structure

```bash
.
├── fpu.v                   # Top-level FPU module (with ADD, SUB, MUL, DIV logic)
├── program_counter.v       # 8-bit PC with synchronous reset
├── instruction_memory.v    # 16-bit-wide instruction memory (13+1+2 format)
├── data_memory.v           # 128-bit-wide data memory (stores 64-bit operand pairs) 
├── fpu_tb1.v               # Testbench 1 – basic arithmetic with real output
├── fpu_tb2.v               # Testbench 2 – Full-system test (PC, IM, DM + FPU)
└── README.md               # This file
