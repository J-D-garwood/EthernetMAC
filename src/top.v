// CLOCK IS CURRENTLY 200 MHz
// NEED TO FLOW CLK THROUGH A PLL
// TO OUTPUT 25 MHz

module top (
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

    localparam width = 8;
    (* MARK_DEBUG = "TRUE" *) wire [width-1:0] data;

    
    (* MARK_DEBUG = "TRUE" *) wire good_frame;

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

// PHY INIT SHOULD ALWAY PRECEDE MDIO HANDSHAKE!! --> Fix this next time
    PHY_INIT #() phy_init(
        .clk(clk),
        .rst_n(sync_rst_n),
        .PHY_rst_n(PHY_rst_n),
        .init_complete(PHY_init_complete)
    );

    MDIO_master #() MDIO_master(
        .clk(clk),
        .rst_n(rst_n_ready),
        .MDIO(MDIO),
        .MDC(MDC)
    );

    
    synchroniser #(1) sync_rst(
        .clk(clk),
    	.rst_n(rst_n_phy),
    	.async_in(1'b1),
    	.sync_out(sync_rst_n)
    );

    RGMII_frame_parser #(8) data_in(
        .clk(clk),
        .rst_n(rst_n_ready),
        .RXC(RXC),
        .RXD(RXD),
        .RX_CTL(RX_CTL),
        .good_frame(good_frame)
        //output frame_type - add this later
    );

    RGMII_transmitter data_out(
    .clk(clk),
    .rst_n(rst_n_ready),
    .en(1'b1), 
    .TXC(TXC),
    .TXD(TXD),
    .TX_CTL(TX_CTL)
    );

endmodule