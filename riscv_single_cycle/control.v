`timescale 1ns / 1ps

module control (
    input  wire [6:0] opcode,
    output reg [3:0] ALUOp,
    output reg       Branch,
    output reg       MemRead,
    output reg       MemToReg,
    output reg       MemWrite,
    output reg       ALUSrc,
    output reg       RegWrite,
    output reg       Jump
);

    localparam OP_RTYPE     = 7'b0110011;
    localparam OP_ITYPE     = 7'b0010011;
    localparam OP_LOAD      = 7'b0000011;
    localparam OP_STORE     = 7'b0100011;
    localparam OP_BRANCH    = 7'b1100011;
    localparam OP_JAL       = 7'b1101111;
    localparam OP_JALR      = 7'b1100111;

    always @(*) begin
        // Default values for all control outputs.
        ALUOp    = 4'b0000;
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemToReg = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;
        Jump     = 1'b0;

        case (opcode)
            OP_RTYPE: begin
                ALUOp    = 4'b1111; // Use funct3/funct7 to resolve exact ALU operation.
                RegWrite = 1'b1;
            end

            OP_ITYPE: begin
                ALUOp    = 4'b0000; // ADD for most immediate arithmetic instructions.
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
            end

            OP_LOAD: begin
                ALUOp    = 4'b0000; // Base address + offset.
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemToReg = 1'b1;
                RegWrite = 1'b1;
            end

            OP_STORE: begin
                ALUOp    = 4'b0000; // Base address + offset.
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
            end

            OP_BRANCH: begin
                ALUOp    = 4'b0001; // SUB for branch comparisons.
                Branch   = 1'b1;
            end

            OP_JAL: begin
                ALUOp    = 4'b0000;
                Jump     = 1'b1;
                RegWrite = 1'b1;
            end

            OP_JALR: begin
                ALUOp    = 4'b0000;
                Jump     = 1'b1;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
            end

            default: begin
                // Unsupported or illegal opcodes default to no operation.
            end
        endcase
    end

endmodule
