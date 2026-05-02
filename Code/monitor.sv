import shared_pkg::*;
import FIFO_transaction_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_scoreboard_pkg::*;
module FIFO_monitor (FIFO_if.MONITOR fifo_if, input event etrigger);

    FIFO_transaction txn;
    FIFO_coverage    cov;
    FIFO_scoreboard  scbd;
    
    initial begin
        txn  = new;
        cov  = new;
        scbd = new;
        forever begin
            wait(etrigger.triggered);
            @(negedge fifo_if.clk);
            // Sample interface data
            txn.data_in = fifo_if.data_in;
            txn.rst_n = fifo_if.rst_n;
            txn.wr_en = fifo_if.wr_en;
            txn.rd_en = fifo_if.rd_en;
            txn.data_out = fifo_if.data_out;
            txn.full = fifo_if.full;
            txn.empty = fifo_if.empty;
            txn.almostfull = fifo_if.almostfull;
            txn.almostempty = fifo_if.almostempty;
            txn.wr_ack = fifo_if.wr_ack;
            txn.overflow = fifo_if.overflow;
            txn.underflow = fifo_if.underflow;

            fork
                begin
                    cov.sample_data(txn);
                end
                begin
                    scbd.check_data(txn);
                end
            join

            if (test_finished) begin
                $display("----------------Test Finished----------------");
                $display("Correct Count: %0d , Error Count: %0d", correct_count, error_count);
                $stop;
            end
        end
    end

endmodule