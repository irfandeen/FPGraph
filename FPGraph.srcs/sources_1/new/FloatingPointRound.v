`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2025 01:25:25
// Design Name: 
// Module Name: FloatingPointRound
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FloatingPointRound(
    input wire [13:0] int,  // Integer part (e.g., 12)
    input wire [13:0] dec,  // Decimal part (e.g., 345 for .345)

    output wire [3:0] int_hundreds,
    output wire [3:0] int_tens,
    output wire [3:0] int_ones,

    output wire [3:0] dec_tenths,
    output wire [3:0] dec_hundredths
);

    // Add 5 for rounding the third decimal digit (e.g., 12.345 ? 12.35)
    wire [15:0] dec_rounded = dec + 50;
    
    // Truncate to 2 decimal digits by dropping 2 least significant digits
    wire [15:0] dec_two_digits = dec_rounded / 100;

    // Handle overflow into the integer part (e.g., 12.995 ? 13.00)
    wire [15:0] new_int = (dec_two_digits >= 100) ? (int + 1) : int;
    wire [15:0] new_dec = (dec_two_digits >= 100) ? 0 : dec_two_digits;

    // Integer digits
    assign int_hundreds = (new_int / 100) % 10;
    assign int_tens     = (new_int / 10)  % 10;
    assign int_ones     = new_int % 10;

    // Decimal digits
    assign dec_tenths     = new_dec / 10;
    assign dec_hundredths = new_dec % 10;

endmodule


