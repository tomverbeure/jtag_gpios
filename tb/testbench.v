
`timescale 1 ns / 1 ps

`include "jtag_tap_defines.v"

module testbench;

    parameter IR_LENGTH     = 4;
    parameter MAX_TDO_VEC   = 64;
 
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

    assign button_ = 1'b0;

    initial begin
        clk     = 0;
        forever begin
            #5 clk  = ~clk;
        end
    end

    initial begin
        tck     = 0;
        forever begin
            #25 tck = ~tck;
        end
    end

    initial begin
        $display("%t: Start of simulation!", $time);
        $dumpfile("waves.vcd");
        $dumpvars(0, testbench);

        trst_   = 0;
        repeat(10) @(posedge tck);
        trst_   = 1;

        repeat(10000) @(posedge tck);
        $display("%t: Simulation complete...", $time);
        $finish;
    end

    task jtag_clocked_reset;
        begin
            $display("%t: JTAG Clocked Reset", $time);
            tms = 1;
            repeat(5) @(negedge tck);
        end
    endtask

    task jtag_apply_tms;
        input tms_in;
        begin
            //$display("Apply TMS %d", tms_in);
            tms = tms_in;
            @(negedge tck);
        end
    endtask

    task jtag_reset_to_run_test_idle;
        begin
            $display("%t: Reset to Run-Test-Idle", $time);

            // Go to RTI
            tms = 0;
            @(negedge tck);
        end
    endtask

    task jtag_scan_vector;

        input [255:0]   vector_in;
        input integer   nr_bits;
        input           exit1;

        integer i;
        begin
            for(i=0; i<nr_bits; i=i+1) begin
                tdi = vector_in[i];

                if (i == nr_bits-1) begin
                    tms = exit1;            // Go to Exit1-*
                end
                @(negedge tck);
            end
        end
    endtask

    task jtag_scan_ir;
        input [IR_LENGTH-1:0] wanted_ir;

        integer i;
        begin
            $display("%t: Set IR 0x%02x", $time, wanted_ir);

            // Go to Select-DR-Scan
            jtag_apply_tms(1);

            // Go to Select-IR-Scan
            jtag_apply_tms(1);

            // Go to Capture-IR
            jtag_apply_tms(0);

            // Go to Shift-IR
            jtag_apply_tms(0);
            tdo_en = 1;

            // Shift vector, then go to EXIT1_IR
            jtag_scan_vector(wanted_ir, IR_LENGTH, 1);

            // Go to Update-IR
            tdo_en = 0;

            jtag_apply_tms(1);

            // Go to Run Test Idle
            jtag_apply_tms(0);
        end
    endtask

    task jtag_scan_dr;
        input [255:0]   vector_in;
        input integer   nr_bits;

        integer i;
        begin
            $display("%t: Set DR to 0x%x", $time, vector_in);

            // Go to Select-DR-Scan
            jtag_apply_tms(1);

            // CAPTURE_DR
            jtag_apply_tms(0);
    
            // SHIFT_DR
            jtag_apply_tms(0);
            tdo_en = 1;
    
            // Shift vector, then go to EXIT1_DR
            jtag_scan_vector(vector_in, nr_bits, 1);
    
            // EXIT1_DR -> UPDATE_DR
            tdo_en = 0;
            jtag_apply_tms(1);
    
            // UPDATE_DR -> RUN_TEST_IDLE
            jtag_apply_tms(0);
        end
    endtask

    initial begin
        tdi = 0;
        tms = 0;
        tdo_en = 0;

        @(posedge trst_);
        @(negedge tck);

        jtag_clocked_reset();

        jtag_reset_to_run_test_idle();

        //============================================================
        // Default IR should be IDCODE. Shift it out...
        //============================================================
        
        // SELECT_DR_SCAN
        jtag_apply_tms(1);
        
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

        // UPDATE_DR -> RUN_TEST_IDLE
        jtag_apply_tms(0);

        $display("%t: IDCODE scanned out: %x", $time, captured_tdo_vec[31:0]);

        //============================================================
        // Select IR 0xa
        //============================================================
        jtag_scan_ir(4'b1111);
        jtag_scan_ir(4'ha);

        //============================================================
        // Select IDCODE register
        //============================================================
        jtag_scan_ir(`IDCODE);
        jtag_scan_dr(32'd0, 32);

        //============================================================
        // GPIOs
        //============================================================
        // All GPIOs output
        jtag_scan_ir(`GPIO_CONFIG);
        jtag_scan_dr(3'b111, 3);

        // Set GPIO output values
        jtag_scan_ir(`GPIO_DATA);
        jtag_scan_dr(3'b111, 3);
        jtag_scan_dr(3'b000, 3);
        jtag_scan_dr(3'd0, 3);
        jtag_scan_dr(3'd1, 3);
        jtag_scan_dr(3'd2, 3);
        jtag_scan_dr(3'd3, 3);
        jtag_scan_dr(3'd4, 3);
        jtag_scan_dr(3'd5, 3);
        jtag_scan_dr(3'd6, 3);
        jtag_scan_dr(3'd7, 3);

    end


    reg [MAX_TDO_VEC-1:0]   captured_tdo_vec;
    initial begin: CAPTURE_TDO
        integer                 bit_cntr;

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

