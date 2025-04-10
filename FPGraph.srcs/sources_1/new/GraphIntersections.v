`timescale 1ns / 1ps

module GraphIntersections(
    input basysClock,
    output led0
);

    // Instantiate the LineIntercepts module with basysClock passed in and all other inputs tied to 0.
    LineIntercepts u_LineIntercepts (
        .basysClock     (basysClock),
        .startCalculate (1'b0),
        // Graph 1 Equation Inputs
        .a1Sign         (1'b0),
        .a1Integer      (24'd0),
        .a1Decimal      (24'd0),
        .b1Sign         (1'b0),
        .b1Integer      (24'd0),
        .b1Decimal      (24'd0),
        .c1Sign         (1'b0),
        .c1Integer      (24'd0),
        .c1Decimal      (24'd0),
        // Graph 2 Equation Inputs
        .a2Sign         (1'b0),
        .a2Integer      (24'd0),
        .a2Decimal      (24'd0),
        .b2Sign         (1'b0),
        .b2Integer      (24'd0),
        .b2Decimal      (24'd0),
        .c2Sign         (1'b0),
        .c2Integer      (24'd0),
        .c2Decimal      (24'd0),
        // Graph 3 Equation Inputs
        .a3Sign         (1'b0),
        .a3Integer      (24'd0),
        .a3Decimal      (24'd0),
        .b3Sign         (1'b0),
        .b3Integer      (24'd0),
        .b3Decimal      (24'd0),
        .c3Sign         (1'b0),
        .c3Integer      (24'd0),
        .c3Decimal      (24'd0),
        // Graph 1 & 2 Intersections Outputs
        .g1g2_X1Sign    (led0),
        .g1g2_X1Int     ( ),
        .g1g2_X1Dec     ( ),
        .g1g2_Y1Sign    ( ),
        .g1g2_Y1Int     ( ),
        .g1g2_Y1Dec     ( ),
        .g1g2_X2Sign    ( ),
        .g1g2_X2Int     ( ),
        .g1g2_X2Dec     ( ),
        .g1g2_Y2Sign    ( ),
        .g1g2_Y2Int     ( ),
        .g1g2_Y2Dec     ( ),
        .g1g2_isCalculated ( ),
        // Graph 1 & 3 Intersections Outputs
        .g1g3_X1Sign    ( ),
        .g1g3_X1Int     ( ),
        .g1g3_X1Dec     ( ),
        .g1g3_Y1Sign    ( ),
        .g1g3_Y1Int     ( ),
        .g1g3_Y1Dec     ( ),
        .g1g3_X2Sign    ( ),
        .g1g3_X2Int     ( ),
        .g1g3_X2Dec     ( ),
        .g1g3_Y2Sign    ( ),
        .g1g3_Y2Int     ( ),
        .g1g3_Y2Dec     ( ),
        .g1g3_isCalculated ( ),
        // Graph 2 & 3 Intersections Outputs
        .g2g3_X1Sign    ( ),
        .g2g3_X1Int     ( ),
        .g2g3_X1Dec     ( ),
        .g2g3_Y1Sign    ( ),
        .g2g3_Y1Int     ( ),
        .g2g3_Y1Dec     ( ),
        .g2g3_X2Sign    ( ),
        .g2g3_X2Int     ( ),
        .g2g3_X2Dec     ( ),
        .g2g3_Y2Sign    ( ),
        .g2g3_Y2Int     ( ),
        .g2g3_Y2Dec     ( ),
        .g2g3_isCalculated ( )
    );

endmodule
