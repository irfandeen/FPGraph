`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2025 20:53:59
// Design Name: 
// Module Name: LineDisplay
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


module LineDisplay #(
    parameter CHAR_WIDTH = 8,
    parameter CHAR_HEIGHT = 16,
    parameter SHOWN_CHARS = 16
)(
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [9:0] base_x,
    input wire [9:0] base_y,
    input wire [5:0] char0, char1, char2, char3, char4, char5, char6, char7, char8, char9, char10, char11, char12, char13, char14, char15, char16, char17, char18, char19, char20,
    output reg [3:0] r, g, b
);

    // Character layout for 21 characters char0-char21
    localparam NUMBER_CHARS = 21;
    wire [5:0] char_map [0:NUMBER_CHARS-1];

    assign char_map[ 0] = char0; 
    assign char_map[ 1] = char1;
    assign char_map[ 2] = char2;
    assign char_map[ 3] = char3; 
    assign char_map[ 4] = char4; 
    assign char_map[ 5] = char5;   
    assign char_map[ 6] = char6;
    assign char_map[ 7] = char7;
    assign char_map[ 8] = char8; 
    assign char_map[ 9] = char9; 
    assign char_map[10] = char10;
    assign char_map[11] = char11;
    assign char_map[12] = char12;
    assign char_map[13] = char13;
    assign char_map[14] = char14;
    assign char_map[15] = char15;  
    assign char_map[16] = char16;
    assign char_map[17] = char17;
    assign char_map[18] = char18;
    assign char_map[19] = char19;
    assign char_map[20] = char20;

    wire [9:0] local_x = x - base_x;
    wire [9:0] local_y = y - base_y;

    wire in_bounds = (local_x < CHAR_WIDTH * SHOWN_CHARS) && (local_y < CHAR_HEIGHT);
    wire [4:0] char_index = local_x / CHAR_WIDTH;
    wire [2:0] char_col   = local_x % CHAR_WIDTH;
    wire [3:0] char_row   = local_y;  //  4 bits for up to 16 rows
    wire [5:0] char_code = (char_index < NUMBER_CHARS) ? char_map[char_index] : 6'd41;

    wire char_pixel;
    vga_char_rom font_rom (
        .char_idx(char_code),
        .row(char_row),
        .col(char_col),
        .pixel(char_pixel)
    );

    always @(*) begin
        if (in_bounds && char_pixel) begin
            r = 4'hf; g = 4'hf; b = 4'hf;
        end else begin
            r = 0; g = 0; b = 0;
        end
    end
endmodule

