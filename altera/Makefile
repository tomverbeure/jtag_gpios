

synth_altera:
	cp jtag_tap_altera.tcl jtag_tap.tcl
	$(QUARTUS_ROOTDIR)/bin/quartus_map --read_settings_files=on --write_settings_files=off jtag_gpios -c top
	$(QUARTUS_ROOTDIR)/bin/quartus_fit --read_settings_files=off --write_settings_files=off jtag_gpios -c top
	$(QUARTUS_ROOTDIR)/bin/quartus_asm --read_settings_files=off --write_settings_files=off jtag_gpios -c top

synth_generic:
	cp jtag_tap_generic.tcl jtag_tap.tcl
	$(QUARTUS_ROOTDIR)/bin/quartus_map --read_settings_files=on --write_settings_files=off jtag_gpios -c top
	$(QUARTUS_ROOTDIR)/bin/quartus_fit --read_settings_files=off --write_settings_files=off jtag_gpios -c top
	$(QUARTUS_ROOTDIR)/bin/quartus_asm --read_settings_files=off --write_settings_files=off jtag_gpios -c top

check:
	$(QUARTUS_ROOTDIR)/bin/quartus_pgm -c "USB-Blaster [1-1]" -a

pgm:
	$(QUARTUS_ROOTDIR)/bin/quartus_pgm -c "USB-Blaster [1-1]" jtag_gpios.cdf

