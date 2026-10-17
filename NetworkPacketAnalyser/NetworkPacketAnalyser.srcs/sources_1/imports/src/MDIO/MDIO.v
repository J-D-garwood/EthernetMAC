module MDIO #(
    parameter CLK_HZ = 125000000,
    parameter MDC_HZ = 12500000
)(
    input clk,
    input rst_n,
    inout MDIO,
    output MDC,
    output [1:0] speed_status,
    output duplex,
    output linked
);

MDIO_top #(CLK_HZ, MDC_HZ) mdio_top (
    .clk(clk),
    .rst_n(rst_n),
    .MDIO(MDIO),
    .MDC(MDC),
    .link_status({speed_status, duplex, linked})
);

endmodule