`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 05:30:28 PM
// Design Name: 
// Module Name: mux4_tb
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
//////////////////////////////////////////////////////////////////////////////////


module mux2_tb;
    reg [7:0] a,b;
    reg sel;
    wire [7:0] y;
    mux2 dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
        $dumpfile("mux2.vcd");
        $dumpvars(0, mux2_tb);

        a = 8'b00000001;
        b = 8'b00000010;

        sel = 1'b0;

        #10

        sel = 1'b1;

        #10

        // change A while A is selected
        sel = 1'b0;
        a = 8'b11111111;

        #10

        $finish;
    end


endmodule
