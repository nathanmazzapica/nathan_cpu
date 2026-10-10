`timescale 1ns / 1ps

module register_file(
        input wire clk,
        input wire write_en,
        input wire [1:0] write_addr,
        input wire [1:0] read_addr,
        input wire write_mode,
        input wire [7:0] data_in,
        output reg [7:0] data_out
    );

    wire [7:0] read_data;
    wire [7:0] write_data;
    wire [3:0] write_select;

    wire [7:0] q0, q1, q2, q3;

    mux4 read_data_mux(
        .a(q0),
        .b(q1),
        .c(q2),
        .d(q3),
        .sel(read_addr),
        .y(read_data)
    );

    mux2 write_data_mux(
        .a(read_data),
        .b(data_in),
        .sel(write_mode),
        .y(write_data)
    );

    decoder2to4 write_decoder(
        .addr(write_addr),
        .en(write_en),
        .y(write_select)
    );
        


    register8 reg0 (
        .clk(clk),
        .en(write_select[0]),
        .d(write_data),
        .q(q0)
    );

    register8 reg1(
        .clk(clk),
        .en(write_select[1]),
        .d(write_data),
        .q(q1)
    );

    register8 reg2(
        .clk(clk),
        .en(write_select[2]),
        .d(write_data),
        .q(q2)
    );
    register8 reg3(
        .clk(clk),
        .en(write_select[3]),
        .d(write_data),
        .q(q3)
    );

    always @(*) begin
        data_out = read_data;
    end

endmodule
