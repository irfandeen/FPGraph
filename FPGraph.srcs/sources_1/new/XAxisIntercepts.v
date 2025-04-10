`timescale 1ns / 1ps

module XAxisIntercepts(
    //----------------------General IO-------------------------
    input                basysClock,
    input                startCalculate,
    //---------------------------------------------------------

    //-----------------Graph Equation Inputs-------------------
    input                a1Sign,
    input       [23:0]   a1Integer, a1Decimal,
    input                b1Sign,
    input       [23:0]   b1Integer, b1Decimal,
    input                c1Sign,
    input       [23:0]   c1Integer, c1Decimal,

    input                a2Sign,
    input       [23:0]   a2Integer, a2Decimal,
    input                b2Sign,
    input       [23:0]   b2Integer, b2Decimal,
    input                c2Sign,
    input       [23:0]   c2Integer, c2Decimal,

    input                a3Sign,
    input       [23:0]   a3Integer, a3Decimal,
    input                b3Sign,
    input       [23:0]   b3Integer, b3Decimal,
    input                c3Sign,
    input       [23:0]   c3Integer, c3Decimal,
    //---------------------------------------------------------

    //---------------Graph 1 X-Intercepts----------------------
    output           g1_X1Sign,
    output  [23:0]   g1_X1Int, g1_X1Dec,

    output           g1_Y1Sign,
    output  [23:0]   g1_Y1Int, g1_Y1Dec,

    output           g1_X2Sign,
    output  [23:0]   g1_X2Int, g1_X2Dec,

    output           g1_Y2Sign,
    output  [23:0]   g1_Y2Int, g1_Y2Dec,

    output           g1_isCalculated,
    //---------------------------------------------------------

    //---------------Graph 2 X-Intercepts----------------------
    output           g2_X1Sign,
    output  [23:0]   g2_X1Int, g2_X1Dec,

    output           g2_Y1Sign,
    output  [23:0]   g2_Y1Int, g2_Y1Dec,

    output           g2_X2Sign,
    output  [23:0]   g2_X2Int, g2_X2Dec,

    output           g2_Y2Sign,
    output  [23:0]   g2_Y2Int, g2_Y2Dec,

    output           g2_isCalculated,
    //----------------------------------------------------------

    //---------------Graph 3 X-Intercepts-----------------------
    output           g3_X1Sign,
    output  [23:0]   g3_X1Int, g3_X1Dec,

    output           g3_Y1Sign,
    output  [23:0]   g3_Y1Int, g3_Y1Dec,

    output           g3_X2Sign,
    output  [23:0]   g3_X2Int, g3_X2Dec,

    output           g3_Y2Sign,
    output  [23:0]   g3_Y2Int, g3_Y2Dec,

    output           g3_isCalculated
    //----------------------------------------------------------
);

    // Instantiate IntersectionQuadratic for Graph 1 X-Intercepts
    IntersectionQuadratic g1XIntercept_inst (
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
        .a2Sign           (0),
        .a2Integer        (0),
        .a2Decimal        (0),
        .b2Sign           (0),
        .b2Integer        (0),
        .b2Decimal        (0),
        .c2Sign           (0),
        .c2Integer        (0),
        .c2Decimal        (0),
        .x1Sign           (g1_X1Sign),
        .x1Integer        (g1_X1Int),
        .x1Decimal        (g1_X1Dec),
        .y1Sign           (g1_Y1Sign),
        .y1Integer        (g1_Y1Int),
        .y1Decimal        (g1_Y1Dec),
        .x2Sign           (g1_X2Sign),
        .x2Integer        (g1_X2Int),
        .x2Decimal        (g1_X2Dec),
        .y2Sign           (g1_Y2Sign),
        .y2Integer        (g1_Y2Int),
        .y2Decimal        (g1_Y2Dec),
        .isCalculated     (g1_isCalculated)
    );

    // Instantiate IntersectionQuadratic for Graph 2 X-Intercepts
    IntersectionQuadratic g2XIntercept_inst (
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
        .a2Sign           (0),
        .a2Integer        (0),
        .a2Decimal        (0),
        .b2Sign           (0),
        .b2Integer        (0),
        .b2Decimal        (0),
        .c2Sign           (0),
        .c2Integer        (0),
        .c2Decimal        (0),
        .x1Sign           (g2_X1Sign),
        .x1Integer        (g2_X1Int),
        .x1Decimal        (g2_X1Dec),
        .y1Sign           (g2_Y1Sign),
        .y1Integer        (g2_Y1Int),
        .y1Decimal        (g2_Y1Dec),
        .x2Sign           (g2_X2Sign),
        .x2Integer        (g2_X2Int),
        .x2Decimal        (g2_X2Dec),
        .y2Sign           (g2_Y2Sign),
        .y2Integer        (g2_Y2Int),
        .y2Decimal        (g2_Y2Dec),
        .isCalculated     (g2_isCalculated)
    );

    // Instantiate IntersectionQuadratic for Graph 3 X-Intercepts
    IntersectionQuadratic g3XIntercept_inst (
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
        .a2Sign           (0),
        .a2Integer        (0),
        .a2Decimal        (0),
        .b2Sign           (0),
        .b2Integer        (0),
        .b2Decimal        (0),
        .c2Sign           (0),
        .c2Integer        (0),
        .c2Decimal        (0),
        .x1Sign           (g3_X1Sign),
        .x1Integer        (g3_X1Int),
        .x1Decimal        (g3_X1Dec),
        .y1Sign           (g3_Y1Sign),
        .y1Integer        (g3_Y1Int),
        .y1Decimal        (g3_Y1Dec),
        .x2Sign           (g3_X2Sign),
        .x2Integer        (g3_X2Int),
        .x2Decimal        (g3_X2Dec),
        .y2Sign           (g3_Y2Sign),
        .y2Integer        (g3_Y2Int),
        .y2Decimal        (g3_Y2Dec),
        .isCalculated     (g3_isCalculated)
    );

endmodule
