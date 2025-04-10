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
    input is_deci,
    input is_neg,
    output [13:0] int_part,
    output [6:0] deci_part,
    output [7:0] neg_sign,
    output [7:0] b4,          //these are pos of digits assuming all digits are used
    output [7:0] b3,
    output [7:0] b2,
    output [7:0] b1,
    output [7:0] b0,          //deci_point if all digits used
    output [7:0] b_1,
    output [7:0] b_2
    );
    
    reg [13:0] int =14'd0;
    reg [3:0] deci_2 = 4'd0;
    reg [3:0] deci_1 = 4'd0;
    reg [3:0] deci_digits = 4'd0;
    parameter [7:0] dot = 8'd44;
    parameter [7:0] space = 8'd36;
    parameter [7:0] neg = 8'd39;
    
    always @ (posedge CLOCK) begin
    if (clear) begin
    int <= 0;
    deci_2 <= 0;
    deci_1 <= 0;
    deci_digits <= 0;
    end else if (add) begin
    if (is_deci) begin
    deci_digits <= (deci_digits < 2) ? deci_digits + 1 : deci_digits;
    case(deci_digits)
    0:begin
    deci_2 <= digit_in;
    end
    1:begin
    deci_1 <= digit_in;
    end
    2:begin
    deci_2 <= deci_1;
    deci_1 <= digit_in;
    end
    default:;
    endcase
    end else begin
    int <= (int < 14'd1000) ? (int * 10 + digit_in) : ((int % 1000) * 10 + digit_in);
    end
    
    end
    end
    
    wire [2:0] int_digits = (int / 1000 != 0) ? (3'd4) : ((int / 100 != 0) ? 3'd3 : (int / 10 != 0) ? 3'd2 : 3'd1);
    //wire [2:0] deci_digits = (deci / 10 != 0) ? (2'd2) : ((deci != 0) ? 2'd1 : 2'd0);
    
    assign neg_sign = (is_neg) ? neg : space;
    assign b4 = (int_digits == 4) ? (int / 1000) :
                ((int_digits == 3) ? (int / 100) : 
                ((int_digits == 2) ? int / 10 : 
                 int));
    assign b3 = (int_digits == 4) ? ((int % 1000) / 100) :
                ((int_digits == 3) ? ((int % 100) / 10) :
                ((int_digits == 2) ? int % 10 :
                (deci_digits == 0) ? space :
                dot));
    assign b2 = (int_digits == 4) ? ((int % 100) / 10) :
                (int_digits == 3) ? (int % 10) :
                (int_digits == 2) ? ((deci_digits == 0) ? space : dot) :
                (deci_digits == 0) ? (space) : deci_2;
    assign b1 = (int_digits == 4) ? (int % 10) :
                (int_digits == 3) ? ((deci_digits == 0) ? space : dot) :
                (int_digits == 2) ? ((deci_digits == 0) ? space : deci_2) :
                (deci_digits == 0) ? space : deci_1;
    assign b0 = (int_digits == 4) ? ((deci_digits == 0) ? space : dot) :
                (int_digits == 3) ? ((deci_digits == 0) ? space : deci_2) : 
                (int_digits == 2) ? ((deci_digits != 0) ? deci_1 : space) :
                space;
    assign b_1 = (int_digits == 4) ? ((deci_digits == 0) ? space : deci_2) : 
                (int_digits == 3) ? ((deci_digits == 0) ? space : deci_1) : space;
    assign b_2 = (int_digits == 4 && deci_digits != 0) ? deci_1 :
                 space;
    assign int_part = int;
    assign deci_part = deci_2 * 10 + deci_1;
endmodule
