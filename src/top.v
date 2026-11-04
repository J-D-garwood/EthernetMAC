// Top level - clocking, resets, MDIO, test frame feeder and the MAC

module top #(
    parameter CLK_HZ = 125000000
)(
    input  sys_clk_p,
    input  sys_clk_n,
    input  rst_n,
    // RGMII INTERFACE
    input RXC,
    input RX_CTL,
    input [3:0] RXD,
    output TXC,
    output TX_CTL,
    output [3:0] TXD,

    // MDIO INTERFACE
    inout MDIO,
    output MDC,

    //OTHER PHY PINS
    output PHY_rst_n
);

    wire clk;
    wire locked;
    wire PHY_init_complete;

    wire sync_rst_n;

    wire rst_n_ready;
    assign rst_n_ready = (sync_rst_n && PHY_init_complete);
    wire [7:0] received_byte;
    
    wire two5Meg;
    wire tx_clk;
    wire tx_rst_n;
// CHECK THE CLOCK WIZARD SETTINGS IF HAVING ISSUES

    wire clk200;
    // 200 MHz board clk -> 125 MHz (clk), 25 MHz (two5Meg), 200 MHz (clk200 for IDELAYCTRL)
    clk_wiz_0 clk_wiz
     (
      // Clock out ports
      .clk_out1(clk),     // output clk_out1
      .clk_out2(two5Meg),
      .clk_out3(clk200),
      // Status and control signals
      .resetn(rst_n), // input resetn
      .locked(locked),       // output locked
     // Clock in ports
      .clk_in1_p(sys_clk_p),    // input clk_in1_p
      .clk_in1_n(sys_clk_n)    // input clk_in1_n
    );
    // calibrates the RX IDELAYs, held in reset until the PLL locks
    (* MARK_DEBUG = "TRUE" *) wire RDY;
    IDELAYCTRL IDELAYCTRL_inst (
    .RDY(RDY),          // probed on ila
    .REFCLK(clk200),
    .RST(!locked)    // active high
    );

    // 20ms PHY reset, then 20ms wait before init_complete
    PHY_INIT #(CLK_HZ) phy_init(
        .clk(clk),
        .rst_n(sync_rst_n),
        .PHY_rst_n(PHY_rst_n),
        .init_complete(PHY_init_complete)
    );

    // rst_n goes straight to the async reset, locked goes through the 2 flops (no LUT on the reset)
    synchroniser #(1) sync_rst(
        .clk(clk),
    	.rst_n(rst_n),
    	.async_in(locked),
    	.sync_out(sync_rst_n)
    );

    wire [1:0] speed_status;
    wire duplex, linked;

    // reads link speed, duplex and link up from the PHY
    MDIO #() mdio(
    .clk(clk),
    .rst_n(sync_rst_n),
    .MDIO(MDIO),
    .MDC(MDC),
    .speed_status(speed_status),
    .duplex(duplex),
    .linked(linked)
    );

    wire ready;
    wire [7:0] data;
    wire valid;
    wire last_byte;

    // test frame (ARP request) for the TX path
    simple_frame_feeder frame_feed (
    .TXC(tx_clk),
    .rst_n(tx_rst_n),
    .ready(ready),
    .data(data),
    .valid(valid),
    .last_byte(last_byte)
    );

    MAC mac(
    .clk(clk),
    .two5Meg(two5Meg),
    .rst_n(sync_rst_n),
    .RXC(RXC),
    .RX_CTL(RX_CTL),
    .RXD(RXD),
    .TXC(TXC),
    .TX_CTL(TX_CTL),
    .TXD(TXD),
    .data_in(data),
    .valid_tx(valid),
    .last_byte(last_byte),
    .data_out(received_byte),
    .speed_status(speed_status),
    .duplex(duplex),
    .linked(linked),
    .ready(ready),
    .tx_clk(tx_clk),
    .tx_rst_n(tx_rst_n)
    );



endmodule