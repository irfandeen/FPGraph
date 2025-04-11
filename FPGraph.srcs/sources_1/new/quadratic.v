`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 02:35:20 PM
// Design Name: 
// Module Name: quadratic
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


module quadratic(
    input wire [20:0] x_in,
    input wire [20:0] y_in,
    input wire [20:0] a_in,
    input wire [20:0] b_in,
    input wire [20:0] c_in,
    input wire [20:0] zoom,
    
    input wire   sign_x,
    input wire   sign_y,
    input wire   sign_a,
    input wire   sign_b,
    input wire   sign_c,
    
    output reg  set_pix = 0
);
    
    wire signed [20:0] x;
    wire signed [20:0] y;
    wire signed [20:0] a;
    wire signed [20:0] b;
    wire signed [20:0] c;
    wire signed [20:0] z;
    
    assign x = sign_x ? x_in : -x_in;
    assign y = sign_y ? y_in : -y_in;
    
    assign a = sign_a ? a_in : -a_in;
    assign b = sign_b ? b_in : -b_in;
    assign c = sign_c ? c_in : -c_in;
    assign z = zoom;
    
    always @(*) begin
        if ((  
               (y >= ( (((((x + 1))  * (a * (x + 1)))*z)>>>5)  + (b * (x + 1))  + ((c<<<5)/z))  && 
               (y <= ( (((((x - 1))  * (a * (x - 1)))*z)>>>5)  + (b * (x - 1))  + ((c<<<5)/z))))
             ||
              (
               (y <= ((((((x + 1))  * (a * (x + 1))))*z)>>>5) +   (b * (x + 1))  + (c<<<5)/z) &&
               (y >= ((((((x - 1))  * (a * (x - 1))))*z)>>>5) +   (b * (x - 1))  + (c<<<5)/z)
              )
            )
             //||
             //(y == (((a * x * x)>>>5)*z) + b * x + ((c<<<5)/z))
        ) begin         
            set_pix <= 1;
        end
        else begin
            set_pix <= 0;
        end
    end
endmodule

// Safe Copy
/*

    always @(*) begin
        if ((  
               (y >= ( ((a * (x + 1))  * (a * (x + 1)))  + (b * (x + 1))  + c)  && 
               (y <= ( ((a * (x - 1))  * (a * (x - 1)))  + (b * (x - 1))  + c)))
             ||
              (
               (y <= (((a * (x + 1))  * (a * (x + 1)))) + (b * (x + 1))  + c) &&
               (y >= (((a * (x - 1)) *  (a * (x - 1))))+   (b * (x - 1)) + c)
              )
            )
             ||
             (y == a * x * x + b * x + c)
        ) begin         
            set_pix <= 1;
        end
        else begin
            set_pix <= 0;
        end
    end
*/
