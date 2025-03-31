`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 19:18:35
// Design Name: 
// Module Name: scroll_state
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


module scroll_state
(
    input clk, reset,
    input signed [3:0] zpos,
    input signed [15:0] min_state,
    input signed [15:0] max_state,
    input overflow, 
    output reg signed [15:0] state = 0 // state initialized as 0
    );
    
    reg signed [3:0] prev_zpos = 0;
    reg z_moved = 0;
    
    always @ (posedge clk or posedge reset) begin
        if (reset) state <= 0;
        
        else if (zpos != prev_zpos && !z_moved) begin
            z_moved = 1;
            if (zpos < prev_zpos) begin // Upscroll, increment state
                state <= (state == max_state) ? 
                (overflow ? min_state : state) : state + 1; 
            end 
            else if (zpos > prev_zpos) begin // Downscroll, decrement state
                state <= (state == min_state) ? 
                (overflow ? max_state : state) : state - 1;
            end
        end
        else if (zpos == 0) begin
             z_moved <= 0; // Reset the movement flag when scroll returns to 0
        end
        prev_zpos <= zpos;
    end
    
    
endmodule
