module transmission_FSM (
    input rst_n,
    input valid,
    input [7:0] data,
    input speed_status,
    input TXC,
    input last_byte,
    output TX_CTL,
    output [3:0] TXD,
    output ready
);

reg [7:0] tx_data;

reg shift_byte; 

reg [31:0] byte_counter;

reg [47:0] src_address;

reg [31:0] CRC_register;
reg feedback;
reg [31:0] crc_next;
reg CRC_run;
reg sending_CRC;

reg cool_off;

reg padding;

wire tx_ready;
assign ready = tx_ready && shift_byte;


integer i;
always @(*) begin
    crc_next = CRC_register;
    for (i = 0; i<8; i = i + 1) begin
        feedback = crc_next[0] ^ tx_data[i];
        crc_next = crc_next >> 1;
        if (feedback) crc_next = crc_next ^ 32'hEDB88320;
    end
end

(* MARK_DEBUG = "TRUE" *) reg [7:0] state;

localparam IDLE = 0;
localparam PREAMBLE = 1;
localparam DESTINATION = 2;
localparam SOURCE = 3;
localparam LENGTH = 4;
localparam DATA = 5;
localparam CRC = 6;
localparam INTERPACKET_GAP = 7;

wire en;
assign en = (valid||sending_CRC)&&(!cool_off);

wire frame;
assign frame = (en||cool_off);

RGMII_transmitter rgmii_tx (
    .TXC(TXC),
    .rst_n(rst_n),
    .en(en),
    .speed_status(speed_status),
    .tx_data(tx_data),
    .TXD(TXD),
    .TX_CTL(TX_CTL),
    .tx_ready(tx_ready)
);

always @(posedge TXC) begin
    if (!rst_n) begin
        tx_data <= 8'b0000_0000;
        byte_counter <= 32'h0000_0000;
        state <= (1 << IDLE);
        shift_byte <= 1'b0;
        src_address <= 48'h2EFC32BA7C99;
        CRC_register <= 32'hFFFF_FFFF;
        cool_off <= 1'b0;
        CRC_run <= 1'b0;
        sending_CRC <= 1'b0;
        padding <= 1'b0;
    end else begin
        if (tx_ready && CRC_run) CRC_register <= crc_next;
        if (frame) begin
            case (state)
            (1 << IDLE): begin
                if (tx_ready) state <= (1 << PREAMBLE);
            end
            (1 << PREAMBLE): begin
                if (byte_counter == 5 && tx_ready) begin
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
                    CRC_run <= 1'b1;
                end
            end
            (1 << SOURCE): begin
                if (byte_counter == 5 && tx_ready) begin
                    state <= (1 << LENGTH);
                    tx_data <= src_address[47:40];
                    shift_byte <= 1'b1;
                    byte_counter <= 32'h0000_0000;
                end else if (tx_ready) begin
                    byte_counter <= byte_counter + 1;
                    src_address <= {src_address[39:0], 8'b0000_0000};
                    tx_data <= src_address[47:40];
                end
            end
            (1 << LENGTH): begin
                if (byte_counter == 1 && tx_ready) begin
                    state <= (1 << DATA);
                    tx_data <= data;
                    byte_counter <= 32'h0000_0000;
                end else if (tx_ready) begin
                    byte_counter <= byte_counter + 1;
                    tx_data <= data;
                end
            end
            (1 << DATA): begin
                if (last_byte && tx_ready) begin
                    if (byte_counter>=44) begin
                        state <= (1 << CRC);
                        byte_counter <= 32'h0000_0000;
                    end else begin
                        padding <= 1'b1;
                        byte_counter <= byte_counter + 1;
                    end
                    sending_CRC <= 1'b1;
                    tx_data <= data;
                    shift_byte <= 1'b0;
                end else if (padding && tx_ready) begin
                    if (byte_counter>=44) begin
                        state <= (1 << CRC);
                        sending_CRC <= 1'b1;
                        byte_counter <= 32'h0000_0000;
                    end else begin
                        byte_counter <= byte_counter + 1;
                    end
                    tx_data <= 8'h00;
                end else if (tx_ready) begin
                    byte_counter <= byte_counter + 1;
                    tx_data <= data;
                end
            end
            (1 << CRC): begin
                if (byte_counter == 3 && tx_ready) begin
                    state <= (1 << INTERPACKET_GAP);
                    tx_data <= ~(CRC_register[15:8]);
                    byte_counter <= 32'h0000_0000;
                end else if (tx_ready) begin
                    byte_counter <= byte_counter + 1;
                    if (!CRC_run) begin 
                        CRC_register <= {8'hFF, CRC_register[31:8]};
                    end 
                    tx_data <= (CRC_run) ? ~(crc_next[7:0]) : ~(CRC_register[15:8]);
                    CRC_run <= 1'b0;
                end
            end
            (1 << INTERPACKET_GAP): begin
                if ((speed_status&&byte_counter == 12)||(!speed_status&&byte_counter == 24)) begin
                    state <= (1 << IDLE);
                    cool_off <= 1'b0;
                    byte_counter <= 32'h0000_0000;
                    CRC_register <= 32'hFFFF_FFFF;
                    shift_byte <= 1'b0;
                    src_address <= 48'h2EFC32BA7C99;
                    CRC_run <= 1'b0;
                    tx_data <= 8'h55;
                    padding <= 1'b0;
                end else begin
                    if (tx_ready) begin
                        sending_CRC <= 1'b0;
                        cool_off <= 1'b1;
                    end
                    if (!sending_CRC) byte_counter <= byte_counter + 1;
                end
            end
            endcase
        end else begin
            state <= (1 << IDLE);
            cool_off <= 1'b0;
            byte_counter <= 32'h0000_0000;
            sending_CRC <= 1'b0;
            CRC_register <= 32'hFFFF_FFFF;
            shift_byte <= 1'b0;
            src_address <= 48'h2EFC32BA7C99;
            CRC_run <= 1'b0;
            tx_data <= 8'h55;
            padding <= 1'b0;
        end
    end
end



endmodule