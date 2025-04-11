`timescale 1ns / 1ps

module GraphIntersections(
    input basysClock,
    output led0
);

reg startCalculate = 0;
    wire clk5Khz;

// Instantiate the flexible_clock module with CLK_DIV = 50000 to get 1kHz output:
flexible_clock #(.CLK_DIV(10000)) clk_gen (
    .clk_in(basysClock),
    .clk_out(clk5Khz)
);

always @ (clk5Khz) begin
    startCalculate <= 1;
end

    // Instantiate the LineIntercepts module with basysClock passed in and all other inputs tied to 0.
    LineIntercepts u_LineIntercepts (
        .basysClock     (basysClock),
        .startCalculate (startCalculate),
        // Graph 1 Equation Inputs
        .a1Sign         (0),
        .a1Integer      (0),
        .b1Sign         (0),
        .b1Integer      (0),
        .c1Sign         (0),
        .c1Integer      (0),
        // Graph 2 Equation Inputs
        .a2Sign         (0),
        .a2Integer      (0),
        .b2Sign         (0),
        .b2Integer      (0),
        .c2Sign         (0),
        .c2Integer      (0),
        // Graph 3 Equation Inputs
        .a3Sign         (0),
        .a3Integer      (0),
        .b3Sign         (0),
        .b3Integer      (0),
        .c3Sign         (0),
        .c3Integer      (0),
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
