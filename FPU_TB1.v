//TEST BENCH-1
module FPU_TB1;
    reg [63:0] a;
    reg [63:0] b;
    reg [1:0] op;
    wire [63:0] result;
    real real_result;

    FPU dut(.a(a), .b(b), .op(op), .result(result));

    initial begin
        $dumpfile("FPU.vcd");
        $dumpvars(0, FPU_TB1);

        // -------------------------------
        // Pair 1: 2.5 + 4.75 = 7.25
        // -------------------------------
        a = 64'h4004000000000000; // 2.5
        b = 64'h4013C00000000000; // 4.75
        op = 2'b00;
        #10 real_result = $bitstoreal(result);
        $display("ADD:      %f + %f = %f", $bitstoreal(a), $bitstoreal(b), real_result); // Expected: 7.25

        // -------------------------------
        // Pair 2: 9.0 - 3.25 = 5.75
        // -------------------------------
        a = 64'h4022000000000000; // 9.0
        b = 64'h400A000000000000; // 3.25
        op = 2'b01;
        #10 real_result = $bitstoreal(result);
        $display("SUB:      %f - %f = %f", $bitstoreal(a), $bitstoreal(b), real_result); // Expected: 5.75

        // -------------------------------
        // Pair 3: 1.5 * 2.5 = 3.75
        // -------------------------------
        a = 64'h3FF8000000000000; // 1.5
        b = 64'h4004000000000000; // 2.5
        op = 2'b10;
        #10 real_result = $bitstoreal(result);
        $display("MUL:      %f * %f = %f", $bitstoreal(a), $bitstoreal(b), real_result); // Expected: 3.75

        // -------------------------------
        // Pair 4: 7.5 / 2.5 = 3.0
        // -------------------------------
        a = 64'h401E000000000000; // 7.5
        b = 64'h4004000000000000; // 2.5
        op = 2'b11;
        #10 real_result = $bitstoreal(result);
        $display("DIV:      %f / %f = %f", $bitstoreal(a), $bitstoreal(b), real_result); // Expected: 3.0

        #10 $finish;
    end
endmodule