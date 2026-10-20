module transmitter (
    input clk,
    input rst_n,
    input tx_valid,
    input tx_last,
    input [7:0] data_in,
    output TXC,
    output TX_CTL,
    output [3:0] TXD,
    output tx_ready
    input speed_status
);

reg en;

reg [2:0] state;

localparam idle = 0;
localparam sending = 0;
localparam cool_off = 0;


always @(posedge clk) begin
    if (!rst_n) begin
        state <= (1<<IDLE);
        en <= 1'b0;
    end else begin
    end
end
endmodule
