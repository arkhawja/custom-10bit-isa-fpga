`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/13/2024 05:16:12 PM
// Design Name:
// Module Name: control
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

module Control(
    input [3:0] OPCODE,        // 4-bit operation code
    output reg [2:0] ALU_OP,   // ALU operation code
    output reg REG_WRITE,      // Register write enable
    output reg MUL_OP,         // Enable multiplication operation
    output reg BNE,            // Branch if not equal
    output reg BEQ,            // Branch if equal
    output reg MEM_WRITE,      // Memory write enable
    output reg MEM_OR_ALU,     // Memory or ALU result select
    output reg JUMP,           // Jump operation
    output reg REG_OR_IM,      // Select immediate or register
    output reg INCR_OP,        // Increment operation
    output reg [1:0] WB_SEL,   // Writeback select signal
    output HALT                // Halt signal
);

    always @(*) begin
        // Default values for control signals
        JUMP = 0;
        MEM_OR_ALU = 0;
        MEM_WRITE = 0;
        REG_OR_IM = 0;
        REG_WRITE = 0;
        INCR_OP = 0;
        BEQ = 0;
        BNE = 0;
        MUL_OP = 0;
        WB_SEL = 2'b00; // Default: ALU output
        ALU_OP = 3'b000;

        case (OPCODE)
            4'b0000: begin // HALT
                // HALT signal only
            end
            4'b0001: begin // ADD
                REG_WRITE = 1;
                ALU_OP = 3'b000;
            end
            4'b0010: begin // MUL
                REG_WRITE = 1;
                MUL_OP = 1;
                ALU_OP = 3'b010;
            end
            4'b0011: begin // SUB
                REG_WRITE = 1;
                ALU_OP = 3'b001;
            end
            4'b0100: begin // SET (Immediate Write)
                REG_WRITE = 1;
                REG_OR_IM = 1;
                WB_SEL = 2'b01; // Immediate Value
                ALU_OP = 3'b110; // PASS: forward immediate to OUT_LO
            end
            4'b0101: begin // SPLIT
                REG_WRITE = 1;
                ALU_OP = 3'b100;
            end
            4'b0110: begin // LOAD
                REG_WRITE = 1;
                MEM_OR_ALU = 1;
                WB_SEL = 2'b10; // Memory Data
                ALU_OP = 3'b110; // PASS: forward immediate address to DataMemory
            end
            4'b0111: begin // STORE
                MEM_WRITE = 1;
                ALU_OP = 3'b110; // PASS: forward immediate address to DataMemory
            end
            4'b1000: begin // BEQ (Branch if Equal)
                BEQ = 1;
                ALU_OP = 3'b001; // ALU SUB for comparison
            end
            4'b1001: begin // JUMP
                JUMP = 1;
            end
            4'b1010: begin // MOD2
                REG_WRITE = 1;
                ALU_OP = 3'b101;
            end
            4'b1011: begin // INCR
                REG_WRITE = 1;
                ALU_OP = 3'b110;
                INCR_OP = 1;
            end
            4'b1100: begin // BNE (Branch if Not Equal)
                BNE = 1;
                ALU_OP = 3'b001; // ALU SUB for comparison
            end
            default: begin
                // Reset all control signals for unsupported opcodes
                ALU_OP = 3'b000;
                WB_SEL = 2'b00;
                REG_WRITE = 0;
                MUL_OP = 0;
                BEQ = 0;
                BNE = 0;
                MEM_WRITE = 0;
                INCR_OP = 0;
            end
        endcase
    end

    // HALT signal for stopping execution
    assign HALT = (OPCODE == 4'b0000) ? 1 : 0;

endmodule
