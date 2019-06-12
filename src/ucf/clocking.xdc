create_clock -period 24.950 -name clock_p -waveform {0.000 12.475} [get_ports clock_p]
create_clock -period 12.500 -name control/led_control_inst/startup/startup_gen_a7.startupe2_inst/CFGMCLK -waveform {0.000 6.250} [get_pins control/led_control_inst/startup/startup_gen_a7.startupe2_inst/CFGMCLK]
create_clock -period 6.237 -name {mgt_clk_p_i[0]} -waveform {0.000 3.119} [get_ports {mgt_clk_p_i[0]}]


set_input_delay -clock [get_clocks clock_p] 12.500 [get_ports {gbt_rxready_i[*]}]
set_input_delay -clock [get_clocks clock_p] 12.500 [get_ports {gbt_rxvalid_i[*]}]
set_input_delay -clock [get_clocks clock_p] 12.500 [get_ports {gbt_txready_i[*]}]

set_input_delay -clock [get_clocks clock_p] 1.625 [get_ports {vfat_sbits_*[*]}]
set_input_delay -clock [get_clocks clock_p] 1.625 [get_ports {vfat_sot_*[*]}]
set_input_delay -clock [get_clocks clock_p] 1.625 [get_ports elink_i_*]

set_output_delay -clock [get_clocks clock_p] -min -add_delay 0.000 [get_ports {led_o[0]}]
set_output_delay -clock [get_clocks clock_p] -max -add_delay 2.000 [get_ports {led_o[0]}]

set_output_delay -clock [get_clocks clock_p] 1.625 [get_ports elink_o_p]

# The active clock pin of the launching sequential cell is called the path startpoint.
# The data input pin of the capturing sequential cell is called the path endpoint.
# For an input port path, the data path starts at the input port. The input port is the path startpoint.
# For an output port path, the data path ends at the output port. The output port is the path endpoint.

set_max_delay -from [get_pins -hierarchical -filter { NAME =~  "*iserdes_a7.iserdes/CLK" }] -to [get_pins -hierarchical -filter { NAME =~  "*dru/data_in_delay_reg*/D" }] 1.500
set_false_path -from [get_pins -hierarchical -filter { NAME =~  "*iserdes_a7.iserdes/CLK" }] -to [get_pins -hierarchical -filter { NAME =~  "*dru/data_in_delay_reg*/D" }]

# Want to ignore timing from the IOpad to the input delay (since there is a delay element and the clock phase is unknown, it makes no sense to constrain the timing)

set_false_path -from [get_ports {vfat_sot_*[*]}] -to [get_pins -hierarchical -filter { NAME =~  "*trig_alignment/*oversample*/*ise1*/DDLY" }]
set_false_path -from [get_ports {vfat_sbits_*[*]}] -to [get_pins -hierarchical -filter { NAME =~  "*trig_alignment/*oversample*/*ise1*/DDLY" }]
set_false_path -from [get_ports elink_i_*] -to [get_pins -hierarchical -filter { NAME =~  "*/*ise1*/DDLY" }]

#set_false_path -from [get_clocks {control/led_control/fader_cnt_reg[0]_0}] -to [get_clocks -of_objects [get_pins clocking/logic_clocking/inst/plle2_adv_inst/CLKOUT0]]

set_max_delay -datapath_only -from [get_clocks control/led_control_inst/startup/startup_gen_a7.startupe2_inst/CFGMCLK] -to [get_clocks clock_p] 12.000

set_max_delay -datapath_only -from [get_pins {trigger/sbits/*cluster_packer*/*clusterloop*.*cluster_reg*/C}] -to [get_pins {trigger/sbits/*cluster_packer*/*cluster_synced*/D}] 5.0
set_max_delay -datapath_only -from [get_pins {trigger/sbits/*cluster_packer_inst*/clusterloop*.cluster_latch_out_extend_reg/C}] -to [get_pins {trigger/sbits/*cluster_packer_inst*/clusterloop*.cluster_synced_reg*/CE}] 5.0

# set switching activity
set_switching_activity -static_probability  0.005 -toggle_rate 0.005 [get_ports {vfat_sbits_p*}]
set_switching_activity -static_probability   12.5 -toggle_rate 0.125 [get_ports {vfat_sot_p*}]

set_switching_activity -static_probability   100  -toggle_rate 0.000 [get_ports {gbt_*ready*}]
set_switching_activity -static_probability   100  -toggle_rate 0.000 [get_ports {gbt_*valid*}]

set_switching_activity -static_probability   50   -toggle_rate 0.500 [get_ports {elink_*_p}]

set_switching_activity -static_probability   75   -toggle_rate 0.0001 [get_ports {led_o*}]

set_switching_activity -static_probability   100  -toggle_rate 0.0    [get_ports {vtrx_mabs*}]
