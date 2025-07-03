module FPU_TB2;
    reg [63:0] a, b;
    reg [1:0] op;
    wire [63:0] result;

    FPU uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    // Correct: Task with 4 arguments
    task print_result;
        input [63:0] a_in, b_in, result_in;
        input [1:0] op_in;
        begin
            $display("------------------------------------------------------");
            $display("A      = %h", a_in);
            $display("B      = %h", b_in);
            $display("Op     = %s", (op_in == 2'b00) ? "ADD" :
                                    (op_in == 2'b01) ? "SUB" :
                                    (op_in == 2'b10) ? "MUL" : "DIV");
            $display("Result = %h", result_in);
        end
    endtask

    initial begin
        // Test 1: 3.0 + 4.0
        a = 64'h4008000000000000; // 3.0
        b = 64'h4010000000000000; // 4.0
        op = 2'b00;
        #10 print_result(a, b, result, op);

        // Test 2: 5.5 - 2.0
        a = 64'h4016000000000000; // 5.5
        b = 64'h4000000000000000; // 2.0
        op = 2'b01;
        #10 print_result(a, b, result, op);

        // Test 3: 2.5 * -3.0
        a = 64'h4004000000000000; // 2.5
        b = 64'hc008000000000000; // -3.0
        op = 2'b10;
        #10 print_result(a, b, result, op);

        // Test 4: -6.0 / 2.0
        a = 64'hc018000000000000; // -6.0
        b = 64'h4000000000000000; // 2.0
        op = 2'b11;
        #10 print_result(a, b, result, op);

        // Test 5: 2.0 / 0.0
        a = 64'h4000000000000000; // 2.0
        b = 64'h0000000000000000; // 0.0
        op = 2'b11;
        #10 print_result(a, b, result, op);

        // Test 6: 0.0 / 3.0
        a = 64'h0000000000000000; // 0.0
        b = 64'h4008000000000000; // 3.0
        op = 2'b11;
        #10 print_result(a, b, result, op);

        // Test 7: NaN + 2.0
        a = 64'h7FF8000000000001; // NaN
        b = 64'h4000000000000000; // 2.0
        op = 2'b00;
        #10 print_result(a, b, result, op);

        $finish;
    end
endmodule