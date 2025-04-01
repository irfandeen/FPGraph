`timescale 1ns / 1ps

module FloatingPointCombiner(
input sign,
input [23:0] integerPart, decimalPart,
output signed [47:0] combinedNumber);

    localparam POS         = 0;
    localparam NEG         = 1;

assign combinedNumber = sign == POS? (integerPart * 1000000) + decimalPart : -((integerPart * 1000000) + decimalPart);

endmodule
