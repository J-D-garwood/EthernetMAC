module RGMII_receiver(
    input rst_n,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    input speed_status,
    output [7:0] data_out,
    output DV,
    output ER,
    output RXC_b,
    output reg valid_byte
);

wire RXC_c;

wire RXC_neg;
assign ER =  DV ^ RXC_neg;
reg DV_d;

wire [3:0] nibble_pos;
wire [3:0] nibble_neg;

reg [7:0] data;

reg full_byte;

assign data_out = data;
   // BUFIO and BUFR: Clock Buffers
   //       Artix-7
   // Xilinx HDL Language Template, version 2025.2
  // Taken from Vivado Language Templates for Artix-7
   BUFIO BUFIO_inst (
   .O(RXC_c), // 1-bit output: Clock output (connect to I/O clock loads).
   .I(RXC)  // 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );

   BUFR #(
      .BUFR_DIVIDE("BYPASS"),   // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
      .SIM_DEVICE("7SERIES")  // Must be set to "7SERIES" 
   )
   BUFR_inst (
      .O(RXC_b),     // 1-bit output: Clock output port
      .CE(1'b1),   // 1-bit input: Active high, clock enable (Divided modes only)
      .CLR(1'b0), // 1-bit input: Active high, asynchronous clear (Divided modes only)
      .I(RXC)      // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
   );
// Template taken from Vivado Tools → Language Templates → Verilog → Device Primitive Instantiation → Artix-7 → I/O Components → DDR Registers → IDDR
   IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_RX_CTL (
      .Q1(DV), // 1-bit output for positive edge of clock
      .Q2(RXC_neg), // 1-bit output for negative edge of clock
      .C(RXC_c),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(RX_CTL),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

genvar i;
generate 
    for (i = 0; i<4; i = i + 1) begin: gen_bits
        IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
        ) IDDR_RXD(
      .Q1(nibble_pos[i]), // 1-bit output for positive edge of clock
      .Q2(nibble_neg[i]), // 1-bit output for negative edge of clock
      .C(RXC_c),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(RXD[i]),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
        );
    end
endgenerate

always @(posedge RXC_b) begin
   if (!rst_n) begin
      data <= 8'b00000000;
      valid_byte <= 1'b0;
      full_byte <= 1'b0;
      DV_d <= 1'b0;
   end else begin
      DV_d <= DV;
      if (speed_status && DV) begin
         data <= {nibble_neg, nibble_pos};
         valid_byte <= 1'b1;
      end else if (speed_status && !DV) begin
          valid_byte <= 1'b0;
      end else begin
         if (DV == 1'b1 && DV_d == 1'b0) begin
            full_byte <= 1'b0;
            data[3:0] <= nibble_pos;
            valid_byte <= 1'b0;
         end else if (DV == 1'b0 && DV_d == 1'b1) begin
            valid_byte <= 1'b0;
         end else if (!full_byte && DV_d) begin
            data[7:4] <= nibble_pos;
            full_byte <= 1'b1;
            valid_byte <= 1'b1;
         end else if (full_byte && DV_d) begin
            data[3:0] <= nibble_pos;
            full_byte <= 1'b0;
            valid_byte <= 1'b0;
         end
      end
   end
end
endmodule