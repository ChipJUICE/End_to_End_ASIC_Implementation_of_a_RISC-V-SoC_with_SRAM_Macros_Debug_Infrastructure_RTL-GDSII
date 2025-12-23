# 🧠 RISC-V SoC with TCM, Telemetry & Trace Infrastructure  
**RTL-to-GDSII ASIC Implementation for CubeSat On-Board Computing**

---

## 📌 Project Overview

This project implements a **custom RISC-V–based System-on-Chip (SoC)** featuring **Tightly Coupled Memory (TCM)**, **SRAM macros**, **performance telemetry**, and **on-chip debug/trace infrastructure**. The design is taken through a **complete RTL-to-GDSII ASIC flow**, targeting **advanced-node (TSMC 16nm-class) physical design constraints**.

The SoC was developed as part of a **CubeSat-oriented system proposal**, with the goal of demonstrating how a **compact, observable, and physically realistic ASIC SoC** can be architected for **small satellite on-board computing (OBC)** applications.

This project emphasizes **end-to-end SoC design competence**, spanning:
- RTL architecture and integration
- Debug- and telemetry-aware hardware design
- Synthesis, STA, and timing closure
- Macro-aware physical design
- Sign-off–ready layout practices

---

## 🛰️ Application Context: CubeSat On-Board Computing (OBC)

### 🎯 Purpose of This SoC

CubeSat platforms operate under **strict constraints** on:
- Power
- Area
- Reliability
- Debug visibility (post-deployment)

This SoC is architected to reflect **realistic CubeSat OBC requirements**, prioritizing:
- **Deterministic execution** via TCM instead of cache hierarchies
- **Low-latency memory access**
- **Hardware-based telemetry and performance monitoring**
- **On-chip debug and trace visibility**
- **Macro-heavy ASIC-style physical design**

Rather than focusing on application software, the project focuses on **hardware architecture and physical implementation readiness**, closely mirroring **how aerospace and space-grade SoCs are developed and evaluated pre-silicon**.

> ⚠️ Note: This design is **not radiation-hardened**, but is **architecturally representative** of CubeSat-class SoCs used for research, prototyping, and methodology validation.

---

## 🧠 Why This Architecture Fits CubeSat Systems

| CubeSat Requirement | Design Choice |
|-------------------|--------------|
| Limited power budget | Simple in-order RISC-V core |
| Predictable execution | TCM instead of caches |
| In-field observability | On-chip trace buffer & telemetry |
| Fault monitoring | MMIO-accessible performance counters |
| Compact form factor | Macro-aware floorplanning |
| ASIC realism | SRAM macros + full RTL→GDSII flow |

---

## 🏗️ SoC Architecture

### Top-Level Block: `riscv_tcm_top`

The SoC integrates the following subsystems:

- **RISC-V Core**
  - Modular pipeline (decode, execute, ALU, CSR, control)
  - CSR access, debug hooks, and trace visibility
- **Tightly Coupled Memory (TCM)**
  - Low-latency instruction/data memory
  - Implemented using single-port SRAM macros
- **SRAM Macro Subsystem**
  - Multiple SRAM macros explicitly instantiated
  - Macro-aware placement, power planning, and routing
- **Telemetry & Performance Monitoring**
  - Hardware performance counters
  - MMIO-based access
- **Debug & Trace Infrastructure**
  - Instruction trace buffer
  - Debug telemetry aggregation
- **Interconnect & Debug Ports**
  - AXI-style debug port muxing
  - Performance MMIO adapter

---

## 🧩 Major RTL Modules

| Module | Description |
|------|-------------|
| `riscv_core.v` | Top-level RISC-V core integration |
| `riscv_decode.v` | Instruction decode logic |
| `riscv_alu.v` | Arithmetic and logic unit |
| `riscv_csr.v` | Control and Status Registers |
| `riscv_pipe_ctrl.v` | Pipeline control and hazards |
| `tcm_mem.v` | TCM memory wrapper |
| `tcm_sram32k_sp.v` | SRAM macro interface |
| `trace_buffer.sv` | Instruction trace buffer |
| `telemetry_counters.sv` | Performance counters |
| `Debug_Telemetry.sv` | Debug + telemetry aggregation |
| `perf_mmio_adapter.v` | MMIO adapter for counters |
| `dport_axi.v` / `dport_mux.v` | Debug port routing |

---

## 🔄 Design Flow (RTL → GDSII)

### 1️⃣ RTL Design & Integration
- Hierarchical Verilog/SystemVerilog RTL
- Macro-safe coding style (`dont_touch`, macro preservation)
- Debug and telemetry integrated at SoC level

### 2️⃣ Functional Readiness
- Clean elaboration
- Stable hierarchy preservation
- Verified macro instantiations pre-synthesis

### 3️⃣ Logic Synthesis
- Synopsys Design Compiler / Cadence Genus
- TSMC 16nm-class standard-cell and SRAM libraries
- Constraint-driven synthesis (SDC)
- Gate-level netlist generation
- RTL ↔ netlist equivalence checks

### 4️⃣ Static Timing Analysis (STA)
- Pre- and post-route STA
- Setup and hold verification
- Clock uncertainty and realistic I/O constraints

### 5️⃣ Physical Design
- Cadence Innovus
- Macro-aware floorplanning
- Explicit SRAM macro placement
- Power planning (rings, stripes, macro PG handling)
- Placement, CTS, and routing
- Post-route optimization and slack closure
- DRC-clean routed layout

### 6️⃣ Sign-Off & Tapeout Preparation
- DRC verification
- LVS-ready layout practices
- Final GDSII generation
- Post-route reports and SDF archived

---

## 🧪 Physical Design Challenges Addressed

- Macro-aware floorplanning and routing congestion
- SRAM power/ground connectivity
- CTS with macro blockages
- DRC cleanup after detailed routing
- Setup and hold timing closure
- Debug and telemetry routing without timing degradation

---

## 🛠️ Tools & Technologies

### Languages
- Verilog
- SystemVerilog
- TCL (EDA automation)

### EDA Tools
- Cadence Genus (Synthesis)
- Cadence Innovus (Physical Design)
- Cadence Tempus (STA)
- Synopsys Design Compiler
- Equivalence checking flows
- Xcelium / ModelSim (simulation readiness)

### Technology
- TSMC 16nm-class PDK  
  (Standard Cells + SRAM Macros)

---

## 🎯 Key Learning Outcomes

- End-to-end ASIC implementation of a RISC-V SoC
- Practical handling of SRAM macros in advanced nodes
- Debug-first SoC architecture design
- Industry-standard RTL → GDSII flow execution
- Realistic physical design closure experience

---

## 🚀 Future Enhancements

- MBIST integration for SRAM macros
- Formal verification of debug paths
- Post-route power analysis (IR drop / EM)
- Low-power techniques (clock gating, power domains)
- OpenROAD / OpenLane comparative flow

---

## 👤 Author

**Naveen Kumar Senthil Kumar**  
M.S. Computer Engineering — NYU Tandon  

Focus Areas:  
**VLSI • SoC Design • Physical Design • RISC-V**

GitHub: https://github.com/ChipJUICE
