module MAC #(
    parameter WIDTH = 8
)(
    input clk,
    input rst_n,
    input RXC,
    input RX_CTL,
    input [3:0] RXD,
    input [WIDTH-1:0] data;
    output TXC,
    output TX_CTL,
    output [3:0] TXD
);

wire Ethertype_seg;
reg [15:0] Ethertype;


always @(posedge clk) begin

end

endmodule