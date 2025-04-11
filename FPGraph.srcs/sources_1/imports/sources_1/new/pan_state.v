`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2025 06:50:50
// Design Name: 
// Module Name: pan_state
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


module pan_state #(
    parameter DEFAULT_X_ORIGIN = 210,
    parameter DEFAULT_Y_ORIGIN = 240
    )(
    input [9:0] cursor_x, cursor_y,
    input left, middle, new_event,
    
    output reg [20:0] origin_x = DEFAULT_X_ORIGIN, origin_y = DEFAULT_Y_ORIGIN,
    output reg dir_x = 1, dir_y = 1,
    output reg led_test = 0
    );
    
    reg left_pressed = 0;
    reg [9:0] last_x, last_y;
    
    always @( posedge new_event) begin
        if (middle) begin
            origin_x <= DEFAULT_X_ORIGIN;
            origin_y <= DEFAULT_Y_ORIGIN;
            left_pressed <= 0;
        end
        else if (left && !left_pressed) begin
            left_pressed <= 1;
            last_x <= cursor_x;
            last_y <= cursor_y;
        end
        else if (left && left_pressed) begin
            led_test <= 1;
                // Update origin
            origin_x <= origin_x + (cursor_x - last_x);
            origin_y <= origin_y + (cursor_y - last_y);

            // Update direction
            dir_x <= (origin_x >= 0);
            dir_y <= (origin_y >= 0);

            last_x <= cursor_x;
            last_y <= cursor_y;
            led_test <= 1;            
            
        end
        else begin
            left_pressed <= 0;
            led_test <= 0;
        end
    end
    
    
endmodule
