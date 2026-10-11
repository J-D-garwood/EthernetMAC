module RGMII_transmitter(
    input clk,
    input rst_n,
    input en, 
    output TXC,
    output [3:0] TXD,
    output TX_CTL
);

assign TXC = clk;

reg [575:0] frame;

localparam preamble = {7{8'b01010101}};
localparam dest_mac = {6{8'hFF}};
localparam src_mac = 48'h997CBA32FC2E;
localparam message = 40'h6f6c6c6568;
localparam [15:0] length = 16'h0500;
localparam padding = 328'h00;
localparam [31:0] CRC = 32'h5CFE1712;//Calculated using crc_calculator.ipynb

reg [31:0] cool_off_countdown;
// Taken from vivado language template
ODDR #(
   .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
   .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
   .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_TX_CTL (
   .Q(TX_CTL),   // 1-bit DDR output
   .C(clk),   // 1-bit clock input
   .CE(1'b1), // 1-bit clock enable input
   .D1(frame != 576'd0), // 1-bit data input (positive edge)
   .D2(frame != 576'd0), // 1-bit data input (negative edge)
   .R(1'b0),   // 1-bit reset
   .S(1'b0)    // 1-bit set
);

genvar i;
generate 
for (i = 0; i < 4; i = i + 1) begin: gen_bits
   ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_TXD (
      .Q(TXD[i]),   // 1-bit DDR output
      .C(clk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(frame[i]), // 1-bit data input (positive edge)
      .D2(frame[i]), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
end
endgenerate

always @(posedge clk) begin 
    if (!rst_n) begin
        frame <= {576'd0};///original message;
        cool_off_countdown <= 300;
    end else begin
        if (frame == 576'd0) begin
            if (cool_off_countdown>0) cool_off_countdown <= cool_off_countdown - 1;
            else if (cool_off_countdown==0 && en) begin
                frame <= {CRC, padding,message,length, src_mac, dest_mac,8'hD5, preamble};
                cool_off_countdown <= 300;
            end
        end else frame <= { 4'b0000, frame[575:4]};
    end
end

endmodule