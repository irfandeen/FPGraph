`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 20:47:36
// Design Name: 
// Module Name: CalculateStartEndPoints
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


module CalculateStartEndPoints # (
    parameter signed [15:0] X0 = -10,
    parameter signed [15:0] X1 = 10,
    parameter signed [15:0] SCALE = 20
) (
    input wire signed [7:0] a, b, c, // y = ax^2 + bx + c
    output wire signed [15:0] x0, y0, x1, y1
    );
    assign x0 = X0 * SCALE;
    assign y0 = ((a * X0 * X0) + (b * X0) + c) * SCALE;
    assign x1 = X1 * SCALE;
    assign y1 = ((a * X1 * X1) + (b * X1) + c) * SCALE;
endmodule
