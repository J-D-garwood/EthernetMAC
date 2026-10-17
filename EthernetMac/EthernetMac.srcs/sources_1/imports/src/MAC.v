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

(* MARK_DEBUG = "TRUE" *) wire [8:0] data;
(* MARK_DEBUG = "TRUE" *) wire valid;
(* MARK_DEBUG = "TRUE" *) wire good_frame;
(* MARK_DEBUG = "TRUE" *) wire bad_frame;
(* MARK_DEBUG = "TRUE" *) wire header_ready;
(* MARK_DEBUG = "TRUE" *) wire [47:0] destination;
(* MARK_DEBUG = "TRUE" *) wire [47:0] source;
(* MARK_DEBUG = "TRUE" *) wire [15:0] ethernet_length;



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

frame_parser parse (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data),
    .valid(valid),
    .good_frame(good_frame),
    .DEST(destination),
    .SRC(source),
    .LEN(ethernet_length),
    .bad_frame(bad_frame),
    .header_ready(header_ready)
);

endmodule