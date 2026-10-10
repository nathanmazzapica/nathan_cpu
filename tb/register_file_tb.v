`timescale 1ns / 1ps

module register_file_tb;
    reg clk = 0;
    reg write_en = 0;
    reg write_mode = 1;

    reg [1:0] write_addr = 0;
    reg [1:0] read_addr = 0;

    reg [7:0] data_in = 0;
    wire [7:0] data_out;

    register_file dut (
        .clk(clk),
        .write_en(write_en),
        .write_addr(write_addr),
        .read_addr(read_addr),
        .write_mode(write_mode),
        .data_in(data_in),
        .data_out(data_out)
    );


    always #5 clk = ~clk;

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars(0, register_file_tb);
        write_addr = 2'b00;
        write_en = 1;
        data_in = 8'h42;
        #10

        // copy time. A into D

        data_in = 8'h99;
        write_mode = 0;
        read_addr = 2'b00;
        write_addr = 2'b11;

        #10

        $finish;
    end
endmodule

