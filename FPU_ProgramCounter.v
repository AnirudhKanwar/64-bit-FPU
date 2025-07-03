// Program Counter (8-bit) with synchronous reset
module ProgramCounter (
    input clk,
    input reset,
    output reg [7:0] pc_out
);
    always @(posedge clk) begin
        if (reset)
            pc_out <= 8'b00000000;
        else
            pc_out <= pc_out + 1;
    end
endmodule
