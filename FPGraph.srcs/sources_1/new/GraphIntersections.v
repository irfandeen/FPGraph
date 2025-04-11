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
wire        line_g1g2_X1Sign;
wire [13:0] line_g1g2_X1Int,  line_g1g2_X1Dec;
wire        line_g1g2_Y1Sign;
wire [13:0] line_g1g2_Y1Int,  line_g1g2_Y1Dec;
wire        line_g1g2_X2Sign;
wire [13:0] line_g1g2_X2Int,  line_g1g2_X2Dec;
wire        line_g1g2_Y2Sign;
wire [13:0] line_g1g2_Y2Int,  line_g1g2_Y2Dec;
wire [1:0]  line_g1g2_isCalculated;

// Wires for LineIntercepts outputs (Graph 1 & 3 outputs)
wire        line_g1g3_X1Sign;
wire [13:0] line_g1g3_X1Int,  line_g1g3_X1Dec;
wire        line_g1g3_Y1Sign;
wire [13:0] line_g1g3_Y1Int,  line_g1g3_Y1Dec;
wire        line_g1g3_X2Sign;
wire [13:0] line_g1g3_X2Int,  line_g1g3_X2Dec;
wire        line_g1g3_Y2Sign;
wire [13:0] line_g1g3_Y2Int,  line_g1g3_Y2Dec;
wire [1:0]  line_g1g3_isCalculated;

// Wires for LineIntercepts outputs (Graph 2 & 3 outputs)
wire        line_g2g3_X1Sign;
wire [13:0] line_g2g3_X1Int,  line_g2g3_X1Dec;
wire        line_g2g3_Y1Sign;
wire [13:0] line_g2g3_Y1Int,  line_g2g3_Y1Dec;
wire        line_g2g3_X2Sign;
wire [13:0] line_g2g3_X2Int,  line_g2g3_X2Dec;
wire        line_g2g3_Y2Sign;
wire [13:0] line_g2g3_Y2Int,  line_g2g3_Y2Dec;
wire [1:0]  line_g2g3_isCalculated;

    LineIntercepts lineIntercepts (
        .basysClock(basysClock),
        .startCalculate(startCalculate),
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
        
        .g1g2_X1Sign(line_g1g2_X1Sign),
        .g1g2_X1Int(line_g1g2_X1Int),
        .g1g2_X1Dec(line_g1g2_X1Dec),
        .g1g2_Y1Sign(line_g1g2_Y1Sign),
        .g1g2_Y1Int(line_g1g2_Y1Int),
        .g1g2_Y1Dec(line_g1g2_Y1Dec),
        .g1g2_X2Sign(line_g1g2_X2Sign),
        .g1g2_X2Int(line_g1g2_X2Int),
        .g1g2_X2Dec(line_g1g2_X2Dec),
        .g1g2_Y2Sign(line_g1g2_Y2Sign),
        .g1g2_Y2Int(line_g1g2_Y2Int),
        .g1g2_Y2Dec(line_g1g2_Y2Dec),
        .g1g2_isCalculated(line_g1g2_isCalculated),
        
        .g1g3_X1Sign(line_g1g3_X1Sign),
        .g1g3_X1Int(line_g1g3_X1Int),
        .g1g3_X1Dec(line_g1g3_X1Dec),
        .g1g3_Y1Sign(line_g1g3_Y1Sign),
        .g1g3_Y1Int(line_g1g3_Y1Int),
        .g1g3_Y1Dec(line_g1g3_Y1Dec),
        .g1g3_X2Sign(line_g1g3_X2Sign),
        .g1g3_X2Int(line_g1g3_X2Int),
        .g1g3_X2Dec(line_g1g3_X2Dec),
        .g1g3_Y2Sign(line_g1g3_Y2Sign),
        .g1g3_Y2Int(line_g1g3_Y2Int),
        .g1g3_Y2Dec(line_g1g3_Y2Dec),
        .g1g3_isCalculated(line_g1g3_isCalculated),
        
        .g2g3_X1Sign(line_g2g3_X1Sign),
        .g2g3_X1Int(line_g2g3_X1Int),
        .g2g3_X1Dec(line_g2g3_X1Dec),
        .g2g3_Y1Sign(line_g2g3_Y1Sign),
        .g2g3_Y1Int(line_g2g3_Y1Int),
        .g2g3_Y1Dec(line_g2g3_Y1Dec),
        .g2g3_X2Sign(line_g2g3_X2Sign),
        .g2g3_X2Int(line_g2g3_X2Int),
        .g2g3_X2Dec(line_g2g3_X2Dec),
        .g2g3_Y2Sign(line_g2g3_Y2Sign),
        .g2g3_Y2Int(line_g2g3_Y2Int),
        .g2g3_Y2Dec(line_g2g3_Y2Dec),
        .g2g3_isCalculated(line_g2g3_isCalculated)
    );

