module divide_clk_by_odd_N #(
    parameter N = 5
)(
    input clk,
    input rst_n,
    output div
);

reg [($clog2(N)-1):0] rise_count;
reg [($clog2(N)-1):0] fall_count;

reg rise_switch;
reg fall_swtich;

reg rise_rst;
reg fall_rst;

assign div = rise_switch^fall_swtich;

always @(posedge clk) begin
    if (!rst_n) begin
        rise_count <= 0;
        rise_switch <= 0;
        rise_rst <= 0;
    end else begin
        if (fall_rst) begin
            rise_count <= 1;
        end else if (rise_count == ((N-1)/2)) begin
            rise_switch <= !rise_switch;
            rise_count <= 0;
            rise_rst <= 1;
        end else begin
            rise_count <= rise_count + 1;
            rise_rst <= 0;
        end
    end
end

always @(negedge clk) begin
    if (!rst_n) begin
        fall_count <= 0;
        fall_swtich <= 0;
        fall_rst <= 0;
    end else begin
        if (rise_rst) begin
            fall_count <= 1;
        end else if (fall_count == ((N-1)/2)) begin
            fall_swtich <= !fall_swtich;
            fall_count <= 0;
            fall_rst <= 1;
        end else begin
            fall_count <= fall_count + 1;
            fall_rst <= 0;
        end
    end
end

endmodule