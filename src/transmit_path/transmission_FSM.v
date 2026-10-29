module transmission_FSM (
    input rst_n,
    input valid,
    input [7:0] data,
    input speed_status,
    input TXC,
    output TX_CTL,
    output [3:0] TXD,
    output ready
);

reg [7:0] tx_data;
reg [31:0] byte_counter;

//reg [31:0] CRC_register;
//reg feedback;
//reg [31:0] crc_next;
////
////integer i;
////always @(*) begin
////    crc_next = CRC_register;
////    for (i = 0; i<8; i = i + 1) begin
////        feedback = crc_next[0] ^ data[i];
////        crc_next = crc_next >> 1;
////        if (feedback) crc_next = crc_next ^ 32'hEDB88320;
////    end
////end
reg shift_byte; 
assign ready = tx_ready && shift_byte;

RGMII_transmitter rgmii_tx (
    .TXC(TXC),
    .rst_n(rst_n),
    .en(valid),
    .speed_status(speed_status),
    .tx_data(tx_data),
    .TXD(TXD),
    .TX_CTL(TX_CTL),
    .tx_ready(tx_ready)
);

(* MARK_DEBUG = "TRUE" *) reg [6:0] state;

localparam IDLE = 0;
localparam PREAMBLE = 1;
localparam DESTINATION = 2;
localparam SOURCE = 3;
localparam LENGTH = 4;
localparam DATA = 5;
localparam WAIT_END = 6;

always @(posedge TXC) begin
    if (!rst_n) begin
        tx_data <= 8'b0000_0000;
        byte_counter <= 32'h0000_0000;
        state <= (1 << IDLE);
        shift_byte <= 1'b0;
    end else begin
        if (valid) begin
            case (state)
                (1 << IDLE): begin
                    state <= (1 << PREAMBLE);
                end
                (1 << PREAMBLE): begin
                    if (byte_counter == 7 && tx_ready) begin
                        state <= (1 << DESTINATION);
                        tx_data <= 8'hD5;
                        byte_counter <= 32'h0000_0000;
                        shift_byte <= 1'b1;
                    end else if (tx_ready) begin
                        byte_counter <= byte_counter + 1;
                        tx_data <= 8'h55;
                    end
                end
                (1 << DESTINATION): begin
                     if (byte_counter == 5 && tx_ready) begin
                        state <= (1 << SOURCE);
                        tx_data <= data;
                        shift_byte <= 1'b0;
                        byte_counter <= 32'h0000_0000;
                    end else if (tx_ready) begin
                        byte_counter <= byte_counter + 1;
                        tx_data <= data;
                    end
                end
                (1 << SOURCE): begin
                end
                (1 << LENGTH): begin
                end
                (1 << DATA): begin
                end
                (1 << CRC): begin
                end
            endcase
        end else begin
            // stuff
        end
    end
end



endmodule
