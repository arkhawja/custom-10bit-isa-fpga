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
    output [2:0] SRC1, SRC2, DEST,
    output [2:0] IMMEDIATE,
    output [5:0] ADDRESS
);
    assign OPCODE = INSTRUCTION[9:6];
    assign SRC1   = INSTRUCTION[5:3];
    assign SRC2   = INSTRUCTION[2:0];
    assign DEST   = INSTRUCTION[5:3]; // For R-Type instructions, and the register field of I-Type
    assign IMMEDIATE = INSTRUCTION[2:0]; // 3-bit immediate/offset for SET, LOAD, STORE, BEQ, BNE
    assign ADDRESS   = INSTRUCTION[5:0]; // Full 6-bit target for J-Type JUMP
endmodule
