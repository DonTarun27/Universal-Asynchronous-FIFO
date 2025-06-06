`timescale 1ns / 1ps
module wptr_handler
    #(parameter PTR_WIDTH = 3)
    (input wclk, wrst_n, w_en,
     input [PTR_WIDTH-1:0] g_rptr_sync,
     output reg [PTR_WIDTH-1:0] b_wptr, g_wptr,
     output reg full);

    wire [PTR_WIDTH-1:0] b_wptr_next = b_wptr + (w_en & !full);
    wire [PTR_WIDTH-1:0] g_wptr_next = (b_wptr_next>>1) ^ b_wptr_next;
    wire wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH-1:PTR_WIDTH-2], g_rptr_sync[PTR_WIDTH-3:0]});

    always@(posedge wclk or negedge wrst_n)
    begin
        if(!wrst_n) {b_wptr, g_wptr} <= 0; // set default value
        else {b_wptr, g_wptr} <= {b_wptr_next, g_wptr_next}; // increment binary & gray write pointer
    end

    always@(posedge wclk or negedge wrst_n)
    begin
        if(!wrst_n) full <= 0;
        else        full <= wfull;
    end
endmodule
