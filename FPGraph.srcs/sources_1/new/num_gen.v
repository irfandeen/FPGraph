`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2025 02:30:59 PM
// Design Name: 
// Module Name: num_gen
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


module num_gen(
    input [4:0] digit_in,
    input add,
    input clear,
    input CLOCK,
    
    input is_neg,
    output [6:0] int_part,
    output [7:0] neg_sign,
    output [7:0] b4,          //these are pos of digits assuming all digits are used
    output [7:0] b3
    );
    
    reg [6:0] int =7'd0;
    parameter [7:0] space = 8'd36;
    parameter [7:0] neg = 8'd39;
    
    always @ (posedge CLOCK) begin
    if (clear) begin
    int <= 0;
    end
    if (add) begin
    
    int <= (int < 7'd10) ? (int * 10 + digit_in) : ((int % 10) * 10 + digit_in);
    end
    end
    
    wire [2:0] int_digits = (int / 10 != 0) ? 3'd2 : 3'd1;
    //wire [2:0] deci_digits = (deci / 10 != 0) ? (2'd2) : ((deci != 0) ? 2'd1 : 2'd0);
    
    assign neg_sign = (is_neg) ? neg : space;
    assign b4 = (int_digits == 1) ? int : int/10;
    assign b3 = (int_digits == 1) ? space : int % 10;
   
    assign int_part = int;
    
endmodule
