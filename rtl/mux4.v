`timescale 1ns / 1ps

module mux4(
        input wire [7:0] a, b, c, d,
        input wire [1:0] sel,
        output reg [7:0] y
    );

    always @(*) begin
        case (sel)
            2'b00 : y = a;
            2'b01 : y = b;
            2'b10 : y = c;
            2'b11 : y = d;
            default: y = 0;
        endcase
    end
endmodule
