`timescale 1ns / 1ps

module FloatingPointSplitter(
input signed [47:0] combinedNumber,
output sign,
output [23:0] integerPart, decimalPart);

    localparam POS         = 0;
    localparam NEG         = 1;
   

assign sign = combinedNumber < 0 ? NEG : POS;

assign integerPart = combinedNumber < 0 ? -(combinedNumber[47:23]) : combinedNumber[47:23];
assign decimalPart = combinedNumber < 0 ? -(combinedNumber[23:0]) : combinedNumber[23:0];

endmodule
