package FIFO_scoreboard_pkg;
    import FIFO_transaction_pkg::*;
    import shared_pkg::*;

    class FIFO_scoreboard;
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;
        bit [FIFO_WIDTH-1:0] data_out_ref;
        bit [FIFO_WIDTH-1:0] fifo_ref[$];


        function void check_data(FIFO_transaction F_txn);
            reference_model(F_txn);
            if(data_out_ref !== F_txn.data_out) begin
                error_count++;
                $display("wr_en = %0b, rd_en = %0b", F_txn.wr_en, F_txn.rd_en);
                $display("Error at time = %0t : Expected = %0h, Got = %0h",
                $time, data_out_ref, F_txn.data_out);
            end
            else begin
                correct_count++;
            end
        endfunction
        

        function void reference_model(FIFO_transaction F_txn);
        
            if(!F_txn.rst_n) begin
                fifo_ref.delete();
                data_out_ref = 0;
            end
            else begin

                // Simultaneous read and write
                if (F_txn.wr_en && F_txn.rd_en) begin

                    // Only write when empty
                    if(fifo_ref.size() == 0)
                        fifo_ref.push_back(F_txn.data_in);

                    // Only read when full
                    else if (fifo_ref.size() == FIFO_DEPTH) 
                        data_out_ref = fifo_ref.pop_front();
                    // Read and Write
                    else begin
                        data_out_ref = fifo_ref.pop_front();
                        fifo_ref.push_back(F_txn.data_in);
                    end    
                end
                
                // Write
                else if (F_txn.wr_en && !F_txn.rd_en) begin
                    if (fifo_ref.size() != FIFO_DEPTH)
                    fifo_ref.push_back(F_txn.data_in);
                end
                
                // Read
                else if (!F_txn.wr_en && F_txn.rd_en) begin
                    if (fifo_ref.size() != 0)
                        data_out_ref = fifo_ref.pop_front();
                end

            end
        endfunction
    endclass

endpackage