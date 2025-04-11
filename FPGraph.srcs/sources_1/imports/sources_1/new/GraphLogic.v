`timescale 1ns / 1ps

module GraphLogic #(
    parameter TOP_LEFT_X_COORD = 10,
    parameter TOP_LEFT_Y_COORD = 10,
    parameter QUADRANT_WIDTH   = 200
)(
    input wire clk,
    input wire [15:0] x_in,
    input wire [15:0] y_in,
    
    // Coefficient MAGNITUDES
    input wire [20:0] a_in_1,
    input wire [20:0] b_in_1,
    input wire [20:0] c_in_1,
    input wire [20:0] a_in_2,
    input wire [20:0] b_in_2,
    input wire [20:0] c_in_2,
    input wire [20:0] a_in_3,
    input wire [20:0] b_in_3,
    input wire [20:0] c_in_3,
    
    // Coefficient Signs
    input wire sign_a_1,
    input wire sign_b_1,
    input wire sign_c_1,
    input wire sign_a_2,
    input wire sign_b_2,
    input wire sign_c_2,
    input wire sign_a_3,
    input wire sign_b_3,
    input wire sign_c_3,
    
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b,

    // Mouse inputs
    input wire signed [3:0] zpos,
    input wire [9:0] cursor_x, cursor_y,
    
    input wire left, middle, new_event,
    output wire led_test
);

    wire [20:0] origin_x, origin_y;
    wire dir_x, dir_y;
    pan_state test_pan (
        .left(left), .middle(middle), .new_event(new_event), 
        .cursor_x(cursor_x), .cursor_y(cursor_y),
        .origin_x(origin_x), .origin_y(origin_y),
        .dir_x(dir_x), .dir_y(dir_y),
        .led_test(led_test)
    );
    
    // (x, y) graph centered signed coordinates
//    wire signed [15:0] x = (x_in - TOP_LEFT_X_COORD - QUADRANT_WIDTH);
//    wire signed [15:0] y = QUADRANT_WIDTH - (y_in - TOP_LEFT_Y_COORD);
    wire signed [20:0] x;
    wire signed [20:0] y;
    assign x = x_in - (dir_x ? origin_x : -origin_x);
    assign y = (dir_y ? origin_y : -origin_y) - y_in;
    
    wire [20:0] magnitude_x;
    wire [20:0] magnitude_y;
    assign magnitude_x = (x >= 0) ? x : -x;
    assign magnitude_y = (y >= 0) ? y : -y;
    
    wire sign_x;
    wire sign_y;
    assign sign_x = (x >= 0) ? 1 : 0;
    assign sign_y = (y >= 0) ? 1 : 0;
    
    wire quad_1_pix;
    wire quad_2_pix;
    wire quad_3_pix;
    
    reg [15:0] zoom = 32; // 1 to 16; 8 is default zoom; Anything lower is zoom in, high is zoom out       
    wire signed [15:0] traceX;
    reg  signed [15:0] last_state = 0;
    
    scroll_state trace_scroll (
        .clk(clk), .reset(0),
        .zpos(zpos),
        .min_state(1),
        .max_state(64),
        .overflow(0), 
        .state(traceX)
    );
   
    
    quadratic quad_1 (
        .x_in(magnitude_x),
        .y_in(magnitude_y),
        .a_in(a_in_1),
        .b_in(b_in_1),
        .c_in(c_in_1),
        .zoom(traceX),
        .sign_x(sign_x),
        .sign_y(sign_y),
        .sign_a(sign_a_1),
        .sign_b(sign_b_1),
        .sign_c(sign_c_1),
        .set_pix(quad_1_pix)
    );
    
    quadratic quad_2 (
        .x_in(magnitude_x),
        .y_in(magnitude_y),
        .a_in(a_in_2),
        .b_in(b_in_2),
        .c_in(c_in_2),
        .zoom(traceX),
        .sign_x(sign_x),
        .sign_y(sign_y),
        .sign_a(sign_a_2),
        .sign_b(sign_b_2),
        .sign_c(sign_c_2),
        .set_pix(quad_2_pix)
    );
    
    quadratic quad_3 (
        .x_in(magnitude_x),
        .y_in(magnitude_y),
        .a_in(a_in_3),
        .b_in(b_in_3),
        .c_in(c_in_3),
        .zoom(traceX),
        .sign_x(sign_x),
        .sign_y(sign_y),
        .sign_a(sign_a_3),
        .sign_b(sign_b_3),
        .sign_c(sign_c_3),
        .set_pix(quad_3_pix)
    );
    
    // === Output RGB ===
    always @(*) begin
        if (   (x_in == cursor_x && y_in == cursor_y)
            || (x_in + 1 == cursor_x && y_in == cursor_y)        
            || (x_in - 1 == cursor_x && y_in == cursor_y)        
            || (x_in == cursor_x && y_in + 1 == cursor_y)        
            || (x_in == cursor_x && y_in - 1 == cursor_y)      
            ) begin
            r <= 4'hf;
            g <= 4'hf;
            b <= 4'hf;  // cursor point
        end
        else if (quad_1_pix && quad_2_pix) begin
            r <= 4'hf;
            g <= 4'hf;
            b <= 4'hf;
        end
        else if (quad_1_pix && quad_3_pix) begin
            r <= 4'hf;
            g <= 4'hf;
            b <= 4'hf;            
        end
        else if (quad_2_pix && quad_3_pix) begin
            r <= 4'hf;
            g <= 4'hf;
            b <= 4'hf;    
        end
        else if (quad_3_pix) begin
            r <= 4'h0;
            g <= 4'h0;
            b <= 4'hf;             
        end
        else if (quad_2_pix) begin
            r <= 4'hf;
            g <= 4'h0;
            b <= 4'h0;        
        end
        else if (quad_1_pix) begin
            r <= 4'h0;
            g <= 4'hf;
            b <= 4'h0;
        end
        else if (x == 0 || y == 0) begin // axes
            r <= 4'hb;
            g <= 4'hb;
            b <= 4'hb;
        end
        else if (x % 25 == 0 || y % 25 == 0) begin
            r <= 4'h2;
            g <= 4'h2;
            b <= 4'h2;
        end
        else begin
            r <= 4'h0;
            g <= 4'h0;
            b <= 4'h0;
        end 
    end
endmodule
