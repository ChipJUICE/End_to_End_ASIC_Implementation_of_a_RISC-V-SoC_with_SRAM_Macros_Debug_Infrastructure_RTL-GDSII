# 🧠 RISC-V SoC with TCM, Telemetry & Trace Infrastructure  
**RTL to GDSII Implementation using Industry-Standard EDA Tools**

## 📌 Project Overview

This project implements a **custom RISC-V–based System-on-Chip (SoC)** featuring tightly coupled memory (TCM), SRAM macros, performance telemetry, and on-chip debug/trace infrastructure. The design is developed and validated through a **complete RTL-to-GDSII ASIC flow**, targeting **advanced-node (TSMC 16nm-class) physical design constraints**.

The primary objective of this project is to demonstrate **end-to-end SoC design competence**, spanning **RTL architecture, verification readiness, synthesis, timing closure, physical design, and sign-off checks**, with emphasis on **macro-heavy layouts and debug-aware SoC design**.

---

## 🏗️ SoC Architecture

### Top-Level Block: `riscv_tcm_top`

The SoC integrates the following major subsystems:

- **RISC-V Core**
  - Modular pipeline with decode, execute, ALU, CSR, and control logic
  - Supports CSR access, debug hooks, and trace visibility
- **Tightly Coupled Memory (TCM)**
  - Low-latency instruction/data memory
  - Implemented using single-port SRAM macros
- **SRAM Macro Subsystem**
  - Multiple SRAM macros instantiated and floorplanned explicitly
  - Macro-aware power, placement, and routing strategies
- **Telemetry & Performance Monitoring**
  - Hardware performance counters
  - MMIO-based telemetry access
- **Debug & Trace Infrastructure**
  - Trace buffer for execution visibility
  - Debug telemetry aggregation
- **Interconnect & Debug Ports**
  - AXI-style debug port muxing
  - Performance MMIO adapter

---

## 🧩 Major RTL Modules

| Module | Description |
|------|-------------|
| riscv_core.v | Top RISC-V core integration |
| riscv_decode.v | Instruction decode logic |
| riscv_alu.v | Arithmetic & logic execution unit |
| riscv_csr.v | Control & Status Register logic |
| riscv_pipe_ctrl.v | Pipeline control & hazard logic |
| tcm_mem.v | TCM memory wrapper |
| tcm_sram32k_sp.v | SRAM macro interface |
| trace_buffer.sv | Instruction trace buffer |
| telemetry_counters.sv | Performance counters |
| Debug_Telemetry.sv | Debug + telemetry aggregation |
| perf_mmio_adapter.v | MMIO interface for counters |
| dport_axi.v / dport_mux.v | Debug port routing |

---

## 🔄 Design Flow (RTL → GDSII)

### 1️⃣ RTL Design & Integration
- Hierarchical RTL in Verilog/SystemVerilog
- Macro-safe coding style (`dont_touch`, `is_macro_cell`)
- Debug and telemetry blocks integrated at SoC level

### 2️⃣ Functional Readiness
- Clean elaboration and hierarchy preservation
- Macro instantiations verified pre-synthesis

### 3️⃣ Logic Synthesis
- Synopsys Design Compiler / Cadence Genus
- Targeted TSMC 16nm standard-cell & SRAM libraries
- Constraint-driven synthesis using SDC
- Generated gate-level netlist
- RTL ↔ Netlist equivalence checks

### 4️⃣ Static Timing Analysis (STA)
- Pre- and post-route timing analysis
- Setup and hold verification
- Clock uncertainty and realistic IO constraints

### 5️⃣ Physical Design
- Cadence Innovus
- Floorplanning with explicit SRAM macro placement
- Power planning (rings, stripes, macro PG handling)
- Placement, CTS, and routing
- DRC-clean routed layout
- Post-route optimization and slack closure

### 6️⃣ Sign-Off & Tapeout Preparation
- DRC verification
- LVS-ready layout practices
- Final GDSII generation
- Post-route SDF and reports archived

---

## 🧪 Physical Design Challenges Addressed

- Macro-aware floorplanning and routing
- SRAM power/ground connectivity
- Clock tree synthesis with macro obstacles
- DRC cleanup after detailed routing
- Timing closure under realistic constraints
- Debug/telemetry routing without congestion

---

## 🛠️ Tools & Technologies

**Languages**
- Verilog, SystemVerilog
- TCL (EDA automation)

**EDA Tools**
- Cadence Genus (Synthesis)
- Cadence Innovus (Physical Design)
- Cadence Tempus (STA)
- Synopsys Design Compiler
- Conformal-style equivalence flow
- Xcelium / ModelSim

**Technology**
- TSMC 16nm-class PDK (Standard Cells + SRAM macros)

---

## 🎯 Key Learning Outcomes

- End-to-end ASIC implementation of a RISC-V SoC
- Real-world handling of SRAM macros in advanced nodes
- Debug-first SoC design with telemetry and trace support
- Hands-on experience with industry-standard Cadence/Synopsys flows
- Practical understanding of physical design closure

---

## 🚀 Future Enhancements

- MBIST integration for SRAM macros  
- Formal verification of debug paths  
- Power analysis (IR drop / EM)  
- Low-power features (clock gating, power domains)  
- OpenROAD/OpenLane comparative flow  

---

## 👤 Author

**Naveen Kumar Senthil Kumar**  
M.S. Computer Engineering — NYU Tandon  
Focus Areas: VLSI • SoC Design • Physical Design • RISC-V  

GitHub: https://github.com/ChipJUICE
