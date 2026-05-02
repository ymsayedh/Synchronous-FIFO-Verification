package FIFO_transaction_pkg;
    
    class FIFO_transaction;
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;
        // Input signals
        rand bit [FIFO_WIDTH-1:0] data_in;
        rand bit rst_n, wr_en, rd_en;
        // Output signals
        bit [FIFO_WIDTH-1:0] data_out;
        bit wr_ack, overflow;
        bit full, empty, almostfull, almostempty, underflow;

        integer RD_EN_ON_DIST;
        integer WR_EN_ON_DIST;
    
        function new(integer RD_EN_ON_DIST = 30, integer WR_EN_ON_DIST = 70);
            this.RD_EN_ON_DIST = RD_EN_ON_DIST;
            this.WR_EN_ON_DIST = WR_EN_ON_DIST;
        endfunction
    
        constraint rst_c     { rst_n  dist {0 := 5, 1 := 95}; }
        constraint wr_en_c   { wr_en  dist {1 := WR_EN_ON_DIST, 0 := 100-WR_EN_ON_DIST}; }
        constraint rd_en_c   { wr_en  dist {1 := RD_EN_ON_DIST, 0 := 100-RD_EN_ON_DIST}; }
    endclass

endpackage