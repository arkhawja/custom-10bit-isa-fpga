`timescale 1ns / 1ps

module tb_factorial;
    reg CLK = 0;
    reg RESET = 1;
    wire [9:0] PC_OUT;
    wire HALT;

    Processor #(.PROGRAM(0)) dut (
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

        $display("---- Factorial(5) ----");
        $display("PC halted at   = %0d", PC_OUT);
        $display("r0 (zero)      = %0d", dut.regFile.registers[0]);
        $display("r1 (result)    = %0d", dut.regFile.registers[1]);
        $display("r2 (counter)   = %0d", dut.regFile.registers[2]);
        $display("r3 (step)      = %0d", dut.regFile.registers[3]);
        $display("r5 (zero-cmp)  = %0d", dut.regFile.registers[5]);
        $display("r6 (SW source) = %0d", dut.regFile.registers[6]);
        $display("Memory[0]      = %0d", dut.dataMem.memory[0]);
        if (dut.dataMem.memory[0] == 120)
            $display("RESULT: PASS (expected 120)");
        else
            $display("RESULT: FAIL (expected 120, got %0d)", dut.dataMem.memory[0]);
        $finish;
    end

    initial begin
        #500;
        $display("TIMEOUT: processor never asserted HALT");
        $finish;
    end
endmodule
