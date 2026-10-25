`timescale 1ns/1ps

module divide_clk_by_odd_N_tb;

reg clk = 0;
reg rst_n = 0;
wire div;

always #20 clk = ~clk;

divide_clk_by_odd_N #() dut(
    .clk(clk),
    .rst_n(rst_n),
    .div(div)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, divide_clk_by_odd_N_tb);
    #100 rst_n = 1;
    #10000
    $finish;
end

endmodule 