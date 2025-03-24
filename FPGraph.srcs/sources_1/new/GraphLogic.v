`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 21:03:29
// Design Name: 
// Module Name: GraphLogic
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


module GraphLogic(
    input wire [15:0] x_in,
    input wire [15:0] y_in,
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b
);
    reg signed [31:0] x;
    reg signed [31:0] y;
    
    always @* begin
        x <= x_in - 560 - 400;
        y <= 400 - (y_in - 140);
    end
    
    always @(*) begin
        if (y >= x - 2 && y <= x + 2) begin
            r <= 4'h0;
            g <= 4'hf;
            b <= 4'h0;
        end
        else if (y >= (2 * x + 10) - 2 && y <= (2 * x + 10) + 2) begin
            r <= 4'hf;
            g <= 4'h0;
            b <= 4'h0;
        end
        else if (x == 0 || y == 0) begin
            r <= 4'h3;
            g <= 4'h3;
            b <= 4'h3;
        end
        else begin
            r <= 4'h0;
            g <= 4'h0;
            b <= 4'h0;
        end
    end
endmodule
