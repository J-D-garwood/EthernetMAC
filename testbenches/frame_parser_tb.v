`timescale 1ns/1ps

module frame_parser_tb;

    // Signals to connect to the module
    reg        clk = 0;
    reg        rst_n = 0;
    reg        RXC = 0;
    reg  [3:0] RXD = 4'd0;
    reg        RX_CTL = 0;
    wire       good_frame;

    // The module being tested
    RGMII_frame_parser dut (
        .clk(clk),
        .rst_n(rst_n),
        .RXC(RXC),
        .RXD(RXD),
        .RX_CTL(RX_CTL),
        .good_frame(good_frame)
    );

    // 100 MHz clock: flips every 5 ns
    always #5 clk = ~clk;

    initial begin
        // Skip the packager: drive its output wires directly
        force dut.data       = 8'h00;
        force dut.byte_valid = 1'b0;

        // Hold reset for 2 clocks
        repeat (2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display("After reset:    register = %h (expect ffffffff)", dut.register);

        // Give the CRC one byte (0xB2) for one clock
        @(negedge clk);
        force dut.data       = 8'hB2;
        force dut.byte_valid = 1'b1;
        @(negedge clk);
        force dut.byte_valid = 1'b0;

        $display("After 1 byte:   register = %h (expect 0892c2d2)", dut.register);

        if (dut.register == 32'h0892C2D2)
            $display("PASS");
        else
            $display("FAIL");

        $finish;
    end

endmodule