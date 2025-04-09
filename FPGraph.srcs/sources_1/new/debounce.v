`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2025 02:34:51
// Design Name: 
// Module Name: debounce
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


module debounce(
    input wire signal_in,
    input wire clk_in,
    output reg signal_out
);
    parameter TIME_OUT = 1000;

    reg [31:0]  counter = 0;
    reg        time_out = 0;
    
    always @ (posedge clk_in) begin
        if (time_out == 1) begin
            if (counter + 1 == TIME_OUT) begin
                time_out   <= 0;
                counter    <= 0;
                signal_out <= 0;
            end
            else begin
                counter <= counter + 1;
            end
        end
        else begin
            if (signal_in == 1) begin
                counter    <= 0;
                signal_out <= 1;
                time_out   <= 1;
            end
            else begin
                signal_out <= 0;
            end
        end
    end
endmodule
