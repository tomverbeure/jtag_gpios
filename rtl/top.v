
module top(
    input   wire        clk,

`ifdef JTAG_TAP_GENERIC
    input   wire        tck,
    input   wire        tms,
    input   wire        tdi,
    output  wire        tdo,
`endif

    output  wire        led0,
    output  wire        led1,
    output  wire        led2,

    input   wire        button_
);

    localparam NR_GPIOS = 3;

    wire [NR_GPIOS-1:0] gpio_inputs, gpio_outputs, gpio_outputs_ena;

    jtag_top #( .NR_GPIOS(NR_GPIOS) ) u_jtag_top
    (
        .reset_(reset_),

`ifdef JTAG_TAP_GENERIC
        .trst_(1'b1),
        .tck(tck),
        .tms(tms),
        .tdi(tdi),
        .tdo(tdo),
`endif

        .gpio_inputs(gpio_inputs),
        .gpio_outputs(gpio_outputs),
        .gpio_outputs_ena(gpio_outputs_ena)
    );


    reg reset_;
    always @(posedge clk) begin
        reset_ <= 1'b1;
    end

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
