`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/15/2024 05:50:55 PM
// Design Name:
// Module Name: Processor
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module Processor #(
    parameter integer PROGRAM = 0   // 0 = Factorial(5), 1 = Square(5) - see InstructionMemory.v
)(
    input CLK,
    input RESET,               // Reset signal
    output [9:0] PC_OUT,       // Program Counter output
    output HALT                // HALT signal
);

    // Internal Wires
    wire [9:0] INSTRUCTION;        // Instruction from memory
    wire [3:0] OPCODE;             // Opcode
    wire [2:0] SRC1, SRC2, DEST;   // R-Type registers and destination register
    wire [2:0] IMMEDIATE;          // 3-bit immediate/offset (SET, LOAD, STORE, BEQ, BNE)
    wire [5:0] ADDRESS;            // 6-bit J-Type jump address
    wire [9:0] ALU_OUT_LO, ALU_OUT_HI, WB_DATA, MemData, ReadA, ReadB;
    wire ZERO, REG_WRITE, MEM_WRITE, MEM_OR_ALU, INCR_OP, JUMP, BEQ, BNE;
    wire [2:0] ALU_OP;
    wire PC_WRITE;

    // Instructions whose ALU input B should come from the decoded immediate
    // field rather than a register read (SET/LOAD/STORE all need the literal
    // 3-bit value; BEQ/BNE need a zero operand so SUB tests the register
    // against zero instead of against whatever SRC2 happens to hold).
    wire IMM_OP    = (OPCODE == 4'b0100) || (OPCODE == 4'b0110) || (OPCODE == 4'b0111);
    wire ZERO_TEST = (OPCODE == 4'b1000) || (OPCODE == 4'b1100);

    // Program Counter Control Logic
    wire [9:0] PC_NEXT, PC_CURRENT;
    assign PC_WRITE = JUMP | (BEQ & ZERO) | (BNE & ~ZERO);

    assign PC_NEXT = (JUMP) ? {4'b0000, ADDRESS} :        // Jump to Address for J-Type
                     (BEQ & ZERO) ? {7'b0, IMMEDIATE} :   // BEQ Condition (Branch Target)
                     (BNE & ~ZERO) ? {7'b0, IMMEDIATE} :  // BNE Condition
                     PC_CURRENT + 10'd1;                  // Default Increment

    // Program Counter
    ProgramCounter pcUnit(
        .CLK(CLK),
        .RESET(RESET),
        .HALT(HALT),
        .NEW_PC(PC_NEXT),
        .PC_WRITE(PC_WRITE),
        .PC(PC_CURRENT)
    );

    assign PC_OUT = PC_CURRENT;

    // Instruction Memory
    InstructionMemory #(.PROGRAM(PROGRAM)) instrMem(
        .ADDRESS(PC_CURRENT),
        .INSTRUCTION(INSTRUCTION)
    );

    // Instruction Decoder
    InstructionDecoder decoder(
        .INSTRUCTION(INSTRUCTION),
        .OPCODE(OPCODE),
        .SRC1(SRC1),
        .SRC2(SRC2),
        .DEST(DEST),          // Added DEST port for R-Type
        .IMMEDIATE(IMMEDIATE),
        .ADDRESS(ADDRESS)
    );

    // Control Unit
    Control controlUnit(
        .OPCODE(OPCODE),
        .ALU_OP(ALU_OP),
        .REG_WRITE(REG_WRITE),
        .MEM_WRITE(MEM_WRITE),
        .MEM_OR_ALU(MEM_OR_ALU),
        .INCR_OP(INCR_OP),
        .JUMP(JUMP),
        .BEQ(BEQ),
        .BNE(BNE),
        .HALT(HALT)
    );

    // Register File
    reg_file regFile(
        .CLK(CLK),
        .RegWrite1(REG_WRITE),
        .RegWrite2(1'b0),
        .srcA(SRC1),
        .srcB(SRC2),
        .writeReg1(DEST),          // Write back to DEST register
        .writeValue1(WB_DATA),
        .ReadA(ReadA),
        .ReadB(ReadB)
    );

    // ALU: Handles R-Type and I-Type Operations
    ALU aluUnit(
        .OP(ALU_OP),
        .INPUTA(ReadA),
        .INPUTB(IMM_OP ? {7'b0, IMMEDIATE} : ZERO_TEST ? 10'b0 : ReadB),
        .INCR_OP(INCR_OP),
        .OUT_LO(ALU_OUT_LO),
        .OUT_HI(ALU_OUT_HI),
        .ZERO(ZERO)
    );

    // Data Memory: Handles LOAD and STORE operations
    DataMemory dataMem(
        .CLK(CLK),
        .RESET(RESET),
        .MEM_WRITE(MEM_WRITE),
        .ADDRESS(ALU_OUT_LO),
        .WRITE_DATA(ReadA),        // STORE's value register (SRC1/DEST field)
        .READ_DATA(MemData)
    );

    // Write-Back Logic
    assign WB_DATA = MEM_OR_ALU ? MemData : ALU_OUT_LO; // Data from Memory or ALU Result

endmodule
