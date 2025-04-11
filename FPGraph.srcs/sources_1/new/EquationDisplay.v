`timescale 1ns / 1ps

module EquationDisplay #(
    parameter CHAR_WIDTH = 8,
    parameter CHAR_HEIGHT = 16
)(
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [9:0] base_x,
    input wire [9:0] base_y,
    
    input wire [5:0] fn,
    
    input wire [5:0] a1, a0,    // ax^2
    input wire [5:0] b1, b0,    // bx
    input wire [5:0] c1, c0,    // constant term
    
    input wire sa, sb, sc, // sign of coefficients a, b, c. 0: Positive, 1: Negative
    
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b
);

    // Character layout for: f1: 00x^2 + 00x + 00
    localparam NUMBER_CHARS = 18;
    wire [5:0] char_map [0:NUMBER_CHARS-1];

    assign char_map[ 0] = 6'd14; // 'e'
    assign char_map[ 1] = fn;  // '1'
    assign char_map[ 2] = 6'd13;  // ':'
    assign char_map[ 3] = 6'd40;  // 'y'
    assign char_map[ 4] = 6'd15;  // '='
    assign char_map[ 5] = sa ? 6'd17 : 6'd12; // sa ? '-' : '+'    
    assign char_map[ 6] = a1;
    assign char_map[ 7] = a0;
    assign char_map[ 8] = 6'd10; // 'x'
    assign char_map[ 9] = 6'd11; // '^'
    assign char_map[10] = 6'd16; // superscript 2
    assign char_map[11] = sb ? 6'd17 : 6'd12; // sb ? '-' : '+'  
    assign char_map[12] = b1;
    assign char_map[13] = b0;
    assign char_map[14] = 6'd10; // 'x'
    assign char_map[15] = sa ? 6'd17 : 6'd12; // sc ? '-' : '+'  
    assign char_map[16] = c1;
    assign char_map[17] = c0;
   

    wire [9:0] local_x = x - base_x;
    wire [9:0] local_y = y - base_y;

    wire in_bounds = (local_x < CHAR_WIDTH * NUMBER_CHARS) && (local_y < CHAR_HEIGHT);
    wire [5:0] char_index = local_x / CHAR_WIDTH;
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
            if (char_index <= 2) begin //first 3 characters coloured
                if (fn == 1) begin
                    r = 4'hf; g = 4'h0; b = 4'h0;
                end
                else if (fn == 2) begin
                    r = 4'h0; g = 4'hf; b = 4'h0;
                end
                else if (fn == 3) begin
                    r = 4'h0; g = 4'h0; b = 4'hf;
                end
            end else begin
                r = 4'hf; g = 4'hf; b = 4'hf;
            end
        end else begin
            r = 0; g = 0; b = 0;
        end
    end
endmodule
