module simple_frame_feeder (
    input TXC,
    input rst_n,
    input ready,
    output [7:0] data,
    output reg valid,
    output reg last_byte
);

reg [7:0] mem [35:0];

reg [5:0] idx;

assign data = mem[idx];

initial begin
    $readmemh("data.hex", mem);
end

always @(posedge TXC) begin
    if (!rst_n) begin
        idx <= 6'b000000;
        valid <= 1'b1;
        last_byte <= 1'b0;
    end else begin
        if (ready) begin
            if (idx==35) begin
                idx <= 6'b000000;
                last_byte <= 1'b0;
            end else begin
                idx <= idx + 1'b1;
                if (idx==34) last_byte <= 1'b1;
            end
        end 
    end 
end

endmodule