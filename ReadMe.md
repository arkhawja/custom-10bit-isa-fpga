# Custom 10-bit ISA Processor

**A custom-designed processor built entirely from scratch in Verilog HDL and deployed on a real FPGA board.**

This project implements a complete, working CPU with its own custom Instruction Set Architecture (ISA). Every component — the arithmetic unit, memory system, control logic, and program counter — was designed, coded, simulated, and synthesized from the ground up. The processor was successfully deployed and tested on a Nexys A7 FPGA development board.

Developed at **COMSATS University Islamabad, Wah Campus** under the mentorship of **Sir Ali Roman**.

**What is an ISA?** An Instruction Set Architecture is the contract between software and hardware — it defines what instructions a processor understands. Most engineers use existing ISAs such as ARM or x86. This project defines and implements an entirely new one.

**What is an FPGA?** A Field-Programmable Gate Array is a chip whose internal hardware connections can be configured by the engineer after manufacturing. It is used to prototype and verify real digital hardware designs before committing to silicon fabrication.

## Project Specifications

| Property | Value |
|---|---|
| Data Width | 10 bits |
| Instruction Width | 10 bits |
| Instruction Types | R-Type (register), I-Type (immediate), J-Type (jump) |
| Number of Registers | 8 general-purpose registers |
| Instruction Memory | 64 locations (10-bit ROM) |
| Data Memory | 256 locations (10-bit RAM) |
| Execution Model | Single-cycle (one instruction completes per clock cycle) |
| Hardware Description Language | Verilog HDL |
| Synthesis and Simulation Tool | Xilinx Vivado |
| Target FPGA Board | Nexys A7 — Artix-7 XC7A100TCSG324-1 |

## Processor Architecture

The processor uses a **single-cycle datapath** design. Every instruction — whether arithmetic, memory access, or branch — completes in exactly one clock cycle. Control signals are generated combinationally from the instruction opcode, and data flows through the processor in a single forward pass from instruction fetch to result writeback.

The diagram below shows how data and control signals move through the processor:

```
  +---------------------------+
  |    Instruction Memory     |
  |    (64 x 10-bit ROM)      |
  |  Holds the program code   |
  +------------+--------------+
               |
               |  10-bit instruction word
               v
  +------------+--------------+
  |    Instruction Decoder    |  Splits instruction into opcode,
  |                           |  SRC1, SRC2, DST, and Immediate
  +------+--------------------+
         |
         +-------------------------------+
         |                               |
         v                               v
  +------+----------+        +-----------+----------+
  |   Control Unit  |        |     Register File     |
  |                 |        |   8 registers x 10b   |
  | Reads opcode,   |        |   2 read ports        |
  | generates all   |        |   1 write port        |
  | control signals |        +-----+-----------+-----+
  +------+----------+              |           |
         |                      SRC1         SRC2
         |  Control signals       |           |
         |                        v           v
         |               +--------+-----------+--------+
         +-------------->|           ALU (10-bit)      |
                         |  ADD  SUB  MUL  XOR         |
                         |  SPLIT  MOD2  PASS  INCR    |
                         +--------+--------------------+
                                  |
                                  |  ALU Result
                     +------------+---------------+
                     |                            |
                     v                            v
        +------------+----------+    +------------+----------+
        |      Data Memory      |    |   Register Writeback  |
        |  (256 x 10-bit RAM)   |    |  Result written into  |
        |  LOAD and STORE ops   |    |  destination register |
        +-----------------------+    +-----------------------+

  +---------------------------+
  |      Program Counter      |
  |  Tracks current address   |
  |  Supports: sequential     |
  |  increment, BEQ, BNE,     |
  |  and unconditional JUMP   |
  +---------------------------+
```

## Core Components

| Component | Role |
|---|---|
| **ALU** | Executes all arithmetic and logic operations. Supports ADD, SUB, MUL, XOR, SPLIT, MOD2, PASS, and INCR |
| **Register File** | Stores eight 10-bit general-purpose values. Provides two simultaneous read ports and one write port, all in one cycle |
| **Program Counter** | Tracks the address of the current instruction. Updated each cycle to either the next address, a branch target, or a jump destination |
| **Instruction Decoder** | Takes the raw 10-bit instruction word and extracts each field: opcode, two source register indices, destination register index, and immediate value |
| **Control Unit** | A purely combinational block that reads the opcode and generates every control signal the datapath needs — RegWrite, ALUSrc, MemWrite, MemRead, Branch, Jump |
| **Instruction Memory** | A 64-location, 10-bit wide ROM that holds the program being executed |
| **Data Memory** | A 256-location, 10-bit wide RAM used by LOAD and STORE instructions at runtime |

## Instruction Set

The ISA supports 13 instructions across three encoding formats. R-Type instructions operate on two register operands. I-Type instructions combine a register with a constant encoded directly in the instruction. J-Type instructions encode a target address for unconditional jumps.

