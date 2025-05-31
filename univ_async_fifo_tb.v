`timescale 1ns / 1ps
module univ_async_fifo_tb;
    // Testbench Variables
    localparam FIFO_DEPTH = 8;
    localparam DATA_WIDTH = 32;

    reg wclk, wrst_n, w_en;
    reg rclk, rrst_n, r_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire full, empty;

    integer i;

    // Instantiate the DUT
    univ_async_fifo
        #(.FIFO_DEPTH(FIFO_DEPTH),
          .DATA_WIDTH(DATA_WIDTH))
        FIFO0
        (.wclk     (wclk     ),
         .wrst_n   (wrst_n   ),
         .w_en     (w_en   ),
         .rclk     (wclk     ),
         .rrst_n   (rrst_n   ),
         .r_en     (r_en   ),
         .data_in  (data_in ),
         .data_out (data_out),
         .full     (full    ),
         .empty    (empty   ));

    task write_data(input [DATA_WIDTH-1:0] d_in);
    begin
        @(posedge wclk); // sync to positive edge of write clock
        w_en = 1;
        data_in = d_in;
        $display($time, " write_data data_in = %0d", data_in);
        #5 w_en = 0;
    end
    endtask

    task read_data();
    begin
        @(posedge rclk);  // sync to positive edge of read clock
        r_en = 1;
        $display($time, " read_data data_out = %0d", data_out);
        #25 r_en = 0;
    end
    endtask

    // Create the write & read clock signal
    always #5 wclk = ~wclk;
    always #25 rclk = ~rclk;

    // Create stimulus
    initial
    begin
        {wclk, rclk} = 0;
        #5 {wrst_n, rrst_n} = 0; {w_en, r_en} = 0;
        #15 {wrst_n, rrst_n} = 2'b11;
        $display($time, "\n SCENARIO 1");
        write_data(1);
        write_data(10);
        write_data(100);
        repeat(3) read_data();

        $display($time, "\n SCENARIO 2");
        for(i=0; i<FIFO_DEPTH; i=i+1)
        begin
            write_data(2**i);
            read_data();
        end

        $display($time, "\n SCENARIO 3");
        for(i=0; i<=FIFO_DEPTH; i=i+1)
            write_data(2**i);
        for(i=0; i<FIFO_DEPTH; i=i+1)
            read_data();

        #1000 $stop;
    end
endmodule
