`timescale 1ns / 1ps

module register_adder(
    input wire clk,
    input wire write_en,
    input wire [1:0] augend_addr,
    input wire [1:0] addend_addr,
    input wire [1:0] write_addr,
    input wire write_mode,
    input wire [7:0] data_in,
    input wire cin,
    output wire cf,
    output reg [7:0] data_out
);
    wire [7:0] augend_data;
    wire [7:0] addend_data;
    wire [7:0] write_data;
    wire [7:0] sum_data;
    wire [3:0] write_select;

    // Da registahs
    wire [7:0] q0, q1, q2, q3;

    mux4 augend_mux(
        .a(q0),
        .b(q1),
        .c(q2),
        .d(q3),
        .sel(augend_addr),
        .y(augend_data)
    );

    mux4 addend_mux(
        .a(q0),
        .b(q1),
        .c(q2),
        .d(q3),
        .sel(addend_addr),
        .y(addend_data)
    );

    full_adder8 adder(
        .a(augend_data),
        .b(addend_data),
        .cin(cin),
        .sum(sum_data),
        .cout(cf)
    );

    mux2 write_data_mux(
        .a(sum_data),
        .b(data_in),
        .sel(write_mode),
        .y(write_data)
    );

    decoder2to4 write_decoder(
        .addr(write_addr),
        .en(write_en),
        .y(write_select)
    );
    
    // REGISTERS //

    register8 reg0 (
        .clk(clk),
        .reset(1'b0), // Reset unused: keep it inactive.
        .en(write_select[0]),
        .d(write_data),
        .q(q0)
    );

    register8 reg1(
        .clk(clk),
        .reset(1'b0), // Reset unused: keep it inactive.
        .en(write_select[1]),
        .d(write_data),
        .q(q1)
    );

    register8 reg2(
        .clk(clk),
        .reset(1'b0), // Reset unused: keep it inactive.
        .en(write_select[2]),
        .d(write_data),
        .q(q2)
    );
    register8 reg3(
        .clk(clk),
        .reset(1'b0), // Reset unused: keep it inactive.
        .en(write_select[3]),
        .d(write_data),
        .q(q3)
    );

    always @(*) begin
        data_out = sum_data;
    end

endmodule

