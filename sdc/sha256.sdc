# ####################################################################

set sdc_version 2.0

# Set the current design
current_design sha256

create_clock -name "clk" -period 600 [get_ports clk]

set_input_delay -clock clk 1  [all_inputs]

set_output_delay -clock clk 300  [all_outputs]


