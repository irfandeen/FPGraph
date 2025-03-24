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

// makes it seem like 

module vga_driver(
    input wire           clk,
    output wire [9:0]      x,
    output wire [9:0]      y,
    output wire       p_tick,
    output wire            en,
    output reg [9:0]   min_x = 560,
    output reg [9:0]   min_y = 140,
    output reg [9:0]   max_x = 1360, 
    output reg [9:0]   max_y = 940,
    output wire        Hsync,
    output wire        Vsync
);
    wire reset;
    assign reset = 0;

    wire [9:0] x_raw;
    wire [9:0] y_raw;

    VGAControl vga_control (
        .clk_100MHz(clk),   // from FPGA
        .reset(reset),        // system reset
        .video_on(en),    // ON while pixel counts for x and y and within display area
        .hsync(Hsync),       // horizontal sync
        .vsync(Vsync),       // vertical sync
        .p_tick(p_tick),      // the 25MHz pixel/second rate signal, pixel tick
        .x(x_raw),     // pixel count/position of pixel x, max 0-799
        .y(y_raw)      // pixel count/position of pixel y, max 0-524
    );
    
    assign x = x_raw * 3;
    assign y = y_raw * 2;
    
    
endmodule
