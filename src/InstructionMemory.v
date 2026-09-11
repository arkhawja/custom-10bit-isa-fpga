`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/16/2024 09:04:45 AM
// Design Name:
// Module Name: InstructionMemory
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


module InstructionMemory #(
    parameter integer PROGRAM = 0   // 0 = Factorial(5) -> 120, 1 = Square(5) -> 25
)(
    input [9:0] ADDRESS,         // Address from Program Counter
    output [9:0] INSTRUCTION     // Output instruction
);

    reg [9:0] instr_mem [0:63];  // 64 memory locations, each 10 bits wide
    integer i;

    // Instruction Initialization
    initial begin
        for (i = 0; i < 64; i = i + 1)
            instr_mem[i] = 10'b0;

        if (PROGRAM == 0) begin
            // Factorial(5): expected result 120, written to DataMemory[0]
            // r1=result accumulator (MOV can only ever read FROM r1, so the
            // running product has to live there), r2=counter, r3=step, r5=0
            instr_mem[0]  = 10'b0100000000;  // LOAD_IMM 0
            instr_mem[1]  = 10'b1110101000;  // MOV r5, r1        -> r5 = 0 (comparison zero)
            instr_mem[2]  = 10'b0100000101;  // LOAD_IMM 5
            instr_mem[3]  = 10'b1110010000;  // MOV r2, r1        -> r2 = 5 (counter)
            instr_mem[4]  = 10'b0100000001;  // LOAD_IMM 1
            instr_mem[5]  = 10'b1110011000;  // MOV r3, r1        -> r3 = 1 (step)
            instr_mem[6]  = 10'b0100000001;  // LOAD_IMM 1        -> r1 = 1 (result accumulator init)
            instr_mem[7]  = 10'b0010001010;  // MUL r1, r2        -> r1 = r1 * r2         [loop]
            instr_mem[8]  = 10'b0011010011;  // SUB r2, r3        -> r2 = r2 - 1
            instr_mem[9]  = 10'b1000010101;  // COMPARE r2, r5    -> EQ_FLAG = (r2 == 0)
            instr_mem[10] = 10'b1101000111;  // JUMP_UNEQUAL 7    -> loop while r2 != 0
            instr_mem[11] = 10'b1110110000;  // MOV r6, r1        -> r6 = result (SW source)
            instr_mem[12] = 10'b0111000000;  // SW 0              -> Memory[0] = r6
            instr_mem[13] = 10'b0000000000;  // HALT
        end else begin
            // Square(5): expected result 25, written to DataMemory[0]
            instr_mem[0] = 10'b0100000101;   // LOAD_IMM 5
            instr_mem[1] = 10'b0010001001;   // MUL r1, r1        -> r1 = r1 * r1
            instr_mem[2] = 10'b1110110000;   // MOV r6, r1        -> r6 = result (SW source)
            instr_mem[3] = 10'b0111000000;   // SW 0              -> Memory[0] = r6
            instr_mem[4] = 10'b0000000000;   // HALT
        end
    end

    // Output Instruction (asynchronous read)
    assign INSTRUCTION = instr_mem[ADDRESS];

endmodule
