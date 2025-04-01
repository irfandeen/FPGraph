`timescale 1ns / 1ps

module Intersection2LinearLines(
    input         basysClock, startCalculate,  // added clock input
    input         m1Sign, c1Sign, m2Sign, c2Sign,
    input  [23:0] m1Integer, m1Decimal, 
                  c1Integer, c1Decimal,
                  m2Integer, m2Decimal, 
                  c2Integer, c2Decimal,
    output        xSign, ySign,
    output [23:0] xInteger, xDecimal,
    output [23:0] yInteger, yDecimal
);

    localparam ADD = 0;
    localparam SUB = 1;
    localparam MUL = 2;
    localparam DIV = 3;

    localparam POS = 0;
    localparam NEG = 1;

    // Signals for FloatingPoint inputs
    reg         firstValueSign;
    reg         secondValueSign;
    reg [23:0]  firstValueInteger;
    reg [23:0]  firstValueDecimal;
    reg [23:0]  secondValueInteger;
    reg [23:0]  secondValueDecimal;
    reg [1:0]   operation;

    // FloatingPoint outputs (driven by instance)
    wire [23:0] finalResultInteger;
    wire [23:0] finalResultDecimal;
    wire        finalSign;
    wire        isCalculated;

    // Instantiate the FloatingPoint calculator module
    FloatingPoint calculator (
        .firstValueSign  (firstValueSign),
        .secondValueSign (secondValueSign),
        .firstValueInteger(firstValueInteger),
        .firstValueDecimal(firstValueDecimal),
        .secondValueInteger(secondValueInteger),
        .secondValueDecimal(secondValueDecimal),
        .operation       (operation),
        .finalSign       (finalSign),
        .finalResultInteger(finalResultInteger),
        .finalResultDecimal(finalResultDecimal),
        .isCalculated    (isCalculated)
    );

    // Calculation phase variable
    reg [3:0] calculationPhase = 10;

    // Intermediate storage for results
    reg        c2MinusC1Sign;
    reg [23:0] c2MinusC1Integer;
    reg [23:0] c2MinusC1Decimal;

    reg        m1MinusM2Sign;
    reg [23:0] m1MinusM2Integer;
    reg [23:0] m1MinusM2Decimal;

    reg        xSign_reg;
    reg [23:0] xInteger_reg;
    reg [23:0] xDecimal_reg;

    reg        m1MultiplyXSign;
    reg [23:0] m1MultiplyXInteger;
    reg [23:0] m1MultiplyXDecimal;

    reg        ySign_reg;
    reg [23:0] yInteger_reg;
    reg [23:0] yDecimal_reg;

    // Drive module outputs from registers
    assign xSign   = xSign_reg;
    assign xInteger = xInteger_reg;
    assign xDecimal = xDecimal_reg;
    assign ySign   = ySign_reg;
    assign yInteger = yInteger_reg;
    assign yDecimal = yDecimal_reg;

    reg prevStartCalculate = 0;

    // Synchronous process updating on rising edge of basysClock
    always @(posedge basysClock) begin
        prevStartCalculate <= startCalculate;

        if (startCalculate && !prevStartCalculate) begin
            calculationPhase <= 0;  // Reset phase on startCalculate
        end

        // Phase 0: Calculate c2 - c1
        else if (calculationPhase == 0) begin
            firstValueSign    <= c2Sign;
            secondValueSign   <= c1Sign;
            firstValueInteger <= c2Integer;
            firstValueDecimal <= c2Decimal;
            secondValueInteger<= c1Integer;
            secondValueDecimal<= c1Decimal;
            operation         <= SUB;
            calculationPhase  <= 1;
        end
        else if (isCalculated == 1 && calculationPhase == 1) begin
            c2MinusC1Sign    <= finalSign;
            c2MinusC1Integer <= finalResultInteger;
            c2MinusC1Decimal <= finalResultDecimal;
            calculationPhase <= 2;
        end
        // Phase 1: Calculate m1 - m2
        else if (calculationPhase == 2) begin
            firstValueSign    <= m1Sign;
            secondValueSign   <= m2Sign;
            firstValueInteger <= m1Integer;
            firstValueDecimal <= m1Decimal;
            secondValueInteger<= m2Integer;
            secondValueDecimal<= m2Decimal;
            operation         <= SUB;
            calculationPhase  <= 3;
        end
        else if (isCalculated == 1 && calculationPhase == 3) begin
            m1MinusM2Sign    <= finalSign;
            m1MinusM2Integer <= finalResultInteger;
            m1MinusM2Decimal <= finalResultDecimal;
            calculationPhase  <= 4;
        end
        // Phase 2: Calculate x = (c2 - c1) / (m1 - m2)
        else if (calculationPhase == 4) begin
            firstValueSign    <= c2MinusC1Sign;
            secondValueSign   <= m1MinusM2Sign;
            firstValueInteger <= c2MinusC1Integer;
            firstValueDecimal <= c2MinusC1Decimal;
            secondValueInteger<= m1MinusM2Integer;
            secondValueDecimal<= m1MinusM2Decimal;
            operation         <= DIV;
            calculationPhase  <= 5;
        end
        else if (isCalculated == 1 && calculationPhase == 5) begin
            xSign_reg    <= finalSign;
            xInteger_reg <= finalResultInteger;
            xDecimal_reg <= finalResultDecimal;
            calculationPhase  <= 6;
        end
        // Phase 3: Calculate m1 * x
        else if (calculationPhase == 6) begin
            firstValueSign    <= m1Sign;
            secondValueSign   <= xSign_reg;
            firstValueInteger <= m1Integer;
            firstValueDecimal <= m1Decimal;
            secondValueInteger<= xInteger_reg;
            secondValueDecimal<= xDecimal_reg;
            operation         <= MUL;
            calculationPhase  <= 7;
        end
        else if (isCalculated == 1 && calculationPhase == 7) begin
            m1MultiplyXSign    <= finalSign;
            m1MultiplyXInteger <= finalResultInteger;
            m1MultiplyXDecimal <= finalResultDecimal;
            calculationPhase   <= 8;
        end
        // Phase 4: Calculate y = (m1 * x) + c1
        else if (calculationPhase == 8) begin
            firstValueSign    <= m1MultiplyXSign;
            secondValueSign   <= c1Sign;
            firstValueInteger <= m1MultiplyXInteger;
            firstValueDecimal <= m1MultiplyXDecimal;
            secondValueInteger<= c1Integer;
            secondValueDecimal<= c1Decimal;
            operation         <= ADD;
            calculationPhase  <= 9;
        end
        else if (isCalculated == 1 && calculationPhase == 9) begin
            ySign_reg    <= finalSign;
            yInteger_reg <= finalResultInteger;
            yDecimal_reg <= finalResultDecimal;
            calculationPhase <= 10;
        end
    end

endmodule
