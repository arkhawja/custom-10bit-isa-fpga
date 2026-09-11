`timescale 1ns / 1ps

module tb_square;
    reg CLK = 0;
    reg RESET = 1;
    wire [9:0] PC_OUT;
    wire HALT;

    Processor #(.PROGRAM(1)) dut (
        .CLK(CLK),
        .RESET(RESET),
        .PC_OUT(PC_OUT),
        .HALT(HALT)
    );

    always #5 CLK = ~CLK;

    initial begin
        RESET = 1;
        #12 RESET = 0;

        wait (HALT === 1'b1);
        #2;

        $display("---- Square(5) ----");
        $display("PC halted at   = %0d", PC_OUT);
        $display("r0 (zero)      = %0d", dut.regFile.registers[0]);
        $display("r1 (result)    = %0d", dut.regFile.registers[1]);
        $display("Memory[0]      = %0d", dut.dataMem.memory[0]);
        if (dut.dataMem.memory[0] == 25)
            $display("RESULT: PASS (expected 25)");
        else
            $display("RESULT: FAIL (expected 25, got %0d)", dut.dataMem.memory[0]);
        $finish;
    end

    initial begin
        #500;
        $display("TIMEOUT: processor never asserted HALT");
        $finish;
    end
endmodule
