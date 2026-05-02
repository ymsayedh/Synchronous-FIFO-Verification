module FIFO(FIFO_if.DUT fifo_if);

	localparam max_fifo_addr = $clog2(fifo_if.FIFO_DEPTH);

	reg [fifo_if.FIFO_WIDTH-1:0] mem [fifo_if.FIFO_DEPTH-1:0];

	reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
	reg [max_fifo_addr:0] count;

	always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
		if (!fifo_if.rst_n) begin
			wr_ptr <= 0;
			fifo_if.wr_ack <= 0; 
			fifo_if.overflow <= 0; 
		end
		else if (fifo_if.wr_en && count < fifo_if.FIFO_DEPTH) begin
			mem[wr_ptr] <= fifo_if.data_in;
			fifo_if.wr_ack <= 1;
			fifo_if.overflow <= 0;
			wr_ptr <= wr_ptr + 1;
		end
		else begin 
			fifo_if.wr_ack <= 0; 
			if (fifo_if.full & fifo_if.wr_en)
				fifo_if.overflow <= 1;
			else
				fifo_if.overflow <= 0;
		end
	end

	always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
		if (!fifo_if.rst_n) begin
			rd_ptr <= 0;
			fifo_if.underflow <= 0; 
			fifo_if.data_out <= 0; 
		end
		else if (fifo_if.rd_en && count != 0) begin
			fifo_if.data_out <= mem[rd_ptr];
			fifo_if.underflow <= 0;
			rd_ptr <= rd_ptr + 1;
		end

		else begin
			if (fifo_if.empty && fifo_if.rd_en) 
				fifo_if.underflow <= 1;
			else
				fifo_if.underflow <= 0;
		end
	end

	always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
		if (!fifo_if.rst_n) begin
			count <= 0;
		end
		else begin
			if	( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b10) && !fifo_if.full) 
					count <= count + 1;
			else if ( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b01) && !fifo_if.empty)
				count <= count - 1;

			else if ({fifo_if.wr_en, fifo_if.rd_en} == 2'b11) begin
				if (fifo_if.empty)
					count <= count + 1;
				if (fifo_if.full)
					count <= count - 1;
			end
		end
	end

	assign fifo_if.full = (count == fifo_if.FIFO_DEPTH)? 1 : 0;
	assign fifo_if.empty = (count == 0)? 1 : 0;
	assign fifo_if.almostfull = (count == fifo_if.FIFO_DEPTH-1)? 1 : 0; // bug fixed
	assign fifo_if.almostempty = (count == 1)? 1 : 0;

	`ifdef SIM

	// Assertion for design requirements
	property reset_behavior;
    	@(posedge fifo_if.clk) (!fifo_if.rst_n) |=> (wr_ptr == 0) && (rd_ptr == 0) && (count == 0);
	endproperty
	assert property(reset_behavior) else $error("Reset assertion failed");
	cover property(reset_behavior);

	property wr_ack_check;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
		(fifo_if.wr_en && !fifo_if.full) |=> fifo_if.wr_ack;
	endproperty
	assert property(wr_ack_check) else $error("Write acknowledge assertion failed");
	cover property(wr_ack_check);

	property overflow_check;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
    	(fifo_if.wr_en && fifo_if.full) |=> fifo_if.overflow;
	endproperty
	assert property(overflow_check) else $error("Overflow assertion failed");
	cover property(overflow_check);

	property underflow_check;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
    	(fifo_if.rd_en && fifo_if.empty) |=> fifo_if.underflow;
	endproperty
	assert property(underflow_check) else $error("Underflow assertion failed");
	cover property(underflow_check);

	property empty_flag_check;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
    	(count == 0) |-> fifo_if.empty;
	endproperty
	assert property(empty_flag_check) else $error("Empty flag assertion failed");
	cover property(empty_flag_check);

	property full_flag_check;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
   		(count == fifo_if.FIFO_DEPTH) |-> fifo_if.full;
	endproperty
	assert property(full_flag_check) else $error("Full flag assertion failed");
	cover property(full_flag_check);

	property almostfull_check;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
    	(count == fifo_if.FIFO_DEPTH - 1) |-> fifo_if.almostfull;
	endproperty
	assert property(almostfull_check) else $error("Almost full assertion failed");
	cover property(almostfull_check);

	property almostempty_check;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
    	(count == 1) |-> fifo_if.almostempty;
	endproperty
	assert property(almostempty_check) else $error("Almost empty assertion failed");
	cover property(almostempty_check);

	property wr_ptr_wraparound;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
    	(wr_ptr == fifo_if.FIFO_DEPTH - 1) && fifo_if.wr_en && (count < fifo_if.FIFO_DEPTH) |=> (wr_ptr == 0);
	endproperty
	assert property(wr_ptr_wraparound) else $error("Write pointer wraparound failed");
	cover property(wr_ptr_wraparound);
	// FIFO_8
	property rd_ptr_wraparound;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
    	(rd_ptr == fifo_if.FIFO_DEPTH - 1) && fifo_if.rd_en && (count != 0) |=> (rd_ptr == 0);
	endproperty
	assert property(rd_ptr_wraparound) else $error("Read pointer wraparound failed");
	cover property(rd_ptr_wraparound);

	property wr_ptr_threshold;
    @(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
    	wr_ptr < fifo_if.FIFO_DEPTH;
	endproperty
	assert property(wr_ptr_threshold) else $error("Write pointer exceeded threshold");
	cover property(wr_ptr_threshold);

	property rd_ptr_threshold;
		@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
		rd_ptr < fifo_if.FIFO_DEPTH;
	endproperty
	assert property(rd_ptr_threshold) else $error("Read pointer exceeded threshold");
	cover property(rd_ptr_threshold);

	property count_threshold;
		@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
		count <= fifo_if.FIFO_DEPTH;
	endproperty
	assert property(count_threshold) else $error("Count exceeded FIFO depth");
	cover property(count_threshold);

	`endif

endmodule