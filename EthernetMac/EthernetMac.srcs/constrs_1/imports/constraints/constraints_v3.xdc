## Bank-0 / configuration voltage ----------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
## Boot from the on-board QSPI flash in x4 mode at 50 MHz -----------------
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

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

## TIMING ASSUMPTIONS ------------------------------------------------------
## Both RGMII directions assume the PHY adds the 2 ns delay (TXDLY = 1 and
## RXDLY = 1), as listed in AX7A035B manual Table 3-2-1. Confirm this against
## the schematic. If either strap differs, the matching section must change.
## sys_clk_p is defined by the clock wizard's own XDC, so it is not repeated.

## RGMII receive timing ----------------------------------------------------
## RXC runs at 125, 25 or 2.5 MHz. Constrain the fastest case: 8 ns.
create_clock -period 8.000 -name rxc [get_ports RXC]

## JL2121 section 4.7.4: data is valid 1.0 ns before and after each RXC edge at
## the FPGA. Each DDR bit lasts 4 ns, so max = 4.0 - 1.0 and min = 1.0.
set_input_delay -clock rxc -max 3.000 [get_ports {{RXD[*]} RX_CTL}]
set_input_delay -clock rxc -min 1.000 [get_ports {{RXD[*]} RX_CTL}]
set_input_delay -clock rxc -clock_fall -max 3.000 -add_delay [get_ports {{RXD[*]} RX_CTL}]
set_input_delay -clock rxc -clock_fall -min 1.000 -add_delay [get_ports {{RXD[*]} RX_CTL}]

## Transmit clocks ----------------------------------------------------------
## div_reg toggles every 5 cycles of 25 MHz, which gives 2.5 MHz.
create_generated_clock -name clk_2p5 -source [get_pins mac/div_by_10/div_reg/C] -divide_by 10 [get_pins mac/div_by_10/div_reg/Q]

## Only one speed can pass through the mux at a time. Giving each speed its own
## clock after the mux lets Vivado treat them as mutually exclusive there, while
## clk_out1 stays a normal clock for the rest of the design.
create_generated_clock -name txc_125 -divide_by 1 -source [get_pins mac/BUFGMUX_inst_b/I1] [get_pins mac/BUFGMUX_inst_b/O]
create_generated_clock -name txc_25 -divide_by 1 -add -master_clock clk_out2_clk_wiz_0 -source [get_pins mac/BUFGMUX_inst_b/I0] [get_pins mac/BUFGMUX_inst_b/O]
create_generated_clock -name txc_2p5 -divide_by 1 -add -master_clock clk_2p5 -source [get_pins mac/BUFGMUX_inst_b/I0] [get_pins mac/BUFGMUX_inst_b/O]

## RGMII transmit timing ----------------------------------------------------
## TXC is forwarded through mac/ODDR_TXC. Only the 125 MHz case is checked:
## the skew limit and I/O path are the same at every speed.
create_generated_clock -name txc_fwd -master_clock txc_125 -divide_by 1 -source [get_pins mac/ODDR_TXC/C] [get_ports TXC]

## JL2121 section 4.7.3: data must be within +/-0.5 ns of each TXC edge at the
## FPGA. Each DDR bit lasts 4 ns, so max = 4.0 - 0.5 and min = 0.5.
set_output_delay -clock txc_fwd -max 3.500 [get_ports {{TXD[*]} TX_CTL}]
set_output_delay -clock txc_fwd -min 0.500 [get_ports {{TXD[*]} TX_CTL}]
set_output_delay -clock txc_fwd -clock_fall -max 3.500 -add_delay [get_ports {{TXD[*]} TX_CTL}]
set_output_delay -clock txc_fwd -clock_fall -min 0.500 -add_delay [get_ports {{TXD[*]} TX_CTL}]

## Clock relationships ------------------------------------------------------
## Safe because the speed clocks never exist on the mux output together.
set_clock_groups -physically_exclusive -group [get_clocks {txc_125 txc_fwd}] -group [get_clocks txc_25] -group [get_clocks txc_2p5]

## Safe because these domains only meet through these crossings:
##   rxc <-> clk: async FIFO Gray pointers, FIFO memory, and synchronisers for
##                reset and speed_status
##   clk -> tx_clk: synchronisers for reset and speed_status
set_clock_groups -asynchronous -group [get_clocks rxc] -group [get_clocks {clk_out1_clk_wiz_0 clk_out2_clk_wiz_0 clk_2p5}] -group [get_clocks {txc_125 txc_25 txc_2p5 txc_fwd}]

## Clock groups remove normal timing checks, so limit the Gray pointer skew
## directly. All pointer bits must arrive within one 8 ns destination period,
## or the synchroniser could capture a value that was never valid.
set_bus_skew -from [get_cells {mac/rx/fifo/W_handler/g_wptr_reg[*]}] -to [get_cells {mac/rx/fifo/sync_R/Ds_reg[*]}] 8.000
set_bus_skew -from [get_cells {mac/rx/fifo/R_handler/g_rptr_reg[*]}] -to [get_cells {mac/rx/fifo/sync_W/Ds_reg[*]}] 8.000

## Slow ports ---------------------------------------------------------------
## rst_n is a human button and enters through a reset synchroniser. MDIO input
## enters through a two-flop synchroniser. Neither has a fixed clock relationship.
set_false_path -from [get_ports {rst_n MDIO}]

## MDC and MDIO change 40 ns before the PHY samples them, far above its 10 ns
## setup and hold limits. PHY_rst_n changes only during reset, on a 20 ms scale.
set_false_path -to [get_ports {MDC MDIO PHY_rst_n}]
