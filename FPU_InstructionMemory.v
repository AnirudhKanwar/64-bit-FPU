// Instruction Memory (16-bit words)
// [15:3] = Data Memory Address (13-bit)
// [2] = Reserved Bit
// [1:0] = Opcode: 00-Add, 01-Sub, 10-Mul, 11-Div
module InstructionMemory (
    input [7:0] addr,
    output reg [15:0] instruction
);
    reg [15:0] memory [0:255];

    initial begin
        memory[0] = 16'b0000000000000000; // Add @ address 0
        memory[1] = 16'b0000000000000101; // Sub @ address 1
        memory[2] = 16'b0000000000001010; // Mul @ address 2
        memory[3] = 16'b0000000000001111; // Div @ address 3
    end

    always @(*) begin
        instruction = memory[addr];
    end
endmodule
