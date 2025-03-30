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


module GraphLogic #(
    parameter TOP_LEFT_X_COORD = 120,
    parameter TOP_LEFT_Y_COORD = 40,
    parameter QUADRANT_WIDTH   = 200
)(
    input wire [15:0] x_in,
    input wire [15:0] y_in,
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b
);
    reg signed [31:0] x;
    reg signed [31:0] y;
    
    always @* begin
        x <= (x_in - TOP_LEFT_X_COORD - QUADRANT_WIDTH);
        y <= (QUADRANT_WIDTH - (y_in - TOP_LEFT_Y_COORD));
    end
    
    // Output Logic
    always @(*) begin
        if (y >= x - 2 && y <= x + 2) begin // linear
            r <= 4'hf;
            g <= 4'h0;
            b <= 4'h0;        
        end
        else if ( // (x-5)^2 / 16 == green
            ((y >= (((x - 4) * (x - 4)) >> 4))
             && (y <= (((x - 6) * (x - 6)) >> 4))) ||
            ((y >= (((x - 6) * (x - 6)) >> 4)
             && (y <= (((x - 4) * (x - 4)) >> 4))))
        ) begin
            r <= 4'h0;
            g <= 4'hf;
            b <= 4'h0;
        end
        else if ( //X^2 == blue
            ((y >= (x - 1) * (x - 1)) && (y <= (x + 1) * (x + 1))) ||
            ((y >= (x + 1) * (x + 1)) && (y <= (x - 1) * (x - 1)))
        ) begin
            r <= 4'h0;
            g <= 4'h0;
            b <= 4'hf;
        end
        else if (x == 0 || y == 0) begin // axes
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
