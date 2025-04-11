`timescale 1ns / 1ps

module SideBar #(
    parameter BASE_X = 527,
    parameter BASE_Y = 60,
    parameter CHAR_WIDTH = 8,
    parameter CHAR_HEIGHT = 16
)(
    input wire clk,
    input wire [15:0] x, y,

    input wire [3:0] a1, a0,
    input wire [3:0] b1, b0,
    input wire [3:0] c1, c0,

    output reg [3:0] sidebar_red,
    output reg [3:0] sidebar_green,
    output reg [3:0] sidebar_blue
);

    wire [3:0] text_red, text_green, text_blue;

    EquationDisplay function1display (
        .x(x),
        .y(y),
        .base_x(BASE_X),
        .base_y(BASE_Y),
        .a1(a1), .a0(a0),
        .b1(b1), .b0(b0),
        .c1(c1), .c0(c0),
        .r(text_red),
        .g(text_green),
        .b(text_blue)
    );

    always @(*) begin
        if (x >= BASE_X && x < BASE_X + CHAR_WIDTH * 20 &&
            y >= BASE_Y && y < BASE_Y + CHAR_HEIGHT) begin
            sidebar_red   = text_red;
            sidebar_green = text_green;
            sidebar_blue  = text_blue;
        end else begin
            sidebar_red   = 0;
            sidebar_green = 0;
            sidebar_blue  = 0;
        end
    end
endmodule
