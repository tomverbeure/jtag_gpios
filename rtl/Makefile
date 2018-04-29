
VERILOG_COMMON = top.v jtag_gpios.v 
VERILOG_GENERIC = $(VERILOG_COMMON) jtag_tap_generic.v
VERILOG_ALTERA = $(VERILOG_COMMON) jtag_tap_altera.v

all: sim_generic sim_altera

sim_generic: $(VERILOG_GENERIC)
	iverilog -D JTAG_TAP_GENERIC $(VERILOG_GENERIC) -o $@

sim_altera: $(VERILOG_ALTERA)
	iverilog -D JTAG_TAP_ALTERA $(VERILOG_ALTERA) blackbox/sld_virtual_jtag.v -o $@

clean:
	rm -f sim_generic sim_altera
