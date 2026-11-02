module divide_clk_by_even_N #(
    parameter N = 10
)(
    input clk,
    input rst_n,
    output reg div
);

reg [31:0] counter;

always @(posedge clk) begin
    if (!rst_n) begin
        counter <= 32'h0000_0000;
        div <= 1'b0;
    end else begin
        if (counter == (N/2)-1) begin
            counter <= 32'h0000_0000;
            div <= !div;
        end else counter <= counter + 1'b1;
    end
end

endmodule