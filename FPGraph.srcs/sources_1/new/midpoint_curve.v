`timescale 1ns / 1ps

module midpoint_curve #(
    parameter WIDTH = 400
)(
    input  wire clk,
    input  wire start,
    input  wire signed [15:0] a,
    input  wire signed [15:0] b,
    input  wire signed [15:0] c,
    output reg  [17:0] addr,  // BRAM address
    output reg  we            // write enable
);

    // FSM State
    localparam INACTIVE = 0;
    localparam CALCULATE_POINT = 1;
    localparam BRES_START = 2;
    localparam BRES_DRAW = 3;
    localparam DONE = 4;
    reg [2:0] state = INACTIVE;
    
    reg signed [31:0] x0, x1;
    reg signed [31:0] y0, y1;
    
    
    // Bresenham module to connect points
    // Drawing state
    reg signed [31:0] bres_x, bres_y;
    reg signed [31:0] dx, dy;
    reg signed [31:0] sx, sy;
    reg signed [31:0] err;
    
    always @(posedge clk) begin
        case (state)
            INACTIVE : begin
                if (start) begin
                    x0 <= -200;
                    x1 <= -200;
                    y0 <= a * (40000) + b * (-200) + c;
                    y1 <= a * (40000) + b * (-200) + c;
                    we <= 0;

                    state <= CALCULATE_POINT;
                end
            end
            
            CALCULATE_POINT : begin
                x0 <= x1;
                x1 <= x1 + 1;
                
                y0 <= y1;
                y1 <= (a * (x1+1) * (x1+1)) + b * (x1+1) + c;
                
                if ((x0 >= -199 && x0 <= 200) &&
                    (y0 >= -199 && y0 <= 200)) begin
                    addr <= ((y0 + 200) * WIDTH) + (x0 + 199);
                    we   <= 1;
                end else begin
                    we <= 0;
                end
                
                if (x0 == 200) begin
                    state <= DONE;
                end else begin
                    state <= BRES_START;
                end
            end
            
            BRES_START : begin
                bres_x <= x0;
                bres_y <= y0;
                dx <= (x1 > x0) ? (x1 - x0) : (x0 - x1);
                dy <= (y1 > y0) ? (y1 - y0) : (y0 - y1);
                sx <= (x0 < x1) ? 1 : -1;
                sy <= (y0 < y1) ? 1 : -1;
                err <= ((x1 > x0) ? (x1 - x0) : (x0 - x1)) - ((y1 > y0) ? (y1 - y0) : (y0 - y1));
                we <= 0;
                state <= BRES_DRAW;
            end
            
            BRES_DRAW: begin
                if (bres_x == x1 && bres_y == y1) begin
                    state <= CALCULATE_POINT;
                    we <= 0;
                end else begin
                    if ((bres_x >= -199 && bres_x <= 200) && (bres_y >= -200 && bres_y <= 199)) begin
                        addr <= (bres_y + 200) * WIDTH + (bres_x + 199);
                        we <= 1;
                    end else begin
                        we <= 0;
                    end
                    
                    if ((err <<< 1) > -dy) begin
                        err = err - dy;
                        bres_x = bres_x + sx;
                    end
    
                    if ((err <<< 1) < dx) begin
                        err = err + dx;
                        bres_y = bres_y + sy;
                    end
                end
            end
            
            DONE:
                we <= 0;
            default:
                we <= 0;
        endcase
    end

endmodule

