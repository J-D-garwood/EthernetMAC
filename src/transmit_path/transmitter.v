module transmitter (
    input clk,
    input rst_n,
    input tx_valid,
    input tx_last,
    input [7:0] data_in,
    output TXC,
    output TX_CTL,
    output [3:0] TXD,
    output tx_ready,
    input speed_status
);

wire PHY_clk;

divide_clk_by_odd_N #(5) clk_divider (
    .clk(clk),
    .rst_n(rst_n),
    .div(PHY_clk) // 25 MHz clk
);


always @(posedge PHY_clk) begin
    if (!rst_n) begin

    end else begin
        
    end
end
endmodule
