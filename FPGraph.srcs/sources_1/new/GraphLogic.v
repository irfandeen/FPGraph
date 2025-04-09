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
    input wire clk,
    input wire [15:0] x_in,
    input wire [15:0] y_in,
    input wire [15:0] origin_x,
    input wire [15:0] origin_y,
    input wire        dir_x,
    input wire        dir_y,
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b
);
    // (x, y) graph centered signed coordinates
    wire signed [15:0] x = x_in - (dir_x ? origin_x : -origin_x);
    wire signed [15:0] y = (dir_y ? origin_y : -origin_y) - y_in;

    /*
    // framebuffer memory
    wire [17:0] read_addr = ((y + 200) * 400 + (x + 200));
    wire read_data;
    reg [17:0] read_addr_reg;
    wire [17:0] write_addr;
    wire write_en;
 
    always @(posedge clk)
        read_addr_reg <= read_addr;
 
     // write data is always 1 for active pixels
    coord_mem bram (
        .clka(clk),
        .ena(1'b1),
        .wea(write_en),
        .addra(write_addr),
        .dina(1'b1),

        .clkb(clk),
        .enb(1'b1),
        .addrb(read_addr_reg),
        .doutb(read_data)
    );   
    
    // === Bresenham Line Drawing ===
    bresenham_line #(.WIDTH(400)) draw_line (
        .clk(clk),
        .start(1),
        .x0(-200), .y0(-200*-20), // testing for y = -20x
        .x1(200),  .y1(200*-20),
        .addr(write_addr),
        .we(write_en)
    );
    
    
    // === Output RGB ===
    always @(*) begin
        if (x >= -200 && x <= 200 && y >= -200 && y <= 200 && read_data) begin
            r <= 4'hf; g <= 4'h0; b <= 4'h0;  // red line
        end else if (x == 0 || y == 0) begin
            r <= 4'h3; g <= 4'h3; b <= 4'h3;  // axis
        end else begin
            r <= 4'h0; g <= 4'h0; b <= 4'h0;  // background
        end
    end */
    
    
    
    
    //Output Logic
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
