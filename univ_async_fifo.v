`timescale 1ns / 1ps
module univ_async_fifo
    #(parameter FIFO_DEPTH = 8, DATA_WIDTH = 32)
    (input wclk, wrst_n, w_en,
     input rclk, rrst_n, r_en,
     input [DATA_WIDTH-1:0] data_in,
     output reg [DATA_WIDTH-1:0] data_out,
     output full, empty);

    localparam PTR_WIDTH = $clog2(FIFO_DEPTH) + 1; // Write/Read pointer have 1 extra bits at MSB

    // Declare a by-dimensional array to store the data
    reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];

    wire [PTR_WIDTH-1:0] g_wptr_sync, g_rptr_sync;
    wire [PTR_WIDTH-1:0] b_wptr, b_rptr;
    wire [PTR_WIDTH-1:0] g_wptr, g_rptr;

    // Sync write pointer to read clock domain
    synchronizer #(PTR_WIDTH) sync_wptr (.clk(rclk), .rst_n(rrst_n), .d_in(g_wptr), .d_out(g_wptr_sync));
    // Sync read pointer to write clock domain
    synchronizer #(PTR_WIDTH) sync_rptr (.clk(wclk), .rst_n(wrst_n), .d_in(g_rptr), .d_out(g_rptr_sync));
    wptr_handler #(PTR_WIDTH) wptr_h(wclk, wrst_n, w_en, g_rptr_sync, b_wptr, g_wptr, full);
    rptr_handler #(PTR_WIDTH) rptr_h(rclk, rrst_n, r_en, g_wptr_sync, b_rptr, g_rptr, empty);

    always@(posedge wclk)
    begin
        if(w_en && !full)
            fifo[b_wptr[PTR_WIDTH-2:0]] <= data_in;
	end

    always @(posedge rclk or negedge rrst_n)
    begin
        if(!rrst_n)
            data_out <= 0;
        else if(r_en && !empty)
            data_out <= fifo[b_rptr[PTR_WIDTH-2:0]];
    end
endmodule
