`timescale 1ns / 1ps

module SideBar #(
    parameter BASE_X = 430,
    parameter BASE_Y0 = 40,
    parameter BASE_Y1 = 240,
    parameter CHAR_WIDTH = 8,
    parameter CHAR_HEIGHT = 16
)(
    input wire clk,
    input wire [15:0] x, y,

    // Coefficients for each equation (6 each, 18 total)
    input wire [4:0] a1_1, a0_1, b1_1, b0_1, c1_1, c0_1,
    input wire [4:0] a1_2, a0_2, b1_2, b0_2, c1_2, c0_2,
    input wire [4:0] a1_3, a0_3, b1_3, b0_3, c1_3, c0_3,
    
    // Sign for each equation (3 each, 9 total)
    input wire sa_1, sb_1, sc_1,
    input wire sa_2, sb_2, sc_2,
    input wire sa_3, sb_3, sc_3,
    

    
    // Integer/Decimal parts for intercept (4 each, 24 total)
    input wire [13:0] r0_c0_int, r0_c0_dec, r0_c1_int, r0_c1_dec, // 0 : e2-e1 
    input wire [13:0] r1_c0_int, r1_c0_dec, r1_c1_int, r1_c1_dec, 
    input wire [13:0] r2_c0_int, r2_c0_dec, r2_c1_int, r2_c1_dec, // 1 : e3-e2
    input wire [13:0] r3_c0_int, r3_c0_dec, r3_c1_int, r3_c1_dec, 
    input wire [13:0] r4_c0_int, r4_c0_dec, r4_c1_int, r4_c1_dec, // 2 : e1-e3
    input wire [13:0] r5_c0_int, r5_c0_dec, r5_c1_int, r5_c1_dec,       
    
    // Signs for intercept (2 each, 12 total)
    input wire r0_c0_s, r0_c1_s,   // 0 : e2-e1 
    input wire r1_c0_s, r1_c1_s,   
    input wire r2_c0_s, r2_c1_s,   // 1 : e3-e2
    input wire r3_c0_s, r3_c1_s,   
    input wire r4_c0_s, r4_c1_s,   // 2 : e1-e3
    input wire r5_c0_s, r5_c1_s,      
    
    // Enable/Disable signal to display intercept
    input wire en_r0,   // 0 : e2-e1 
    input wire en_r1,   
    input wire en_r2,   // 1 : e3-e2
    input wire en_r3,   
    input wire en_r4,   // 2 : e1-e3
    input wire en_r5,  

    // Intercept state 0: GRAPH INTERCEPT, 1: X-INTERCEPT, 2: Y-INTERCEPT, 3: GRAPH-MINMAX
    input wire [1:0] intercept_state,

    output reg [3:0] sidebar_red,
    output reg [3:0] sidebar_green,
    output reg [3:0] sidebar_blue
);

    // For EQUATION, e1, e2, e3
    wire [3:0] r0, g0, b0;
    wire [3:0] r1, g1, b1;
    wire [3:0] r2, g2, b2;
    wire [3:0] r3, g3, b3;

    // For INTECEPT, i1 - i6
    wire [3:0] r4, g4, b4;
    wire [3:0] r5, g5, b5;
    wire [3:0] r6, g6, b6;
    wire [3:0] r7, g7, b7;
    wire [3:0] r8, g8, b8;
    wire [3:0] r9, g9, b9;
    wire [3:0] r10, g10, b10;

    // Display title EQUATION at BASE_Y0
    LineDisplay #(.SHOWN_CHARS(9)) equation (
        .x(x),
        .y(y),
        .base_x(BASE_X),
        .base_y(BASE_Y0),
        .char0(26), .char1(20), .char2(33), .char3(18), .char4(25), .char5(23), .char6(34), .char7(24), .char8(35),
        .r(r0), .g(g0), .b(b0)    
    );

    // Display e1 at BASE_Y0
    EquationDisplay e1 (
        .x(x),
        .y(y),
        .fn(1),
        .base_x(BASE_X),
        .base_y(BASE_Y0 + CHAR_HEIGHT + 2),
        .sa(sa_1), .a1(a1_1), .a0(a0_1),
        .sb(sb_1), .b1(b1_1), .b0(b0_1),
        .sc(sc_1), .c1(c1_1), .c0(c0_1),
        .r(r1), .g(g1), .b(b1)
    );

    // Display e2 below first
    EquationDisplay e2 (
        .x(x),
        .y(y),
        .fn(2),
        .base_x(BASE_X),
        .base_y(BASE_Y0 + 2 * (CHAR_HEIGHT + 2)), // spacing
        .sa(sa_2), .a1(a1_2), .a0(a0_2),
        .sb(sb_2), .b1(b1_2), .b0(b0_2),
        .sc(sc_2), .c1(c1_2), .c0(c0_2),
        .r(r2), .g(g2), .b(b2)
    );

    // Display e3 below second
    EquationDisplay e3 (
        .x(x),
        .y(y),
        .fn(3),
        .base_x(BASE_X),
        .base_y(BASE_Y0 + 3 * (CHAR_HEIGHT + 2)),
        .sa(sa_3), .a1(a1_3), .a0(a0_3),
        .sb(sb_3), .b1(b1_3), .b0(b0_3),
        .sc(sc_3), .c1(c1_3), .c0(c0_3),
        .r(r3), .g(g3), .b(b3)
    );
    
    wire state_1_3 = (intercept_state == 0 || intercept_state == 3);
    wire state_3 = (intercept_state == 3);
    // Display title INTERCEPT at BASE_Y1
    LineDisplay #(.SHOWN_CHARS(15)) intercept (
        .x(x),
        .y(y),
        .base_x(BASE_X),
        .base_y(BASE_Y1),
        .char0(state_1_3 ? 19 : 41), // G : ' '
        .char1(state_1_3 ? 21 : 41), // R : ' '
        .char2(state_1_3 ? 18 : 41), // A : ' '
        .char3(state_1_3 ? 28 : 41), // P : ' '
        .char4(state_1_3 ? 22 : intercept_state == 1 ? 29 : 30),  // H : X : Y
        .char5(state_1_3 ? 41 : 17), // ' ' : - 
        .char6(!state_3 ? 23 : 31), // I : M 
        .char7(!state_3 ? 24 : 23), // N : I 
        .char8(!state_3 ? 25 : 24), // T : N 
        .char9(!state_3 ? 26 : 31), // E : M 
        .char10(!state_3 ? 21 : 18), // R : A 
        .char11(!state_3 ? 36 : 29), // C : X 
        .char12(!state_3 ? 26 : 41), // E : ' '        
        .char13(!state_3 ? 28 : 41), // P : ' '
        .char14(!state_3 ? 25 : 41), // T : ' ' 

        .r(r4), .g(g4), .b(b4)    
    );
    
    // Display i1 at BASE_Y0
    InterceptDisplay i1 (
        .x(x),
        .y(y),
        .intercept_state(intercept_state),
        .fn(1),
        .base_x(BASE_X),
        .base_y(BASE_Y1 + CHAR_HEIGHT + 2),
        .en(1),
        .x_sign(0), .y_sign(1),
        .x_int(000), .x_dec(000), .y_int(0012), .y_dec(949),    
        .r(r5), .g(g5), .b(b5)
    );
    InterceptDisplay i2 (
        .x(x),
        .y(y),
        .intercept_state(intercept_state),
        .fn(0),
        .base_x(BASE_X),
        .base_y(BASE_Y1 + 2 * (CHAR_HEIGHT + 2)),
        .en(en_r1),
        .x_sign(r1_c0_s), .y_sign(r1_c1_s),
        .x_int(r1_c0_int), .x_dec(r1_c0_dec), .y_int(r1_c1_int), .y_dec(r1_c1_dec),    
        .r(r6), .g(g6), .b(b6)
    );
    InterceptDisplay i3 (
        .x(x),
        .y(y),
        .intercept_state(intercept_state),
        .fn(2),
        .base_x(BASE_X),
        .base_y(BASE_Y1 + 3 * (CHAR_HEIGHT + 2)),
        .en(en_r2),
        .x_sign(r2_c0_s), .y_sign(r2_c1_s),
        .x_int(r2_c0_int), .x_dec(r2_c0_dec), .y_int(r2_c1_int), .y_dec(r2_c1_dec),    
        .r(r7), .g(g7), .b(b7)
    );
    InterceptDisplay i4 (
        .x(x),
        .y(y),
        .intercept_state(intercept_state),
        .fn(0),
        .base_x(BASE_X),
        .base_y(BASE_Y1 + 4 * (CHAR_HEIGHT + 2)),
        .en(en_r3),
        .x_sign(r3_c0_s), .y_sign(r3_c1_s),
        .x_int(r3_c0_int), .x_dec(r3_c0_dec), .y_int(r3_c1_int), .y_dec(r3_c1_dec),    
        .r(r8), .g(g8), .b(b8)
    );      
    InterceptDisplay i5 (
        .x(x),
        .y(y),
        .intercept_state(intercept_state),
        .fn(3),
        .base_x(BASE_X),
        .base_y(BASE_Y1 + 5 * (CHAR_HEIGHT + 2)),
        .en(en_r4),
        .x_sign(r4_c0_s), .y_sign(r4_c1_s),
        .x_int(r4_c0_int), .x_dec(r4_c0_dec), .y_int(r4_c1_int), .y_dec(r4_c1_dec),    
        .r(r9), .g(g9), .b(b9)
    );      
    InterceptDisplay i6 (
        .x(x),
        .y(y),
        .intercept_state(intercept_state),
        .fn(0),
        .base_x(BASE_X),
        .base_y(BASE_Y1 + 6 * (CHAR_HEIGHT + 2)),
        .en(en_r5),
        .x_sign(r5_c0_s), .y_sign(r5_c1_s),
        .x_int(r5_c0_int), .x_dec(r5_c0_dec), .y_int(r5_c1_int), .y_dec(r5_c1_dec),    
        .r(r10), .g(g10), .b(b10)
    );
always @(*) begin
        // EQUATION and e1, e2, e3
        if (y >= BASE_Y0 && y < BASE_Y0 + CHAR_HEIGHT &&
            x >= BASE_X && x < BASE_X + CHAR_WIDTH * 21) begin
            sidebar_red = r0; sidebar_green = g0; sidebar_blue = b0;
        end
        else if (y >= BASE_Y0 + CHAR_HEIGHT + 2 &&
                 y < BASE_Y0 + CHAR_HEIGHT + 2 + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 20) begin
            sidebar_red = r1; sidebar_green = g1; sidebar_blue = b1;
        end
        else if (y >= BASE_Y0 + 2 * (CHAR_HEIGHT + 2) &&
                 y < BASE_Y0 + 2 * (CHAR_HEIGHT + 2) + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 20) begin
            sidebar_red = r2; sidebar_green = g2; sidebar_blue = b2;
        end
        else if (y >= BASE_Y0 + 3 * (CHAR_HEIGHT + 2) &&
                 y < BASE_Y0 + 3 * (CHAR_HEIGHT + 2) + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 20) begin
            sidebar_red = r3; sidebar_green = g3; sidebar_blue = b3;
        end
        
        // INTERCEPTS and rows/columns of intercept Integer and Decimal parts
        else if (y >= BASE_Y1 && y < BASE_Y1 + CHAR_HEIGHT &&
            x >= BASE_X && x < BASE_X + CHAR_WIDTH * 21) begin
            sidebar_red = r4; sidebar_green = g4; sidebar_blue = b4;
        end
        else if (y >= BASE_Y1 + CHAR_HEIGHT + 2 &&
                 y < BASE_Y1 + CHAR_HEIGHT + 2 + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 23) begin
            sidebar_red = r5; sidebar_green = g5; sidebar_blue = b5;
        end
        else if (y >= BASE_Y1 + 2 * (CHAR_HEIGHT + 2) &&
                 y < BASE_Y1 + 2 * (CHAR_HEIGHT + 2) + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 23) begin
            sidebar_red = r6; sidebar_green = g6; sidebar_blue = b6;
        end
        else if (y >= BASE_Y1 + 3 * (CHAR_HEIGHT + 2) &&
                 y < BASE_Y1 + 3 * (CHAR_HEIGHT + 2) + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 23) begin
            sidebar_red = r7; sidebar_green = g7; sidebar_blue = b7;
        end    
        else if (y >= BASE_Y1 + 4 * (CHAR_HEIGHT + 2) &&
                 y < BASE_Y1 + 4 * (CHAR_HEIGHT + 2) + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 23) begin
            sidebar_red = r8; sidebar_green = g8; sidebar_blue = b8;
        end  
        else if (y >= BASE_Y1 + 5 * (CHAR_HEIGHT + 2) &&
                 y < BASE_Y1 + 5 * (CHAR_HEIGHT + 2) + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 23) begin
            sidebar_red = r9; sidebar_green = g9; sidebar_blue = b9;
        end  
        else if (y >= BASE_Y1 + 6 * (CHAR_HEIGHT + 2) &&
                 y < BASE_Y1 + 6 * (CHAR_HEIGHT + 2) + CHAR_HEIGHT &&
                 x >= BASE_X && x < BASE_X + CHAR_WIDTH * 23) begin
            sidebar_red = r10; sidebar_green = g10; sidebar_blue = b10;
        end  
        else begin
            sidebar_red = 0;
            sidebar_green = 0;
            sidebar_blue = 0;
        end
    end

endmodule
