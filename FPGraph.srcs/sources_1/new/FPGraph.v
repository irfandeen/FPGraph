`timescale 1ns / 1ps

// FOR USE WITH AN FPGA THAT HAS 12 PINS FOR RGB VALUES, 4 PER COLOR


module FPGraph(
    input wire clk,
    input btnC,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    output reg [3:0]   vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0]  vgaBlue,
    output wire Hsync,
    output wire Vsync,
    output reg sanity_led,
    output wire [3:0] an,
    output wire [7:0] seg,
    output [7:0] JB,
    
    // Mouse IO
    inout PS2Clk,
    inout PS2Data
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

    // VGA Wires
	wire reset, p_tick, p_en;
	wire [9:0]  x_raw, y_raw;
	wire [15:0] x, y;
    
    // Graphing Wires
    wire [15:0] graph_x, graph_y;
    wire [3:0]  graph_red, graph_green, graph_blue;
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
        .clk(clk),
        .x_in(x),
        .y_in(y),
        .r(graph_red),
        .g(graph_green),
        .b(graph_blue)
    );
    
    
    
        wire main_reset;
    wire clock_25Mhz;
    wire clock_6_25Mhz;
    wire [12:0] pixel_index;
    wire [7:0] x_cor = pixel_index % 96;
    wire [7:0] y_cor = pixel_index / 96;
    
    // Generate 25 MHz clock for control_screen
    flexible_clock #( .CLK_DIV(3) ) clk_gen_25Mhz (
        .clk_in(clk),
        .clk_out(clock_25Mhz)
    );
    
    // Generate 6.25 MHz clock for oled_driver
    flexible_clock #( .CLK_DIV(7) ) clk_gen_6_25Mhz (
            .clk_in(clk),
            .clk_out(clock_6_25Mhz)
     );
    
    // Declare wires for the outputs
    wire [15:0] colour_out;
    wire [6:0] int_part_A1, int_part_B1, int_part_C1;
    wire [6:0] int_part_A2, int_part_B2, int_part_C2;
    wire [6:0] int_part_A3, int_part_B3, int_part_C3;
    
    wire is_neg_A1, is_neg_B1, is_neg_C1;
    wire is_neg_A2, is_neg_B2, is_neg_C2;
    wire is_neg_A3, is_neg_B3, is_neg_C3;
    
    // Instantiate control_screen
    control_screen u_control_screen (
        .CLOCK(clock_25Mhz),
        .x_cor(x_cor),
        .y_cor(y_cor),
        .pixel_index(pixel_index),
        .btnc(btnC),
        .btnr(btnR),
        .btnl(btnL),
        .btnu(btnU),
        .btnd(btnD),
        .colour_out(colour_out),
        .int_part_A1(int_part_A1), .int_part_B1(int_part_B1), .int_part_C1(int_part_C1),
        .int_part_A2(int_part_A2), .int_part_B2(int_part_B2), .int_part_C2(int_part_C2),
        .int_part_A3(int_part_A3), .int_part_B3(int_part_B3), .int_part_C3(int_part_C3),
        .is_negA1(is_neg_A1), .is_negB1(is_neg_B1), .is_negC1(is_neg_C1),
        .is_negA2(is_neg_A2), .is_negB2(is_neg_B2), .is_negC2(is_neg_C2),
        .is_negA3(is_neg_A3), .is_negB3(is_neg_B3), .is_negC3(is_neg_C3)
    );
    
    Oled_Display oled_driver(
                    .clk(clock_6_25Mhz), 
                    .reset(main_reset), 
                    .frame_begin(), 
                    .sending_pixels(),
                    .sample_pixel(), 
                    .pixel_index(pixel_index), 
                    .pixel_data(colour_out), 
                    .cs(JB[0]), 
                    .sdin(JB[1]), 
                    .sclk(JB[3]), 
                    .d_cn(JB[4]), 
                    .resn(JB[5]), 
                    .vccen(JB[6]),
                    .pmoden(JB[7])
           );
           
    
//    // Wires/regs to connect (you'll need real values or signals for these)
          
          
           
           wire [13:0] r0_c0_int, r0_c0_dec, r0_c1_int, r0_c1_dec;
           wire [13:0] r1_c0_int, r1_c0_dec, r1_c1_int, r1_c1_dec;
           wire [13:0] r2_c0_int, r2_c0_dec, r2_c1_int, r2_c1_dec;
           wire [13:0] r3_c0_int, r3_c0_dec, r3_c1_int, r3_c1_dec;
           wire [13:0] r4_c0_int, r4_c0_dec, r4_c1_int, r4_c1_dec;
           wire [13:0] r5_c0_int, r5_c0_dec, r5_c1_int, r5_c1_dec;
           
           wire r0_c0_s, r0_c1_s;
           wire r1_c0_s, r1_c1_s;
           wire r2_c0_s, r2_c1_s;
           wire r3_c0_s, r3_c1_s;
           wire r4_c0_s, r4_c1_s;
           wire r5_c0_s, r5_c1_s;
           
           wire en_r0, en_r1, en_r2, en_r3, en_r4, en_r5;
           wire [1:0] intercept_state;
           
           wire [3:0] sidebar_red, sidebar_green, sidebar_blue;
           
           SideBar #(
               .BASE_X(430),
               .BASE_Y0(40),
               .BASE_Y1(240),
               .CHAR_WIDTH(8),
               .CHAR_HEIGHT(16)
           ) sidebar_inst (
               .clk(clk),
               .x(x),
               .y(y),
           
               .a1_1(int_part_A1 / 10), .a0_1(int_part_A1 % 10), .b1_1(int_part_B1 / 10), .b0_1(int_part_B1 % 10), .c1_1(int_part_C1 / 10), .c0_1(int_part_C1 % 10),
               .a1_2(int_part_A2 / 10), .a0_2(int_part_A2 % 10), .b1_2(int_part_B2 / 10), .b0_2(int_part_B2 % 10), .c1_2(int_part_C2 / 10), .c0_2(int_part_C2 % 10),
               .a1_3(int_part_A3 / 10), .a0_3(int_part_A3 % 10), .b1_3(int_part_B3 / 10), .b0_3(int_part_B3 % 10), .c1_3(int_part_C3 / 10), .c0_3(int_part_C3 % 10),
           
               .sa_1(is_neg_A1), .sb_1(is_neg_B1), .sc_1(is_neg_C1),
               .sa_2(is_neg_A2), .sb_2(is_neg_B2), .sc_2(is_neg_C1),
               .sa_3(is_neg_A3), .sb_3(is_neg_B3), .sc_3(is_neg_C1),
           
               .r0_c0_int(r0_c0_int), .r0_c0_dec(r0_c0_dec), .r0_c1_int(r0_c1_int), .r0_c1_dec(r0_c1_dec),
               .r1_c0_int(r1_c0_int), .r1_c0_dec(r1_c0_dec), .r1_c1_int(r1_c1_int), .r1_c1_dec(r1_c1_dec),
               .r2_c0_int(r2_c0_int), .r2_c0_dec(r2_c0_dec), .r2_c1_int(r2_c1_int), .r2_c1_dec(r2_c1_dec),
               .r3_c0_int(r3_c0_int), .r3_c0_dec(r3_c0_dec), .r3_c1_int(r3_c1_int), .r3_c1_dec(r3_c1_dec),
               .r4_c0_int(r4_c0_int), .r4_c0_dec(r4_c0_dec), .r4_c1_int(r4_c1_int), .r4_c1_dec(r4_c1_dec),
               .r5_c0_int(r5_c0_int), .r5_c0_dec(r5_c0_dec), .r5_c1_int(r5_c1_int), .r5_c1_dec(r5_c1_dec),
           
               .r0_c0_s(r0_c0_s), .r0_c1_s(r0_c1_s),
               .r1_c0_s(r1_c0_s), .r1_c1_s(r1_c1_s),
               .r2_c0_s(r2_c0_s), .r2_c1_s(r2_c1_s),
               .r3_c0_s(r3_c0_s), .r3_c1_s(r3_c1_s),
               .r4_c0_s(r4_c0_s), .r4_c1_s(r4_c1_s),
               .r5_c0_s(r5_c0_s), .r5_c1_s(r5_c1_s),
           
               .en_r0(en_r0), .en_r1(en_r1), .en_r2(en_r2),
               .en_r3(en_r3), .en_r4(en_r4), .en_r5(en_r5),
           
               .intercept_state(intercept_state),
           
               .sidebar_red(sidebar_red),
               .sidebar_green(sidebar_green),
               .sidebar_blue(sidebar_blue)
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
    
    // Test Code for Scroll State module
    wire signed [15:0] digit;
    scroll_state segstate (
        .clk(clk), .reset(reset),
        .zpos(zpos),
        .min_state(0),
        .max_state(9),
        .overflow(1), 
        .state(digit)
        );
    assign an = 4'b1110;
    assign seg = (digit == 0) ? 8'b1100_0000 :
    (digit == 1) ? 8'b1111_1001 :
    (digit == 2) ? 8'b1010_0100 :
    (digit == 3) ? 8'b1011_0000 :
    (digit == 4) ? 8'b1001_1001 :
    (digit == 5) ? 8'b1001_0010 :
    (digit == 6) ? 8'b1000_0010 :
    (digit == 7) ? 8'b1111_1000 :
    (digit == 8) ? 8'b1000_0000 :
    (digit == 9) ? 8'b1001_0000 : 8'b1111_1111;

endmodule