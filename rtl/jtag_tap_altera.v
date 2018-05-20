`define ALTERA_VJTAG

`default_nettype none

module jtag_tap_altera
    #( 
        parameter IR_BITS    = 4
    ) 
    (
        output wire                 tck,
        output wire                 tdi,
        input  wire                 tdo,

        output wire [IR_BITS-1:0]   ir,

        output wire                 capture_dr,
        output wire                 shift_dr,
        output wire                 update_dr
    );

    sld_virtual_jtag u_vjtag (
        .tck                (tck),
        .tdi                (tdi),
        .tdo                (tdo),

        .ir_out             (),
        .ir_in              (ir),

        .virtual_state_cdr  (capture_dr),
        .virtual_state_cir  ( ),
        .virtual_state_e1dr ( ),
        .virtual_state_e2dr ( ),
        .virtual_state_pdr  ( ),
        .virtual_state_sdr  (shift_dr),
        .virtual_state_udr  (update_dr),
        .virtual_state_uir  ( )
        );

    defparam
        u_vjtag.sld_auto_instance_index = "YES",
        u_vjtag.sld_instance_index = 0,
        u_vjtag.sld_ir_width = IR_BITS;

endmodule
