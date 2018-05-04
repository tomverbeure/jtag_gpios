
# Link to my own compiled version
OCD_PREFIX=~/projects/openocd_tvb/

sudo $OCD_PREFIX/src/openocd --search $OCD_PREFIX/tcl -f jtag_gpio.cfg

