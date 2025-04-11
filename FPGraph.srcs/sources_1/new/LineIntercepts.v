`timescale 1ns / 1ps

module LineIntercepts(
    //----------------------General IO-------------------------
    input                basysClock,
    input                startCalculate,
    //---------------------------------------------------------

    //-----------------Graph Equation Inputs-------------------
    input                a1Sign,
    input       [13:0]   a1Integer,
    input                b1Sign,
    input       [13:0]   b1Integer,
    input                c1Sign,
    input       [13:0]   c1Integer,
    
    input                a2Sign,
    input       [13:0]   a2Integer,
    input                b2Sign,
    input       [13:0]   b2Integer,
    input                c2Sign,
    input       [13:0]   c2Integer,

    input                a3Sign,
    input       [13:0]   a3Integer,
    input                b3Sign,
    input       [13:0]   b3Integer,
    input                c3Sign,
    input       [13:0]   c3Integer,
    //---------------------------------------------------------

    //---------------Graph 1 Graph 2 Intercepts----------------
    output reg           g1g2_X1Sign,
    output reg [13:0]   g1g2_X1Int, g1g2_X1Dec,
    
    output reg           g1g2_Y1Sign,
    output reg [13:0]   g1g2_Y1Int, g1g2_Y1Dec,
    
    output reg           g1g2_X2Sign,
    output reg [13:0]   g1g2_X2Int, g1g2_X2Dec,
    
    output reg           g1g2_Y2Sign,
    output reg [13:0]   g1g2_Y2Int, g1g2_Y2Dec,
    
    output reg [1:0]    g1g2_isCalculated,
    //---------------------------------------------------------

    //---------------Graph 1 Graph 3 Intercepts----------------
    output reg           g1g3_X1Sign,
    output reg [13:0]   g1g3_X1Int, g1g3_X1Dec,
    
    output reg           g1g3_Y1Sign,
    output reg [13:0]   g1g3_Y1Int, g1g3_Y1Dec,
    
    output reg           g1g3_X2Sign,
    output reg [13:0]   g1g3_X2Int, g1g3_X2Dec,
    
    output reg           g1g3_Y2Sign,
    output reg [13:0]   g1g3_Y2Int, g1g3_Y2Dec,
    
    output reg [1:0]    g1g3_isCalculated,
    //----------------------------------------------------------
    
    //---------------Graph 2 Graph 3 Intercepts-----------------
    output reg           g2g3_X1Sign,
    output reg [13:0]   g2g3_X1Int, g2g3_X1Dec,
    
    output reg           g2g3_Y1Sign,
    output reg [13:0]   g2g3_Y1Int, g2g3_Y1Dec,
    
    output reg           g2g3_X2Sign,
    output reg [13:0]   g2g3_X2Int, g2g3_X2Dec,
    
    output reg           g2g3_Y2Sign,
    output reg [13:0]   g2g3_Y2Int, g2g3_Y2Dec,
    
    output reg [1:0]    g2g3_isCalculated
    //----------------------------------------------------------
);

    localparam NOT_CALCULATED = 0, CALCULATED = 1, NO_SOLUTION = 2;
    localparam ADD = 0, SUB = 1, MUL = 2, DIV = 3;
    localparam POS = 0, NEG = 1;

    // Instantiate IntersectionQuadratic

    // Inputs to IntersectionQuadratic for equation coefficients
    reg        temp_a1Sign;
    reg [13:0] temp_a1Integer;
    reg        temp_b1Sign;
    reg [13:0] temp_b1Integer;
    reg        temp_c1Sign;
    reg [13:0] temp_c1Integer;

    reg        temp_a2Sign;
    reg [13:0] temp_a2Integer;
    reg        temp_b2Sign;
    reg [13:0] temp_b2Integer;
    reg        temp_c2Sign;
    reg [13:0] temp_c2Integer;

    // Outputs from IntersectionQuadratic
    wire       temp_X1Sign;
    wire [13:0] temp_X1Int;
    wire [13:0] temp_X1Dec;

    wire       temp_Y1Sign;
    wire [13:0] temp_Y1Int;
    wire [13:0] temp_Y1Dec;

    wire       temp_X2Sign;
    wire [13:0] temp_X2Int;
    wire [13:0] temp_X2Dec;

    wire       temp_Y2Sign;
    wire [13:0] temp_Y2Int;
    wire [13:0] temp_Y2Dec;

    reg startIntersectionQuadratic = 0;
    wire [1:0]      temp_isCalculated;
    
    IntersectionQuadratic IntersectionQuadratic_inst (
        .basysClock       (basysClock),
        .startCalculate   (startIntersectionQuadratic),
        .a1Sign           (temp_a1Sign),
        .a1Integer        (temp_a1Integer),
        .b1Sign           (temp_b1Sign),
        .b1Integer        (temp_b1Integer),
        .c1Sign           (temp_c1Sign),
        .c1Integer        (temp_c1Integer),
        .a2Sign           (temp_a2Sign),
        .a2Integer        (temp_a2Integer),
        .b2Sign           (temp_b2Sign),
        .b2Integer        (temp_b2Integer),
        .c2Sign           (temp_c2Sign),
        .c2Integer        (temp_c2Integer),
        .x1Sign           (temp_X1Sign),
        .x1Integer        (temp_X1Int),
        .x1Decimal        (temp_X1Dec),
        .y1Sign           (temp_Y1Sign),
        .y1Integer        (temp_Y1Int),
        .y1Decimal        (temp_Y1Dec),
        .x2Sign           (temp_X2Sign),
        .x2Integer        (temp_X2Int),
        .x2Decimal        (temp_X2Dec),
        .y2Sign           (temp_Y2Sign),
        .y2Integer        (temp_Y2Int),
        .y2Decimal        (temp_Y2Dec),
        .isCalculated     (temp_isCalculated)
    );


    wire clk100Khz;

    // Instantiate the flexible_clock module with CLK_DIV = 50000 to get 1kHz output:
    flexible_clock #(.CLK_DIV(500)) clk_gen (
        .clk_in(basysClock),
        .clk_out(clk100Khz)
    );

    // Correct state declaration (example uses 3 bits)
    reg [2:0] state = 6;
    reg prevStartCalculate = 0;


    always @ (posedge clk100Khz) begin
        prevStartCalculate <= startCalculate;

        if (startCalculate && !prevStartCalculate) begin
            state <= 0;
            g1g2_isCalculated <= 0;
            g1g3_isCalculated <= 0;
            g2g3_isCalculated <= 0;
            startIntersectionQuadratic <= 0;
        end else begin
            case (state)
                0: begin
                    // Set up the first intersection calculation
                    temp_a1Sign <= a1Sign;
                    temp_a1Integer <= a1Integer;
                    temp_b1Sign <= b1Sign;
                    temp_b1Integer <= b1Integer;
                    temp_c1Sign <= c1Sign;
                    temp_c1Integer <= c1Integer;

                    temp_a2Sign <= a2Sign;
                    temp_a2Integer <= a2Integer;
                    temp_b2Sign <= b2Sign;
                    temp_b2Integer <= b2Integer;
                    temp_c2Sign <= c2Sign;
                    temp_c2Integer <= c2Integer;

                    startIntersectionQuadratic <= 1; // Start the intersection calculation
                    state <= 1;
                end

                1: if (temp_isCalculated == CALCULATED || temp_isCalculated == NO_SOLUTION) begin
                    // Store the results for Graph 1 and Graph 2
                    g1g2_X1Sign <= temp_X1Sign;
                    g1g2_X1Int <= temp_X1Int;
                    g1g2_X1Dec <= temp_X1Dec;

                    g1g2_Y1Sign <= temp_Y1Sign;
                    g1g2_Y1Int <= temp_Y1Int;
                    g1g2_Y1Dec <= temp_Y1Dec;

                    g1g2_X2Sign <= temp_X2Sign;
                    g1g2_X2Int <= temp_X2Int;
                    g1g2_X2Dec <= temp_X2Dec;

                    g1g2_Y2Sign <= temp_Y2Sign;
                    g1g2_Y2Int <= temp_Y2Int;
                    g1g2_Y2Dec <= temp_Y2Dec;

                    g1g2_isCalculated <= 1; // Indicate that the calculation is done
                    startIntersectionQuadratic <= 0; 
                    state <= 2;
                end

                2: begin
                    // Set up the second intersection calculation
                    temp_a1Sign <= a1Sign;
                    temp_a1Integer <= a1Integer;
                    temp_b1Sign <= b1Sign;
                    temp_b1Integer <= b1Integer;
                    temp_c1Sign <= c1Sign;
                    temp_c1Integer <= c1Integer;

                    temp_a2Sign <= a3Sign;
                    temp_a2Integer <= a3Integer;
                    temp_b2Sign <= b3Sign;
                    temp_b2Integer <= b3Integer;
                    temp_c2Sign <= c3Sign;
                    temp_c2Integer <= c3Integer;

                    startIntersectionQuadratic <= 1; // Start the intersection calculation
                    state <= 3;
                end

                3: if(temp_isCalculated == CALCULATED || temp_isCalculated == NO_SOLUTION) begin
                    // Store the results for Graph 1 and Graph 3
                    g1g3_X1Sign <= temp_X1Sign;
                    g1g3_X1Int <= temp_X1Int;
                    g1g3_X1Dec <= temp_X1Dec;

                    g1g3_Y1Sign <= temp_Y1Sign;
                    g1g3_Y1Int <= temp_Y1Int;
                    g1g3_Y1Dec <= temp_Y1Dec;

                    g1g3_X2Sign <= temp_X2Sign;
                    g1g3_X2Int <= temp_X2Int;
                    g1g3_X2Dec <= temp_X2Dec;

                    g1g3_Y2Sign <= temp_Y2Sign;
                    g1g3_Y2Int <= temp_Y2Int;
                    g1g3_Y2Dec <= temp_Y2Dec;

                    g1g3_isCalculated <= 1; // Indicate that the calculation is done
                    startIntersectionQuadratic <= 0; 
                    state <= 4;
                end

                4: begin
                    // Set up the third intersection calculation
                    temp_a1Sign <= a2Sign;
                    temp_a1Integer <= a2Integer;
                    temp_b1Sign <= b2Sign;
                    temp_b1Integer <= b2Integer;
                    temp_c1Sign <= c2Sign;
                    temp_c1Integer <= c2Integer;

                    temp_a2Sign <= a3Sign;
                    temp_a2Integer <= a3Integer;
                    temp_b2Sign <= b3Sign;
                    temp_b2Integer <= b3Integer;
                    temp_c2Sign <= c3Sign;
                    temp_c2Integer <= c3Integer;

                    startIntersectionQuadratic <= 1; // Start the intersection calculation
                    state <= 5;
                end

                5: if(temp_isCalculated == CALCULATED || temp_isCalculated == NO_SOLUTION) begin
                    // Store the results for Graph 2 and Graph 3
                    g2g3_X1Sign <= temp_X1Sign;
                    g2g3_X1Int <= temp_X1Int;
                    g2g3_X1Dec <= temp_X1Dec;

                    g2g3_Y1Sign <= temp_Y1Sign;
                    g2g3_Y1Int <= temp_Y1Int;
                    g2g3_Y1Dec <= temp_Y1Dec;

                    g2g3_X2Sign <= temp_X2Sign;
                    g2g3_X2Int <= temp_X2Int;
                    g2g3_X2Dec <= temp_X2Dec;

                    g2g3_Y2Sign <= temp_Y2Sign;
                    g2g3_Y2Int <= temp_Y2Int;
                    g2g3_Y2Dec <= temp_Y2Dec;

                    g2g3_isCalculated <= 1; // Indicate that the calculation is done
                    startIntersectionQuadratic <= 0; 
                    state <= 6;
                end

                6: begin
                    // Do nothing, final state
                    state <= 6;
                end

                default: state <= 6;
            endcase
        end
    end

endmodule

