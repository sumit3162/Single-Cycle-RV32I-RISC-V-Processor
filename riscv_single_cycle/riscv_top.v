`timescale 1ns / 1ps

module riscv_top (
    input wire clk,
    input wire rst
);

    // -------------------------------------------------------------------------
    // Instruction and data memory arrays.
    // -------------------------------------------------------------------------
    reg [31:0] imem [0:255];
    reg [31:0] dmem [0:255];
    integer i;

    // -------------------------------------------------------------------------
    // PC and fetch stage.
    // -------------------------------------------------------------------------
    wire [31:0] pc_current;
    wire [31:0] pc_plus4;
    wire [31:0] pc_next;

    pc u_pc (
        .clk(clk),
        .rst(rst),
        .next_pc(pc_next),
        .pc(pc_current)
    );

    assign pc_plus4 = pc_current + 32'd4;

    // -------------------------------------------------------------------------
    // Instruction fetch.
    // -------------------------------------------------------------------------
    wire [31:0] instruction;
    assign instruction = ((pc_current >> 2) < 256) ? imem[pc_current[9:2]] : 32'h00000013;

    // -------------------------------------------------------------------------
    // Decode fields.
    // -------------------------------------------------------------------------
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    // -------------------------------------------------------------------------
    // Immediate generation.
    // -------------------------------------------------------------------------
    wire [31:0] imm_i = {{20{instruction[31]}}, instruction[31:20]};
    wire [31:0] imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    wire [31:0] imm_b = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    wire [31:0] imm_u = {instruction[31:12], 12'b0};
    wire [31:0] imm_j = {{11{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

    // -------------------------------------------------------------------------
    // Control logic.
    // -------------------------------------------------------------------------
    wire [3:0] ALUOp;
    wire       Branch;
    wire       MemRead;
    wire       MemToReg;
    wire       MemWrite;
    wire       ALUSrc;
    wire       RegWrite;
    wire       Jump;

    // -------------------------------------------------------------------------
    // Register file.
    // -------------------------------------------------------------------------
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] reg_write_data;

    regfile u_regfile (
        .clk(clk),
        .we(RegWrite),
        .ra1(instruction[19:15]),
        .ra2(instruction[24:20]),
        .wa(instruction[11:7]),
        .wd(reg_write_data),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

    control u_control (
        .opcode(opcode),
        .ALUOp(ALUOp),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump)
    );

    // -------------------------------------------------------------------------
    // ALU control decoding based on opcode and function bits.
    // -------------------------------------------------------------------------
    reg [3:0] alu_ctrl;

    always @(*) begin
        alu_ctrl = 4'b0000;

        case (opcode)
            7'b0110011: begin // R-type instructions.
                case (funct3)
                    3'b000: alu_ctrl = instruction[30] ? 4'b0001 : 4'b0000; // SUB / ADD
                    3'b001: alu_ctrl = 4'b0101; // SLL
                    3'b010: alu_ctrl = 4'b1000; // SLT
                    3'b011: alu_ctrl = 4'b1001; // SLTU
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    3'b101: alu_ctrl = instruction[30] ? 4'b0111 : 4'b0110; // SRA / SRL
                    3'b110: alu_ctrl = 4'b0011; // OR
                    3'b111: alu_ctrl = 4'b0010; // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            7'b0010011: begin // I-type ALU instructions.
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b001: alu_ctrl = 4'b0101; // SLLI
                    3'b010: alu_ctrl = 4'b1000; // SLTI
                    3'b011: alu_ctrl = 4'b1001; // SLTIU
                    3'b100: alu_ctrl = 4'b0100; // XORI
                    3'b101: alu_ctrl = instruction[30] ? 4'b0111 : 4'b0110; // SRAI / SRLI
                    3'b110: alu_ctrl = 4'b0011; // ORI
                    3'b111: alu_ctrl = 4'b0010; // ANDI
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            7'b1100011: begin // Branch instructions.
                alu_ctrl = 4'b0001; // SUB for compare.
            end

            default: begin
                alu_ctrl = 4'b0000;
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // ALU operand selection and execution.
    // -------------------------------------------------------------------------
    wire [31:0] alu_b;
    assign alu_b = ALUSrc ? ((opcode == 7'b0100011) ? imm_s : imm_i) : rs2_data;

    wire [31:0] alu_result;
    wire        alu_zero;

    alu u_alu (
        .a(rs1_data),
        .b(alu_b),
        .alu_op(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    // -------------------------------------------------------------------------
    // Data memory.
    // -------------------------------------------------------------------------
    wire [31:0] mem_read_data;
    assign mem_read_data = dmem[alu_result[9:2]];

    always @(posedge clk) begin
        if (MemWrite) begin
            dmem[alu_result[9:2]] <= rs2_data;
        end
    end

    // -------------------------------------------------------------------------
    // Write-back path.
    // -------------------------------------------------------------------------
    wire [31:0] branch_target = pc_plus4 + imm_b;
    wire [31:0] jal_target = pc_current + imm_j;
    wire [31:0] jalr_target = (rs1_data + imm_i) & 32'hFFFFFFFE;
    wire        branch_taken = Branch & alu_zero;

    assign reg_write_data = (Jump) ? pc_plus4 : ((MemToReg) ? mem_read_data : alu_result);

    // -------------------------------------------------------------------------
    // Next PC selection.
    // -------------------------------------------------------------------------
    assign pc_next = (Jump && (opcode == 7'b1100111)) ? jalr_target :
                    ((Jump) ? jal_target :
                    (branch_taken ? branch_target : pc_plus4));

    // -------------------------------------------------------------------------
    // Memory initialization.
    // -------------------------------------------------------------------------
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            imem[i] = 32'b0;
            dmem[i] = 32'b0;
        end
    end

endmodule
