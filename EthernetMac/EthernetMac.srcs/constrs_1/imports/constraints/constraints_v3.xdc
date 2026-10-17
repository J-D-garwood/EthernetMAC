## Bank-0 / configuration voltage ----------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
## Boot from the on-board QSPI flash in x4 mode at 50 MHz -----------------
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

create_clock -period 5.000 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]
set_property PACKAGE_PIN R4 [get_ports sys_clk_p]
set_property PACKAGE_PIN T4 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n]

set_property PACKAGE_PIN N13 [get_ports MDC]
set_property IOSTANDARD LVCMOS33 [get_ports MDC]
set_property PACKAGE_PIN P14 [get_ports MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports MDIO]
set_property PACKAGE_PIN R14 [get_ports PHY_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports PHY_rst_n]
set_property PACKAGE_PIN F15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## RGMII receive ----------------------------------------------------------
set_property PACKAGE_PIN V18 [get_ports RXC]
set_property PACKAGE_PIN R19 [get_ports RX_CTL]
set_property PACKAGE_PIN P19 [get_ports {RXD[0]}]
set_property PACKAGE_PIN U18 [get_ports {RXD[1]}]
set_property PACKAGE_PIN U17 [get_ports {RXD[2]}]
set_property PACKAGE_PIN P17 [get_ports {RXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RXC RX_CTL {RXD[*]}}]

set_property PACKAGE_PIN P15 [get_ports TXC]
set_property PACKAGE_PIN N17 [get_ports TX_CTL]
set_property PACKAGE_PIN N14 [get_ports {TXD[0]}]
set_property PACKAGE_PIN P16 [get_ports {TXD[1]}]
set_property PACKAGE_PIN R17 [get_ports {TXD[2]}]
set_property PACKAGE_PIN R16 [get_ports {TXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {TXC TX_CTL {TXD[*]}}]

create_clock -period 40.000 -name rxc [get_ports RXC]

set_clock_groups -asynchronous -group [get_clocks rxc] -group [get_clocks -include_generated_clocks sys_clk_p]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_wiz/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {mdio/mdio_top/mdio/received[0]} {mdio/mdio_top/mdio/received[1]} {mdio/mdio_top/mdio/received[2]} {mdio/mdio_top/mdio/received[3]} {mdio/mdio_top/mdio/received[4]} {mdio/mdio_top/mdio/received[5]} {mdio/mdio_top/mdio/received[6]} {mdio/mdio_top/mdio/received[7]} {mdio/mdio_top/mdio/received[8]} {mdio/mdio_top/mdio/received[9]} {mdio/mdio_top/mdio/received[10]} {mdio/mdio_top/mdio/received[11]} {mdio/mdio_top/mdio/received[12]} {mdio/mdio_top/mdio/received[13]} {mdio/mdio_top/mdio/received[14]} {mdio/mdio_top/mdio/received[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 6 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {mdio/mdio_top/mdio/state[0]} {mdio/mdio_top/mdio/state[1]} {mdio/mdio_top/mdio/state[2]} {mdio/mdio_top/mdio/state[3]} {mdio/mdio_top/mdio/state[4]} {mdio/mdio_top/mdio/state[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 9 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {mac/data[0]} {mac/data[1]} {mac/data[2]} {mac/data[3]} {mac/data[4]} {mac/data[5]} {mac/data[6]} {mac/data[7]} {mac/data[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 7 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {mac/parse/state[0]} {mac/parse/state[1]} {mac/parse/state[2]} {mac/parse/state[3]} {mac/parse/state[4]} {mac/parse/state[5]} {mac/parse/state[6]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 48 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {mac/source[0]} {mac/source[1]} {mac/source[2]} {mac/source[3]} {mac/source[4]} {mac/source[5]} {mac/source[6]} {mac/source[7]} {mac/source[8]} {mac/source[9]} {mac/source[10]} {mac/source[11]} {mac/source[12]} {mac/source[13]} {mac/source[14]} {mac/source[15]} {mac/source[16]} {mac/source[17]} {mac/source[18]} {mac/source[19]} {mac/source[20]} {mac/source[21]} {mac/source[22]} {mac/source[23]} {mac/source[24]} {mac/source[25]} {mac/source[26]} {mac/source[27]} {mac/source[28]} {mac/source[29]} {mac/source[30]} {mac/source[31]} {mac/source[32]} {mac/source[33]} {mac/source[34]} {mac/source[35]} {mac/source[36]} {mac/source[37]} {mac/source[38]} {mac/source[39]} {mac/source[40]} {mac/source[41]} {mac/source[42]} {mac/source[43]} {mac/source[44]} {mac/source[45]} {mac/source[46]} {mac/source[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {mac/ethernet_length[0]} {mac/ethernet_length[1]} {mac/ethernet_length[2]} {mac/ethernet_length[3]} {mac/ethernet_length[4]} {mac/ethernet_length[5]} {mac/ethernet_length[6]} {mac/ethernet_length[7]} {mac/ethernet_length[8]} {mac/ethernet_length[9]} {mac/ethernet_length[10]} {mac/ethernet_length[11]} {mac/ethernet_length[12]} {mac/ethernet_length[13]} {mac/ethernet_length[14]} {mac/ethernet_length[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 48 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {mac/destination[0]} {mac/destination[1]} {mac/destination[2]} {mac/destination[3]} {mac/destination[4]} {mac/destination[5]} {mac/destination[6]} {mac/destination[7]} {mac/destination[8]} {mac/destination[9]} {mac/destination[10]} {mac/destination[11]} {mac/destination[12]} {mac/destination[13]} {mac/destination[14]} {mac/destination[15]} {mac/destination[16]} {mac/destination[17]} {mac/destination[18]} {mac/destination[19]} {mac/destination[20]} {mac/destination[21]} {mac/destination[22]} {mac/destination[23]} {mac/destination[24]} {mac/destination[25]} {mac/destination[26]} {mac/destination[27]} {mac/destination[28]} {mac/destination[29]} {mac/destination[30]} {mac/destination[31]} {mac/destination[32]} {mac/destination[33]} {mac/destination[34]} {mac/destination[35]} {mac/destination[36]} {mac/destination[37]} {mac/destination[38]} {mac/destination[39]} {mac/destination[40]} {mac/destination[41]} {mac/destination[42]} {mac/destination[43]} {mac/destination[44]} {mac/destination[45]} {mac/destination[46]} {mac/destination[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list mac/bad_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list mdio/mdio_top/mdio/done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list mac/good_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list mac/header_ready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list mac/valid]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
