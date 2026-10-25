`timescale 1ns / 1ps
/*
* Ops:
    * ADD   - 0000
    * SUB   - 0001
    * INCR  - 0010
    * DECR  - 0011
    * AND   - 0100
    * NAND  - 0101
    * OR    - 0110
    * NOR   - 0111
    * XOR   - 1000
    * NOT   - 1001
    * PASS  - 1010
    * ???   - 1011
    * ???   - 1100
    * ???   - 1101
    * ???   - 1110
    * ???   - 1111
* */
module alu(
    input wire [3:0] op_sel, // allows for 16 ops
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] result,
    output wire cout
);

    // ARITHMETIC
    wire [7:0]  addition_result, subtraction_result,
                increment_result, decrement_result;

    wire        addition_cout, subtraction_cout,
                increment_cout, decrement_cout;

    wire [7:0]  and_result, nand_result, or_result,
                nor_result, xor_result, not_result;

    wire [7:0] pass_result;

    mux16 operation(
        .a(addition_result),
        .b(subtraction_result),
        .c(increment_result),
        .d(decrement_result),
        .e(and_result),
        .f(nand_result),
        .g(or_result),
        .h(nor_result),
        .i(xor_result),
        .j(not_result),
        .k(pass_result),
        .l(8'b0),
        .m(8'b0),
        .n(8'b0),
        .o(8'b0),
        .p(8'b0),
        .sel(op_sel),
        .y(result)
    );

    full_adder8 adder(
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(addition_result),
        .cout(addition_cout)
    );

    full_adder8 subtractor(
        .a(a),
        .b(~b),
        .cin(1'b1),
        .sum(subtraction_result),
        .cout(subtraction_cout)
    );

    full_adder8 incrementor(
        .a(a),
        .b(8'b1),
        .cin(1'b0),
        .sum(increment_result),
        .cout(increment_cout)
    );
    
    full_adder8 decrementor(
        .a(a),
        .b(8'b11111110),
        .cin(1'b1),
        .sum(decrement_result),
        .cout(decrement_cout)
    );

    assign cout =   (op_sel == 4'b0000) ? addition_cout     :
                    (op_sel == 4'b0001) ? subtraction_cout  :
                    (op_sel == 4'b0010) ? increment_cout    :
                    (op_sel == 4'b0011) ? decrement_cout    :
                    1'b0;
    // LOGIC

    assign and_result   = a & b;
    assign nand_result  = ~(a & b);
    assign or_result    = a | b;
    assign nor_result   = ~(a | b);
    assign xor_result   = a ^ b;
    assign not_result   = ~a;
    assign pass_result  = a;

endmodule
