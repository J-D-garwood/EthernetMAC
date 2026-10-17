module MAC (
    input clk,
    input rst_n,
    input RXC,
    input RX_CTL,
    input [3:0] RXD,
    output TXC,
    output TX_CTL,
    output [3:0] TXD,
    input [1:0] speed_status,
    input duplex,
    input linked
);

(* MARK_DEBUG = "TRUE" *) wire [7:0] data;
(* MARK_DEBUG = "TRUE" *) wire valid;

RGMII_receiver_CDC rx (
    .clk(clk),
    .rst_n(rst_n),
    .speed_status(speed_status[1]),
    .RXC(RXC),
    .RXD(RXD),
    .RX_CTL(RX_CTL),
    .data(data),
    .valid(valid)
);

endmodule