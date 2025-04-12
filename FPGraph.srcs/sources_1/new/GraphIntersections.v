`timescale 1ns/1ps

module GraphIntersections(
    input               basysClock,
    input [15:0]        sw,
    
    // Graph Equation Inputs
    input               a1Sign,
    input       [13:0]  a1Integer,
    input               b1Sign,
    input       [13:0]  b1Integer,
    input               c1Sign,
    input       [13:0]  c1Integer,
    
    input               a2Sign,
    input       [13:0]  a2Integer,
    input               b2Sign,
    input       [13:0]  b2Integer,
    input               c2Sign,
    input       [13:0]  c2Integer,
    
    input               a3Sign,
    input       [13:0]  a3Integer,
    input               b3Sign,
    input       [13:0]  b3Integer,
    input               c3Sign,
    input       [13:0]  c3Integer,
    
    // Common output interface (example signal names)
    //Pair 0 - Outputs------------------------------
    output reg          p0_x_sign,
    output reg [13:0]   p0_x_int,
    output reg [13:0]   p0_x_dec,
    
    output reg          p0_y_sign,
    output reg [13:0]   p0_y_int,
    output reg [13:0]   p0_y_dec,
 
    output reg          p0_en,
    //-----------------------------------------------
    
    //Pair 1 - Outputs-------------------------------
    output reg          p1_x_sign,
    output reg [13:0]   p1_x_int,
    output reg [13:0]   p1_x_dec,
    
    output reg          p1_y_sign,
    output reg [13:0]   p1_y_int,
    output reg [13:0]   p1_y_dec,
    
    output reg          p1_en,
    //-----------------------------------------------
    
    //Pair 2 - Outputs-------------------------------
    output reg          p2_x_sign,
    output reg [13:0]   p2_x_int,
    output reg [13:0]   p2_x_dec,
    
    output reg          p2_y_sign,
    output reg [13:0]   p2_y_int,
    output reg [13:0]   p2_y_dec,
    
    output reg          p2_en,
    //-----------------------------------------------
    
    //Pair 3 - Outputs-------------------------------
    output reg          p3_x_sign,
    output reg [13:0]   p3_x_int,
    output reg [13:0]   p3_x_dec,
    
    output reg          p3_y_sign,
    output reg [13:0]   p3_y_int,
    output reg [13:0]   p3_y_dec,
    
    output reg          p3_en,
    //-----------------------------------------------
    
    //Pair 4 - Outputs-------------------------------
    output reg          p4_x_sign,
    output reg [13:0]   p4_x_int,
    output reg [13:0]   p4_x_dec,
    
    output reg          p4_y_sign,
    output reg [13:0]   p4_y_int,
    output reg [13:0]   p4_y_dec,
    
    output reg          p4_en,
    //-----------------------------------------------
    
    //Pair 5 - Outputs-------------------------------
    output reg          p5_x_sign,
    output reg [13:0]   p5_x_int,
    output reg [13:0]   p5_x_dec,
    
    output reg          p5_y_sign,
    output reg [13:0]   p5_y_int,
    output reg [13:0]   p5_y_dec,
    
    output reg          p5_en
    //-----------------------------------------------
);

reg startCalculate = 0;

// Instantiate the LineIntercepts module and its respective wires--------------------------------

// Wires for LineIntercepts outputs (Graph 1 & 2 outputs)
wire        g1g2_X1Sign;
wire [13:0] g1g2_X1Int,  g1g2_X1Dec;
wire        g1g2_Y1Sign;
wire [13:0] g1g2_Y1Int,  g1g2_Y1Dec;
wire        g1g2_X2Sign;
wire [13:0] g1g2_X2Int,  g1g2_X2Dec;
wire        g1g2_Y2Sign;
wire [13:0] g1g2_Y2Int,  g1g2_Y2Dec;
wire [1:0]  g1g2_isCalculated;

// Wires for LineIntercepts outputs (Graph 1 & 3 outputs)
wire        g1g3_X1Sign;
wire [13:0] g1g3_X1Int,  g1g3_X1Dec;
wire        g1g3_Y1Sign;
wire [13:0] g1g3_Y1Int,  g1g3_Y1Dec;
wire        g1g3_X2Sign;
wire [13:0] g1g3_X2Int,  g1g3_X2Dec;
wire        g1g3_Y2Sign;
wire [13:0] g1g3_Y2Int,  g1g3_Y2Dec;
wire [1:0]  g1g3_isCalculated;

// Wires for LineIntercepts outputs (Graph 2 & 3 outputs)
wire        g2g3_X1Sign;
wire [13:0] g2g3_X1Int,  g2g3_X1Dec;
wire        g2g3_Y1Sign;
wire [13:0] g2g3_Y1Int,  g2g3_Y1Dec;
wire        g2g3_X2Sign;
wire [13:0] g2g3_X2Int,  g2g3_X2Dec;
wire        g2g3_Y2Sign;
wire [13:0] g2g3_Y2Int,  g2g3_Y2Dec;
wire [1:0]  g2g3_isCalculated;

wire mode;
assign mode = sw[GRAPH_INTERCEPT] == 1 ? 0 : 1;

LineIntercepts lineIntercepts (
    .basysClock(basysClock),
    .startCalculate(startCalculate),
    .mode(mode),
    .a1Sign(a1Sign),
    .a1Integer(a1Integer),
    .b1Sign(b1Sign),
    .b1Integer(b1Integer),
    .c1Sign(c1Sign),
    .c1Integer(c1Integer),
    .a2Sign(a2Sign),
    .a2Integer(a2Integer),
    .b2Sign(b2Sign),
    .b2Integer(b2Integer),
    .c2Sign(c2Sign),
    .c2Integer(c2Integer),
    .a3Sign(a3Sign),
    .a3Integer(a3Integer),
    .b3Sign(b3Sign),
    .b3Integer(b3Integer),
    .c3Sign(c3Sign),
    .c3Integer(c3Integer),
    
    .g1g2_X1Sign(g1g2_X1Sign),
    .g1g2_X1Int(g1g2_X1Int),
    .g1g2_X1Dec(g1g2_X1Dec),
    .g1g2_Y1Sign(g1g2_Y1Sign),
    .g1g2_Y1Int(g1g2_Y1Int),
    .g1g2_Y1Dec(g1g2_Y1Dec),
    .g1g2_X2Sign(g1g2_X2Sign),
    .g1g2_X2Int(g1g2_X2Int),
    .g1g2_X2Dec(g1g2_X2Dec),
    .g1g2_Y2Sign(g1g2_Y2Sign),
    .g1g2_Y2Int(g1g2_Y2Int),
    .g1g2_Y2Dec(g1g2_Y2Dec),
    .g1g2_isCalculated(g1g2_isCalculated),
    
    .g1g3_X1Sign(g1g3_X1Sign),
    .g1g3_X1Int(g1g3_X1Int),
    .g1g3_X1Dec(g1g3_X1Dec),
    .g1g3_Y1Sign(g1g3_Y1Sign),
    .g1g3_Y1Int(g1g3_Y1Int),
    .g1g3_Y1Dec(g1g3_Y1Dec),
    .g1g3_X2Sign(g1g3_X2Sign),
    .g1g3_X2Int(g1g3_X2Int),
    .g1g3_X2Dec(g1g3_X2Dec),
    .g1g3_Y2Sign(g1g3_Y2Sign),
    .g1g3_Y2Int(g1g3_Y2Int),
    .g1g3_Y2Dec(g1g3_Y2Dec),
    .g1g3_isCalculated(g1g3_isCalculated),
    
    .g2g3_X1Sign(g2g3_X1Sign),
    .g2g3_X1Int(g2g3_X1Int),
    .g2g3_X1Dec(g2g3_X1Dec),
    .g2g3_Y1Sign(g2g3_Y1Sign),
    .g2g3_Y1Int(g2g3_Y1Int),
    .g2g3_Y1Dec(g2g3_Y1Dec),
    .g2g3_X2Sign(g2g3_X2Sign),
    .g2g3_X2Int(g2g3_X2Int),
    .g2g3_X2Dec(g2g3_X2Dec),
    .g2g3_Y2Sign(g2g3_Y2Sign),
    .g2g3_Y2Int(g2g3_Y2Int),
    .g2g3_Y2Dec(g2g3_Y2Dec),
    .g2g3_isCalculated(g2g3_isCalculated)
);

//------------ACTUAL LOGIC HERE ONWARDS------------------
localparam GRAPH_INTERCEPT = 0;
localparam X_INTERCEPT     = 1;
localparam Y_INTERCEPT     = 2;
localparam NOT_CALCULATED  = 0, CALCULATED = 1, NO_SOLUTION = 2;
localparam ADD = 0, SUB = 1, MUL = 2, DIV = 3;
localparam POS = 0, NEG = 1;

wire clk10Khz;
flexible_clock #(.CLK_DIV(5000)) clk_gen (
    .clk_in(basysClock),
    .clk_out(clk10Khz)
);

always @(posedge clk10Khz) begin
    if (sw[GRAPH_INTERCEPT] == 0 && sw[X_INTERCEPT] == 0 && sw[Y_INTERCEPT] == 0) begin
        startCalculate <= 0;
        p0_en <= 0;
        p1_en <= 0;
        p2_en <= 0;
        p3_en <= 0;
        p4_en <= 0;
        p5_en <= 0;
    end else if (sw[GRAPH_INTERCEPT] == 1) begin
        startCalculate <= 1;
        
        if (g1g2_isCalculated == CALCULATED && startCalculate == 1) begin
            p0_x_sign <= g1g2_X1Sign;
            p0_x_int  <= g1g2_X1Int;
            p0_x_dec  <= g1g2_X1Dec;
            
            p0_y_sign <= g1g2_Y1Sign;
            p0_y_int  <= g1g2_Y1Int;
            p0_y_dec  <= g1g2_Y1Dec;
            
            p1_x_sign <= g1g2_X2Sign;
            p1_x_int  <= g1g2_X2Int;
            p1_x_dec  <= g1g2_X2Dec;
            
            p1_y_sign <= g1g2_Y2Sign;
            p1_y_int  <= g1g2_Y2Int;
            p1_y_dec  <= g1g2_Y2Dec;
            
            p0_en <= 1;
            p1_en <= 1;
        end else if (g1g2_isCalculated == NO_SOLUTION && startCalculate == 1) begin
            p0_en <= 0;
            p1_en <= 0;
        end
        
        if (g2g3_isCalculated == CALCULATED && startCalculate == 1) begin
            p2_x_sign <= g2g3_X1Sign;
            p2_x_int  <= g2g3_X1Int;
            p2_x_dec  <= g2g3_X1Dec;
            
            p2_y_sign <= g2g3_Y1Sign;
            p2_y_int  <= g2g3_Y1Int;
            p2_y_dec  <= g2g3_Y1Dec;
            
            p3_x_sign <= g2g3_X2Sign;
            p3_x_int  <= g2g3_X2Int;
            p3_x_dec  <= g2g3_X2Dec;
            
            p3_y_sign <= g2g3_Y2Sign;
            p3_y_int  <= g2g3_Y2Int;
            p3_y_dec  <= g2g3_Y2Dec;
            
            p2_en <= 1;
            p3_en <= 1;
        end else if (g2g3_isCalculated == NO_SOLUTION && startCalculate == 1) begin
            p2_en <= 0;
            p3_en <= 0;
        end
        
        if (g1g3_isCalculated == CALCULATED && startCalculate == 1) begin
            p4_x_sign <= g1g3_X1Sign;
            p4_x_int  <= g1g3_X1Int;
            p4_x_dec  <= g1g3_X1Dec;
            
            p4_y_sign <= g1g3_Y1Sign;
            p4_y_int  <= g1g3_Y1Int;
            p4_y_dec  <= g1g3_Y1Dec;
            
            p5_x_sign <= g1g3_X2Sign;
            p5_x_int  <= g1g3_X2Int;
            p5_x_dec  <= g1g3_X2Dec;
            
            p5_y_sign <= g1g3_Y2Sign;
            p5_y_int  <= g1g3_Y2Int;
            p5_y_dec  <= g1g3_Y2Dec;
            
            p4_en <= 1;
            p5_en <= 1;
        end else if (g1g3_isCalculated == NO_SOLUTION && startCalculate == 1) begin
            p4_en <= 0;
            p5_en <= 0;
        end
    end else if (sw[X_INTERCEPT] == 1) begin
        startCalculate <= 1;
        
        if (g1g2_isCalculated == CALCULATED && startCalculate == 1) begin
            p0_x_sign <= g1g2_X1Sign;
            p0_x_int  <= g1g2_X1Int;
            p0_x_dec  <= g1g2_X1Dec;
            
            p0_y_sign <= g1g2_Y1Sign;
            p0_y_int  <= g1g2_Y1Int;
            p0_y_dec  <= g1g2_Y1Dec;
            
            p1_x_sign <= g1g2_X2Sign;
            p1_x_int  <= g1g2_X2Int;
            p1_x_dec  <= g1g2_X2Dec;
            
            p1_y_sign <= g1g2_Y2Sign;
            p1_y_int  <= g1g2_Y2Int;
            p1_y_dec  <= g1g2_Y2Dec;
            
            p0_en <= 1;
            p1_en <= 1;
        end else if (g1g2_isCalculated == NO_SOLUTION && startCalculate == 1) begin
            p0_en <= 0;
            p1_en <= 0;
        end
        
        if (g1g3_isCalculated == CALCULATED && startCalculate == 1) begin
            p2_x_sign <= g1g3_X1Sign;
            p2_x_int  <= g1g3_X1Int;
            p2_x_dec  <= g1g3_X1Dec;
            
            p2_y_sign <= g1g3_Y1Sign;
            p2_y_int  <= g1g3_Y1Int;
            p2_y_dec  <= g1g3_Y1Dec;
            
            p3_x_sign <= g1g3_X2Sign;
            p3_x_int  <= g1g3_X2Int;
            p3_x_dec  <= g1g3_X2Dec;
            
            p3_y_sign <= g1g3_Y2Sign;
            p3_y_int  <= g1g3_Y2Int;
            p3_y_dec  <= g1g3_Y2Dec;
            
            p2_en <= 1;
            p3_en <= 1;
        end else if (g1g3_isCalculated == NO_SOLUTION && startCalculate == 1) begin
            p2_en <= 0;
            p3_en <= 0;
        end
        
        if (g2g3_isCalculated == CALCULATED && startCalculate == 1) begin
            p4_x_sign <= g2g3_X1Sign;
            p4_x_int  <= g2g3_X1Int;
            p4_x_dec  <= g2g3_X1Dec;
            
            p4_y_sign <= g2g3_Y1Sign;
            p4_y_int  <= g2g3_Y1Int;
            p4_y_dec  <= g2g3_Y1Dec;
            
            p5_x_sign <= g2g3_X2Sign;
            p5_x_int  <= g2g3_X2Int;
            p5_x_dec  <= g2g3_X2Dec;
            
            p5_y_sign <= g2g3_Y2Sign;
            p5_y_int  <= g2g3_Y2Int;
            p5_y_dec  <= g2g3_Y2Dec;
            
            p4_en <= 1;
            p5_en <= 1;
        end else if (g2g3_isCalculated == NO_SOLUTION && startCalculate == 1) begin
            p4_en <= 0;
            p5_en <= 0;
        end
    end else if (sw[Y_INTERCEPT] == 1) begin
        startCalculate <= 0; // Y intercept does not use module, so reset
        p0_x_sign <= 0;
        p0_x_int  <= 0;
        p0_x_dec  <= 0;
        
        p0_y_sign <= c1Sign;
        p0_y_int  <= c1Integer;
        p0_y_dec  <= 0;
        
        p2_x_sign <= 0;
        p2_x_int  <= 0;
        p2_x_dec  <= 0;
        
        p2_y_sign <= c2Sign;
        p2_y_int  <= c2Integer;
        p2_y_dec  <= 0;
        
        p4_x_sign <= 0;
        p4_x_int  <= 0;
        p4_x_dec  <= 0;
        
        p4_y_sign <= c3Sign;
        p4_y_int  <= c3Integer;
        p4_y_dec  <= 0;
        
        p0_en <= 1;
        p1_en <= 0;
        p2_en <= 1;
        p3_en <= 0;
        p4_en <= 1;
        p5_en <= 0;
    end
end

endmodule