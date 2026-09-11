# Instruction Set Manual

## Overview

The processor supports three instruction formats based on its 10-bit instruction width:

| Type    | Bit Division                               |
|:--------|:-------------------------------------------|
| R-Type  | [ OPCODE (4 bits) | SRC1/DEST (3 bits) | SRC2 (3 bits) ] |
| I-Type  | [ OPCODE (4 bits) | IMMEDIATE (6 bits) ]     |
| J-Type  | [ OPCODE (4 bits) | ADDRESS (6 bits) ]       |

I-Type instructions have no room left for a register field once the opcode
takes 4 bits and the immediate takes the remaining 6, so they always operate
on a fixed register instead of an encoded one (see **Register Convention**
below). Each instruction is decoded by the **InstructionDecoder module** and
then directed by the **Control Unit** for execution.

---

## Register Convention

| Register | Purpose                                              |
|:--------:|:------------------------------------------------------|
| r0       | Hardwired to `0`. Writes to r0 are silently ignored.  |
| r1       | Shared gateway register. `LOAD_IMM`/`LW` always write here, `SW` always reads from here. |
| r2 - r7  | General purpose. `MOV` moves freely between any two registers, including r1. |

---

## Detailed Instruction Set

| Opcode | Mnemonic     | Description                                          | Type   |
|:------:|:-------------|:------------------------------------------------------|:------:|
| 0000   | HALT         | Stop program execution                                | -      |
| 0001   | ADD          | SRC1 = SRC1 + SRC2                                     | R-Type |
| 0010   | MUL          | SRC1 = SRC1 * SRC2 (20-bit product, split OUT_LO/OUT_HI)| R-Type |
| 0011   | SUB          | SRC1 = SRC1 - SRC2                                     | R-Type |
| 0100   | LOAD_IMM     | r1 = 6-bit immediate                                   | I-Type |
| 0101   | SPLIT        | Extract upper/lower 5 bits from a register             | R-Type |
| 0110   | LW           | r1 = DataMemory[6-bit address]                         | I-Type |
| 0111   | SW           | DataMemory[6-bit address] = r1                         | I-Type |
| 1000   | COMPARE      | EQ_FLAG = (SRC1 == SRC2)                               | R-Type |
| 1001   | JUMP         | Unconditional jump to 6-bit address                    | J-Type |
| 1010   | MOD2         | Extract LSB of register (even/odd check)                | R-Type |
| 1011   | INCR         | SRC1 = SRC1 + 1                                        | R-Type |
| 1100   | JUMP_EQUAL   | PC = address if EQ_FLAG is set                         | J-Type |
| 1101   | JUMP_UNEQUAL | PC = address if EQ_FLAG is clear                       | J-Type |
| 1110   | MOV          | DEST = SRC2 (general register-to-register copy)       | R-Type |
| 1111   | -            | Reserved / unassigned                                   | -      |

---

## Instruction Encoding Examples

### R-Type Example: ADD
```
Opcode: 0001
SRC1/DEST: 001 (r1)
SRC2:      010 (r2)
Binary: 0001 001 010
```
Meaning: r1 = r1 + r2.

---

### I-Type Example: LOAD_IMM
```
Opcode: 0100
Immediate: 000110
Binary: 0100 000110
```
Meaning: r1 = 6 (there is no destination field - LOAD_IMM always targets r1).

---

### R-Type Example: MOV
```
Opcode: 1110
DEST: 010 (r2)
SRC2:  001 (r1)
Binary: 1110 010 001
```
Meaning: r2 = r1. MOV is a plain R-Type instruction - DEST (bits[5:3]) and
SRC2 (bits[2:0]) can be any two registers, including r1 on either side.

---

### J-Type Example: JUMP
```
Opcode: 1001
Address: 001010
Binary: 1001 001010
```
Meaning: Jump to instruction address `10`.

---

## Conditional Branching

There is no direct "branch if register is zero" instruction. Conditional
control flow is two instructions:

```assembly
COMPARE r2, r5      ; EQ_FLAG = (r2 == r5)
JUMP_UNEQUAL LOOP    ; if r2 != r5, PC = LOOP
```

`EQ_FLAG` is a single flip-flop, written only when `COMPARE` executes and
held otherwise (including across `RESET`, which clears it to 0). Any
`JUMP_EQUAL`/`JUMP_UNEQUAL` reads whatever `EQ_FLAG` was last set to by the
most recent `COMPARE` - there is no implicit re-comparison.

To test a register against zero (the common loop-counter case), compare it
against r0:
```assembly
COMPARE r2, r0
JUMP_UNEQUAL LOOP    ; loop while r2 != 0
```

---

## Working With Registers Other Than r1

Because `LOAD_IMM`/`LW`/`SW` all funnel through r1 (it's the only register
with room to spend all 6 remaining bits on an immediate or address), moving
a constant or loaded value into or out of any other register costs one
extra `MOV`:

```assembly
LOAD_IMM 5     ; r1 = 5
MOV r2, r1      ; r2 = 5
```

```assembly
; result is in r2
MOV r1, r2       ; r1 = r2
SW 0              ; Memory[0] = r1
```

`MOV` itself is fully general (`MOV rX, rY` for any two registers, r1
included on either side) - the constraint is entirely in `LOAD_IMM`/`LW`/`SW`
always using r1, not in `MOV`.

---

# Special Notes
- **MUL Result:** Splits into OUT_LO (low 10 bits) and OUT_HI (high 10 bits).
- **SPLIT Operation:** Controlled by SRC2 value to extract higher or lower nibble.
- **COMPARE / JUMP_EQUAL / JUMP_UNEQUAL:** COMPARE performs SRC1 - SRC2 on the
  ALU and latches the ZERO flag into EQ_FLAG on the next clock edge;
  JUMP_EQUAL/JUMP_UNEQUAL read EQ_FLAG combinationally in the same cycle they
  execute.
- **r0:** Hardwired to zero at the register-file level (write-enable for
  register 0 is masked off), not by convention alone.

---
