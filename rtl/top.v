
`define ALTERA_VJTAG
//`define JTAG

module top(
	input	wire		clk,

	output	wire		led0,
	output	wire		led1,
	output	wire		led2,

	input	wire		button_
);


`ifdef ALTERA_VJTAG
	wire		tck;
	wire		tdi;
	wire		tdo;

    wire [3:0]  ir;

    wire        capture_dr, shift_dr, update_dr;

	sld_virtual_jtag u_vjtag (
		.tck				(tck),
		.tdi				(tdi),
		.tdo				(tdo),

		.ir_out				(),
		.ir_in				(ir),

		.virtual_state_cdr	(capture_dr),
		.virtual_state_cir  ( ),
		.virtual_state_e1dr	( ),
		.virtual_state_e2dr	( ),
		.virtual_state_pdr	( ),
		.virtual_state_sdr	(shift_dr),
		.virtual_state_udr	(update_dr),
		.virtual_state_uir	( )
		);

    defparam
        u_vjtag.sld_auto_instance_index = "YES",
        u_vjtag.sld_instance_index = 0,
        u_vjtag.sld_ir_width = 4;
`endif

    localparam  GPIO_DATA_IR   = 4'b0010;
    localparam  GPIO_CONFIG_IR = 4'b0011;

    wire gpio_data_ir, gpio_config_ir;
    assign gpio_data_ir   = (ir == GPIO_DATA_IR);
    assign gpio_config_ir = (ir == GPIO_CONFIG_IR);

    reg reset_;
    always @(posedge clk) begin
        reset_ <= 1'b1;
    end

    localparam NR_GPIOS = 3;
     
    wire [NR_GPIOS-1:0] gpio_inputs, gpio_outputs, gpio_outputs_ena;
    wire gpios_tdo;

    assign tdo = gpios_tdo;

	jtag_gpios #(
        .NR_GPIOS(NR_GPIOS)
    )
    u_jtag_gpios (
        .reset_             (reset_),
		.tck				(tck),
		.tdi				(tdi),
		.gpios_tdo			(gpios_tdo),

		.capture_dr	        (update_dr),
		.shift_dr	        (shift_dr),
		.update_dr	        (update_dr),

        .gpio_data_ir       (gpio_data_ir),
        .gpio_config_ir     (gpio_config_ir),

        .gpio_inputs        (gpio_inputs),
        .gpio_outputs       (gpio_outputs),
        .gpio_outputs_ena   (gpio_outputs_ena)
	);

    assign led0 = gpio_outputs_ena[0] ? gpio_outputs[0] : 1'bz;
    assign led1 = gpio_outputs_ena[1] ? gpio_outputs[1] : 1'bz;

    assign gpio_inputs[0] = led0;
    assign gpio_inputs[1] = led1;
    assign gpio_inputs[2] = button_;

	reg [31:0] counter;

	always @(posedge clk)
	begin
		if (!button_) begin
			counter <= 0;
		end
		else begin
			counter <= counter + 1'b1;
		end
	end
	
	assign led2 = ~counter[24];

endmodule
