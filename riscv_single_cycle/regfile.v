`timescale 1ns / 1ps

module regfile (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  ra1,
    input  wire [4:0]  ra2,
    input  wire [4:0]  wa,
    input  wire [31:0] wd,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);

    reg [31:0] registers [0:31];
    integer i;

    // Read ports are asynchronous, so data is available immediately.
    assign rd1 = (ra1 == 5'd0) ? 32'b0 : registers[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'b0 : registers[ra2];

    // Register x0 is hard-wired to zero and cannot be written.
    always @(posedge clk) begin
        if (we && (wa != 5'd0)) begin
            registers[wa] <= wd;
        end
    end

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

endmodule
