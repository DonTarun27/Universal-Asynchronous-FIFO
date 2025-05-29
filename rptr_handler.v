`timescale 1ns / 1ps
module rptr_handler
    #(parameter PTR_WIDTH=3)
    (input rclk, rrst_n, r_en,
     input [PTR_WIDTH-1:0] g_wptr_sync,
     output reg [PTR_WIDTH-1:0] b_rptr, g_rptr,
     output reg empty);

    wire [PTR_WIDTH-1:0] b_rptr_next = b_rptr + (r_en & !empty);
    wire [PTR_WIDTH-1:0] g_rptr_next = (b_rptr_next >>1)^b_rptr_next;
    wire rempty = (g_wptr_sync == g_rptr_next);

    always@(posedge rclk or negedge rrst_n)
    begin
        if(!rrst_n) {b_rptr, g_rptr} <= 0; // set default value
        else {b_rptr, g_rptr} <= {b_rptr_next, g_rptr_next}; // increment binary & gray read pointer
    end

    always@(posedge rclk or negedge rrst_n)
    begin
        if(!rrst_n) empty <= 1;
        else        empty <= rempty;
    end
endmodule