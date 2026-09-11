`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2024 05:00:50 PM
// Design Name: 
// Module Name: ALU
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

module ALU(
    input [2:0] OP,            // ALU Operation (3 bits)
    input [9:0] INPUTA,        // 10-bit Input A
    input [9:0] INPUTB,        // 10-bit Input B
    input INCR_OP,             // Increment operation enable
    output reg [9:0] OUT_LO,   // Low 10 bits of output
    output reg [9:0] OUT_HI,   // High 10 bits of output (for MUL operation)
    output reg ZERO            // Zero flag
);

    reg [19:0] MUL_RESULT;     // Temporary variable for multiplication result

    // Purely combinational: a single-cycle datapath needs the ALU result
    // available within the same cycle as the instruction that produced it,
    // not delayed by an extra clock edge.
    always @(*) begin
        OUT_LO = 10'b0;
        OUT_HI = 10'b0;

        // Check for Increment Operation first
        if (INCR_OP) begin
            OUT_LO = INPUTA + 10'b1; // Increment INPUTA
        end else begin
            // Perform operations based on ALU operation code (OP)
            case (OP)
                3'b000: begin
                    // ADD operation
                    OUT_LO = INPUTA + INPUTB;
                end

                3'b001: begin
                    // SUB operation
                    OUT_LO = INPUTA - INPUTB;
                end

                3'b010: begin
                    // MUL operation: Perform multiplication
                    MUL_RESULT = INPUTA * INPUTB;    // 10-bit x 10-bit -> 20-bit result
                    OUT_LO = MUL_RESULT[9:0];      // Lower 10 bits
                    OUT_HI = MUL_RESULT[19:10];    // Higher 10 bits
                end

                3'b011: begin
                    // XOR operation
                    OUT_LO = INPUTA ^ INPUTB;       // Bitwise XOR
                end

                3'b100: begin
                    // SPLIT Operation
                    if (INPUTB == 10'd0) begin
                        // Split Left: Upper 5 bits shifted right
                        OUT_LO = (INPUTA & 10'b1111100000) >> 5;
                    end else begin
                        // Split Right: Mask lower 5 bits
                        OUT_LO = INPUTA & 10'b0000011111;
                    end
                end

                3'b101: begin
                    // MOD2 Operation: Extract LSB (Check even or odd)
                    OUT_LO = INPUTA & 10'b0000000001;
                end

                3'b110: begin
                    // PASS Operation: Pass INPUTB directly to OUT_LO
                    OUT_LO = INPUTB;
                end

                default: begin
                    // Default case: Outputs are zeroed
                    OUT_LO = 10'b0;
                    OUT_HI = 10'b0;
                end
            endcase
        end

        // Update ZERO flag if OUT_LO is zero
        ZERO = (OUT_LO == 10'b0);
    end

endmodule
