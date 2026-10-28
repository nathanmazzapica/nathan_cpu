`timescale 1ns / 1ps
module program_counter(
    input wire jmp,
    input wire [7:0] jmp_addr,
    input wire reset,
    input wire en,
    input wire clk,
    output wire [7:0] pc
);

    wire [7:0] incremented_pc;
    wire [7:0] next_pc;
    
    mux2 next_pc_mux(
        .a(incremented_pc),
        .b(jmp_addr),
        .sel(jmp),
        .y(next_pc)
    );

    register8 pc_register(
        .clk(clk),
        .en(en),
        .reset(reset),
        .d(next_pc),
        .q(pc)
    );

    full_adder8 incr(
        .a(pc),
        .b(8'b1),
        .cin(1'b0),
        .sum(incremented_pc),
        .cout()
    );

endmodule
