## AX7A035B basic constraints for top.v
## Pins, I/O standards, config and primary clocks only.

## Bank-0 / configuration voltage ----------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## Boot from the on-board QSPI flash in x4 mode at 50 MHz -----------------
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

## 200 MHz system clock (Bank 34, 1.5 V) ----------------------------------
## The clock wizard's own XDC creates the clock on sys_clk_p.
set_property PACKAGE_PIN R4 [get_ports sys_clk_p]
set_property PACKAGE_PIN T4 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n]

## Reset key (active low) -------------------------------------------------
set_property PACKAGE_PIN F15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## PHY management and reset -----------------------------------------------
set_property PACKAGE_PIN N13 [get_ports MDC]
set_property PACKAGE_PIN P14 [get_ports MDIO]
set_property PACKAGE_PIN R14 [get_ports PHY_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports MDC]
set_property IOSTANDARD LVCMOS33 [get_ports MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports PHY_rst_n]

## RGMII receive ----------------------------------------------------------
set_property PACKAGE_PIN V18 [get_ports RXC]
set_property PACKAGE_PIN R19 [get_ports RX_CTL]
set_property PACKAGE_PIN P19 [get_ports {RXD[0]}]
set_property PACKAGE_PIN U18 [get_ports {RXD[1]}]
set_property PACKAGE_PIN U17 [get_ports {RXD[2]}]
set_property PACKAGE_PIN P17 [get_ports {RXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RXC RX_CTL {RXD[*]}}]

## RXC is an external clock, so it needs its own create_clock (125 MHz).
create_clock -period 8.000 -name rxc [get_ports RXC]

