`timescale 1ns / 1ps

module EquationDisplay #(
    parameter CHAR_WIDTH = 8,
    parameter CHAR_HEIGHT = 16
)(
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [9:0] base_x,
    input wire [9:0] base_y,

    input wire [4:0] a1, a0,    // ax^2
    input wire [4:0] b1, b0,    // bx
    input wire [4:0] c1, c0,    // constant term

    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b
);

    // Character layout for: f1: 00x^2 + 00x + 00
    wire [4:0] char_map [0:19];

    assign char_map[ 0] = 5'd14; // 'f'
    assign char_map[ 1] = 5'd1;  // '1'
    assign char_map[ 2] = a1;
    assign char_map[ 3] = a0;
    assign char_map[ 4] = 5'd10; // 'x'
    assign char_map[ 5] = 5'd11; // '^'
    assign char_map[ 6] = 5'd16; // superscript 2
    assign char_map[ 7] = 5'd12; // '+'
    assign char_map[ 8] = b1;
    assign char_map[ 9] = b0;
    assign char_map[10] = 5'd10; // 'x'
    assign char_map[11] = 5'd12; // '+'
    assign char_map[12] = c1;
    assign char_map[13] = c0;
    assign char_map[14] = 5'd31;
   

    wire [9:0] local_x = x - base_x;
    wire [9:0] local_y = y - base_y;

    wire in_bounds = (local_x < CHAR_WIDTH * 20) && (local_y < CHAR_HEIGHT);
    wire [4:0] char_index = local_x / CHAR_WIDTH;
    wire [2:0] char_col   = local_x % CHAR_WIDTH;
    wire [3:0] char_row   = local_y;  // ? 4 bits for up to 16 rows

    wire [4:0] char_code = (char_index < 20) ? char_map[char_index] : 5'd31;

    wire char_pixel;
    vga_char_rom font_rom (
        .char_idx(char_code),
        .row(char_row),
        .col(char_col),
        .pixel(char_pixel)
    );

    always @(*) begin
        if (in_bounds && char_pixel) begin
            if (char_index <= 1) begin
                r = 4'hf; g = 4'h0; b = 4'h0;
            end else begin
                r = 4'hf; g = 4'hf; b = 4'hf;
            end
        end else begin
            r = 0; g = 0; b = 0;
        end
    end
endmodule
