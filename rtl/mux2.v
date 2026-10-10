`timescale 1ns / 1ps

module mux2(
    input wire [7:0] a, b,
    input wire sel,
    output reg [7:0] y
);
    always @(*) begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = 0;
        endcase
    end
endmodule
