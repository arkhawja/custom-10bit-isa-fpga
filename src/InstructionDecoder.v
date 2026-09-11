`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/16/2024 09:03:26 AM
// Design Name:
// Module Name: InstructionDecoder
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


module InstructionDecoder(
    input [9:0] INSTRUCTION,
    output [3:0] OPCODE,
    output [2:0] SRC1, SRC2, DEST,     // R-Type register fields
    output [5:0] IMMEDIATE,            // 6-bit immediate for LOAD_IMM/LW/SW (no register field)
    output [5:0] ADDRESS               // 6-bit target for JUMP/JUMP_EQUAL/JUMP_UNEQUAL
);
    assign OPCODE = INSTRUCTION[9:6];
    assign SRC1   = INSTRUCTION[5:3];  // R-Type / COMPARE source, MOV destination
    assign SRC2   = INSTRUCTION[2:0];  // R-Type source
    assign DEST   = INSTRUCTION[5:3];  // R-Type destination (shared with SRC1)
    assign IMMEDIATE = INSTRUCTION[5:0];
    assign ADDRESS   = INSTRUCTION[5:0];
endmodule