## RGMII transmit ---------------------------------------------------------
set_property PACKAGE_PIN P15 [get_ports TXC]
set_property PACKAGE_PIN N17 [get_ports TX_CTL]
set_property PACKAGE_PIN N14 [get_ports {TXD[0]}]
set_property PACKAGE_PIN P16 [get_ports {TXD[1]}]
set_property PACKAGE_PIN R17 [get_ports {TXD[2]}]
set_property PACKAGE_PIN R16 [get_ports {TXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {TXC TX_CTL {TXD[*]}}]
set_property SLEW FAST [get_ports {TXC TX_CTL {TXD[*]}}]

## =========================================================================
## TIMING
## Assumes the PHY adds the 2 ns clock delay on both TX and RX (TXDLY = 1,
## RXDLY = 1), as in AX7A035B manual Table 3-2-1.
## =========================================================================

## RGMII receive timing ----------------------------------------------------
## JL2121 section 4.7.4: data is valid 1.0 ns before and after each RXC edge.
## Each DDR bit lasts 4 ns, so max = 4.0 - 1.0 and min = 1.0.
set_input_delay -clock rxc -max 3.000 [get_ports {{RXD[*]} RX_CTL}]
set_input_delay -clock rxc -min 1.000 [get_ports {{RXD[*]} RX_CTL}]
set_input_delay -clock rxc -clock_fall -max -add_delay 3.000 [get_ports {{RXD[*]} RX_CTL}]
set_input_delay -clock rxc -clock_fall -min -add_delay 1.000 [get_ports {{RXD[*]} RX_CTL}]

## Transmit clocks ----------------------------------------------------------
## div_reg toggles every 5 cycles of 25 MHz, which gives 2.5 MHz.
create_generated_clock -name clk_2p5 -source [get_pins mac/div_by_10/div_reg/C] -divide_by 10 [get_pins mac/div_by_10/div_reg/Q]

## Only one speed passes through the mux at a time. Each speed gets its own
## clock on the mux output so Vivado can treat them as mutually exclusive.
create_generated_clock -name txc_125 -source [get_pins mac/BUFGMUX_inst_b/I1] -divide_by 1 [get_pins mac/BUFGMUX_inst_b/O]
create_generated_clock -name txc_25 -source [get_pins mac/BUFGMUX_inst_b/I0] -divide_by 1 -add -master_clock clk_out2_clk_wiz_0 [get_pins mac/BUFGMUX_inst_b/O]
create_generated_clock -name txc_2p5 -source [get_pins mac/BUFGMUX_inst_b/I0] -divide_by 1 -add -master_clock clk_2p5 [get_pins mac/BUFGMUX_inst_b/O]

## RGMII transmit timing ----------------------------------------------------
## TXC is forwarded through mac/ODDR_TXC. Only the 125 MHz case is checked.
create_generated_clock -name txc_fwd -source [get_pins mac/ODDR_TXC/C] -divide_by 1 -add -master_clock txc_125 [get_ports TXC]

## JL2121 section 4.7.3: data must be within +/-0.5 ns of each TXC edge.
## Each DDR bit lasts 4 ns, so max = 4.0 - 0.5 and min = 0.5.
set_output_delay -clock txc_fwd -max 3.500 [get_ports {{TXD[*]} TX_CTL}]
set_output_delay -clock txc_fwd -min 0.500 [get_ports {{TXD[*]} TX_CTL}]
set_output_delay -clock txc_fwd -clock_fall -max -add_delay 3.500 [get_ports {{TXD[*]} TX_CTL}]
set_output_delay -clock txc_fwd -clock_fall -min -add_delay 0.500 [get_ports {{TXD[*]} TX_CTL}]

## Clock relationships ------------------------------------------------------
## The speed clocks never exist on the mux output together.
set_clock_groups -physically_exclusive -group [get_clocks {txc_125 txc_fwd}] -group [get_clocks txc_25] -group [get_clocks txc_2p5]

## These domains only meet through synchronisers and the async FIFO.
set_clock_groups -asynchronous -group [get_clocks rxc] -group [get_clocks {clk_out1_clk_wiz_0 clk_out2_clk_wiz_0 clk_2p5}] -group [get_clocks {txc_125 txc_25 txc_2p5 txc_fwd}]

## Clock groups remove normal checks, so limit the Gray pointer skew directly:
## all bits must arrive within one 8 ns period.
set_bus_skew -from [get_cells {mac/rx/fifo/W_handler/g_wptr_reg[*]}] -to [get_cells {mac/rx/fifo/sync_R/Ds_reg[*]}] 8.000
set_bus_skew -from [get_cells {mac/rx/fifo/R_handler/g_rptr_reg[*]}] -to [get_cells {mac/rx/fifo/sync_W/Ds_reg[*]}] 8.000

## Slow ports ---------------------------------------------------------------
## rst_n is a button and MDIO input goes through a synchroniser.
set_false_path -from [get_ports {rst_n MDIO}]

## MDC/MDIO change far slower than the PHY needs. PHY_rst_n only changes
## during reset.
set_false_path -to [get_ports {MDC MDIO PHY_rst_n}]



create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_wiz/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 7 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {mac/parse/state[0]} {mac/parse/state[1]} {mac/parse/state[2]} {mac/parse/state[3]} {mac/parse/state[4]} {mac/parse/state[5]} {mac/parse/state[6]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {mac/payload_byte[0]} {mac/payload_byte[1]} {mac/payload_byte[2]} {mac/payload_byte[3]} {mac/payload_byte[4]} {mac/payload_byte[5]} {mac/payload_byte[6]} {mac/payload_byte[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 48 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {mac/source[0]} {mac/source[1]} {mac/source[2]} {mac/source[3]} {mac/source[4]} {mac/source[5]} {mac/source[6]} {mac/source[7]} {mac/source[8]} {mac/source[9]} {mac/source[10]} {mac/source[11]} {mac/source[12]} {mac/source[13]} {mac/source[14]} {mac/source[15]} {mac/source[16]} {mac/source[17]} {mac/source[18]} {mac/source[19]} {mac/source[20]} {mac/source[21]} {mac/source[22]} {mac/source[23]} {mac/source[24]} {mac/source[25]} {mac/source[26]} {mac/source[27]} {mac/source[28]} {mac/source[29]} {mac/source[30]} {mac/source[31]} {mac/source[32]} {mac/source[33]} {mac/source[34]} {mac/source[35]} {mac/source[36]} {mac/source[37]} {mac/source[38]} {mac/source[39]} {mac/source[40]} {mac/source[41]} {mac/source[42]} {mac/source[43]} {mac/source[44]} {mac/source[45]} {mac/source[46]} {mac/source[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 9 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {mac/data[0]} {mac/data[1]} {mac/data[2]} {mac/data[3]} {mac/data[4]} {mac/data[5]} {mac/data[6]} {mac/data[7]} {mac/data[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {mac/ethernet_length[0]} {mac/ethernet_length[1]} {mac/ethernet_length[2]} {mac/ethernet_length[3]} {mac/ethernet_length[4]} {mac/ethernet_length[5]} {mac/ethernet_length[6]} {mac/ethernet_length[7]} {mac/ethernet_length[8]} {mac/ethernet_length[9]} {mac/ethernet_length[10]} {mac/ethernet_length[11]} {mac/ethernet_length[12]} {mac/ethernet_length[13]} {mac/ethernet_length[14]} {mac/ethernet_length[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list mac/bad_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list mdio/mdio_top/mdio/done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list mac/rx/empty]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list mac/good_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list mac/header_ready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list mac/new_byte]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list mac/receiving_payload]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list mac/valid_rx]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list mac/tx_clk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 8 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {mac/tx/state[0]} {mac/tx/state[1]} {mac/tx/state[2]} {mac/tx/state[3]} {mac/tx/state[4]} {mac/tx/state[5]} {mac/tx/state[6]} {mac/tx/state[7]}]]
create_debug_core u_ila_2 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_2]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_2]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_2]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_2]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_2]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_2]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_2]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_2]
set_property port_width 1 [get_debug_ports u_ila_2/clk]
connect_debug_port u_ila_2/clk [get_nets [list mac/rx/rx/RXC_b]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe0]
set_property port_width 1 [get_debug_ports u_ila_2/probe0]
connect_debug_port u_ila_2/probe0 [get_nets [list mac/rx/rx/DV]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe1]
set_property port_width 1 [get_debug_ports u_ila_2/probe1]
connect_debug_port u_ila_2/probe1 [get_nets [list mac/rx/RXC_rst_n]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe2]
set_property port_width 1 [get_debug_ports u_ila_2/probe2]
connect_debug_port u_ila_2/probe2 [get_nets [list mac/rx/rx/valid_byte]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe3]
set_property port_width 1 [get_debug_ports u_ila_2/probe3]
connect_debug_port u_ila_2/probe3 [get_nets [list mac/rx/valid_byte_q]]
create_debug_core u_ila_3 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_3]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_3]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_3]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_3]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_3]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_3]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_3]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_3]
set_property port_width 1 [get_debug_ports u_ila_3/clk]
connect_debug_port u_ila_3/clk [get_nets [list clk_wiz/inst/clk_out3]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe0]
set_property port_width 1 [get_debug_ports u_ila_3/probe0]
connect_debug_port u_ila_3/probe0 [get_nets [list RDY]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