| Opcode | Mnemonic | Format | Operation |
|--------|----------|--------|-----------|
| 0000 | HALT | — | Stops processor execution |
| 0001 | ADD | R-Type | DST = SRC1 + SRC2 |
| 0010 | MUL | R-Type | DST = SRC1 x SRC2 |
| 0011 | SUB | R-Type | DST = SRC1 - SRC2 |
| 0100 | SET | I-Type | DST = Immediate value (loads a constant into a register) |
| 0101 | SPLIT | R-Type | Extracts the upper or lower 5 bits from a register |
| 0110 | LOAD | I-Type | DST = DataMemory[address] |
| 0111 | STORE | I-Type | DataMemory[address] = SRC |
| 1000 | BEQ | I-Type | Branch to offset address if DST equals zero |
| 1001 | JUMP | J-Type | Unconditional jump to target address |
| 1010 | MOD2 | R-Type | DST = 1 if SRC is even, 0 if odd (checks least-significant bit) |
| 1011 | INCR | R-Type | DST = DST + 1 |
| 1100 | BNE | I-Type | Branch to offset address if DST is not zero |

Complete instruction encoding, field-level bit layouts, and worked examples are in [docs/instruction_set_manual.md](docs/instruction_set_manual.md).

## Repository Structure

```
custom-10bit-isa-fpga/
|
+-- src/
|   +-- processor.v              Top-level module — connects all components
|   +-- alu.v                    Arithmetic Logic Unit
|   +-- control.v                Control Unit (purely combinational)
|   +-- reg_file.v               8-register file with dual read port
|   +-- instruction_decoder.v    Splits 10-bit instruction into fields
|   +-- instruction_memory.v     64 x 10-bit program ROM
|   +-- data_memory.v            256 x 10-bit data RAM
|   +-- program_counter.v        PC with sequential, branch, and jump logic
|   +-- mux8x1.v                 8-to-1 multiplexer
|   +-- dff_10bit.v              10-bit D flip-flop
|
+-- docs/
|   +-- architecture_overview.md   Full datapath and control unit description
|   +-- instruction_set_manual.md  Complete ISA encoding reference
|   +-- design_flow.md             Simulation methodology and verified results
|
+-- constraints/
|   +-- Processor.xdc              Nexys A7 FPGA pin assignment file
|
+-- simulation and Other/          Waveform captures and simulation outputs
```

## Simulation and Verification

The processor was verified against three test programs before deploying to hardware. Each program tests a different combination of instructions and control flow paths.

| Test Program | Instructions Exercised | Result |
|---|---|---|
| Factorial of 5 (expected: 120) | SET, MUL, DECR, BNE, JUMP, STORE | Pass |
| Square of 5 (expected: 25) | SET, MUL, STORE | Pass |
| HALT instruction | HALT — PC must stop advancing | Pass |

Full waveform captures and per-instruction trace analysis are in [docs/design_flow.md](docs/design_flow.md).

## FPGA Resource Utilization

The design was synthesized and implemented on the Nexys A7 (Artix-7 XC7A100TCSG324-1). Resource consumption is low because this is an educational-scale processor — the focus is correctness and clarity of design, not performance optimization.

| FPGA Resource | Utilization |
|---|---|
| Look-Up Tables (LUTs) | ~1% |
| Flip-Flops (FFs) | ~1% |
| DSP Blocks | ~1% |
| IO Pins | ~6% |

## How to Build and Run

**Requirements:** Xilinx Vivado (any version supporting Artix-7), Nexys A7 FPGA board for hardware deployment.

**Step 1 — Clone the repository**

```bash
git clone https://github.com/Engrr2025/custom-10bit-isa-fpga.git
cd custom-10bit-isa-fpga
```

**Step 2 — Create a Vivado project**

Launch Vivado and create a new RTL project. Add all `.v` files from the `src/` directory as Verilog design sources. Apply the `constraints/Processor.xdc` constraints file. Set `processor.v` as the top-level module.

**Step 3 — Simulate**

Run Behavioral Simulation in Vivado. Inspect waveforms for program counter progression, register write values, ALU outputs, and memory read/write operations. Compare against the expected outputs documented in the `docs/` folder.

**Step 4 — Synthesize and Implement**

From the Vivado Flow Navigator, run Synthesis, then Implementation, then Generate Bitstream in sequence.

**Step 5 — Program the FPGA**

Connect the Nexys A7 board via USB. Open Vivado Hardware Manager, detect the board, and program it with the generated `.bit` bitstream file.

## Contributors

- **Junaid Khalid** — [GitHub](https://github.com/Engrr2025) | [LinkedIn](https://www.linkedin.com/in/junaid-khalid23/)
- **Abdul Rahman** — [GitHub](https://github.com/arkhawja)

Mentored by **Sir Ali Roman**, COMSATS University Islamabad, Wah Campus.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for full terms.
