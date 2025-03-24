`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 19:06:42
// Design Name: 
// Module Name: vga_driver
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


module vga_driver(
    input wire [9:0] x_in,
    input wire [9:0] y_in,
    output wire [15:0] x_out,
    output wire [15:0] y_out
);
    
    assign x_out = x_in * 3;
    assign y_out = (y_in * 9) >> 2;
    
endmodule
