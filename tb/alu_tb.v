`timescale 1ns / 1ps

// Run from the repository root with Icarus Verilog:
//   iverilog -g2012 -s alu_tb -o /tmp/alu_tb.out tb/alu_tb.v rtl/alu.v rtl/full_adder8.v rtl/mux16.v
//   vvp /tmp/alu_tb.out
// Optional: vvp /tmp/alu_tb.out +waves (creates alu_tb.vcd for a waveform viewer).
//
// These checks describe the named operations, not a copy of the implementation.
module alu_tb;
    // A testbench has no ports. It supplies inputs to the device under test
    // (DUT) using reg variables and observes its outputs through wires.
    // A reg here is a simulation variable; it does not imply a hardware register.
    reg [3:0] op_sel;
    reg [7:0] a, b;
    wire [7:0] result;
    wire cout, zf;

    // localparam gives each opcode a readable, constant name.
    localparam [3:0] ADD  = 4'b0000, SUB  = 4'b0001,
                     INCR = 4'b0010, DECR = 4'b0011,
                     AND_OP = 4'b0100, NAND_OP = 4'b0101,
                     OR_OP  = 4'b0110, NOR_OP  = 4'b0111,
                     XOR_OP = 4'b1000, NOT_OP  = 4'b1001,
                     PASS = 4'b1010;

    integer tests, failures;
    integer unused_op;
    integer bit_index;

    alu dut (
        .op_sel(op_sel), .a(a), .b(b), .result(result), .cout(cout), .zf(zf)
    );

    // A task is a reusable simulation procedure. Each call drives one input
    // combination, waits for the combinational logic, and checks all outputs.
    task check;
        input [3:0] operation;
        input [7:0] input_a, input_b;
        input [7:0] expected_result;
        input expected_cout;
        input [8*96-1:0] description; // Packed bytes hold a printable text label.
        reg expected_zf;
        begin
            // ZF is 1 exactly when the eight-bit result is zero, even if cout
            // is 1 after overflow. Derive it from our EXPECTED result, not the
            // DUT's result, so an incorrect DUT output cannot define the answer.
            expected_zf = (expected_result == 8'h00);
            op_sel = operation;
            a = input_a;
            b = input_b;
            // No clock is needed for this combinational ALU. #1 advances time
            // by 1 ns so continuous assignments and the mux can settle first.
            #1;
            tests = tests + 1;
            // !== also catches X (unknown) and Z (undriven) output bits.
            // Ordinary != can itself evaluate to X and miss a failure in an if.
            if ((result !== expected_result) || (cout !== expected_cout) ||
                (zf !== expected_zf)) begin
                failures = failures + 1;
                $display("FAIL: %0s | op=%b a=%h b=%h expected result=%h cout=%b zf=%b, got result=%h cout=%b zf=%b",
                         description, operation, input_a, input_b,
                         expected_result, expected_cout, expected_zf, result, cout, zf);
            end else begin
                $display("PASS: %0s | result=%h cout=%b zf=%b", description, result, cout, zf);
            end
        end
    endtask

    // An initial block runs once at the start of simulation, from top to bottom.
    initial begin
        tests = 0;
        failures = 0;
        // Waveform dumping is optional so normal runs do not create extra files.
        if ($test$plusargs("waves")) begin
            $dumpfile("alu_tb.vcd");
            $dumpvars(0, alu_tb);
        end

        // 8'd is an 8-bit decimal literal; 8'h is an 8-bit hexadecimal literal.
        // Eight bits hold unsigned values 0..255. Arithmetic results wrap modulo
        // 256; addition's ninth bit appears on cout instead of in result.
        check(ADD, 8'd0,   8'd0,   8'd0,   1'b0, "ADD zero");
        check(ADD, 8'd12,  8'd34,  8'd46,  1'b0, "ADD ordinary values");
        check(ADD, 8'd254, 8'd1,   8'd255, 1'b0, "ADD reaches unsigned maximum");
        check(ADD, 8'd255, 8'd1,   8'd0,   1'b1, "ADD unsigned overflow: 255 + 1 wraps to 0");
        check(ADD, 8'd255, 8'd255, 8'd254, 1'b1, "ADD maximum operands");

        // SUB uses a + ~b + 1. Its carry is 1 when no unsigned borrow is
        // needed, and 0 when a < b. It is NOT a signed-overflow flag.
        check(SUB, 8'd34,  8'd12,  8'd22,  1'b1, "SUB ordinary values, no borrow");
        check(SUB, 8'd12,  8'd34,  8'd234, 1'b0, "SUB underflow wraps: 12 - 34");
        check(SUB, 8'd42,  8'd42,  8'd0,   1'b1, "SUB equal operands");
        check(SUB, 8'd0,   8'd0,   8'd0,   1'b1, "SUB zero minus zero, no borrow");
        check(SUB, 8'd0,   8'd1,   8'd255, 1'b0, "SUB underflow: 0 - 1 wraps to 255");
        check(SUB, 8'd0,   8'd255, 8'd1,   1'b0, "SUB zero minus maximum");
        check(SUB, 8'd255, 8'd0,   8'd255, 1'b1, "SUB maximum minus zero");

        // If interpreted as signed two's-complement, the same eight bits range
        // from -128 to +127. The ALU has no signed-overflow output. These cases
        // show signed overflow/underflow through the wrapped result bits.
        check(ADD, 8'h7f, 8'h01, 8'h80, 1'b0, "Signed ADD: 127 + 1 wraps to -128, cout stays 0");
        check(ADD, 8'h80, 8'hff, 8'h7f, 1'b1, "Signed ADD: -128 + -1 wraps to 127");
        check(SUB, 8'h80, 8'h01, 8'h7f, 1'b1, "Signed SUB: -128 - 1 wraps to 127, no unsigned borrow");
        check(SUB, 8'h7f, 8'hff, 8'h80, 1'b0, "Signed SUB: 127 - -1 wraps to -128");

        // Unary operations use only a. Repeating a with different b values
        // checks that the unused operand does not affect the output.
        check(INCR, 8'd0,   8'd0,   8'd1,   1'b0, "INCR zero");
        check(INCR, 8'd42,  8'd0,   8'd43,  1'b0, "INCR ordinary value");
        check(INCR, 8'd42,  8'd255, 8'd43,  1'b0, "INCR ignores b");
        check(INCR, 8'd254, 8'd0,   8'd255, 1'b0, "INCR reaches maximum");
        check(INCR, 8'd255, 8'd0,   8'd0,   1'b1, "INCR unsigned overflow");
        check(INCR, 8'h7f,  8'd0,   8'h80,  1'b0, "INCR signed overflow");

        // DECR is expected to mean a - 1, with the same no-borrow carry
        // convention as SUB. In particular 0 - 1 wraps to 8'hff (255 unsigned,
        // or -1 signed), with cout=0 and zf=0.
        check(DECR, 8'd42,  8'd0,   8'd41,  1'b1, "DECR ordinary value");
        check(DECR, 8'd42,  8'd255, 8'd41,  1'b1, "DECR ignores b");
        check(DECR, 8'd1,   8'd0,   8'd0,   1'b1, "DECR reaches zero without borrowing");
        check(DECR, 8'd0,   8'd0,   8'd255, 1'b0, "DECR underflow: zero should wrap to 255");
        check(DECR, 8'd255, 8'd0,   8'd254, 1'b1, "DECR maximum value");
        check(DECR, 8'h80,  8'd0,   8'h7f,  1'b1, "DECR signed underflow");

        // These mixed patterns contain all four per-bit input combinations
        // (00, 01, 10, 11), so they distinguish each bitwise truth table.
        // Logic, PASS, and unused opcodes must all force cout to zero.
        check(AND_OP,  8'hcc, 8'haa, 8'h88, 1'b0, "AND mixed bits");
        check(NAND_OP, 8'hcc, 8'haa, 8'h77, 1'b0, "NAND mixed bits");
        check(OR_OP,   8'hcc, 8'haa, 8'hee, 1'b0, "OR mixed bits");
        check(NOR_OP,  8'hcc, 8'haa, 8'h11, 1'b0, "NOR mixed bits");
        check(XOR_OP,  8'hcc, 8'haa, 8'h66, 1'b0, "XOR mixed bits");
        check(AND_OP,  8'hff, 8'hff, 8'hff, 1'b0, "AND all ones, arithmetic carry must not leak");
        check(NAND_OP, 8'hff, 8'hff, 8'h00, 1'b0, "NAND all ones");
        check(OR_OP,   8'h00, 8'h00, 8'h00, 1'b0, "OR all zeros");
        check(NOR_OP,  8'h00, 8'h00, 8'hff, 1'b0, "NOR all zeros");
        check(XOR_OP,  8'hff, 8'hff, 8'h00, 1'b0, "XOR identical operands");
        check(NOT_OP,  8'h00, 8'h00, 8'hff, 1'b0, "NOT zero");
        check(NOT_OP,  8'hff, 8'hff, 8'h00, 1'b0, "NOT all ones");
        check(NOT_OP,  8'ha5, 8'h00, 8'h5a, 1'b0, "NOT mixed bits");
        check(NOT_OP,  8'ha5, 8'hff, 8'h5a, 1'b0, "NOT ignores b");
        check(PASS,    8'ha5, 8'h00, 8'ha5, 1'b0, "PASS copies a");
        check(PASS,    8'ha5, 8'hff, 8'ha5, 1'b0, "PASS ignores b");
        check(PASS,    8'h00, 8'hff, 8'h00, 1'b0, "PASS zero");
        check(PASS,    8'hff, 8'hff, 8'hff, 1'b0, "PASS maximum");

        // Together with the checks above, these cover both ZF values for every
        // defined operation. Nonzero operands can still produce a zero result.
        check(AND_OP, 8'haa, 8'h55, 8'h00, 1'b0, "AND disjoint bits sets ZF");
        check(NOR_OP, 8'haa, 8'h55, 8'h00, 1'b0, "NOR complementary bits sets ZF");

        // Keep both operands fixed and change only the opcode. ZF must follow
        // the selected result, rather than an input or an unselected operation.
        check(SUB, 8'd1, 8'd1, 8'd0, 1'b1, "ZF sets when selected result is zero");
        check(ADD, 8'd1, 8'd1, 8'd2, 1'b0, "ZF clears when only opcode changes");
        check(XOR_OP, 8'd1, 8'd1, 8'd0, 1'b0, "ZF sets again when only opcode changes");

        // << shifts a bit left. Move a single 1 through all eight positions to
        // check that EVERY result bit can clear ZF, including the top bit.
        // Interleave zero results to test ZF changing in both directions.
        for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
            check(PASS, 8'h01 << bit_index, 8'h00, 8'h01 << bit_index,
                  1'b0, "Each individual result bit clears ZF");
            check(PASS, 8'h00, 8'h00, 8'h00, 1'b0, "Returning to zero sets ZF");
        end

        // A for loop repeats checks for the five unused selectors. The current
        // ALU explicitly connects these mux inputs to zero.
        for (unused_op = 11; unused_op < 16; unused_op = unused_op + 1)
            check(unused_op[3:0], 8'hff, 8'hff, 8'h00, 1'b0, "Unused opcode returns zero");

        $display("ALU summary: %0d checks, %0d passed, %0d failed",
                 tests, tests - failures, failures);
        // Collect all failures before stopping, so one bug does not hide other
        // results. $fatal returns an error status to automated test runners.
        if (failures != 0)
            $fatal(1, "ALU tests failed; see expected and actual values above.");
        $finish;
    end
endmodule
