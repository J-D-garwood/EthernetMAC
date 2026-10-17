module MDIO_top #(
    parameter CLK_HZ = 125000000,
    parameter MDC_HZ = 12500000
)(
    input clk,
    input rst_n,
    inout MDIO,
    output MDC,
    output reg [3:0] link_status
);

reg init;
reg [31:0] transmitting;
reg [31:0] read_1;
wire done;
wire busy;
wire [15:0] received;

reg [31:0] counter; 

reg [31:0] link_check;
reg [31:0] page_select;

MDC #() mdc(
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC)
);

reg [2:0] state;
reg [2:0] queued_state;

localparam  transmission_1 = 0;
localparam  transmission_2 = 1;

MDIO_bottom #() mdio(
	.init(init),
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC),
	.transmitting(transmitting),
	.MDIO(MDIO),
	.done(done),
	.busy(busy),
	.received(received)
);

always @(posedge clk) begin
    if (!rst_n) begin
        init <= 1'b0;
        transmitting <= {2'b01, 2'b01, 5'b00001, 5'b11111, 2'b10, 16'b0000101001000011};
        link_check <= {2'b01, 2'b10, 5'b00001, 5'b11010, 2'b00, 16'hFFFF};
        page_select <= {2'b01, 2'b01, 5'b00001, 5'b11111, 2'b10, 16'b0000101001000011};
        counter <= 0;
        state <= transmission_1;
        link_status <= 4'b0000;
        queued_state <= 3'b000;
    end else begin
        if (counter==CLK_HZ-1) begin
            init <= 1;
            counter <= 0;
            state <= queued_state;
        end else begin
            case (state)
            transmission_1: begin
                if (done) begin 
                    queued_state <= transmission_2;
                    transmitting <= link_check; 
                end
            end
            transmission_2: begin
                if (done) begin 
                    queued_state <= transmission_1;
                    transmitting <= page_select;
                    link_status <= received[5:2]; 
                end
            end
            endcase
            counter <= counter + 1;
        end
        if (busy && init) begin
            init <= 0;
        end
    end
end

endmodule