`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2025 17:28:11
// Design Name: 
// Module Name: cursor_state
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


module cursor_state(
    input [9:0] xpos, ypos,
    input [9:0] xpos_max, ypos_max,
    input [9:0] xpos_min, ypos_min,
    
    output [9:0] cursor_x, cursor_y
    );
    
    assign cursor_x = (xpos > xpos_max) ? xpos_max: (xpos < xpos_min) ? xpos_min : xpos;
    assign cursor_y = (ypos > ypos_max) ? ypos_max: (ypos < ypos_min) ? ypos_min : ypos;
endmodule
