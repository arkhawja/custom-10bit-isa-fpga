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
            instr_mem[0] = 10'b0100001101;   // SET r1, 5   (counter)
            instr_mem[1] = 10'b0100010001;   // SET r2, 1   (decrement step)
            instr_mem[2] = 10'b0100011001;   // SET r3, 1   (result accumulator)
            instr_mem[3] = 10'b0010011001;   // MUL r3, r1  -> r3 = r3 * r1
            instr_mem[4] = 10'b0011001010;   // SUB r1, r2  -> r1 = r1 - 1
            instr_mem[5] = 10'b1100001011;   // BNE r1, 3   -> loop while r1 != 0
            instr_mem[6] = 10'b0111011000;   // STORE r3, 0 -> Memory[0] = r3
            instr_mem[7] = 10'b0000000000;   // HALT
        end else begin
            // Square(5): expected result 25, written to DataMemory[0]
            instr_mem[0] = 10'b0100001101;   // SET r1, 5
            instr_mem[1] = 10'b0010001001;   // MUL r1, r1  -> r1 = r1 * r1
            instr_mem[2] = 10'b0111001000;   // STORE r1, 0 -> Memory[0] = r1
            instr_mem[3] = 10'b0000000000;   // HALT
        end
    end

    // Output Instruction (asynchronous read)
    assign INSTRUCTION = instr_mem[ADDRESS];

endmodule