// Instantiate the XAxisIntercepts module and its respective wires-------------------------------

// Wires for XAxisIntercepts outputs (Graph 1 outputs)
wire        xAxis_g1_X1Sign;
wire [13:0] xAxis_g1_X1Int,  xAxis_g1_X1Dec;
wire        xAxis_g1_Y1Sign;
wire [13:0] xAxis_g1_Y1Int,  xAxis_g1_Y1Dec;
wire        xAxis_g1_X2Sign;
wire [13:0] xAxis_g1_X2Int,  xAxis_g1_X2Dec;
wire        xAxis_g1_Y2Sign;
wire [13:0] xAxis_g1_Y2Int,  xAxis_g1_Y2Dec;
wire [1:0]  xAxis_g1_isCalculated;

// Wires for XAxisIntercepts outputs (Graph 2 outputs)
wire        xAxis_g2_X1Sign;
wire [13:0] xAxis_g2_X1Int,  xAxis_g2_X1Dec;
wire        xAxis_g2_Y1Sign;
wire [13:0] xAxis_g2_Y1Int,  xAxis_g2_Y1Dec;
wire        xAxis_g2_X2Sign;
wire [13:0] xAxis_g2_X2Int,  xAxis_g2_X2Dec;
wire        xAxis_g2_Y2Sign;
wire [13:0] xAxis_g2_Y2Int,  xAxis_g2_Y2Dec;
wire [1:0]  xAxis_g2_isCalculated;

