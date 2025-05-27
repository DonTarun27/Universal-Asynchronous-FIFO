`timescale 1ns / 1ps
module synchronizer
    #(parameter WIDTH = 3)
    (input clk, rst_n, [WIDTH-1:0] d_in,
     output reg [WIDTH-1:0] d_out);

    reg [WIDTH-1:0] q1;

    always@(posedge clk)
    begin
        if(!rst_n) {q1, d_out} = 0;
        else {q1, d_out} = {d_in, q1};
    end
endmodule