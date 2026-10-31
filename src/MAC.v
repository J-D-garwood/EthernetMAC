// ADD THE 125, 25, 2.5 MHz clks for the different speeds

module MAC (
    input clk,
    input rst_n,
    input RXC,
    input RX_CTL,
    input [3:0] RXD,
    output TXC,
    output TX_CTL,
    output [3:0] TXD,
    input [7:0] data_in,
    input valid_tx,
    input last_byte,
    output [7:0] data_out,
    input [1:0] speed_status,
    input duplex,
    input linked,
    output ready
);

(* MARK_DEBUG = "TRUE" *) wire [8:0] data;
(* MARK_DEBUG = "TRUE" *) wire valid_rx;
(* MARK_DEBUG = "TRUE" *) wire good_frame;
(* MARK_DEBUG = "TRUE" *) wire bad_frame;
(* MARK_DEBUG = "TRUE" *) wire header_ready;
(* MARK_DEBUG = "TRUE" *) wire [47:0] destination;
(* MARK_DEBUG = "TRUE" *) wire [47:0] source;
(* MARK_DEBUG = "TRUE" *) wire [15:0] ethernet_length;
(* MARK_DEBUG = "TRUE" *) wire receiving_payload;
(* MARK_DEBUG = "TRUE" *) wire [7:0] payload_byte;
(* MARK_DEBUG = "TRUE" *) wire new_byte;

assign data_out = payload_byte;

RGMII_receiver_CDC rx (
    .clk(clk),
    .rst_n(rst_n),
    .speed_status(speed_status[1]),
    .RXC(RXC),
    .RXD(RXD),
    .RX_CTL(RX_CTL),
    .data(data),
    .valid(valid_rx)
);

frame_parser parse (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data),
    .valid(valid_rx),
    .good_frame(good_frame),
    .DEST(destination),
    .SRC(source),
    .LEN(ethernet_length),
    .bad_frame(bad_frame),
    .header_ready(header_ready)
);

frame_filter filter (
    .clk(clk),
    .rst_n(rst_n),
    .data(data[7:0]),
    .DEST(destination),
    .SRC(source),
    .LEN(ethernet_length),
    .good_frame(good_frame),
    .bad_frame(bad_frame),
    .header_ready(header_ready),
    .valid(valid_rx),
    .payload_byte(payload_byte),
    .receiving_payload(receiving_payload),
    .new_byte(new_byte)
);

transmission_FSM tx (
    .rst_n(rst_n),
    .valid(valid_tx),
    .data(data_in),
    .speed_status(speed_status[1]),
    .TXC(TXC),
    .last_byte(last_byte),
    .TX_CTL(TX_CTL),
    .TXD(TXD),
    .ready(ready)
);

endmodule