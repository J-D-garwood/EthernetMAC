module frame_filter(
    input clk,
    input rst_n,
    input [7:0] data,
    input [47:0] DEST,
    input [47:0] SRC,
    input [15:0] LEN,
    input good_frame,
    input bad_frame,
    input header_ready,
    input valid,
    output reg [7:0] payload_byte,
    output reg receiving_payload,
    output reg new_byte

);

reg [7:0] data_Q;

reg [7:0] byte_1, byte_2, byte_3;
reg new_byte_1, new_byte_2, new_byte_3;

always @(posedge clk) begin
    if (!rst_n) begin
        payload_byte <= 8'b0000_0000;
        data_Q <= 8'b0000_0000; 
        receiving_payload <= 1'b0;
        new_byte <= 1'b0;
        new_byte_1 <= 1'b0;
        new_byte_2 <= 1'b0;
        new_byte_3 <= 1'b0;
        byte_1 <= 8'b0000_0000;
        byte_2 <= 8'b0000_0000;
        byte_3 <= 8'b0000_0000;
    end else begin
            if (valid) begin
                data_Q <= data;
                if (header_ready && ((DEST==48'hFFFF_FFFF_FFFF)||(DEST==48'h2EFC_32BA_7C99)) && !receiving_payload) begin
                    receiving_payload <= 1'b1;
                    new_byte <= 1'b0;
                    new_byte_1 <= 1'b0;
                    new_byte_2 <= 1'b0;
                    new_byte_3 <= 1'b1;

                    payload_byte <= 8'b0000_0000;
                    byte_1 <= 8'b0000_0000;
                    byte_2 <= 8'b0000_0000;
                    byte_3 <= data_Q;
                end 

                if (receiving_payload) begin
                    new_byte <= new_byte_1;
                    new_byte_1 <= new_byte_2;
                    new_byte_2 <= new_byte_3;
                    new_byte_3 <= 1'b1;

                    payload_byte <= byte_1;
                    byte_1 <= byte_2;
                    byte_2 <= byte_3;
                    byte_3 <= data_Q;
                end 
            end else begin
                new_byte <= 1'b0;
            end

            if (good_frame || bad_frame) begin
                new_byte <= 1'b0;
                new_byte_1 <= 1'b0;
                new_byte_2 <= 1'b0;
                new_byte_3 <= 1'b0;

                payload_byte <= 8'b0000_0000;
                byte_1 <= 8'b0000_0000;
                byte_2 <= 8'b0000_0000;
                byte_3 <= 8'b0000_0000;

                receiving_payload <= 1'b0;
            end
    end
end

endmodule