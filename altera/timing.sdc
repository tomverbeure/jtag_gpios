create_clock -name "tck" -period "10MHz" [get_ports tck]
create_clock -name "clk" -period "50MHz" [get_ports clk]

set_input_delay  -clock "clk" 5.0 [get_ports button_]
set_output_delay -clock "clk" 5.0 [get_ports {led*}]



