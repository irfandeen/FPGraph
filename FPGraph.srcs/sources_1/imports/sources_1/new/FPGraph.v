`timescale 1ns / 1ps

// FOR USE WITH AN FPGA THAT HAS 12 PINS FOR RGB VALUES, 4 PER COLOR


module FPGraph(
    input wire clk,
    output reg [3:0]   vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0]  vgaBlue,
    output wire Hsync,
    output wire Vsync,
    output reg sanity_led,
    output wire [3:0] an,
    output wire [7:0] seg,
    
    // Mouse IO
    inout PS2Clk,
    inout PS2Data
);
    // Graph boundaries (AFTER SCALING)         // 1080p //480p
    parameter TOP_LEFT_X_COORD  =   10;        //560;   //120;
    parameter TOP_RIGHT_X_COORD =   410;        //1360;  //520;
    parameter TOP_Y_COORD       =   40;         //140;   //40;
    parameter BOTTOM_Y_COORD    =   440;        //940;   //440;
    parameter QUADRANT_WIDTH    = (TOP_RIGHT_X_COORD - TOP_LEFT_X_COORD) / 2;
    
    // Adjust when scaling
                         // 1080p 480p (no scaling)
    parameter X_MUL = 1; // 3     1   // target x resolution / 640
    parameter X_DIV = 1; // 1     1
    parameter Y_MUL = 1; // 9     1   // target y resolution / 480
    parameter Y_DIV = 1; // 4     1

    // VGA Wires
	wire reset, p_tick, p_en;
	wire [9:0]  x_raw, y_raw;
	wire [15:0] x, y;
    
    // Graphing Wires
    wire [3:0]  graph_red, graph_green, graph_blue;
    wire [3:0] sidebar_red, sidebar_green, sidebar_blue;
    
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
    
    assign x = x_raw;
    assign y = y_raw;
    
    wire led_test;
    GraphLogic #(
        .TOP_LEFT_X_COORD(TOP_LEFT_X_COORD),
        .TOP_LEFT_Y_COORD(TOP_Y_COORD),
        .QUADRANT_WIDTH(QUADRANT_WIDTH)
    ) graphing_logic (
        .clk(clk),
        .x_in(x),
        .y_in(y),
        
        // Coefficients MAGNITUDES
        .a_in_1(1), // x^2
        .b_in_1(0),
        .c_in_1(0),
        .a_in_2(1), // -x^2 + 50
        .b_in_2(0),
        .c_in_2(50),
        .a_in_3(0), // x + 25
        .b_in_3(1),
        .c_in_3(25),
        
        // Coefficient SIGNS (1 for positive, 0 for negative)
        .sign_a_1(1),
        .sign_b_1(1),
        .sign_c_1(1),
        .sign_a_2(0), // -x^2
        .sign_b_2(1),
        .sign_c_2(1),
        .sign_a_3(1),
        .sign_b_3(1),
        .sign_c_3(1),        
        
        .r(graph_red),
        .g(graph_green),
        .b(graph_blue),

        .zpos(zpos),
        .cursor_x(cursor_x), .cursor_y(cursor_y),

        .left(left), .middle(middle), .new_event(new_event),
        .led_test(led_test)
    );
    

    // Mouse wires
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire left, middle, right, new_event;
    
    // Mouse block
    MouseCtl mouse_interface (
       .clk(clk),
       .rst(0),
       .xpos(xpos),
       .ypos(ypos),
       .zpos(zpos),
       .left(left),
       .middle(middle),
       .right(right),
       .new_event(new_event),
       .value(0),
       .setx(0),
       .sety(0),
       .setmax_x(0),
       .setmax_y(0),
       .ps2_clk(PS2Clk),
       .ps2_data(PS2Data)
    );
    
    // Cursor Block
    wire [9:0] cursor_x, cursor_y;
    cursor_state cursor (
        .xpos(xpos), .ypos(ypos),
        .xpos_min(TOP_LEFT_X_COORD), .ypos_min(TOP_Y_COORD),
        .xpos_max(TOP_RIGHT_X_COORD), .ypos_max(BOTTOM_Y_COORD), // Bounded to pixel limits of VGA display
        
        .cursor_x(cursor_x), .cursor_y(cursor_y)
    
    );

    SideBar sidebar_display (
        .clk(clk),
        .x(x),
        .y(y),
        .a1(4'd0), .a0(4'd3),
        .b1(4'd0), .b0(4'd2),
        .c1(4'd0), .c0(4'd5),
        .sidebar_red(sidebar_red),
        .sidebar_green(sidebar_green),
        .sidebar_blue(sidebar_blue)
    );

        
    always @ (posedge p_tick) begin
        if (p_en) begin
            sanity_led      <= led_test;
            if (x >= TOP_LEFT_X_COORD   &&          // Is current pixel within graph? 
                x <= TOP_RIGHT_X_COORD  &&
                y >= TOP_Y_COORD        &&
                y <= BOTTOM_Y_COORD) begin
                vgaRed   <= graph_red;
                vgaGreen <= graph_green;
                vgaBlue  <= graph_blue;            
            end
            else if (x >= TOP_LEFT_X_COORD  - 2 && // Is current pixel at graph border?
                     x <= TOP_RIGHT_X_COORD + 2 &&
                     y >= TOP_Y_COORD       - 2 &&
                     y <= BOTTOM_Y_COORD    + 2) begin
                vgaRed   <= 4'hf;
                vgaGreen <= 4'hf;
                vgaBlue  <= 4'hf;            
            end
            else if (x > TOP_RIGHT_X_COORD + 5) begin
                vgaRed   <= sidebar_red;
                vgaGreen <= sidebar_green;
                vgaBlue  <= sidebar_blue;
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