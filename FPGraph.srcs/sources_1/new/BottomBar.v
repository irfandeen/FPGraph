`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2025 20:19:29
// Design Name: 
// Module Name: BottomBar
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


module TopBottomBar #(
    parameter BASE_X0 = 10,
    parameter BASE_X1 = 410,
    parameter BASE_Y = 20,
    parameter CHAR_WIDTH = 8,
    parameter CHAR_HEIGHT = 16
) (
    
    input wire clk,
    input wire [15:0] x, y, 
    
    input wire sign_origin_x, sign_origin_y,    
    input wire [20:0] origin_x, origin_y, quad_width,
   
    input wire isTop,
    
    output reg [3:0] sidebar_red,
    output reg [3:0] sidebar_green,
    output reg [3:0] sidebar_blue
);

    localparam NUM_CHARS = 15;
    wire [3:0] r0, g0, b0;
    wire [3:0] r1, g1, b1;

    wire signed [20:0] signed_origin_x = (sign_origin_x) ? -origin_x : origin_x;
    wire signed [20:0] signed_origin_y = (sign_origin_y) ? -origin_y : origin_y;

    wire signed [20:0] signed_left_x = origin_x - quad_width;
    wire signed [20:0] signed_right_x = origin_x + quad_width;
    wire [20:0] magnitude_left_x = (signed_left_x < 0) ? -signed_left_x : signed_left_x;
    wire [20:0] magnitude_right_x = (signed_right_x < 0) ? -signed_right_x : signed_right_x;
   
    wire signed [20:0] signed_y = isTop ? signed_origin_x + quad_width : signed_origin_x - quad_width;
    wire [20:0] magnitude_y = (signed_y < 0) ? -signed_y : signed_y;
    
    LineDisplay #(.SHOWN_CHARS(NUM_CHARS)) leftCoords (
        .x(x),
        .y(y),
        .base_x(BASE_X0),
        .base_y(BASE_Y),
        .char0(36), // (
        .char1(signed_left_x < 0 ? 17 : 12), // negative ? - : +
        .char2((magnitude_left_x / 10000) % 10), // x ten thousandths
        .char3((magnitude_left_x / 1000)  % 10), // thousandths               
        .char4((magnitude_left_x / 100)   % 10), // hundreds
        .char5((magnitude_left_x / 10)    % 10), // tens
        .char6(magnitude_left_x           % 10), // ones 
        .char7(38), // , 
        .char8(signed_y < 0 ? 17 : 12), // negative ? - : +
        .char9((magnitude_y / 10000)  % 10), // y ten thousandths
        .char10((magnitude_y / 1000)  % 10), // thousandths               
        .char11((magnitude_y / 100)   % 10), // hundreds
        .char12((magnitude_y / 10)    % 10), // tens
        .char13(magnitude_y           % 10), // ones 
        .char14(37), // ) 
        
        .r(r0), .g(g0), .b(b0)    
    );

    LineDisplay #(.SHOWN_CHARS(NUM_CHARS)) rightCoords (
        .x(x),
        .y(y),
        .base_x(BASE_X1),
        .base_y(BASE_Y),
        .char0(36), // (
        .char1(signed_right_x < 0 ? 17 : 12), // negative ? - : +
        .char2((magnitude_right_x / 10000) % 10), // x ten thousandths
        .char3((magnitude_right_x / 1000)  % 10), // thousandths               
        .char4((magnitude_right_x / 100)   % 10), // hundreds
        .char5((magnitude_right_x / 10)    % 10), // tens
        .char6(magnitude_right_x           % 10), // ones 
        .char7(38), // , 
        .char8(signed_y < 0 ? 17 : 12), // negative ? - : +
        .char9((magnitude_y / 10000)  % 10), // y ten thousandths
        .char10((magnitude_y / 1000)  % 10), // thousandths               
        .char11((magnitude_y / 100)   % 10), // hundreds
        .char12((magnitude_y / 10)    % 10), // tens
        .char13(magnitude_y           % 10), // ones 
        .char14(37), // ) 
        
        .r(r1), .g(g1), .b(b1)    
    );    


    always @(*) begin
            // EQUATION and e1, e2, e3
            if (y >= BASE_Y && y < BASE_Y + CHAR_HEIGHT &&
                x >= BASE_X0 && x < BASE_X0 + CHAR_WIDTH * NUM_CHARS) begin
                sidebar_red = r0; sidebar_green = g0; sidebar_blue = b0;
            end
            else if (y >= BASE_Y && y < BASE_Y + CHAR_HEIGHT &&
                x >= BASE_X1 && x < BASE_X1 + CHAR_WIDTH * NUM_CHARS) begin
                sidebar_red = r1; sidebar_green = g1; sidebar_blue = b1;
            end
    end
endmodule
