`timescale 1ns / 1ps

module register_adder_tb;
    reg clk = 0;

    // controls
    reg write_en = 0;
    reg write_mode = 1;
    reg cin = 0;

    // addresses
    reg [1:0] augend_addr = 0;
    reg [1:0] addend_addr = 0;
    reg [1:0] write_addr = 0;

    // data
    reg [7:0] data_in = 0;
    wire [7:0] data_out;

    // flag
    wire cf;

    register_adder dut (
        .clk(clk),
        .write_en(write_en),
        .augend_addr(augend_addr),
        .addend_addr(addend_addr),
        .write_addr(write_addr),
        .write_mode(write_mode),
        .data_in(data_in),
        .data_out(data_out),
        .cin(cin),
        .cf(cf)
    );


    always #5 clk = ~clk;

    initial begin
        $dumpfile("register_adder.vcd");
        $dumpvars(0, register_adder_tb);
        augend_addr = 2'b01;

        write_addr = 2'b00;
        write_en = 1;
        data_in = 5;

        #10;

        write_addr = 2'b01;
        data_in = 10;

        #10;
        
        write_addr = 2'b10;
        write_mode = 0;

        #10;

        $finish;
    end


    
endmodule
