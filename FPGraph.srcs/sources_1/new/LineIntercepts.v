`timescale 1ns / 1ps

module LineIntercepts(
    //----------------------General IO-------------------------
    input                basysClock,
    input                startCalculate,
    //---------------------------------------------------------

    //-----------------Graph Equation Inputs-------------------
    input                a1Sign,
    input       [13:0]   a1Integer, a1Decimal,
    input                b1Sign,
    input       [13:0]   b1Integer, b1Decimal,
    input                c1Sign,
    input       [13:0]   c1Integer, c1Decimal,

    input                a2Sign,
    input       [13:0]   a2Integer, a2Decimal,
    input                b2Sign,
    input       [13:0]   b2Integer, b2Decimal,
    input                c2Sign,
    input       [13:0]   c2Integer, c2Decimal,

    input                a3Sign,
    input       [13:0]   a3Integer, a3Decimal,
    input                b3Sign,
    input       [13:0]   b3Integer, b3Decimal,
    input                c3Sign,
    input       [13:0]   c3Integer, c3Decimal,
    //---------------------------------------------------------

    //---------------Graph 1 Graph 2 Intercepts----------------
    output           g1g2_X1Sign,
    output  [13:0]   g1g2_X1Int, g1g2_X1Dec,

    output           g1g2_Y1Sign,
    output  [13:0]   g1g2_Y1Int, g1g2_Y1Dec,

    output           g1g2_X2Sign,
    output  [13:0]   g1g2_X2Int, g1g2_X2Dec,

    output           g1g2_Y2Sign,
    output  [13:0]   g1g2_Y2Int, g1g2_Y2Dec,

    output           g1g2_isCalculated,
    //---------------------------------------------------------

    //---------------Graph 1 Graph 3 Intercepts----------------
    output           g1g3_X1Sign,
    output  [13:0]   g1g3_X1Int, g1g3_X1Dec,

    output           g1g3_Y1Sign,
    output  [13:0]   g1g3_Y1Int, g1g3_Y1Dec,

    output           g1g3_X2Sign,
    output  [13:0]   g1g3_X2Int, g1g3_X2Dec,

    output           g1g3_Y2Sign,
    output  [13:0]   g1g3_Y2Int, g1g3_Y2Dec,

    output           g1g3_isCalculated,
    //----------------------------------------------------------

    //---------------Graph 2 Graph 3 Intercepts-----------------
    output           g2g3_X1Sign,
    output  [13:0]   g2g3_X1Int, g2g3_X1Dec,

    output           g2g3_Y1Sign,
    output  [13:0]   g2g3_Y1Int, g2g3_Y1Dec,

    output           g2g3_X2Sign,
    output  [13:0]   g2g3_X2Int, g2g3_X2Dec,

    output           g2g3_Y2Sign,
    output  [13:0]   g2g3_Y2Int, g2g3_Y2Dec,

    output           g2g3_isCalculated
    //----------------------------------------------------------
);

    // Instantiate IntersectionQuadratic for Graph 1 & Graph 2
    IntersectionQuadratic g1g2Intercept_inst (
        .basysClock       (basysClock),
        .startCalculate   (startCalculate),
        .a1Sign           (a1Sign),
        .a1Integer        (a1Integer),
        .a1Decimal        (a1Decimal),
        .b1Sign           (b1Sign),
        .b1Integer        (b1Integer),
        .b1Decimal        (b1Decimal),
        .c1Sign           (c1Sign),
        .c1Integer        (c1Integer),
        .c1Decimal        (c1Decimal),
        .a2Sign           (a2Sign),
        .a2Integer        (a2Integer),
        .a2Decimal        (a2Decimal),
        .b2Sign           (b2Sign),
        .b2Integer        (b2Integer),
        .b2Decimal        (b2Decimal),
        .c2Sign           (c2Sign),
        .c2Integer        (c2Integer),
        .c2Decimal        (c2Decimal),
        .x1Sign           (g1g2_X1Sign),
        .x1Integer        (g1g2_X1Int),
        .x1Decimal        (g1g2_X1Dec),
        .y1Sign           (g1g2_Y1Sign),
        .y1Integer        (g1g2_Y1Int),
        .y1Decimal        (g1g2_Y1Dec),
        .x2Sign           (g1g2_X2Sign),
        .x2Integer        (g1g2_X2Int),
        .x2Decimal        (g1g2_X2Dec),
        .y2Sign           (g1g2_Y2Sign),
        .y2Integer        (g1g2_Y2Int),
        .y2Decimal        (g1g2_Y2Dec),
        .isCalculated     (g1g2_isCalculated)
    );

    // Instantiate IntersectionQuadratic for Graph 1 & Graph 3
    IntersectionQuadratic g1g3Intercept_inst (
        .basysClock       (basysClock),
        .startCalculate   (startCalculate),
        .a1Sign           (a1Sign),
        .a1Integer        (a1Integer),
        .a1Decimal        (a1Decimal),
        .b1Sign           (b1Sign),
        .b1Integer        (b1Integer),
        .b1Decimal        (b1Decimal),
        .c1Sign           (c1Sign),
        .c1Integer        (c1Integer),
        .c1Decimal        (c1Decimal),
        .a2Sign           (a3Sign),
        .a2Integer        (a3Integer),
        .a2Decimal        (a3Decimal),
        .b2Sign           (b3Sign),
        .b2Integer        (b3Integer),
        .b2Decimal        (b3Decimal),
        .c2Sign           (c3Sign),
        .c2Integer        (c3Integer),
        .c2Decimal        (c3Decimal),
        .x1Sign           (g1g3_X1Sign),
        .x1Integer        (g1g3_X1Int),
        .x1Decimal        (g1g3_X1Dec),
        .y1Sign           (g1g3_Y1Sign),
        .y1Integer        (g1g3_Y1Int),
        .y1Decimal        (g1g3_Y1Dec),
        .x2Sign           (g1g3_X2Sign),
        .x2Integer        (g1g3_X2Int),
        .x2Decimal        (g1g3_X2Dec),
        .y2Sign           (g1g3_Y2Sign),
        .y2Integer        (g1g3_Y2Int),
        .y2Decimal        (g1g3_Y2Dec),
        .isCalculated     (g1g3_isCalculated)
    );

    // Instantiate IntersectionQuadratic for Graph 2 & Graph 3
    IntersectionQuadratic g2g3Intercept_inst (
        .basysClock       (basysClock),
        .startCalculate   (startCalculate),
        .a1Sign           (a2Sign),
        .a1Integer        (a2Integer),
        .a1Decimal        (a2Decimal),
        .b1Sign           (b2Sign),
        .b1Integer        (b2Integer),
        .b1Decimal        (b2Decimal),
        .c1Sign           (c2Sign),
        .c1Integer        (c2Integer),
        .c1Decimal        (c2Decimal),
        .a2Sign           (a3Sign),
        .a2Integer        (a3Integer),
        .a2Decimal        (a3Decimal),
        .b2Sign           (b3Sign),
        .b2Integer        (b3Integer),
        .b2Decimal        (b3Decimal),
        .c2Sign           (c3Sign),
        .c2Integer        (c3Integer),
        .c2Decimal        (c3Decimal),
        .x1Sign           (g2g3_X1Sign),
        .x1Integer        (g2g3_X1Int),
        .x1Decimal        (g2g3_X1Dec),
        .y1Sign           (g2g3_Y1Sign),
        .y1Integer        (g2g3_Y1Int),
        .y1Decimal        (g2g3_Y1Dec),
        .x2Sign           (g2g3_X2Sign),
        .x2Integer        (g2g3_X2Int),
        .x2Decimal        (g2g3_X2Dec),
        .y2Sign           (g2g3_Y2Sign),
        .y2Integer        (g2g3_Y2Int),
        .y2Decimal        (g2g3_Y2Dec),
        .isCalculated     (g2g3_isCalculated)
    );

endmodule