// Wires for XAxisIntercepts outputs (Graph 3 outputs)
wire        xAxis_g3_X1Sign;
wire [13:0] xAxis_g3_X1Int,  xAxis_g3_X1Dec;
wire        xAxis_g3_Y1Sign;
wire [13:0] xAxis_g3_Y1Int,  xAxis_g3_Y1Dec;
wire        xAxis_g3_X2Sign;
wire [13:0] xAxis_g3_X2Int,  xAxis_g3_X2Dec;
wire        xAxis_g3_Y2Sign;
wire [13:0] xAxis_g3_Y2Int,  xAxis_g3_Y2Dec;
wire [1:0]  xAxis_g3_isCalculated;

    XAxisIntercepts xAxisIntercepts (
        .basysClock      (basysClock),
        .startCalculate  (startCalculate),
        .a1Sign          (a1Sign),
        .a1Integer       (a1Integer),
        .b1Sign          (b1Sign),
        .b1Integer       (b1Integer),
        .c1Sign          (c1Sign),
        .c1Integer       (c1Integer),
        .a2Sign          (a2Sign),
        .a2Integer       (a2Integer),
        .b2Sign          (b2Sign),
        .b2Integer       (b2Integer),
        .c2Sign          (c2Sign),
        .c2Integer       (c2Integer),
        .a3Sign          (a3Sign),
        .a3Integer       (a3Integer),
        .b3Sign          (b3Sign),
        .b3Integer       (b3Integer),
        .c3Sign          (c3Sign),
        .c3Integer       (c3Integer),
        
        .g1_X1Sign       (xAxis_g1_X1Sign),
        .g1_X1Int        (xAxis_g1_X1Int),
        .g1_X1Dec        (xAxis_g1_X1Dec),
        .g1_Y1Sign       (xAxis_g1_Y1Sign),
        .g1_Y1Int        (xAxis_g1_Y1Int),
        .g1_Y1Dec        (xAxis_g1_Y1Dec),
        .g1_X2Sign       (xAxis_g1_X2Sign),
        .g1_X2Int        (xAxis_g1_X2Int),
        .g1_X2Dec        (xAxis_g1_X2Dec),
        .g1_Y2Sign       (xAxis_g1_Y2Sign),
        .g1_Y2Int        (xAxis_g1_Y2Int),
        .g1_Y2Dec        (xAxis_g1_Y2Dec),
        .g1_isCalculated (xAxis_g1_isCalculated),
        
        .g2_X1Sign       (xAxis_g2_X1Sign),
        .g2_X1Int        (xAxis_g2_X1Int),
        .g2_X1Dec        (xAxis_g2_X1Dec),
        .g2_Y1Sign       (xAxis_g2_Y1Sign),
        .g2_Y1Int        (xAxis_g2_Y1Int),
        .g2_Y1Dec        (xAxis_g2_Y1Dec),
        .g2_X2Sign       (xAxis_g2_X2Sign),
        .g2_X2Int        (xAxis_g2_X2Int),
        .g2_X2Dec        (xAxis_g2_X2Dec),
        .g2_Y2Sign       (xAxis_g2_Y2Sign),
        .g2_Y2Int        (xAxis_g2_Y2Int),
        .g2_Y2Dec        (xAxis_g2_Y2Dec),
        .g2_isCalculated (xAxis_g2_isCalculated),
        
        .g3_X1Sign       (xAxis_g3_X1Sign),
        .g3_X1Int        (xAxis_g3_X1Int),
        .g3_X1Dec        (xAxis_g3_X1Dec),
        .g3_Y1Sign       (xAxis_g3_Y1Sign),
        .g3_Y1Int        (xAxis_g3_Y1Int),
        .g3_Y1Dec        (xAxis_g3_Y1Dec),
        .g3_X2Sign       (xAxis_g3_X2Sign),
        .g3_X2Int        (xAxis_g3_X2Int), 
        .g3_X2Dec        (xAxis_g3_X2Dec),
        .g3_Y2Sign       (xAxis_g3_Y2Sign),
        .g3_Y2Int        (xAxis_g3_Y2Int),
        .g3_Y2Dec        (xAxis_g3_Y2Dec),
        .g3_isCalculated (xAxis_g3_isCalculated)
    );
    
    //------------ACTUAL LOGIC HERE ONWARDS------------------
    localparam GRAPH_INTERCEPT = 0;
    localparam X_INTERCEPT     = 1;
    localparam Y_INTERCEPT     = 2;
    localparam GRAPH_MINMAX    = 3;
    localparam NOT_CALCULATED = 0, CALCULATED = 1, NO_SOLUTION = 2;
    localparam ADD = 0, SUB = 1, MUL = 2, DIV = 3;
    localparam POS = 0, NEG = 1;
    
    wire clk10Khz;
    flexible_clock #(.CLK_DIV(5000)) clk_gen (
        .clk_in(basysClock),
        .clk_out(clk10Khz)
    );
    
    always @ (posedge clk10Khz) begin
        startCalculate <= 0;
        
        if (sw[GRAPH_INTERCEPT] == 1) begin
            startCalculate <= 1;
            
            if (line_g1g2_isCalculated == CALCULATED) begin
                p0_x_sign <= line_g1g2_X1Sign;
                p0_x_int  <= line_g1g2_X1Int;
                p0_x_dec  <= line_g1g2_X1Dec;
                
                p0_y_sign <= line_g1g2_Y1Sign;
                p0_y_int  <= line_g1g2_Y1Int;
                p0_y_dec  <= line_g1g2_Y1Dec;
                
                p1_x_sign <= line_g1g2_X2Sign;
                p1_x_int  <= line_g1g2_X2Int;
                p1_x_dec  <= line_g1g2_X2Dec;
                
                p1_y_sign <= line_g1g2_Y2Sign;
                p1_y_int  <= line_g1g2_Y2Int;
                p1_y_dec  <= line_g1g2_Y2Dec;
                
                p0_en     <= 1;
                p1_en     <= 1;
            end else if (line_g1g2_isCalculated == NO_SOLUTION) begin
                p0_en <= 0;
                p1_en <= 0;
            end
            
            if (line_g2g3_isCalculated == CALCULATED) begin
                p2_x_sign <= line_g2g3_X1Sign;
                p2_x_int  <= line_g2g3_X1Int;
                p2_x_dec  <= line_g2g3_X1Dec;
                
                p2_y_sign <= line_g2g3_Y1Sign;
                p2_y_int  <= line_g2g3_Y1Int;
                p2_y_dec  <= line_g2g3_Y1Dec;
                
                p3_x_sign <= line_g2g3_X2Sign;
                p3_x_int  <= line_g2g3_X2Int;
                p3_x_dec  <= line_g2g3_X2Dec;
                
                p3_y_sign <= line_g2g3_Y2Sign;
                p3_y_int  <= line_g2g3_Y2Int;
                p3_y_dec  <= line_g2g3_Y2Dec;
                
                p2_en     <= 1;
                p3_en     <= 1;
            end else if (line_g2g3_isCalculated == NO_SOLUTION) begin
                p2_en <= 0;
                p3_en <= 0;
            end
            
            if (line_g1g3_isCalculated == CALCULATED) begin
                p4_x_sign <= line_g1g3_X1Sign;
                p4_x_int  <= line_g1g3_X1Int;
                p4_x_dec  <= line_g1g3_X1Dec;
                
                p4_y_sign <= line_g1g3_Y1Sign;
                p4_y_int  <= line_g1g3_Y1Int;
                p4_y_dec  <= line_g1g3_Y1Dec;
                
                p5_x_sign <= line_g1g3_X2Sign;
                p5_x_int  <= line_g1g3_X2Int;
                p5_x_dec  <= line_g1g3_X2Dec;
                
                p5_y_sign <= line_g1g3_Y2Sign;
                p5_y_int  <= line_g1g3_Y2Int;
                p5_y_dec  <= line_g1g3_Y2Dec;
                
                p4_en     <= 1;
                p5_en     <= 1;
            end else if (line_g1g3_isCalculated == NO_SOLUTION) begin
                p4_en <= 0;
                p5_en <= 0;
            end
        end else if (sw[X_INTERCEPT] == 1) begin
            startCalculate <= 1;
            
            if (xAxis_g1_isCalculated == CALCULATED) begin
                p0_x_sign <= xAxis_g1_X1Sign;
                p0_x_int  <= xAxis_g1_X1Int;
                p0_x_dec  <= xAxis_g1_X1Dec;
                
                p0_y_sign <= xAxis_g1_Y1Sign;
                p0_y_int  <= xAxis_g1_Y1Int;
                p0_y_dec  <= xAxis_g1_Y1Dec;
                
                p1_x_sign <= xAxis_g1_X2Sign;
                p1_x_int  <= xAxis_g1_X2Int;
                p1_x_dec  <= xAxis_g1_X2Dec;
                
                p1_y_sign <= xAxis_g1_Y2Sign;
                p1_y_int  <= xAxis_g1_Y2Int;
                p1_y_dec  <= xAxis_g1_Y2Dec;
                
                p0_en     <= 1;
                p1_en     <= 1;
            end else if (xAxis_g1_isCalculated == NO_SOLUTION) begin
                p0_en <= 0;
                p1_en <= 0;
            end
            
            if (xAxis_g2_isCalculated == CALCULATED) begin
                p2_x_sign <= xAxis_g2_X1Sign;
                p2_x_int  <= xAxis_g2_X1Int;
                p2_x_dec  <= xAxis_g2_X1Dec;
                
                p2_y_sign <= xAxis_g2_Y1Sign;
                p2_y_int  <= xAxis_g2_Y1Int;
                p2_y_dec  <= xAxis_g2_Y1Dec;
                
                p3_x_sign <= xAxis_g2_X2Sign;
                p3_x_int  <= xAxis_g2_X2Int;
                p3_x_dec  <= xAxis_g2_X2Dec;
                
                p3_y_sign <= xAxis_g2_Y2Sign;
                p3_y_int  <= xAxis_g2_Y2Int;
                p3_y_dec  <= xAxis_g2_Y2Dec;
                
                p2_en     <= 1;
                p3_en     <= 1;
            end else if (xAxis_g2_isCalculated == NO_SOLUTION) begin
                p2_en <= 0;
                p3_en <= 0;
            end
            
            if (xAxis_g3_isCalculated == CALCULATED) begin
                p4_x_sign <= xAxis_g3_X1Sign;
                p4_x_int  <= xAxis_g3_X1Int;
                p4_x_dec  <= xAxis_g3_X1Dec;
                
                p4_y_sign <= xAxis_g3_Y1Sign;
                p4_y_int  <= xAxis_g3_Y1Int;
                p4_y_dec  <= xAxis_g3_Y1Dec;
                
                p5_x_sign <= xAxis_g3_X2Sign;
                p5_x_int  <= xAxis_g3_X2Int;
                p5_x_dec  <= xAxis_g3_X2Dec;
                
                p5_y_sign <= xAxis_g3_Y2Sign;
                p5_y_int  <= xAxis_g3_Y2Int;
                p5_y_dec  <= xAxis_g3_Y2Dec;
                
                p4_en     <= 1;
                p5_en     <= 1;
            end else if (xAxis_g3_isCalculated == NO_SOLUTION) begin
                p4_en <= 0;
                p5_en <= 0;
            end
            
        end else if (sw[Y_INTERCEPT] == 1) begin
            startCalculate <= 1;
            
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
            
            p0_en     <= 1;
            p1_en     <= 0;
            p2_en     <= 1;
            p3_en     <= 0;
            p4_en     <= 1;
            p5_en     <= 0;
            
        end else if (sw[GRAPH_MINMAX] == 1) begin
            startCalculate <= 1;
            // Implement logic for finding min/max points of the graphs
            // This part is not implemented in this example, but you can add your logic here.
        end else begin
            p0_en <= 0;
            p1_en <= 0;
            p2_en <= 0;
            p3_en <= 0;
            p4_en <= 0;
            p5_en <= 0;
        end
    end
    
endmodule