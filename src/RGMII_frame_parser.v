
// parses the received bytes from the rgmii - outputs if frame if good or bad
//Uses CRC
// Will add additional feature to output the type of frame detected

module RGMII_frame_parser #(
    parameter WIDTH = 8
)(
    input clk,
    input rst_n,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    output [WIDTH-1:0] data,
    output reg good_frame
    //output frame_type - add this later
);

//wire [(WIDTH-1):0] data;
reg [(WIDTH-1):0] DATA;
wire byte_is_edge; //flag that indicates if byte is at the edge of a frame
reg BYTE_EDGE;
wire frame_error; //flag that indicates if an error has been detected this frame
reg FRAME_ERROR;
wire byte_valid;
reg BYTE_VALID;

reg [31:0] register;
reg feedback;
reg [31:0] crc_next;

reg [4:0] cycle_count;

integer i;
always @(*) begin
    crc_next = register;
    for (i = 0; i<8; i = i + 1) begin
        feedback = crc_next[0] ^ DATA[i];
        crc_next = crc_next >> 1;
        if (feedback) crc_next = crc_next ^ 32'hEDB88320;
    end
end

reg processing_frame;

RGMII_byte_packager #(WIDTH, 8) byte_packager(
    .clk(clk),
    .rst_n(rst_n),
    .RXC(RXC),
    .RXD(RXD),
    .RX_CTL(RX_CTL),
    .data(data),
    .byte_is_edge(byte_is_edge), 
    .frame_error(frame_error), 
    .byte_valid(byte_valid)
);

always @(posedge clk) begin
    if (!rst_n) begin 
        register <= 32'hFFFF_FFFF;
        processing_frame <= 1'b0;
        good_frame <= 1'b0;
        cycle_count <= 5'b00000;
    end else begin
        BYTE_EDGE <= byte_is_edge;
        FRAME_ERROR <= frame_error;
        BYTE_VALID <= byte_valid;
        DATA <= data;

        if (BYTE_VALID) begin 
            cycle_count <= 5'b00000;
            register <= crc_next;
            if (BYTE_EDGE) begin
                if (processing_frame) begin
                    if (crc_next == 32'hDEBB20E3 && !FRAME_ERROR) good_frame <= 1'b1;
                    register <= 32'hFFFF_FFFF;
                    processing_frame <= 1'b0;
                end else processing_frame <= 1'b1;
            end
        end else begin
            good_frame <= 1'b0;
            if (!processing_frame) begin
                cycle_count <= 5'b00000;
            end else if (cycle_count == 5'b11111) begin
                processing_frame <= 1'b0;
                register <= 32'hFFFF_FFFF;
                cycle_count <= 5'b00000;
            end else cycle_count <= cycle_count + 1;
        end
    end
end
endmodule