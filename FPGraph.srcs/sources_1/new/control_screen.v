`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2025 09:55:39 PM
// Design Name: 
// Module Name: control_screen
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


module control_screen(
    input CLOCK,
    input [7:0] x_cor,
    input [7:0] y_cor,
    input [12:0] pixel_index,
    input btnc,
    input btnr,
    input btnl,
    input btnu,
    input btnd,
    output reg [15:0] colour_out,
    output [13:0] int_part_A1, int_part_B1, int_part_C1, int_part_D1,
                      int_part_A2, int_part_B2, int_part_C2, int_part_D2,
                      int_part_A3, int_part_B3, int_part_C3, int_part_D3,
        
        output [6:0]  deci_part_A1, deci_part_B1, deci_part_C1, deci_part_D1,
                      deci_part_A2, deci_part_B2, deci_part_C2, deci_part_D2,
                      deci_part_A3, deci_part_B3, deci_part_C3, deci_part_D3,
        
        output        is_neg_A1, is_neg_B1, is_neg_C1, is_neg_D1,
                      is_neg_A2, is_neg_B2, is_neg_C2, is_neg_D2,
                      is_neg_A3, is_neg_B3, is_neg_C3, is_neg_D3

    );
    
    parameter [7:0] x_incr = 5;
    parameter [7:0] y_incr = 5;
    parameter [7:0] start_x = 3;
    parameter [7:0] start_y = 2;
    parameter [7:0] end_x = 92;
    parameter [7:0] end_y = 61;
    parameter [15:0] white = 16'hFFFF;
    
    reg [15:0] oled_holder;
    
   
  

//18 pixels on x and 12 pixels on y.this is storing row by row
   wire [7:0] screen_chars;  // Stores character codes
   // Declare a 2D wire array to store pixel outputs
   //wire pixel_array [0:11][0:17];
   
   wire [2:0] x;
   wire [2:0] y;
   
   assign x = (x_cor - start_x) % 5;
   assign y = (y_cor - start_y) % 5;
   
   
   
   //scene_controller control_scene (.btnc(btnc), .btnr(btnr), .btnl(btnl), .btnu(btnu), .btnd(btnd), .x_cor(x_cor), .CLOCK(CLOCK), .y_cor(y_cor), .array_out(screen_chars));
  // Instantiate the scene_controller module
   scene_controller u_scene_controller (
       .btnc(btnc),
       .btnr(btnr),
       .btnl(btnl),
       .btnu(btnu),
       .btnd(btnd),
       .CLOCK(CLOCK),
       .x_cor(x_cor),
       .y_cor(y_cor),
       .array_out(screen_chars),
   
       .int_part_A1(int_part_A1), .int_part_B1(int_part_B1), .int_part_C1(int_part_C1), .int_part_D1(int_part_D1),
       .int_part_A2(int_part_A2), .int_part_B2(int_part_B2), .int_part_C2(int_part_C2), .int_part_D2(int_part_D2),
       .int_part_A3(int_part_A3), .int_part_B3(int_part_B3), .int_part_C3(int_part_C3), .int_part_D3(int_part_D3),
   
       .deci_part_A1(deci_part_A1), .deci_part_B1(deci_part_B1), .deci_part_C1(deci_part_C1), .deci_part_D1(deci_part_D1),
       .deci_part_A2(deci_part_A2), .deci_part_B2(deci_part_B2), .deci_part_C2(deci_part_C2), .deci_part_D2(deci_part_D2),
       .deci_part_A3(deci_part_A3), .deci_part_B3(deci_part_B3), .deci_part_C3(deci_part_C3), .deci_part_D3(deci_part_D3),
   
       .is_neg_A1(is_neg_A1), .is_neg_B1(is_neg_B1), .is_neg_C1(is_neg_C1), .is_neg_D1(is_neg_D1),
       .is_neg_A2(is_neg_A2), .is_neg_B2(is_neg_B2), .is_neg_C2(is_neg_C2), .is_neg_D2(is_neg_D2),
       .is_neg_A3(is_neg_A3), .is_neg_B3(is_neg_B3), .is_neg_C3(is_neg_C3), .is_neg_D3(is_neg_D3)
   );
   

               wire pixel_out;
   
              charRom rom (.char(screen_chars), .row(y), .col(x), .pixel(pixel_out));


reg [7:0] x_pos;
reg [7:0] y_pos;
   
   always @(posedge CLOCK) begin
      if (x_cor > end_x || y_cor > end_y || x_cor < start_x || y_cor < start_y) begin
      colour_out <= 16'h0000;
      end else begin
      x_pos = (x_cor - start_x) / 5;
      y_pos = (y_cor - start_y) / 5;
      
      if (pixel_out) begin
      colour_out <= 16'hFFFF;
      end else begin
      colour_out <= 16'h0000;
      end
      
      
      end
      
      
   end
endmodule
