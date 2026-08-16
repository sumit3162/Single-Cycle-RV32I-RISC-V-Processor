`timescale 1ns / 1ps

module riscv_tb;

    reg clk;
    reg rst;

    riscv_top dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #20;
        rst = 0;

        // Example instruction memory programming.
        dut.imem[0] = 32'h00A00513; // addi x10, x0, 10
        dut.imem[1] = 32'h00B58593; // addi x11, x11, 11
        dut.imem[2] = 32'h00A00613; // addi x12, x0, 10
        dut.imem[3] = 32'h00C60633; // add x12, x12, x12

        $dumpfile("riscv_waveform.vcd");
        $dumpvars(0, riscv_tb);

        #200;
        $finish;
    end

endmodule
