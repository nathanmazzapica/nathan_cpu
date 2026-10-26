`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 04:27:47 PM
// Design Name: 
// Module Name: register8
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


module register8(
        input wire clk,
        input wire en,
        input wire reset,
        input wire [7:0] d,
        output reg [7:0] q   
    );
    
    always @(posedge clk) begin
        if (reset) begin
            q <= 8'b0;
        end
        else if (en) begin
            q <= d;
        end 
    end
endmodule
