
RTL_DIR=../rtl/

VERILOG_COMMON = $(RTL_DIR)/top.v $(RTL_DIR)/jtag_top.v $(RTL_DIR)/jtag_gpios.v 
VERILOG_GENERIC = $(VERILOG_COMMON) $(RTL_DIR)/jtag_tap_generic.v
VERILOG_ALTERA = $(VERILOG_COMMON) $(RTL_DIR)/jtag_tap_altera.v

VERILOG_TB = testbench.v

all: sim_generic 
	./sim_generic

sim_generic: $(VERILOG_TB) $(VERILOG_GENERIC) 
	iverilog -D JTAG_TAP_GENERIC -I $(RTL_DIR) $(VERILOG_TB) $(VERILOG_GENERIC) -o $@

sim_altera: $(VERILOG_TB) $(VERILOG_ALTERA)
	iverilog -D JTAG_TAP_ALTERA $(VERILOG_TB) $(VERILOG_ALTERA) blackbox/sld_virtual_jtag.v -o $@

wave:
	gtkwave waves.gtkw &

clean:
	rm -f sim_generic sim_altera *.vcd
