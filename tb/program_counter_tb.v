`timescale 1ns / 1ps

// From the repository root:
//   iverilog -g2012 -s program_counter_tb -o /tmp/program_counter_tb.out tb/program_counter_tb.v rtl/program_counter.v rtl/register8.v rtl/mux2.v rtl/full_adder8.v
//   vvp /tmp/program_counter_tb.out
// Add +waves to the vvp command to create program_counter_tb.vcd.
//
// Reset contract assumed by these tests: active high, clears pc to zero,
// and takes priority over en and jmp. We check after a rising edge, so either
// synchronous or asynchronous reset can satisfy these checks.
module program_counter_tb;
    // The testbench drives inputs with reg variables and observes outputs
    // through wires. DUT means "device under test."
    reg clk, en, jmp, reset;
    reg [7:0] jmp_addr;
    wire [7:0] pc;
    integer tests, failures;

    program_counter dut (
        .clk(clk), .en(en), .jmp(jmp), .jmp_addr(jmp_addr),
        .reset(reset), .pc(pc)
    );

    // A task is a reusable procedure. This one compares the actual output
    // against an explicit expected value and records failures without stopping.
    task check;
        input [7:0] expected_pc;
        input [8*96-1:0] description;
        begin
            tests = tests + 1;
            // Case inequality (!==) catches unknown (X) and undriven (Z) bits
            // as failures too; ordinary != can produce an unknown comparison.
            if (pc !== expected_pc) begin
                failures = failures + 1;
                $display("FAIL: %0s | expected pc=%h, got pc=%h", description, expected_pc, pc);
            end else
                $display("PASS: %0s | pc=%h", description, pc);
        end
    endtask

    // Manually generate one clock cycle per call. Set controls BEFORE calling
    // this task, so they are stable when the rising edge arrives.
    task tick;
        begin
            #4 clk = 1'b1;
            // Clocked nonblocking assignments (<=) update later in the same
            // simulation time step. Waiting avoids checking the old value.
            #1;
            #4 clk = 1'b0;
            #1;
        end
    endtask

    initial begin
        clk = 0;
        en = 0;
        jmp = 0;
        reset = 0;
        jmp_addr = 0;
        tests = 0;
        failures = 0;

        if ($test$plusargs("waves")) begin
            $dumpfile("program_counter_tb.vcd");
            $dumpvars(0, program_counter_tb);
        end

        // No power-up value is assumed. Ask reset to establish a known state.
        #1 reset = 1;
        tick;
        check(8'd0, "Reset establishes zero while disabled");
        reset = 0;

        // Seed through the public jump inputs rather than changing internal
        // registers. This lets later tests run even if the reset test fails.
        en = 1;
        jmp = 1;
        jmp_addr = 8'd10;
        tick;
        check(8'd10, "Enabled jump loads its exact address");

        jmp = 0;
        tick;
        check(8'd11, "Enabled counter increments by one");
        tick;
        check(8'd12, "Counter increments on consecutive cycles");

        en = 0;
        tick;
        check(8'd12, "Disabled counter holds");
        jmp = 1;
        jmp_addr = 8'd90;
        tick;
        check(8'd12, "Disabled counter ignores jump");
        tick;
        check(8'd12, "Disabled counter holds across multiple cycles");

        en = 1;
        // Changing inputs alone must not update clocked storage.
        #1;
        check(8'd12, "Enabling jump without a clock edge leaves pc unchanged");
        tick;
        check(8'd90, "Jump takes priority over increment");
        tick;
        check(8'd90, "Keeping jump high reloads the address");

        // Exercise the falling edge separately: only a rising edge should load.
        #4 clk = 1;
        #1;
        jmp_addr = 8'd37;
        #1;
        check(8'd90, "Changing jump address while clock is high does not load");
        #3 clk = 0;
        #1;
        check(8'd90, "Falling edge does not load jump address");
        tick;
        check(8'd37, "Next rising edge loads changed jump address");

        jmp = 0;
        tick;
        check(8'd38, "Increment resumes after jump is released");

        jmp = 1;
        jmp_addr = 8'd255;
        tick;
        check(8'd255, "Jump can load maximum address");
        jmp = 0;
        tick;
        // Eight bits retain only the low eight bits of 255 + 1, giving zero.
        check(8'd0, "Increment wraps from 255 to zero");
        tick;
        check(8'd1, "Counting continues after wraparound");
        jmp = 1;
        jmp_addr = 8'd0;
        tick;
        check(8'd0, "Jump can load address zero");

        // Seed a nonzero value before each reset check, so an already-zero pc
        // cannot accidentally make a missing reset appear to work.
        jmp_addr = 8'd40;
        tick;
        check(8'd40, "Prepare nonzero value for reset test");
        jmp = 0;
        reset = 1;
        tick;
        check(8'd0, "Reset overrides enabled increment");
        tick;
        check(8'd0, "Held reset keeps pc at zero");
        reset = 0;
        // Reseed to keep subsequent tests independent of reset behavior.
        jmp = 1;
        jmp_addr = 8'd40;
        tick;
        en = 0;
        jmp = 0;
        reset = 1;
        tick;
        check(8'd0, "Reset clears a nonzero counter even when disabled");

        reset = 0;
        en = 1;
        jmp = 1;
        jmp_addr = 8'd40;
        tick;
        jmp_addr = 8'd80;
        reset = 1;
        tick;
        check(8'd0, "Reset takes priority over jump");
        reset = 0;
        tick;
        check(8'd80, "Jump works after reset is released");

        $display("Program counter summary: %0d checks, %0d passed, %0d failed",
                 tests, tests - failures, failures);
        // $fatal reports an unsuccessful simulation after all checks have run.
        if (failures != 0)
            $fatal(1, "Program counter tests failed; see results above.");
        $finish;
    end
endmodule
