Custom 10-bit ISA Processor 🚀
A fully functional single-cycle processor implementing a custom MIPS and RISC-V inspired 10-bit Instruction Set Architecture, built in Verilog HDL, simulated and synthesized with Xilinx Vivado, and deployed on the Nexys A7 FPGA.
> Developed as part of coursework at **COMSATS University Islamabad – Wah Campus**, mentored by **Sir Ali Roman**.
---
📚 Project Overview
This project constructs a simple yet complete single-cycle processor that executes R-Type, I-Type, and J-Type instructions. It emphasizes clarity, modularity, and practical demonstration of computer architecture principles — from instruction fetch all the way through writeback.
Feature	Details
Word Size	10-bit
Instruction Width	10-bit
Instruction Types	R-Type, I-Type, J-Type
FPGA Board	Nexys A7 (Artix-7 XC7A100TCSG324-1)
Development Tools	Verilog HDL, Xilinx Vivado
Simulation	Vivado Simulator
---
🏗 Architecture
The processor follows a classical single-cycle datapath design. Every instruction completes in exactly one clock cycle — control signals are combinationally derived from the opcode, and data flows through the datapath in a single pass.
```
Instruction Memory → Instruction Decoder → Control Unit
                                        ↓
                          Register File → ALU → Data Memory → Writeback
                                        ↑
                                  Program Counter
```
---
🛠 Core Components
ALU (Arithmetic Logic Unit)
Supports 8 operations: `ADD`, `SUB`, `MUL`, `XOR`, `SPLIT`, `MOD2`, `PASS`, and `INCR`.
Register File
8 registers, each 10 bits wide. Supports dual-read, single-write in a single cycle.
Program Counter (PC)
Handles sequential execution, unconditional jumps, and conditional branches (BEQ, BNE).
Instruction Decoder
Splits the 10-bit instruction word into opcode, source registers, destination register, and immediate fields.
Control Unit
Generates all control signals (ALUSrc, MemWrite, RegWrite, Branch, Jump, etc.) combinationally from the opcode.
Instruction Memory
64 × 10-bit ROM — holds the program to execute.
Data Memory
256 × 10-bit RAM — used for LOAD and STORE operations.
---
📜 Instruction Set Reference
Opcode	Mnemonic	Type	Operation
`0000`	HALT	—	Stop execution
`0001`	ADD	R	SRC1 + SRC2 → DST
`0010`	MUL	R	SRC1 × SRC2 → DST
`0011`	SUB	R	SRC1 − SRC2 → DST
`0100`	SET	I	Load immediate into DST
`0101`	SPLIT	R	Extract upper/lower 5 bits
`0110`	LOAD	I	Data Memory[addr] → DST
`0111`	STORE	I	SRC → Data Memory[addr]
`1000`	BEQ	I	Branch if DST == 0
`1001`	JUMP	J	Unconditional jump
`1010`	MOD2	R	Check if even (LSB test)
`1011`	INCR	R	DST = DST + 1
`1100`	BNE	I	Branch if DST ≠ 0
Full encoding details are in `docs/instruction_set_manual.md`.
---
🧩 Repository Structure
```
custom-10bit-isa-fpga/
├── docs/
│   ├── architecture_overview.md       # Full datapath and control description
│   ├── instruction_set_manual.md      # Instruction encoding and field layout
│   └── design_flow.md                 # Simulation results and design decisions
├── src/
│   ├── alu.v                          # Arithmetic Logic Unit
│   ├── control.v                      # Control Unit (combinational)
│   ├── data_memory.v                  # 256×10-bit RAM
│   ├── instruction_decoder.v          # Instruction field splitter
│   ├── instruction_memory.v           # 64×10-bit ROM
│   ├── mux8x1.v                       # 8-to-1 multiplexer
│   ├── dff_10bit.v                    # D flip-flop (10-bit)
│   ├── program_counter.v              # PC with branch/jump logic
│   ├── reg_file.v                     # 8-register file
│   └── processor.v                    # Top-level integration
├── constraints/
│   └── Processor.xdc                  # Nexys A7 pin constraints
├── simulation and Other/              # Simulation waveforms and outputs
├── .gitignore
├── LICENSE
└── ReadMe.md
```
---
🛠 How to Build and Run
1. Clone this Repository
```bash
git clone https://github.com/Engrr2025/custom-10bit-isa-fpga.git
cd custom-10bit-isa-fpga
```
2. Open in Vivado
Launch Xilinx Vivado and create a new project.
Add all `.v` files from the `src/` directory as design sources.
Apply the `constraints/Processor.xdc` constraints file.
Set `processor.v` as the top module.
3. Simulate (Optional but Recommended)
Create a testbench or use the provided simulation files.
Run Behavioral Simulation in Vivado to verify instruction execution.
Check waveforms for PC progression, register writes, and memory accesses.
4. Synthesize and Implement
Run Synthesis → Implementation → Generate Bitstream in sequence.
5. Program the FPGA
Connect the Nexys A7 via USB.
Open Vivado Hardware Manager and program the device with the generated `.bit` file.
---
📈 Simulation Results
Test Case	Expected Behaviour	Result
Factorial of 5 (5!)	Loop executes correctly, result stored in memory	✅ Pass
Square of 5 (5²)	MUL instruction validates correctly	✅ Pass
HALT execution	Processor stops cleanly at HALT opcode	✅ Pass
> Full waveform captures and analysis available in [`docs/design_flow.md`](docs/design_flow.md).
---
⚙️ FPGA Resource Utilization (Nexys A7)
Resource	Utilization
LUTs	~1%
Flip-Flops	~1%
DSP Blocks	~1%
IO Pins	~6%
The design is intentionally minimal — this is a learning-oriented processor, not a performance-optimized one.
---
👥 Contributors
Junaid Khalid — GitHub · LinkedIn
Abdul Rahman — GitHub
Mentored by Sir Ali Roman, COMSATS University Islamabad – Wah Campus.
---
📋 License
This project is licensed under the MIT License.
---
> Built for learning, hardware exploration, and FPGA fun. ❤️
