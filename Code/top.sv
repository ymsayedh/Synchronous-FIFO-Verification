module FIFO_top();

    bit clk;
    // Clock generation
    initial begin
        clk = 0;
        forever 
            #1 clk = ~clk;
    end
    FIFO_if fifo_if(clk);
    FIFO dut(fifo_if);
    FIFO_tb tb(fifo_if);
    FIFO_monitor mon(fifo_if, tb.etrigger);

    // Assertion for asynchronous reset
    always_comb begin
        if (!fifo_if.rst_n) begin
            async_reset_a: assert final (
                (fifo_if.data_out == 0) && !fifo_if.full && fifo_if.empty && !fifo_if.almostfull && 
                !fifo_if.almostempty && !fifo_if.wr_ack && !fifo_if.overflow && !fifo_if.underflow);
            async_reset_cover: cover final (
                (fifo_if.data_out == 0) && !fifo_if.full && fifo_if.empty && !fifo_if.almostfull && 
                !fifo_if.almostempty && !fifo_if.wr_ack && !fifo_if.overflow && !fifo_if.underflow);
        end
    end

endmodule