// This testbench is for FPU as well as program counter, instruction memory and data memory
`timescale 1ns/1ps

module FPU_TB3;

    reg clk;
    reg reset;

    wire [7:0] pc_out;
    wire [15:0] instruction;
    wire [1:0] opcode;
    wire [12:0] data_addr;
    wire [127:0] data;
    wire [63:0] operand_a, operand_b;
    wire [63:0] fpu_result;
    real real_result;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock
    end

    // Instantiate modules
    ProgramCounter pc (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out)
    );

    InstructionMemory imem (
        .addr(pc_out),
        .instruction(instruction)
    );

    DataMemory dmem (
        .addr(instruction[15:3]),  // 13-bit address from instruction
        .data_out(data)
    );

    FPU fpu (
        .a(operand_a),
        .b(operand_b),
        .op(opcode),
        .result(fpu_result)
    );

    // Decode instruction
    assign data_addr = instruction[15:3];
    assign opcode = instruction[1:0];
    assign operand_a = data[127:64];
    assign operand_b = data[63:0];

    // Test Sequence
    initial begin
        $dumpfile("FPU_TB3.vcd");
        $dumpvars(0, FPU_TB3);

        reset = 1;
        #10 reset = 0;

        repeat (4) begin
            @(posedge clk);
            #1 real_result = $bitstoreal(fpu_result);

            case (opcode)
                2'b00: $display("PC=%0d ADD: %f + %f = %f", pc_out, $bitstoreal(operand_a), $bitstoreal(operand_b), real_result);
                2'b01: $display("PC=%0d SUB: %f - %f = %f", pc_out, $bitstoreal(operand_a), $bitstoreal(operand_b), real_result);
                2'b10: $display("PC=%0d MUL: %f * %f = %f", pc_out, $bitstoreal(operand_a), $bitstoreal(operand_b), real_result);
                2'b11: $display("PC=%0d DIV: %f / %f = %f", pc_out, $bitstoreal(operand_a), $bitstoreal(operand_b), real_result);
                default: $display("Unknown opcode at PC=%0d", pc_out);
            endcase
        end

        $finish;
    end

endmodule
