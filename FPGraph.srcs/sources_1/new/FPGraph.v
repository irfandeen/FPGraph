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
	wire [9:0] x;
	wire [9:0] y;
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
        .x(x),     // pixel count/position of pixel x, max 0-799
        .y(y)      // pixel count/position of pixel y, max 0-524
    );
    
    always @ (posedge p_tick) begin
        if (p_en) begin
            sanity_led      <= 1;
            if (x >= 0 && x < 640 && y >= 0 && y < 480) begin
                if (x >= 186 && x < 453 && y >= 62 && y < 417) begin
                    vgaRed   <= 4'hf;
                    vgaGreen <= 4'h0;
                    vgaBlue  <= 4'h0;                    
                end else begin
                    vgaRed   <= 4'h0;
                    vgaGreen <= 4'hf;
                    vgaBlue  <= 4'h0;
                end
            end
            else begin
                sanity_led      <= 0;
                vgaRed   <= 4'hf;
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