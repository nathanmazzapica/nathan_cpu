`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 04:42:08 PM
// Design Name: 
// Module Name: register8_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
///////////////////////////////////////////////////////;///////////////////////////


module register8_tb;
    reg clk = 0;
    reg en = 0;
    reg [7:0] d = 0;
    wire [7:0] q;
    register8 dut (
        .clk(clk),
        .reset(1'b0), // Reset unused: keep it inactive.
        .en(en),
        .d(d),
        .q(q)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("register8.vcd");
        $dumpvars(0, register8_tb);
        // Test 1: Write a value
        en = 1;
        d = 8'b10110101;

        #10;

        // Test 2: Disable writing
        en = 0;
        d = 8'b1111111;

        #10;

        en = 1;

        #10;

        $finish;
    end
endmodule
