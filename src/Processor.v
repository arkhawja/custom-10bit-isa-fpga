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
    wire [5:0] IMMEDIATE;          // 6-bit immediate for LOAD_IMM/LW/SW
    wire [5:0] ADDRESS;            // 6-bit target for JUMP/JUMP_EQUAL/JUMP_UNEQUAL
    wire [9:0] ALU_OUT_LO, ALU_OUT_HI, WB_DATA, MemData, ReadA, ReadB;
    wire ZERO, REG_WRITE, MEM_WRITE, MEM_OR_ALU, INCR_OP, JUMP, JEQ, JNE, CMP;
    wire [2:0] ALU_OP;
    wire PC_WRITE;

    localparam OP_LOAD_IMM = 4'b0100;
    localparam OP_LW       = 4'b0110;
    localparam OP_SW       = 4'b0111;
    localparam REG_ONE     = 3'b001; // r1 - shared LOAD_IMM/LW/SW gateway register

    // LOAD_IMM/LW/SW spend their whole 6-bit tail on an immediate or
    // address, so they can't also encode a register field - LOAD_IMM/LW
    // always target r1, and SW always reads r1. MOV is a plain R-Type
    // instruction (DEST = SRC2) and needs no override: DEST already
    // resolves to bits[5:3] and SRC2 to bits[2:0] like every other R-Type op.
    wire [2:0] srcA_sel      = (OPCODE == OP_SW) ? REG_ONE : SRC1;
    wire [2:0] writeReg_sel  = (OPCODE == OP_LOAD_IMM || OPCODE == OP_LW) ? REG_ONE : DEST;
    wire IMM_OP = (OPCODE == OP_LOAD_IMM) || (OPCODE == OP_LW) || (OPCODE == OP_SW);

    // EQ_FLAG: latched by COMPARE (SRC1 == SRC2), consumed by JUMP_EQUAL/JUMP_UNEQUAL.
    reg EQ_FLAG;
    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            EQ_FLAG <= 1'b0;
        else if (CMP)
            EQ_FLAG <= ZERO;
    end

    // Program Counter Control Logic
    wire [9:0] PC_NEXT, PC_CURRENT;
    assign PC_WRITE = JUMP | (JEQ & EQ_FLAG) | (JNE & ~EQ_FLAG);

    assign PC_NEXT = (JUMP)            ? {4'b0000, ADDRESS} :   // Unconditional jump
                      (JEQ & EQ_FLAG)  ? {4'b0000, ADDRESS} :   // JUMP_EQUAL taken
                      (JNE & ~EQ_FLAG) ? {4'b0000, ADDRESS} :   // JUMP_UNEQUAL taken
                      PC_CURRENT + 10'd1;                       // Default Increment

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
        .JEQ(JEQ),
        .JNE(JNE),
        .CMP(CMP),
        .HALT(HALT)
    );

    // Register File
    reg_file regFile(
        .CLK(CLK),
        .RegWrite1(REG_WRITE),
        .RegWrite2(1'b0),
        .srcA(srcA_sel),
        .srcB(SRC2),
        .writeReg1(writeReg_sel),  // Write back to DEST, or r1 for LOAD_IMM/LW
        .writeValue1(WB_DATA),
        .ReadA(ReadA),
        .ReadB(ReadB)
    );

    // ALU: Handles R-Type and I-Type Operations
    ALU aluUnit(
        .OP(ALU_OP),
        .INPUTA(ReadA),
        .INPUTB(IMM_OP ? {4'b0000, IMMEDIATE} : ReadB),
        .INCR_OP(INCR_OP),
        .OUT_LO(ALU_OUT_LO),
        .OUT_HI(ALU_OUT_HI),
        .ZERO(ZERO)
    );

    // Data Memory: Handles LW and SW operations
    DataMemory dataMem(
        .CLK(CLK),
        .RESET(RESET),
        .MEM_WRITE(MEM_WRITE),
        .ADDRESS(ALU_OUT_LO),
        .WRITE_DATA(ReadA),        // r1 for SW, via srcA_sel
        .READ_DATA(MemData)
    );

    // Write-Back Logic
    assign WB_DATA = MEM_OR_ALU ? MemData : ALU_OUT_LO; // Data from Memory or ALU Result

endmodule

