
module jtag_gpios
    #(
        parameter NR_GPIOS = 1
    )
    (
        // Non-jtag reset
        input               reset_,

        // In the case come either straight from the IO pins or from the
        // virtual jtag TAP.
        input   wire        tck,
        input   wire        tdi,

        // Output of the GPIO status registers.
        // The real or the virtual JTAG TAP will select this when the GPIO
        // scan chain is selected by the TAP.
        output              gpios_tdo,

        // TAP states
        input               capture_dr,
        input               shift_dr,
        input               update_dr,

        // Current active instruction
        input               gpio_data_ir,
        input               gpio_config_ir,

        input      [NR_GPIOS-1:0]   gpio_inputs,
        output reg [NR_GPIOS-1:0]   gpio_outputs,
        output reg [NR_GPIOS-1:0]   gpio_outputs_ena       
    );

    // There is only 1 shift register because we use capture_dr for both
    // IRs. So since the shift register updated before the scan operation
    // anyway, the previous value of the shift register doesn't matter.
    reg [NR_GPIOS-1:0]  gpio_dr;

    always @(posedge tck) 
    begin
        if (gpio_data_ir) begin
            case(1'b1) // synthesis parallel_case full_case
                capture_dr: begin
                    gpio_dr         <= gpio_inputs;
                end
                shift_dr: begin
                    gpio_dr         <= { tdi, gpio_dr[NR_GPIOS-1:1] };
                end
                update_dr: begin
                    gpio_outputs    <= gpio_dr;
                end
            endcase
        end

        if (gpio_config_ir) begin
            case(1'b1) // synthesis parallel_case full_case
                capture_dr: begin
                    gpio_dr         <= gpio_outputs_ena;
                end
                shift_dr: begin
                    gpio_dr         <= { tdi, gpio_dr[NR_GPIOS-1:1] };
                end
                update_dr: begin
                    gpio_outputs_ena<= gpio_dr;
                end
            endcase
        end

        if (!reset_) begin
            gpio_outputs_ena <= {NR_GPIOS{1'b0}};
        end
    end

    assign gpios_tdo = gpio_dr[0];

endmodule
