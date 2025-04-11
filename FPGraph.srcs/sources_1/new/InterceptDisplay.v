`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2025 00:31:27
// Design Name: 
// Module Name: InterceptDisplay
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


module InterceptDisplay #(
    parameter CHAR_WIDTH = 8,
    parameter CHAR_HEIGHT = 16
)(

    input wire [9:0] x,
    input wire [9:0] y,
    input wire [9:0] base_x,
    input wire [9:0] base_y,
    
    input wire en,
    input wire [1:0] intercept_state,
    input wire [1:0] fn,
    input wire x_sign, y_sign,
    input wire [14:0] x_int, x_dec, y_int, y_dec,    
    
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b
);
    
    wire [3:0] x_hundreds, x_tens, x_ones, x_tenths, x_hundredths;
    FloatingPointRound roundx (    
    .int(x_int),  .dec(x_dec), 
    .int_hundreds(x_hundreds), .int_tens(x_tens), .int_ones(x_ones),
    .dec_tenths(x_tenths), .dec_hundredths(x_hundredths)
    );
    
    wire [3:0] y_hundreds, y_tens, y_ones, y_tenths, y_hundredths;
    FloatingPointRound roundy (    
    .int(y_int),  .dec(y_dec), 
    .int_hundreds(y_hundreds), .int_tens(y_tens), .int_ones(y_ones),
    .dec_tenths(y_tenths), .dec_hundredths(y_hundredths)
    );

    // Character layout for: f1: 00x^2 + 00x + 00
    localparam NUMBER_CHARS = 23;
    wire [5:0] char_map [0:NUMBER_CHARS-1];
    
    wire display_label = (fn > 0);
    wire display_other = (intercept_state == 0) && display_label;
    // Characters for label e.g. e2-e1: or    e1: 
    assign char_map[ 0] = (display_other ? 14 : 41); // e : ' '
    assign char_map[ 1] = (display_other ? ((fn + 1) % 3) : 41);  // fn + 1 % 3 : ' '
    assign char_map[ 2] = (display_other ? 17 : 41);  // - : ' '
    assign char_map[ 3] = (display_label ? 14 : 41);  // e : ' '
    assign char_map[ 4] = (display_label ? fn : 41); // fn : ' '
    assign char_map[ 5] = (display_label ? 13 : 41); // ':' : ' ' 
    
//    // Characters for coordinates (+123.45,-678.90) 
    assign char_map[ 6] = (en ? 36 : (intercept_state == 0 ? 17 : 41)); // ( : -
    assign char_map[ 7] = (en ? (x_sign ? 17 : 12): 41); // - : +
    assign char_map[ 8] = (en ? x_hundreds : 41);
    assign char_map[ 9] = (en ? x_tens : 41);
    assign char_map[10] = (en ? x_ones : 41 );
    assign char_map[11] = (en ? 39 : 41); // .
    assign char_map[12] = (en ? x_tenths : 41); 
    assign char_map[13] = (en ? x_hundredths : 41);
    assign char_map[14] = (en ? 38 : 41); // ,
    assign char_map[15] = (en ? (y_sign ? 17 : 12): 41); // 'x'
    assign char_map[16] = (en ? y_hundreds : 41);
    assign char_map[17] = (en ? y_tens : 41);
    assign char_map[18] = (en ? y_ones : 41);
    assign char_map[19] = (en ? 39 : 41);
    assign char_map[20] = (en ? y_tenths : 41);
    assign char_map[21] = (en ? y_hundredths : 41);
    assign char_map[22] = (en ? 37 : 41);
   

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
            if (char_index <= 1 && display_other) begin //first 2 characters coloured
                if (fn == 1) begin // e2-e1
                    r = 4'h0; g = 4'hf; b = 4'h0;
                end
                else if (fn == 2) begin // e3-e1
                    r = 4'h0; g = 4'h0; b = 4'hf;
                end
                else if (fn == 3) begin // e1-e3
                    r = 4'hf; g = 4'h0; b = 4'h0;
                end
            end 
            else if (char_index >= 3 && char_index <= 4 && display_label) begin
                if (fn == 1) begin // e2-e1
                    r = 4'hf; g = 4'h0; b = 4'h0;
                end
                else if (fn == 2) begin // e3-e1
                    r = 4'h0; g = 4'hf; b = 4'h0;
                end
                else if (fn == 3) begin // e1-e3
                    r = 4'h0; g = 4'h0; b = 4'hf;
                end            
            end
            else begin
                r = 4'hf; g = 4'hf; b = 4'hf;
            end
        end else begin
            r = 0; g = 0; b = 0;
        end
    end
endmodule
