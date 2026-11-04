module MDC #(
    parameter CLK_HZ = 125000000
)(
    input clk,
    input rst_n,
    output MDC
);

// 5 bit johnson counter -> MDC = clk/10 (12.5 MHz from 125 MHz)
reg [4:0] johnson_counter;

assign MDC = johnson_counter[0];

integer j; 
always @(posedge clk) begin
    if (!rst_n) begin
        johnson_counter <= 5'b00000;
    end else begin
        for (j = 1; j < 5; j = j + 1) begin
            johnson_counter[j] <= johnson_counter[j-1]; // The synthesizer unrolls this into parallel logic
        end
        johnson_counter[0] <= !johnson_counter[4];
    end
end

endmodule