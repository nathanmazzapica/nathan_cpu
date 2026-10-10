`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 05:48:17 PM
// Design Name: 
// Module Name: decoder2to4
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


module decoder2to4(
    input wire [1:0] addr,
    input wire en,
    output reg [3:0] y
    );

    always @(*) begin
        if (en) begin
            case (addr)
                2'b00 : y = 4'b0001;
                2'b01 : y = 4'b0010;
                2'b10 : y = 4'b0100;
                2'b11 : y = 4'b1000;
            endcase
        end
        else begin
            y = 4'b0000;
        end
    end
endmodule
