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


module mux4_tb;
    reg [7:0] a,b,c,d;
    reg [1:0] sel;
    wire [7:0] y;
    mux4 dut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sel(sel),
        .y(y)
    );

    initial begin
        a = 8'b00000001;
        b = 8'b00000010;
        c = 8'b00000011;
        d = 8'b00000100;

        sel = 2'b00;

        #10

        sel = 2'b01;

        #10

        sel = 2'b10;

        #10

        sel = 2'b11;

        #10

        // change A while A is selected
        sel = 2'b00;
        a = 8'b11111111;

        #10

        $finish;
    end


endmodule
