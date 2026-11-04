// ADD THE 125, 25, 2.5 MHz clks for the different speeds

module MAC (
    input clk,
    input two5Meg,
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
    output ready,
    output tx_clk,    // Internal transmit clock, muxed for the link speed
    output tx_rst_n   // Reset synchronised to tx_clk
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

wire twopoint5;
wire below100;

divide_clk_by_even_N #() div_by_10 (
    .clk(two5Meg),
    .rst_n(rst_n),
    .div(twopoint5)
);


   BUFGMUX #() BUFGMUX_inst_a (
      .O(below100),   // 1-bit output: Clock output
      .I0(twopoint5), // 1-bit input: Clock input (S=0)
      .I1(two5Meg), // 1-bit input: Clock input (S=1)
      .S(speed_status[0])    // 1-bit input: Clock select
   );

      BUFGMUX #() BUFGMUX_inst_b (
      .O(tx_clk),   // 1-bit output: Clock output
      .I0(below100), // 1-bit input: Clock input (S=0)
      .I1(clk), // 1-bit input: Clock input (S=1)
      .S(speed_status[1])    // 1-bit input: Clock select
   );

// Forward the clock through an ODDR so TXC leaves the FPGA the same way as
// TXD and TX_CTL. This keeps the clock edge-aligned with the data.
ODDR #(
   .DDR_CLK_EDGE("SAME_EDGE"),
   .INIT(1'b0),
   .SRTYPE("SYNC")
) ODDR_TXC (
   .Q(TXC),
   .C(tx_clk),
   .CE(1'b1),
   .D1(1'b1),
   .D2(1'b0),
   .R(1'b0),
   .S(1'b0)
);

// rst_n and speed_status belong to clk, so synchronise them into tx_clk.
wire speed_status_tx_cd;

synchroniser #(1) sync_rst_TX(
    .clk(tx_clk),
    .rst_n(rst_n),
    .async_in(1'b1),
    .sync_out(tx_rst_n)
);

synchroniser #(1) sync_speed_TX(
    .clk(tx_clk),
    .rst_n(rst_n),
    .async_in(speed_status[1]),
    .sync_out(speed_status_tx_cd)
);

transmission_FSM tx (
    .rst_n(tx_rst_n),
    .valid(valid_tx),
    .data(data_in),
    .speed_status(speed_status_tx_cd),
    .TXC(tx_clk),
    .last_byte(last_byte),
    .TX_CTL(TX_CTL),
    .TXD(TXD),
    .ready(ready)
);

endmodule