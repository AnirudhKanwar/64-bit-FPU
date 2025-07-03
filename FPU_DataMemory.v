// Data Memory (128-bit)
// [127:64] = Operand A
// [63:0]   = Operand B
module DataMemory (
    input [12:0] addr,
    output reg [127:0] data_out
);
    reg [127:0] memory [0:8191];

    initial begin
        memory[0] = {64'h400921FB54442D18, 64'h4000000000000000}; // π and 2.0
        memory[1] = {64'hC008000000000000, 64'h3FF0000000000000}; // -3 and 1
        memory[2] = {64'h3FF0000000000000, 64'h3FF0000000000000}; // 1 and 1
        memory[3] = {64'h4000000000000000, 64'h3FF0000000000000}; // 2 and 1
    end

    always @(*) begin
        data_out = memory[addr];
    end
endmodule
