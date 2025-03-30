`timescale 1ns / 1ps

// FOR USE WITH AN FPGA THAT HAS 12 PINS FOR RGB VALUES, 4 PER COLOR


module FPGraph(
    input wire clk,
    output reg [3:0]   vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0]  vgaBlue,
    output wire Hsync,
    output wire Vsync,
    output reg sanity_led
);
    // Graph boundaries (AFTER SCALING)         // 1080p //480p
    parameter TOP_LEFT_X_COORD  =   120;        //560;   //120;
    parameter TOP_RIGHT_X_COORD =   520;        //1360;  //520;
    parameter TOP_Y_COORD       =   40;         //140;   //40;
    parameter BOTTOM_Y_COORD    =   440;        //940;   //440;
    parameter QUADRANT_WIDTH    = (TOP_RIGHT_X_COORD - TOP_LEFT_X_COORD) / 2;
    
    // Adjust when scaling
                         // 1080p 480p (no scaling)
    parameter X_MUL = 1; // 3     1   // target x resolution / 640
    parameter X_DIV = 1; // 1     1
    parameter Y_MUL = 1; // 9     1   // target y resolution / 480
    parameter Y_DIV = 1; // 4     1

	wire reset, p_tick, p_en;
	wire [9:0]  x_raw;
	wire [9:0]  y_raw;
	wire [15:0] x;
    wire [15:0] y;
    
    wire [15:0] graph_x;
    wire [15:0] graph_y;
    wire [3:0]  graph_red;
    wire [3:0]  graph_green;
    wire [3:0]  graph_blue;
  
	assign reset = 0;

    VGAControl vga_control (
        .clk_100MHz(clk),     // from FPGA
        .reset(reset),        // system reset
        .video_on(p_en),      // ON while pixel counts for x and y and within display area
        .hsync(Hsync),        // horizontal sync
        .vsync(Vsync),        // vertical sync
        .p_tick(p_tick),      // the 25MHz pixel/second rate signal, pixel tick
        .x(x_raw),            // pixel count/position of pixel x, max 0-799
        .y(y_raw)             // pixel count/position of pixel y, max 0-524
    );
    
    
    vga_driver #(
        .X_MUL(X_MUL),
        .X_DIV(X_DIV),
        .Y_MUL(Y_MUL),
        .Y_DIV(Y_DIV)
    ) driver (
        .x_in(x_raw),
        .y_in(y_raw),
        .x_out(x),
        .y_out(y)
    );
 
    
    GraphLogic #(
        .TOP_LEFT_X_COORD(TOP_LEFT_X_COORD),
        .TOP_LEFT_Y_COORD(TOP_Y_COORD),
        .QUADRANT_WIDTH(QUADRANT_WIDTH)
    ) graphing_logic (
        .x_in(x),
        .y_in(y),
        .r(graph_red),
        .g(graph_green),
        .b(graph_blue)
    );
    
    always @ (posedge p_tick) begin
        if (p_en) begin
            sanity_led      <= 1;
            if (x >= TOP_LEFT_X_COORD   &&          // Is current pixel within graph? 
                x <= TOP_RIGHT_X_COORD  &&
                y >= TOP_Y_COORD        &&
                y <= BOTTOM_Y_COORD) begin
                vgaRed   <= graph_red;
                vgaGreen <= graph_green;
                vgaBlue  <= graph_blue;            
            end
            else if (x >= TOP_LEFT_X_COORD  - 5 && // Is current pixel at graph border?
                     x <= TOP_RIGHT_X_COORD + 5 &&
                     y >= TOP_Y_COORD       - 5 &&
                     y <= BOTTOM_Y_COORD    + 5) begin
                vgaRed   <= 4'hf;
                vgaGreen <= 4'hf;
                vgaBlue  <= 4'hf;            
            end
            else begin                                // Background is black
                vgaRed   <= 4'h0;
                vgaGreen <= 4'h0;
                vgaBlue  <= 4'h0;
            end
        end
        else begin                                   // When at front/back porch or retrace = BLACK
            sanity_led <= 0;
            vgaRed     <= 4'h0;
            vgaGreen   <= 4'h0;
            vgaBlue    <= 4'h0;
        end
    end

endmodule