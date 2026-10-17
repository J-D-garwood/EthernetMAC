// CLOCK IS CURRENTLY 200 MHz
// NEED TO FLOW CLK THROUGH A PLL
// TO OUTPUT 25 MHz

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
    wire rst_n_phy;
    assign rst_n_phy = (rst_n && locked); // reset finished and clock confirmed at 25 MHz

    wire rst_n_ready;
    assign rst_n_ready = (sync_rst_n && PHY_init_complete);
    
// CHECK THE CLOCK WIZARD SETTINGS IF HAVING ISSUES
    clk_wiz_0 clk_wiz
     (
      // Clock out ports
      .clk_out1(clk),     // output clk_out1
      // Status and control signals
      .resetn(rst_n), // input resetn
      .locked(locked),       // output locked
     // Clock in ports
      .clk_in1_p(sys_clk_p),    // input clk_in1_p
      .clk_in1_n(sys_clk_n)    // input clk_in1_n
    );

    PHY_INIT #() phy_init(
        .clk(clk),
        .rst_n(sync_rst_n),
        .PHY_rst_n(PHY_rst_n),
        .init_complete(PHY_init_complete)
    );

    synchroniser #(1) sync_rst(
        .clk(clk),
    	.rst_n(rst_n_phy),
    	.async_in(1'b1),
    	.sync_out(sync_rst_n)
    );

    wire [1:0] speed_status;
    wire duplex, linked;

    MDIO #() mdio(
    .clk(clk),
    .rst_n(sync_rst_n),
    .MDIO(MDIO),
    .MDC(MDC),
    .speed_status(speed_status),
    .duplex(duplex),
    .linked(linked)
    );

    MAC mac(
    .clk(clk),
    .rst_n(sync_rst_n),
    .RXC(RXC),
    .RX_CTL(RX_CTL),
    .RXD(RXD),
    .TXC(TXC),
    .TX_CTL(TX_CTL),
    .TXD(TXD),
    .speed_status(speed_status),
    .duplex(duplex),
    .linked(linked)
    );
endmodule