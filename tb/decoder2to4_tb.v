`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 05:48:32 PM
// Design Name: 
// Module Name: decoder2to4_tb
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


module decoder2to4_tb;
    reg [1:0] addr;
    reg en = 0;
    wire [3:0] y;
    decoder2to4 dut (
        .addr(addr),
        .en(en),
        .y(y)
    );

    initial begin
        en = 1;
        
        // TEST ENABLED
        addr = 2'b00;

        #10

        addr = 2'b01;
        
        #10

        addr = 2'b10;

        #10

        addr = 2'b11;

        #10

        // TEST DISABLED
        en = 0;

        addr = 2'b00;

        #10

        addr = 2'b01;
        
        #10

        addr = 2'b10;

        #10

        addr = 2'b11;

        #10

        $finish;

    end

endmodule
