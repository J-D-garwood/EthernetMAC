module frame_parser(
    input clk,
    input rst_n,
    input [8:0] data_in,
    input valid,
    output reg good_frame,
    output reg [47:0] DEST,
    output reg [47:0] SRC,
    output reg [15:0] LEN,
    output reg bad_frame,
    output reg header_ready
);

wire [7:0] data;
assign data = data_in[7:0];

wire end_byte;
assign end_byte = data_in[8];

(* MARK_DEBUG = "TRUE" *) reg [6:0] state;

reg [47:0] dest_mac_add;
reg [47:0] src_mac_add;
reg [15:0] eth_len;

reg [31:0] CRC_register;
reg feedback;
reg [31:0] crc_next;
reg CRC;

integer i;
always @(*) begin
    crc_next = CRC_register;
    for (i = 0; i<8; i = i + 1) begin
        feedback = crc_next[0] ^ data[i];
        crc_next = crc_next >> 1;
        if (feedback) crc_next = crc_next ^ 32'hEDB88320;
    end
end

localparam IDLE = 0;
localparam PREAMBLE = 1;
localparam DESTINATION = 2;
localparam SOURCE = 3;
localparam LENGTH = 4;
localparam DATA_and_CRC = 5;
localparam WAIT_END = 6;

reg [31:0] byte_counter;

always @(posedge clk) begin
    if (!rst_n) begin
        good_frame <= 1'b0;
        bad_frame <= 1'b0;
        byte_counter <= 32'h0000_0000;
        state <= (1 << IDLE);
        dest_mac_add <= 48'hFFFF_FFFF_FFFF;
        src_mac_add <= 48'hFFFF_FFFF_FFFF;
        eth_len <= 16'hFFFF;
        CRC_register <= 32'hFFFF_FFFF;
        CRC <= 1'b0;
        DEST <= 48'h0000_0000_0000;
        SRC <= 48'h0000_0000_0000;        
        LEN <= 16'h0000;
        header_ready <= 1'b0;
    end else begin

        if (valid) begin
            if (CRC) begin
                CRC_register <= crc_next;
            end
            case (state)
                (1 << IDLE): begin
                    good_frame <= 1'b0;
                    bad_frame <= 1'b0;
                    state <= (1 << PREAMBLE);
                    CRC_register <= 32'hFFFF_FFFF;
                    CRC <= 0; 
                    byte_counter <= 0;
                end
                (1 << PREAMBLE): begin
                    if (data == 8'hD5) begin
                        state <= (1 << DESTINATION);
                        CRC <= 1'b1;
                    end

                    if (end_byte) begin
                        bad_frame <= 1'b1;
                        state <= (1 << IDLE);
                    end
                end
                (1 << DESTINATION): begin
                    dest_mac_add <= {dest_mac_add[39:0], data};
                    if (byte_counter == 5) begin
                        byte_counter <= 0;
                        state <= (1 << SOURCE);
                    end else begin
                        byte_counter <= byte_counter + 1;
                    end

                    if (end_byte) begin
                        bad_frame <= 1'b1;
                        state <= (1 << IDLE);
                    end
                end
                (1 << SOURCE): begin
                    DEST <= dest_mac_add;
                    src_mac_add <= {src_mac_add[39:0], data};
                    if (byte_counter == 5) begin
                        byte_counter <= 0;
                        state <= (1 << LENGTH);
                    end else begin
                        byte_counter <= byte_counter + 1;
                    end

                    if (end_byte) begin
                        bad_frame <= 1'b1;
                        state <= (1 << IDLE);
                    end
                end
                (1 << LENGTH): begin
                    SRC <= src_mac_add;
                    eth_len <= {eth_len[7:0], data};
                    if (byte_counter == 1) begin
                        byte_counter <= 0;
                        state <= (1 << DATA_and_CRC);
                    end else begin
                        byte_counter <= byte_counter + 1;
                    end
                    if (end_byte) begin
                        bad_frame <= 1'b1;
                        state <= (1 << IDLE);
                    end
                end
                (1 << DATA_and_CRC): begin
                    if (byte_counter == 0) begin
                        LEN <= eth_len;
                        header_ready <= 1'b1;
                    end else header_ready <= 1'b0;
                    if (byte_counter >1503) begin
                        bad_frame <= 1'b1;
                        state <= (end_byte) ? (1 << IDLE) : (1 << WAIT_END);
                    end else if (end_byte && crc_next == 32'hDEBB20E3 && byte_counter > 48) begin
                        good_frame <= 1'b1;
                        state <= (1 << IDLE);
                    end else if (end_byte) begin
                        bad_frame <= 1'b1;
                        state <= (1 << IDLE);
                    end else byte_counter <= byte_counter + 1;
                end
                (1 << WAIT_END): begin
                    if (end_byte) state <= (1 << IDLE);
                    bad_frame <= 1'b0;
                end
                default: state <= (1 << IDLE);
            endcase
        end else begin 
            good_frame <= 1'b0;
            bad_frame <= 1'b0;
        end
    end
end

endmodule