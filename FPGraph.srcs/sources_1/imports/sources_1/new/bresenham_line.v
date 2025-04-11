`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 22:05:55
// Design Name: 
// Module Name: bresenham_line
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
module bresenham_line #(
    parameter WIDTH = 400
)(
    input wire clk,
    input wire start,
    input wire signed [31:0] x0, y0,
    input wire signed [31:0] x1, y1,

    output reg [17:0] addr,  // BRAM address
    output reg we,            // write enable
    output reg done = 0
);

    // FSM state
    reg active = 0;
    

    // Drawing state
    reg signed [31:0] x, y;
    reg signed [31:0] dx, dy;
    reg signed [31:0] sx, sy;
    reg signed [31:0] err;
    reg signed [31:0] e2;

    always @(posedge clk) begin
        if (start && !active) begin
            // Initialization
            x <= x0;
            y <= y0;
            dx <= (x1 > x0) ? (x1 - x0) : (x0 - x1);
            dy <= (y1 > y0) ? (y1 - y0) : (y0 - y1);
            sx <= (x0 < x1) ? 1 : -1;
            sy <= (y0 < y1) ? 1 : -1;
            err <= ((x1 > x0) ? (x1 - x0) : (x0 - x1)) - ((y1 > y0) ? (y1 - y0) : (y0 - y1));
            e2 <= 0;
            active <= 1;
            we <= 0;
            done <= 0;
        end else if (active && !done) begin
            // Stop condition before stepping
            if (x == x1 && y == y1) begin
                active <= 0;
                done <= 1;
                we <= 0;
            end else begin
                // Calculate address (only if in range)
                if ((x >= -199 && x <= 200) && (y >= -200 && y <= 199)) begin
                    addr <= (y + 200) * WIDTH + (x + 199);
                    we <= 1;
                end else begin
                    we <= 0;
                end

                // Bresenham logic
                
                e2 <= err <<< 1;

                if ((err <<< 1) > -dy) begin
                    err <= err - dy;
                    x <= x + sx;
                end

                if ((err <<< 1) < dx) begin
                    err <= err + dx;
                    y <= y + sy;
                end
            end
        end else begin
            we <= 0;
        end
    end

endmodule
