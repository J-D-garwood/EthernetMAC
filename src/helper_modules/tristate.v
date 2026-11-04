// MDIO is bidirectional - drive pin when drive = 1, else high-z
module tristate(
    input drive,
    input transmit,
    output receive,
    inout pin 
);

    assign pin = drive ? transmit : 1'bz;
    assign receive = pin;

endmodule