
`timescale 1 ns / 1 ps

`include "jtag_tap_defines.v"

module testbench;

	parameter IR_LENGTH 	= 4;
	parameter MAX_TDO_VEC	= 64;
 
    reg clk;
    wire led0, led1, led2, button_;

	reg trst_, tck, tdi, tms, tdo_en;

    top u_top(
        .clk(clk),

`ifdef JTAG_TAP_GENERIC
        .tck(tck),
        .tms(tms),
        .tdi(tdi),
        .tdo(tdo),
`endif

        .led0(led0),
        .led1(led1),
        .led2(led2),

        .button_(button_)
    );

    initial begin
		clk		= 0;
		forever begin
			#5 clk	= ~clk;
		end
    end

	initial begin
		tck		= 0;
		forever begin
			#25 tck	= ~tck;
		end
	end

	initial begin
		$display("%t: Start of simulation!", $time);
		$dumpfile("waves.vcd");
		$dumpvars(0, testbench);

		trst_	= 0;
		repeat(10) @(posedge tck);
		trst_	= 1;

		repeat(10000) @(posedge tck);
		$display("%t: Simulation complete...", $time);
		$finish;
	end

	task jtag_clocked_reset;
		begin
			$display("%t: JTAG Clocked Reset", $time);
			tms	= 1;
			repeat(5) @(negedge tck);
		end
	endtask

	task jtag_apply_tms;
		input tms_in;
		begin
			tms = tms_in;
			@(negedge tck);
		end
	endtask

	task jtag_reset_to_select_dr_scan;
		begin
			$display("%t: Reset to Select-DR-Scan", $time);

			// Go to RTI
			tms = 0;
			@(negedge tck);

			// Go to Select-DR-Scan
			tms = 1;
			@(negedge tck);
		end
	endtask

	task jtag_scan_vector;

		input [255:0] 	vector_in;
		input integer 	nr_bits;
		input 			exit1;

		integer i;
		begin
			for(i=0; i<nr_bits; i=i+1) begin
				tdi = vector_in[i];

				if (i == nr_bits-1) begin
					tms = exit1;			// Go to Exit1-*
				end
				@(negedge tck);
			end
		end
	endtask

	task jtag_set_ir;
		input [IR_LENGTH-1:0] wanted_ir;

		integer i;
		begin
			$display("%t: Set IR", $time);

			// Go to Select-IR-Scan
			tms = 1;
			@(negedge tck);

			// Go to Capture-IR
			tms = 0;
			@(negedge tck);

			// Go to Shift-IR
            tdo_en = 1;
			tms = 0;
			@(negedge tck);

			for(i=0; i<IR_LENGTH; i=i+1) begin
				tdi = wanted_ir[i];

				if (i == IR_LENGTH-1) begin
					tms = 1;			// Go to Exit1-IR
				end
				@(negedge tck);
			end

			// Go to Update-IR
            tdo_en = 0;
			tms = 1;
			@(negedge tck);

			// Go to Select-DR-Scan
			tms = 1;
			@(negedge tck);
		end
	endtask


	initial begin
		tdi = 0;
		tms = 0;
        tdo_en = 0;

		@(posedge trst_);
		@(negedge tck);

		jtag_clocked_reset();

		jtag_reset_to_select_dr_scan();

		//============================================================
		// Default IR should be IDCODE. Shift it out...
		//============================================================

		// CAPTURE_DR
		jtag_apply_tms(0);

		// SHIFT_DR
		jtag_apply_tms(0);

		// Scan out IDCODE
        tdo_en = 1;
		jtag_scan_vector(32'h0, 32, 1);

		// EXIT1_DR -> UPDATE_DR
        tdo_en = 0;
		jtag_apply_tms(1);

		// UPDATE_DR -> SELECT_DR_SCAN
		jtag_apply_tms(1);

		$display("%t: IDCODE scanned out: %x", $time, captured_tdo_vec[31:0]);

		//============================================================
		// Select IR 0xa
		//============================================================
		jtag_set_ir(4'b1111);
		jtag_set_ir(4'ha);

		//============================================================
		// Select BYPASS register
		//============================================================
		jtag_set_ir(4'b1111);

		// CAPTURE_DR
		jtag_apply_tms(0);

		// SHIFT_DR
		jtag_apply_tms(0);

		// Scan vector, but stay in DR_SCAN
		jtag_scan_vector(8'hc1, 8, 0);

		// Scan out last bit out of BYPASS, then go to EXIT1_DR
		jtag_scan_vector(1'h0, 1, 1);

		// EXIT1_DR -> UPDATE_DR
		jtag_apply_tms(1);

		// UPDATE_DR -> SELECT_DR_SCAN
		jtag_apply_tms(1);

	end


	reg [MAX_TDO_VEC-1:0]	captured_tdo_vec;
	initial begin: CAPTURE_TDO
		integer 				bit_cntr;

		forever begin
			while(!tdo_en) begin
				@(posedge tck);
			end
			bit_cntr = 0;
			captured_tdo_vec = {MAX_TDO_VEC{1'bz}};
			while(tdo_en) begin
				captured_tdo_vec[bit_cntr] = tdo;
				bit_cntr = bit_cntr + 1;
				@(posedge tck);
			end
			$display("%t: TDO_CAPTURED: %b", $time, captured_tdo_vec);
			@(posedge tck);
		end
	end



endmodule

