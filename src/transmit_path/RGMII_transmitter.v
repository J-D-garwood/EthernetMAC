
// To fix the module: send the low nibble first, delay en by one clock so it matches the data, 
// forward TXC through an ODDR, and at 10/100 run TXC at 25/2.5 MHz with each nibble held for a full 
// TXC cycle and a ready signal so the byte is held until it’s sent.


module RGMII_transmitter(
    input clk,
    input rst_n,
    input en,
    input [7:0] tx_data,
    input speed_status,
    output TXC,
    output [3:0] TXD,
    output TX_CTL
);

assign TXC = clk;

reg [3:0] nibble_pos;
reg [3:0] nibble_neg;

reg en_Q;

reg byte_idx;

ODDR #(
   .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
   .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
   .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_TX_CTL (
   .Q(TX_CTL),   // 1-bit DDR output
   .C(clk),   // 1-bit clock input
   .CE(1'b1), // 1-bit clock enable input
   .D1(en_Q), // 1-bit data input (positive edge)
   .D2(en_Q), // 1-bit data input (negative edge)
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
      .D1(nibble_pos[i]), // 1-bit data input (positive edge)
      .D2(nibble_neg[i]), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
end
endgenerate

always @(posedge clk) begin
    if (!rst_n) begin
        nibble_pos <= 4'b0000;
        nibble_neg <= 4'b0000;
        byte_idx <= 0;
    end else begin
        en_Q <= en;
        if (en) begin
            if (speed_status) begin
                nibble_neg <= tx_data[7:4];
                nibble_pos <= tx_data[3:0];
            end else begin
                if (byte_idx) begin
                    nibble_pos <= tx_data[7:4];
                    nibble_neg <= tx_data[7:4];
                end else begin
                    nibble_pos <= tx_data[3:0];
                    nibble_neg <= tx_data[3:0];
                end
                byte_idx <= !byte_idx;
            end
        end else begin
            nibble_pos <= 4'b0000;
            nibble_neg <= 4'b0000;
            byte_idx <= 0;
        end
    end
end

endmodule