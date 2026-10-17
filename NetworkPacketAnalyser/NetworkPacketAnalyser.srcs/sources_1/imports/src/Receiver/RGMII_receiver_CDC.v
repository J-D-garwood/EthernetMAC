module RGMII_receiver_CDC (
    input clk,
    input rst_n,
    input speed_status,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    output [7:0] data,
    output valid
);

wire [7:0] data_out; 

wire RXC_rst_n;

wire DV;

wire ER;
wire RXC_b;
wire valid_byte;

wire full; //FIFO full
wire empty; //FIFO empty
wire r_en;
assign r_en = !(empty);

wire speed_status_rxc_cd;

RGMII_receiver rx (
    .rst_n(RXC_rst_n),
    .RXC(RXC),
    .RXD(RXD),
    .RX_CTL(RX_CTL),
    .speed_status(speed_status_rxc_cd),
    .data_out(data_out),
    .DV(DV),
    .ER(ER),
    .RXC_b(RXC_b),
    .valid_byte(valid_byte)
);

FIFO_byte fifo(
    .rclk(clk), 
    .wclk(RXC_b), 
    .r_en(r_en), 
    .w_en(valid_byte),
    .rst_n(rst_n),
    .wdata(data_out),
    .rdata(data),
    .full(full), 
    .empty(empty),
    .valid(valid)
);

synchroniser #(1) sync_rst_RXC(
    .clk(RXC_b),
	.rst_n(rst_n),
	.async_in(1'b1),
	.sync_out(RXC_rst_n)
);

synchroniser #(1) sync_speed_status(
    .clk(RXC_b),
	.rst_n(rst_n),
	.async_in(speed_status),
	.sync_out(speed_status_rxc_cd)
);

endmodule