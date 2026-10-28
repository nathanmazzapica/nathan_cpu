`timescale 1ns / 1ps

// 256 byte-addressed locations = 256 bytes = 2048 bits.
module program_rom #(
    parameter MEM_FILE = "program.hex"
) (
    input wire [7:0] addr,
    output wire [7:0] data_out
);
    reg [7:0] memory [0:255];

    initial begin
        $readmemh(MEM_FILE, memory);
    end

    assign data_out = memory[addr];
endmodule
