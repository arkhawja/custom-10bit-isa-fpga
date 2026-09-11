`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 05:14:37 AM
// Design Name: 
// Module Name: ProgramCounter
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


module ProgramCounter (
    input CLK, RESET,
    input HALT,                 // Freeze PC once a HALT instruction is fetched
    input [9:0] NEW_PC,        // New PC value for jumps or branches
    input PC_WRITE,            // Enable PC update
    output reg [9:0] PC        // Program Counter output
);

    // Update PC on Clock or Reset
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            PC <= 10'b0;          // Reset PC to 0
        end else if (HALT) begin
            PC <= PC;             // Stop advancing once halted
        end else if (PC_WRITE) begin
            PC <= NEW_PC;         // Update PC with NEW_PC for JUMP or Branch
        end else begin
            PC <= PC + 10'b1;     // Default Increment if no branch or jump
        end
    end
endmodule




