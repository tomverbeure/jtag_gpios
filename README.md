
# JTAG GPIOS

This repo contains a simple functionality, GPIOs controlled by JTAG, and uses that to
illustrate how we can use different techniques to control these GPIOs through various methods and for
various platforms.

For more info, check out my blog post that goes along with this: 
[JTAG for FPGAs - Part 1: JTAG_GPIO](https://tomverbeure.github.io/jtag/2018/05/04/JTAG-for-FPGAs-1-JTAG-GPIO.html)

## Contents

* `./rtl`

    Design example with JTAG GPIOs that uses either an instantiated generic JTAG TAP or ties in to
    an Intel/Altera virtual JTAG.

* `./tb`

    Simulation testbench

* `./altera`

    Quartus build files for an EP2C5T144 FPGA board.

* `,.ice40`

    ICE40 build files for a BlackIce-II FPGA board

* `./openocd/basic`

    Example on how to control the generic JTAG TAP with OpenOCD and TCL commands.

* `./openocd/target`

    Example on how to control the generic JTAG TAP with OpenOCD and a Python script
 


## License

All code is released under an [Unlicense license](https://unlicense.org/), except the code that was not
written by me:

* `rtl/jtag_tap_generic.v` and `rtl/jtag_tap_defines.v` are released un LGPL (see top of file.)
* `rtl/blackbox/sld_virtual_jtag.v` is released under some Altera licence.
