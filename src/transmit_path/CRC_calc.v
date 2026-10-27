module CRC_calc (
    input rst_n,
    input en,
    input [7:0] data_in,
    input speed_status,
    input TXC,
    output TX_CTL,
    output [3:0] TXD,
    output tx_ready
);

RGMII_transmitter rgmii_tx (
    .TXC(TXC),
    .rst_n(rst_n),
    .en(en),
    .speed_status(speed_status),
    .tx_data(data_in),
    .TXD(TXD),
    .TX_CTL(TX_CTL),
    .tx_ready(tx_ready)
);

//always @(posedge clk) begin
//    if (!rst_n) begin
//        tx_ready <= 1'b1;
//        cycle <= 1'b0; 
//    end else begin
//        TXC_Q <= TXC;
//        if (en) begin
//            if (speed_status) begin
//                tx_ready <= (TXC_Q == 0 && TXC == 1) ? 1'b1 : 1'b0;
//            end else begin
//                cycle <= (cycle == 1'b1) ? 1'b0 : 1'b1;
//                tx_ready <= (TXC_Q == 0 && TXC == 1 && cycle == 1'b1) ? 1'b1 : 1'b0;
//            end
//        end else begin
//            tx_ready <= 1'b1;
//            cycle <= 1'b0;
//        end
//    end
//end

endmodule
