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
    output reg MEM_WRITE,      // Memory write enable
    output reg MEM_OR_ALU,     // Memory or ALU result select
    output reg INCR_OP,        // Increment operation
    output reg JUMP,           // Unconditional jump
    output reg JEQ,            // Jump if EQ_FLAG set
    output reg JNE,            // Jump if EQ_FLAG clear
    output reg CMP,            // Latch EQ_FLAG from this cycle's ALU ZERO
    output HALT                // Halt signal
);

    always @(*) begin
        // Default values for control signals
        JUMP = 0;
        JEQ = 0;
        JNE = 0;
        CMP = 0;
        MEM_OR_ALU = 0;
        MEM_WRITE = 0;
        REG_WRITE = 0;
        INCR_OP = 0;
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
                ALU_OP = 3'b010;
            end
            4'b0011: begin // SUB
                REG_WRITE = 1;
                ALU_OP = 3'b001;
            end
            4'b0100: begin // LOAD_IMM: r1 = 6-bit immediate
                REG_WRITE = 1;
                ALU_OP = 3'b110; // PASS: forward immediate to OUT_LO
            end
            4'b0101: begin // SPLIT
                REG_WRITE = 1;
                ALU_OP = 3'b100;
            end
            4'b0110: begin // LW: r1 = DataMemory[6-bit address]
                REG_WRITE = 1;
                MEM_OR_ALU = 1;
                ALU_OP = 3'b110; // PASS: forward immediate address to DataMemory
            end
            4'b0111: begin // SW: DataMemory[6-bit address] = r1
                MEM_WRITE = 1;
                ALU_OP = 3'b110; // PASS: forward immediate address to DataMemory
            end
            4'b1000: begin // COMPARE: latch (SRC1 == SRC2) into EQ_FLAG
                CMP = 1;
                ALU_OP = 3'b001; // SUB; ZERO flag reflects equality
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
            4'b1100: begin // JUMP_EQUAL: PC = address if EQ_FLAG
                JEQ = 1;
            end
            4'b1101: begin // JUMP_UNEQUAL: PC = address if ~EQ_FLAG
                JNE = 1;
            end
            4'b1110: begin // MOV: DEST = SRC2 (general register-to-register copy)
                REG_WRITE = 1;
                ALU_OP = 3'b110; // PASS: forward SRC2's value to OUT_LO
            end
            default: begin
                // Reserved / unsupported opcode: no side effects
            end
        endcase
    end

    // HALT signal for stopping execution
    assign HALT = (OPCODE == 4'b0000) ? 1 : 0;

endmodule


