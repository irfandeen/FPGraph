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
	wire reset, p_tick, p_en;
	wire [9:0] x_raw;
	wire [9:0] y_raw;
	wire [15:0] x;
	wire [15:0] y;
	wire [9:0] min_x;
	wire [9:0] min_y;
	wire [9:0] max_x;
	wire [9:0] max_y;
	assign reset = 0;

    VGAControl vga_control (
        .clk_100MHz(clk),   // from FPGA
        .reset(reset),        // system reset
        .video_on(p_en),    // ON while pixel counts for x and y and within display area
        .hsync(Hsync),       // horizontal sync
        .vsync(Vsync),       // vertical sync
        .p_tick(p_tick),      // the 25MHz pixel/second rate signal, pixel tick
        .x(x_raw),     // pixel count/position of pixel x, max 0-799
        .y(y_raw)      // pixel count/position of pixel y, max 0-524
    );
    
    vga_driver driver(
        .x_in(x_raw),
        .y_in(y_raw),
        .x_out(x),
        .y_out(y)
    );
    
    wire [15:0] graph_x;
    wire [15:0] graph_y;
    wire [3:0] graph_red;
    wire [3:0] graph_green;
    wire [3:0] graph_blue;
    
    
    GraphLogic graphing_logic(
        .x_in(x),
        .y_in(y),
        .r(graph_red),
        .g(graph_green),
        .b(graph_blue)
    );
    
    always @ (posedge p_tick) begin
        if (p_en) begin
            sanity_led      <= 1;
            if (x >= 560 && x <= 1360 && y >= 140 && y <= 940) begin
                vgaRed   <= graph_red;
                vgaGreen <= graph_green;
                vgaBlue  <= graph_blue;
            end 
            else if (x >= 555 && x <= 1365 && y >= 135 && y <= 945) begin
                vgaRed   <= 4'hf;
                vgaGreen <= 4'hf;
                vgaBlue  <= 4'hf;                 
            end
            else begin
                vgaRed   <= 4'h0;
                vgaGreen <= 4'h0;
                vgaBlue  <= 4'h0;            
            end
        end 
        else begin
            sanity_led      <= 0;
            vgaRed   <= 4'h0;
            vgaGreen <= 4'h0;
            vgaBlue  <= 4'h0;
        end
    end

endmodule