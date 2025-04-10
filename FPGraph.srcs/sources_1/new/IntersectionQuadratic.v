`timescale 1ns/1ps

module IntersectionQuadratic(
    input         basysClock, startCalculate,
    input         a1Sign, b1Sign, c1Sign, a2Sign, b2Sign, c2Sign,
    input  [23:0] a1Integer, a1Decimal, 
                  b1Integer, b1Decimal,
                  c1Integer, c1Decimal,
                  a2Integer, a2Decimal,
                  b2Integer, b2Decimal,
                  c2Integer, c2Decimal,
    output reg    x1Sign, y1Sign, x2Sign, y2Sign,
    output reg [23:0] x1Integer, x1Decimal,
                      y1Integer, y1Decimal,
                      x2Integer, x2Decimal,
                      y2Integer, y2Decimal,
    output reg [1:0] isCalculated  // 0: NOT_CALCULATED, 1: CALCULATED, 2: NO_SOLUTION

    /*
    //DEBUG ONLY
    output reg [5:0] calculationPhaseDebug,

    output reg discSignDebug,
    output reg [23:0] discIntDebug, discDecDebug,

    output reg isCalculatedRootDebug,

    output reg sqrtDiscSignDebug,
    output reg [23:0] sqrtDiscIntDebug, sqrtDiscDecDebug,

    output reg firstAnsSignDebug,
    output reg [23:0] firstAnsIntDebug, firstAnsDecDebug
    //DEBUG ONLY
    */

);

    localparam NOT_CALCULATED = 0, CALCULATED = 1, NO_SOLUTION = 2;
    localparam ADD = 0, SUB = 1, MUL = 2, DIV = 3;
    localparam POS = 0, NEG = 1;
    
    // FloatingPoint Calculator Signals
    reg         firstValueSign;
    reg         secondValueSign;
    reg [23:0]  firstValueInteger;
    reg [23:0]  firstValueDecimal;
    reg [23:0]  secondValueInteger;
    reg [23:0]  secondValueDecimal;
    reg [1:0]   operation;
    
    wire [23:0] finalResultInteger;
    wire [23:0] finalResultDecimal;
    wire        finalSign;
    wire        isCalculatedFloating;
    
    FloatingPoint calculator (
        .firstValueSign(firstValueSign),
        .secondValueSign(secondValueSign),
        .firstValueInteger(firstValueInteger),
        .firstValueDecimal(firstValueDecimal),
        .secondValueInteger(secondValueInteger),
        .secondValueDecimal(secondValueDecimal),
        .operation(operation),
        .finalSign(finalSign),
        .finalResultInteger(finalResultInteger),
        .finalResultDecimal(finalResultDecimal),
        .isCalculated(isCalculatedFloating)
    );
    
    // FloatingSquareRoot Calculator Signals
    reg         sqrtStart;
    reg [23:0]  sqrtInteger;
    reg [23:0]  sqrtDecimal;
    
    wire [23:0] sqrtResultInteger;
    wire [23:0] sqrtResultDecimal;
    wire sqrtResultSign;
    wire        isCalculatedRoot;
    
    FloatingSquareRoot squareRootCalculator (
        .basysClock(basysClock),
        .startCalculate(sqrtStart),
        .sign(POS),
        .xInteger(sqrtInteger),
        .xDecimal(sqrtDecimal),
        .resultInteger(sqrtResultInteger),
        .resultDecimal(sqrtResultDecimal),
        .resultSign(sqrtResultSign), 
        .isCalculated(isCalculatedRoot)
    );
    
    // Register section: Intermediate registers for quadratic computation
    // Coefficients
    reg        aSign;
    reg [23:0] aInt, aDec;
    reg        bSign;
    reg [23:0] bInt, bDec;
    reg        cSign;
    reg [23:0] cInt, cDec;
    
    // Intermediate Products and Squares
    reg        acSign;
    reg [23:0] acInt;
    reg [23:0] acDec;
    
    reg        fourAcSign;
    reg [23:0] fourAcInt;
    reg [23:0] fourAcDec;
    
    reg        bSquareSign;
    reg [23:0] bSquareInt;
    reg [23:0] bSquareDec;
    
    // Discriminant
    reg        discSign;
    reg [23:0] discInt;
    reg [23:0] discDec;
    
    // Square root of discriminant
    reg        sqrtDiscSign;
    reg [23:0] sqrtDiscInt;
    reg [23:0] sqrtDiscDec;
    
    // -b value
    reg        minusBSign;
    reg [23:0] minusBInt;
    reg [23:0] minusBDec;
    
    // 2a value
    reg        twoASign;
    reg [23:0] twoAInt;
    reg [23:0] twoADec;
    
    // Numerators for x solutions
    reg        firstNumeratorSign;
    reg [23:0] firstNumeratorInt;
    reg [23:0] firstNumeratorDec;
    
    reg        secondNumeratorSign;
    reg [23:0] secondNumeratorInt;
    reg [23:0] secondNumeratorDec;
    
    // First x solution and related steps for y calculation
    reg        firstAnsSign;
    reg [23:0] firstAnsInt;
    reg [23:0] firstAnsDec;
    
    reg        firstAnsSquareSign;
    reg [23:0] firstAnsSquareInt;
    reg [23:0] firstAnsSquareDec;
    
    reg        firstAnsSquareMultiplyASign;
    reg [23:0] firstAnsSquareMultiplyAInt;
    reg [23:0] firstAnsSquareMultiplyADec;
    
    reg        firstAnsMultiplyBSign;
    reg [23:0] firstAnsMultiplyBInt;
    reg [23:0] firstAnsMultiplyBDec;
    
    reg        firstAnsAPlusBSign;
    reg [23:0] firstAnsAPlusBInt;
    reg [23:0] firstAnsAPlusBDec;
    
    reg        firstAnsYSign;
    reg [23:0] firstAnsYInt;
    reg [23:0] firstAnsYDec;
    
    // Second x solution and related steps for y calculation
    reg        secondAnsSign;
    reg [23:0] secondAnsInt;
    reg [23:0] secondAnsDec;
    
    reg        secondAnsSquareSign;
    reg [23:0] secondAnsSquareInt;
    reg [23:0] secondAnsSquareDec;
    
    reg        secondAnsSquareMultiplyASign;
    reg [23:0] secondAnsSquareMultiplyAInt;
    reg [23:0] secondAnsSquareMultiplyADec;
    
    reg        secondAnsMultiplyBSign;
    reg [23:0] secondAnsMultiplyBInt;
    reg [23:0] secondAnsMultiplyBDec;
    
    reg        secondAnsAPlusBSign;
    reg [23:0] secondAnsAPlusBInt;
    reg [23:0] secondAnsAPlusBDec;
    
    reg        secondAnsYSign;
    reg [23:0] secondAnsYInt;
    reg [23:0] secondAnsYDec;
    
    // Control: Calculation Phase
    reg [5:0] calculationPhase = 49;
    reg prevStartCalculate = 0;
    
    /* Main Sequential Calculation */
    always @(posedge basysClock) begin
        /*
        //DEBUG ONLY
        calculationPhaseDebug <= calculationPhase;

        discSignDebug <= discSign;
        discIntDebug <= discInt;
        discDecDebug <= discDec;

        isCalculatedRootDebug <= isCalculatedRoot;

        sqrtDiscSignDebug <= sqrtDiscSign;
        sqrtDiscIntDebug <= sqrtDiscInt;
        sqrtDiscDecDebug <= sqrtDiscDec;

        firstAnsSignDebug <= firstAnsSign;
        firstAnsIntDebug <= firstAnsInt;
        firstAnsDecDebug <= firstAnsDec;
        //DEBUG ONLY
        */

        prevStartCalculate <= startCalculate;
        if (startCalculate && !prevStartCalculate) begin
            calculationPhase <= 0;
            isCalculated     <= NOT_CALCULATED;

        end else begin
            case (calculationPhase)
                // Phases 0-5: Compute coefficients a, b, c.
                0: begin // Compute a = a1 - a2
                    firstValueSign    <= a1Sign;
                    firstValueInteger <= a1Integer;
                    firstValueDecimal <= a1Decimal;
                    secondValueSign   <= a2Sign;
                    secondValueInteger<= a2Integer;
                    secondValueDecimal<= a2Decimal;
                    operation         <= SUB;
                    calculationPhase  <= 1;
                end
                1: if (isCalculatedFloating) begin // Latch a result
                        aSign <= finalSign;
                        aInt  <= finalResultInteger;
                        aDec  <= finalResultDecimal;
                        calculationPhase <= 2;
                    end
                2: begin // Compute b = b1 - b2
                    firstValueSign    <= b1Sign;
                    firstValueInteger <= b1Integer;
                    firstValueDecimal <= b1Decimal;
                    secondValueSign   <= b2Sign;
                    secondValueInteger<= b2Integer;
                    secondValueDecimal<= b2Decimal;
                    operation         <= SUB;
                    calculationPhase  <= 3;
                end
                3: if (isCalculatedFloating) begin // Latch b result
                        bSign <= finalSign;
                        bInt  <= finalResultInteger;
                        bDec  <= finalResultDecimal;
                        calculationPhase <= 4;
                    end
                4: begin // Compute c = c1 - c2
                    firstValueSign    <= c1Sign;
                    firstValueInteger <= c1Integer;
                    firstValueDecimal <= c1Decimal;
                    secondValueSign   <= c2Sign;
                    secondValueInteger<= c2Integer;
                    secondValueDecimal<= c2Decimal;
                    operation         <= SUB;
                    calculationPhase  <= 5;
                end
                5: if (isCalculatedFloating) begin // Latch c result
                        cSign <= finalSign;
                        cInt  <= finalResultInteger;
                        cDec  <= finalResultDecimal;
                        calculationPhase <= 6;
                    end
                // Phases 6-9: Compute ac, then 4ac.
                6: begin // Compute ac = a * c
                    firstValueSign    <= aSign;
                    firstValueInteger <= aInt;
                    firstValueDecimal <= aDec;
                    secondValueSign   <= cSign;
                    secondValueInteger<= cInt;
                    secondValueDecimal<= cDec;
                    operation         <= MUL;
                    calculationPhase  <= 7;
                end
                7: if (isCalculatedFloating) begin // Latch ac result
                        acSign <= finalSign;
                        acInt  <= finalResultInteger;
                        acDec  <= finalResultDecimal;
                        calculationPhase <= 8;
                    end
                8: begin // Compute 4ac = ac * 4
                    firstValueSign    <= acSign;
                    firstValueInteger <= acInt;
                    firstValueDecimal <= acDec;
                    secondValueSign   <= POS;
                    secondValueInteger<= 4;
                    secondValueDecimal<= 0;
                    operation         <= MUL;
                    calculationPhase  <= 9;
                end
                9: if (isCalculatedFloating) begin // Latch 4ac result
                        fourAcSign <= finalSign;
                        fourAcInt  <= finalResultInteger;
                        fourAcDec  <= finalResultDecimal;
                        calculationPhase <= 10;
                    end
                // Phases 10-13: Compute b^2 and discriminant = b^2 - 4ac.
                10: begin // Compute b^2 = b * b
                    firstValueSign    <= bSign;
                    firstValueInteger <= bInt;
                    firstValueDecimal <= bDec;
                    secondValueSign   <= bSign;
                    secondValueInteger<= bInt;
                    secondValueDecimal<= bDec;
                    operation         <= MUL;
                    calculationPhase  <= 11;
                end
                11: if (isCalculatedFloating) begin // Latch b^2 result
                        bSquareSign <= finalSign;
                        bSquareInt  <= finalResultInteger;
                        bSquareDec  <= finalResultDecimal;
                        calculationPhase <= 12;
                    end
                12: begin // Compute discriminant = b^2 - 4ac
                    firstValueSign    <= bSquareSign;
                    firstValueInteger <= bSquareInt;
                    firstValueDecimal <= bSquareDec;
                    secondValueSign   <= fourAcSign;
                    secondValueInteger<= fourAcInt;
                    secondValueDecimal<= fourAcDec;
                    operation         <= SUB;
                    calculationPhase  <= 13;
                end
                13: if (isCalculatedFloating) begin // Latch discriminant
                        discSign <= finalSign;
                        discInt  <= finalResultInteger;
                        discDec  <= finalResultDecimal;
                        calculationPhase <= 14;
                    end
                // Phase 14: Check discriminant
                14: begin
                    if (discSign == NEG) begin
                        isCalculated <= NO_SOLUTION;
                        calculationPhase <= 50;
                    end else begin
                        sqrtStart <= 0;
                        sqrtInteger <= discInt;
                        sqrtDecimal <= discDec;
                        calculationPhase <= 15;
                    end
                end
                // Phase 15: Compute sqrt(discriminant)
                15: begin
                    sqrtStart <= 1;
                    calculationPhase  <= 16;
                end
                // Phase 16: Latch sqrt(discriminant)
                16: if (isCalculatedRoot) begin
                        sqrtDiscSign <= sqrtResultSign;
                        sqrtDiscInt  <= sqrtResultInteger;
                        sqrtDiscDec  <= sqrtResultDecimal;
                        sqrtStart    <= 0;
                        calculationPhase <= 17;
                    end
                // Phases 17-22: Compute -b and numerators for x solutions.
                17: begin // Compute -b = b * (-1)
                    firstValueSign    <= bSign;
                    firstValueInteger <= bInt;
                    firstValueDecimal <= bDec;
                    secondValueSign   <= NEG;
                    secondValueInteger<= 1;
                    secondValueDecimal<= 0;
                    operation         <= MUL;
                    calculationPhase  <= 18;
                end
                18: if (isCalculatedFloating) begin // Latch -b
                        minusBSign <= finalSign;
                        minusBInt  <= finalResultInteger;
                        minusBDec  <= finalResultDecimal;
                        calculationPhase <= 19;
                    end
                19: begin // Compute first numerator = (-b + sqrt)
                    firstValueSign    <= minusBSign;
                    firstValueInteger <= minusBInt;
                    firstValueDecimal <= minusBDec;
                    secondValueSign   <= sqrtDiscSign;
                    secondValueInteger<= sqrtDiscInt;
                    secondValueDecimal<= sqrtDiscDec;
                    operation         <= ADD;
                    calculationPhase  <= 20;
                end
                20: if (isCalculatedFloating) begin // Latch first numerator
                        firstNumeratorSign <= finalSign;
                        firstNumeratorInt  <= finalResultInteger;
                        firstNumeratorDec  <= finalResultDecimal;
                        calculationPhase <= 21;
                    end
                21: begin // Compute second numerator = (-b - sqrt)
                    firstValueSign    <= minusBSign;
                    firstValueInteger <= minusBInt;
                    firstValueDecimal <= minusBDec;
                    secondValueSign   <= sqrtDiscSign;
                    secondValueInteger<= sqrtDiscInt;
                    secondValueDecimal<= sqrtDiscDec;
                    operation         <= SUB;
                    calculationPhase  <= 22;
                end
                22: if (isCalculatedFloating) begin // Latch second numerator
                        secondNumeratorSign <= finalSign;
                        secondNumeratorInt  <= finalResultInteger;
                        secondNumeratorDec  <= finalResultDecimal;
                        calculationPhase <= 23;
                    end
                // Phases 23-24: Compute 2a
                23: begin // Compute 2a = a * 2
                    firstValueSign    <= aSign;
                    firstValueInteger <= aInt;
                    firstValueDecimal <= aDec;
                    secondValueSign   <= POS;
                    secondValueInteger<= 2;
                    secondValueDecimal<= 0;
                    operation         <= MUL;
                    calculationPhase  <= 24;
                end
                24: if (isCalculatedFloating) begin // Latch 2a
                        twoASign <= finalSign;
                        twoAInt  <= finalResultInteger;
                        twoADec  <= finalResultDecimal;
                        calculationPhase <= 25;
                    end
                // Phases 25-26: Compute first x solution = first numerator / (2a)
                25: begin
                    firstValueSign    <= firstNumeratorSign;
                    firstValueInteger <= firstNumeratorInt;
                    firstValueDecimal <= firstNumeratorDec;
                    secondValueSign   <= twoASign;
                    secondValueInteger<= twoAInt;
                    secondValueDecimal<= twoADec;
                    operation         <= DIV;
                    calculationPhase  <= 26;
                end
                26: if (isCalculatedFloating) begin // Latch first x solution
                        firstAnsSign <= finalSign;
                        firstAnsInt  <= finalResultInteger;
                        firstAnsDec  <= finalResultDecimal;
                        calculationPhase <= 27;
                    end
                // Phases 27-28: Compute y for first solution using a1, b1, and c1.
                27: begin // Compute (first x)^2
                    firstValueSign    <= firstAnsSign;
                    firstValueInteger <= firstAnsInt;
                    firstValueDecimal <= firstAnsDec;
                    secondValueSign   <= firstAnsSign;
                    secondValueInteger<= firstAnsInt;
                    secondValueDecimal<= firstAnsDec;
                    operation         <= MUL;
                    calculationPhase  <= 28;
                end
                28: if (isCalculatedFloating) begin // Latch x^2
                        firstAnsSquareSign <= finalSign;
                        firstAnsSquareInt  <= finalResultInteger;
                        firstAnsSquareDec  <= finalResultDecimal;
                        calculationPhase <= 29;
                    end
                29: begin // Compute ax^2 using a1 coefficient
                    firstValueSign    <= firstAnsSquareSign;
                    firstValueInteger <= firstAnsSquareInt;
                    firstValueDecimal <= firstAnsSquareDec;
                    secondValueSign   <= a1Sign;
                    secondValueInteger<= a1Integer;
                    secondValueDecimal<= a1Decimal;
                    operation         <= MUL;
                    calculationPhase  <= 30;
                end
                30: if (isCalculatedFloating) begin // Latch ax^2
                        firstAnsSquareMultiplyASign <= finalSign;
                        firstAnsSquareMultiplyAInt  <= finalResultInteger;
                        firstAnsSquareMultiplyADec  <= finalResultDecimal;
                        calculationPhase <= 31;
                    end
                31: begin // Compute bx using b1 coefficient
                    firstValueSign    <= firstAnsSign;
                    firstValueInteger <= firstAnsInt;
                    firstValueDecimal <= firstAnsDec;
                    secondValueSign   <= b1Sign;
                    secondValueInteger<= b1Integer;
                    secondValueDecimal<= b1Decimal;
                    operation         <= MUL;
                    calculationPhase  <= 32;
                end
                32: if (isCalculatedFloating) begin // Latch bx
                        firstAnsMultiplyBSign <= finalSign;
                        firstAnsMultiplyBInt  <= finalResultInteger;
                        firstAnsMultiplyBDec  <= finalResultDecimal;
                        calculationPhase <= 33;
                    end
                33: begin // Compute (ax^2) + (bx)
                    firstValueSign    <= firstAnsSquareMultiplyASign;
                    firstValueInteger <= firstAnsSquareMultiplyAInt;
                    firstValueDecimal <= firstAnsSquareMultiplyADec;
                    secondValueSign   <= firstAnsMultiplyBSign;
                    secondValueInteger<= firstAnsMultiplyBInt;
                    secondValueDecimal<= firstAnsMultiplyBDec;
                    operation         <= ADD;
                    calculationPhase  <= 34;
                end
                34: if (isCalculatedFloating) begin // Latch (ax^2 + bx)
                        firstAnsAPlusBSign <= finalSign;
                        firstAnsAPlusBInt  <= finalResultInteger;
                        firstAnsAPlusBDec  <= finalResultDecimal;
                        calculationPhase <= 35;
                    end
                35: begin // Compute y for first solution: (ax^2 + bx) + c1
                    firstValueSign    <= firstAnsAPlusBSign;
                    firstValueInteger <= firstAnsAPlusBInt;
                    firstValueDecimal <= firstAnsAPlusBDec;
                    secondValueSign   <= c1Sign;
                    secondValueInteger<= c1Integer;
                    secondValueDecimal<= c1Decimal;
                    operation         <= ADD;
                    calculationPhase  <= 36;
                end
                36: if (isCalculatedFloating) begin // Latch first y result
                        firstAnsYSign <= finalSign;
                        firstAnsYInt  <= finalResultInteger;
                        firstAnsYDec  <= finalResultDecimal;
                        calculationPhase <= 37;
                    end
                // Phases 37-38: Compute second x solution = second numerator / (2a)
                37: begin
                    firstValueSign    <= secondNumeratorSign;
                    firstValueInteger <= secondNumeratorInt;
                    firstValueDecimal <= secondNumeratorDec;
                    secondValueSign   <= twoASign;
                    secondValueInteger<= twoAInt;
                    secondValueDecimal<= twoADec;
                    operation         <= DIV;
                    calculationPhase  <= 38;
                end
                38: if (isCalculatedFloating) begin // Latch second x solution
                        secondAnsSign <= finalSign;
                        secondAnsInt  <= finalResultInteger;
                        secondAnsDec  <= finalResultDecimal;
                        calculationPhase <= 39;
                    end
                // Phases 39-40: Compute y for second solution using a1 and c1.
                39: begin // Compute (second x)^2
                    firstValueSign    <= secondAnsSign;
                    firstValueInteger <= secondAnsInt;
                    firstValueDecimal <= secondAnsDec;
                    secondValueSign   <= secondAnsSign;
                    secondValueInteger<= secondAnsInt;
                    secondValueDecimal<= secondAnsDec;
                    operation         <= MUL;
                    calculationPhase  <= 40;
                end
                40: if (isCalculatedFloating) begin // Latch (second x)^2
                        secondAnsSquareSign <= finalSign;
                        secondAnsSquareInt  <= finalResultInteger;
                        secondAnsSquareDec  <= finalResultDecimal;
                        calculationPhase <= 41;
                    end
                41: begin // Compute ax^2 for second solution
                    firstValueSign    <= secondAnsSquareSign;
                    firstValueInteger <= secondAnsSquareInt;
                    firstValueDecimal <= secondAnsSquareDec;
                    secondValueSign   <= a1Sign;
                    secondValueInteger<= a1Integer;
                    secondValueDecimal<= a1Decimal;
                    operation         <= MUL;
                    calculationPhase  <= 42;
                end
                42: if (isCalculatedFloating) begin // Latch ax^2 for second solution
                        secondAnsSquareMultiplyASign <= finalSign;
                        secondAnsSquareMultiplyAInt  <= finalResultInteger;
                        secondAnsSquareMultiplyADec  <= finalResultDecimal;
                        calculationPhase <= 43;
                    end
                43: begin // Compute bx for second solution using b1
                    firstValueSign    <= secondAnsSign;
                    firstValueInteger <= secondAnsInt;
                    firstValueDecimal <= secondAnsDec;
                    secondValueSign   <= b1Sign;
                    secondValueInteger<= b1Integer;
                    secondValueDecimal<= b1Decimal;
                    operation         <= MUL;
                    calculationPhase  <= 44;
                end
                44: if (isCalculatedFloating) begin // Latch bx for second solution
                        secondAnsMultiplyBSign <= finalSign;
                        secondAnsMultiplyBInt  <= finalResultInteger;
                        secondAnsMultiplyBDec  <= finalResultDecimal;
                        calculationPhase <= 45;
                    end
                45: begin // Compute (ax^2 for second + bx for second)
                    firstValueSign    <= secondAnsSquareMultiplyASign;
                    firstValueInteger <= secondAnsSquareMultiplyAInt;
                    firstValueDecimal <= secondAnsSquareMultiplyADec;
                    secondValueSign   <= secondAnsMultiplyBSign;
                    secondValueInteger<= secondAnsMultiplyBInt;
                    secondValueDecimal<= secondAnsMultiplyBDec;
                    operation         <= ADD;
                    calculationPhase  <= 46;
                end
                46: if (isCalculatedFloating) begin // Latch (ax^2+bx) for second solution
                        secondAnsAPlusBSign <= finalSign;
                        secondAnsAPlusBInt  <= finalResultInteger;
                        secondAnsAPlusBDec  <= finalResultDecimal;
                        calculationPhase <= 47;
                    end
                47: begin // Compute y for second solution: (ax^2+bx) + c1
                    firstValueSign    <= secondAnsAPlusBSign;
                    firstValueInteger <= secondAnsAPlusBInt;
                    firstValueDecimal <= secondAnsAPlusBDec;
                    secondValueSign   <= c1Sign;
                    secondValueInteger<= c1Integer;
                    secondValueDecimal<= c1Decimal;
                    operation         <= ADD;
                    calculationPhase  <= 48;
                end
                48: if (isCalculatedFloating) begin // Latch y for second solution
                        secondAnsYSign <= finalSign;
                        secondAnsYInt  <= finalResultInteger;
                        secondAnsYDec  <= finalResultDecimal;
                        calculationPhase <= 49;
                    end
                49: begin // Assign final outputs and complete calculation
                    x1Sign    <= firstAnsSign;
                    x1Integer <= firstAnsInt;
                    x1Decimal <= firstAnsDec;
                    y1Sign    <= firstAnsYSign;
                    y1Integer <= firstAnsYInt;
                    y1Decimal <= firstAnsYDec;
                    
                    x2Sign    <= secondAnsSign;
                    x2Integer <= secondAnsInt;
                    x2Decimal <= secondAnsDec;
                    y2Sign    <= secondAnsYSign;
                    y2Integer <= secondAnsYInt;
                    y2Decimal <= secondAnsYDec;
                    
                    isCalculated <= CALCULATED;
                    calculationPhase <= 50;
                end
                50: begin // Final state: wait for next startCalculate
                    // No operation.
                end
                default: ;
            endcase
        end
    end

endmodule
