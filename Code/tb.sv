module FIFO_tb(FIFO_if.TEST fifo_if);

    import FIFO_transaction_pkg::*;
    import shared_pkg::*;
    event etrigger;
    FIFO_transaction txn;
    
    initial begin

        txn = new();
        

        // Reset the DUT
        fifo_if.rst_n = 0;
        fifo_if.data_in = 0;
        fifo_if.wr_en = 0;
        fifo_if.rd_en = 0;
        @(negedge fifo_if.clk);
        -> etrigger;

        fifo_if.rst_n = 1;
        @(negedge fifo_if.clk);
        -> etrigger;

        // Random stimulus
        repeat(10000) begin
            assert(txn.randomize());
            fifo_if.rst_n = txn.rst_n;
            fifo_if.data_in = txn.data_in;
            fifo_if.wr_en = txn.wr_en;
            fifo_if.rd_en = txn.rd_en;
            @(negedge fifo_if.clk);
            -> etrigger; 
        end

        test_finished = 1;
    end
endmodule