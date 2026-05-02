package FIFO_coverage_pkg;
    import FIFO_transaction_pkg::*;

    class FIFO_coverage;
        FIFO_transaction F_cvg_txn;

        covergroup fifo_cg; 

            wr_cp: coverpoint F_cvg_txn.wr_en;
            rd_cp: coverpoint F_cvg_txn.rd_en;
            full_cp: coverpoint F_cvg_txn.full;
            empty_cp: coverpoint F_cvg_txn.empty;
            almostfull_cp: coverpoint F_cvg_txn.almostfull;
            almostempty_cp: coverpoint F_cvg_txn.almostempty;
            overflow_cp: coverpoint F_cvg_txn.overflow;
            underflow_cp: coverpoint F_cvg_txn.underflow;
            wr_ack_cp: coverpoint F_cvg_txn.wr_ack;
            cross_full: cross wr_cp, rd_cp, full_cp {

                illegal_bins full_wr_rd = binsof(full_cp) intersect {1} && 
                                          binsof(wr_cp) intersect {1}   && 
                                          binsof(rd_cp) intersect {1};

                illegal_bins full_rd_only = binsof(full_cp) intersect {1} && 
                                            binsof(wr_cp) intersect {0}   && 
                                            binsof(rd_cp) intersect {1};
            }

            cross_empty: cross wr_cp, rd_cp, empty_cp;
            cross_almostfull: cross wr_cp, rd_cp, almostfull_cp;
            cross_almostempty: cross wr_cp, rd_cp, almostempty_cp;
            cross_overflow: cross wr_cp, rd_cp, overflow_cp {
                illegal_bins overflow_no_wr = binsof(overflow_cp) intersect {1} && 
                                              binsof(wr_cp) intersect {0};
            }
            cross_underflow: cross wr_cp, rd_cp, underflow_cp {
                illegal_bins underflow_no_rd = binsof(underflow_cp) intersect {1} && 
                                               binsof(rd_cp) intersect {0};
            }
            cross_wr_ack: cross wr_cp, rd_cp, wr_ack_cp {
                illegal_bins wr_ack_no_wr = binsof(wr_ack_cp) intersect {1} && 
                                            binsof(wr_cp) intersect {0};
            }
        endgroup

        function new();
            fifo_cg = new;
            F_cvg_txn = new;
        endfunction

        function void sample_data(FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            fifo_cg.sample();
        endfunction
    endclass
endpackage