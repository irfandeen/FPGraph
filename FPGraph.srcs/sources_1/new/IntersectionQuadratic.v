`timescale 1ns/1ps

module IntersectionQuadratic(
    input         basysClock,
    input         startCalculate,
    input         a1Sign, b1Sign, c1Sign, a2Sign, b2Sign, c2Sign,
    input  [13:0] a1Integer, b1Integer, c1Integer, a2Integer, b2Integer, c2Integer,
    // Graph 1 & 2 Intercepts Outputs
    output reg    x1Sign, y1Sign, x2Sign, y2Sign,
    output reg [13:0] x1Integer, x1Decimal,
                      y1Integer, y1Decimal,
                      x2Integer, x2Decimal,
                      y2Integer, y2Decimal,
    output reg [1:0] isCalculated,  // 0: NOT_CALCULATED, 1: CALCULATED, 2: NO_SOLUTION

    
    //DEBUG ONLY
    output reg [5:0] calculationPhaseDebug,

    output reg isCalculatedRootDebug,

    output reg sqrtDiscSignDebug,
    output reg [13:0] sqrtDiscIntDebug, sqrtDiscDecDebug,

    output reg firstAnsSignDebug,
    output reg [13:0] firstAnsIntDebug, firstAnsDecDebug
    //DEBUG ONLY
    
);

    localparam NOT_CALCULATED = 0, CALCULATED = 1, NO_SOLUTION = 2;
    localparam ADD = 0, SUB = 1, MUL = 2, DIV = 3;
    localparam POS = 0, NEG = 1;
    
    // FloatingPoint Calculator Signals
    reg         firstValueSign;
    reg         secondValueSign;
    reg [13:0]  firstValueInteger;
    reg [13:0]  firstValueDecimal;
    reg [13:0]  secondValueInteger;
    reg [13:0]  secondValueDecimal;
    reg [1:0]   operation;
    
    wire [13:0] finalResultInteger;
    wire [13:0] finalResultDecimal;
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
    reg [13:0]  sqrtInteger;
    reg [13:0]  sqrtDecimal;
    
    wire [13:0] sqrtResultInteger;
    wire [13:0] sqrtResultDecimal;
    wire        sqrtResultSign;
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
    
    // Internal registers for quadratic computation
    // Combine the sign with the integer coefficients (decimals are not used)
    reg signed [14:0] a1, b1, c1, a2, b2, c2;
    
    // Discriminant
    reg signed [14:0] disc;
    reg        discSign;
    reg [13:0] discInt;
    
    // Square root of discriminant
    reg        sqrtDiscSign;
    reg [13:0] sqrtDiscInt;
    reg [13:0] sqrtDiscDec;
    
    // -b value
    reg        minusBSign;
    reg [13:0] minusBInt;
    reg [13:0] minusBDec;
    
    // 2a value
    reg        twoASign;
    reg [13:0] twoAInt;
    reg [13:0] twoADec;
    
    // Numerators for x solutions
    reg        firstNumeratorSign;
    reg [13:0] firstNumeratorInt;
    reg [13:0] firstNumeratorDec;
    
    reg        secondNumeratorSign;
    reg [13:0] secondNumeratorInt;
    reg [13:0] secondNumeratorDec;
    
    // First x solution and related steps for y calculation
    reg        firstAnsSign;
    reg [13:0] firstAnsInt;
    reg [13:0] firstAnsDec;
    
    reg        firstAnsSquareSign;
    reg [13:0] firstAnsSquareInt;
    reg [13:0] firstAnsSquareDec;
    
    reg        firstAnsSquareMultiplyASign;
    reg [13:0] firstAnsSquareMultiplyAInt;
    reg [13:0] firstAnsSquareMultiplyADec;
    
    reg        firstAnsMultiplyBSign;
    reg [13:0] firstAnsMultiplyBInt;
    reg [13:0] firstAnsMultiplyBDec;
    
    reg        firstAnsAPlusBSign;
    reg [13:0] firstAnsAPlusBInt;
    reg [13:0] firstAnsAPlusBDec;
    
    reg        firstAnsYSign;
    reg [13:0] firstAnsYInt;
    reg [13:0] firstAnsYDec;
    
    // Second x solution and related steps for y calculation
    reg        secondAnsSign;
    reg [13:0] secondAnsInt;
    reg [13:0] secondAnsDec;
    
    reg        secondAnsSquareSign;
    reg [13:0] secondAnsSquareInt;
    reg [13:0] secondAnsSquareDec;
    
    reg        secondAnsSquareMultiplyASign;
    reg [13:0] secondAnsSquareMultiplyAInt;
    reg [13:0] secondAnsSquareMultiplyADec;
    
    reg        secondAnsMultiplyBSign;
    reg [13:0] secondAnsMultiplyBInt;
    reg [13:0] secondAnsMultiplyBDec;
    
    reg        secondAnsAPlusBSign;
    reg [13:0] secondAnsAPlusBInt;
    reg [13:0] secondAnsAPlusBDec;
    
    reg        secondAnsYSign;
    reg [13:0] secondAnsYInt;
    reg [13:0] secondAnsYDec;
    
    // Control: Calculation Phase
    reg [5:0] calculationPhase = 39;
    reg prevStartCalculate = 0;
    
    /* Main Sequential Calculation */
    always @(posedge basysClock) begin
        
        //DEBUG ONLY
        calculationPhaseDebug <= calculationPhase;

        isCalculatedRootDebug <= isCalculatedRoot;

        sqrtDiscSignDebug <= sqrtDiscSign;
        sqrtDiscIntDebug <= sqrtDiscInt;
        sqrtDiscDecDebug <= sqrtDiscDec;

        firstAnsSignDebug <= firstAnsSign;
        firstAnsIntDebug <= firstAnsInt;
        firstAnsDecDebug <= firstAnsDec;
        //DEBUG ONLY
        
        prevStartCalculate <= startCalculate;
        if (startCalculate && !prevStartCalculate) begin
            calculationPhase <= 0;
            isCalculated     <= NOT_CALCULATED;
        end else begin
            case (calculationPhase)
                // Phase 0: Compute coefficients (combine sign and integer value)
                0: begin
                    a1 = (a1Sign == POS) ? a1Integer : -a1Integer;
                    b1 = (b1Sign == POS) ? b1Integer : -b1Integer;
                    c1 = (c1Sign == POS) ? c1Integer : -c1Integer;
                    a2 = (a2Sign == POS) ? a2Integer : -a2Integer;
                    b2 = (b2Sign == POS) ? b2Integer : -b2Integer;
                    c2 = (c2Sign == POS) ? c2Integer : -c2Integer;
                    calculationPhase <= 1;
                end
                // Phase 1: Calculate discriminant
                1: if (isCalculatedFloating) begin
                       disc <= ((b1 - b2) * (b1 - b2)) - (4 * (a1 - a2) * (c1 - c2));
                       calculationPhase <= 2;
                   end
                // Phase 2: Determine sign of discriminant and latch absolute value
                2: begin
                       if (disc < 0) begin
                           discSign <= NEG;
                           discInt  <= -disc;
                       end else begin
                           discSign <= POS;
                           discInt  <= disc;
                       end
                       calculationPhase <= 3;
                   end
                // Phase 3: Check discriminant
                3: begin
                       if (discSign == NEG) begin
                           isCalculated <= NO_SOLUTION;
                           calculationPhase <= 39;
                       end else begin
                           sqrtStart   <= 0;
                           sqrtInteger <= discInt;
                           sqrtDecimal <= 0;
                           calculationPhase <= 4;
                       end
                   end
                // Phase 4: Start computing sqrt(discriminant)
                4: begin
                       sqrtStart <= 1;
                       calculationPhase <= 5;
                   end
                // Phase 5: Latch sqrt(discriminant)
                5: if (isCalculatedRoot) begin
                       sqrtDiscSign <= sqrtResultSign;
                       sqrtDiscInt  <= sqrtResultInteger;
                       sqrtDiscDec  <= sqrtResultDecimal;
                       sqrtStart    <= 0;
                       calculationPhase <= 6;
                   end
                // Phase 6: Compute -b (multiply b1 by -1)
                6: begin
                       firstValueSign    <= b1Sign;
                       firstValueInteger <= b1Integer;
                       firstValueDecimal <= 0;
                       secondValueSign   <= NEG;
                       secondValueInteger<= 1;
                       secondValueDecimal<= 0;
                       operation         <= MUL;
                       calculationPhase  <= 7;
                   end
                // Phase 7: Latch -b
                7: if (isCalculatedFloating) begin
                       minusBSign <= finalSign;
                       minusBInt  <= finalResultInteger;
                       minusBDec  <= finalResultDecimal;
                       calculationPhase <= 8;
                   end
                // Phase 8: Compute first numerator = (-b + sqrt)
                8: begin
                       firstValueSign    <= minusBSign;
                       firstValueInteger <= minusBInt;
                       firstValueDecimal <= minusBDec;
                       secondValueSign   <= sqrtDiscSign;
                       secondValueInteger<= sqrtDiscInt;
                       secondValueDecimal<= sqrtDiscDec;
                       operation         <= ADD;
                       calculationPhase  <= 9;
                   end
                // Phase 9: Latch first numerator
                9: if (isCalculatedFloating) begin
                       firstNumeratorSign <= finalSign;
                       firstNumeratorInt  <= finalResultInteger;
                       firstNumeratorDec  <= finalResultDecimal;
                       calculationPhase <= 10;
                   end
                // Phase 10: Compute second numerator = (-b - sqrt)
                10: begin
                       firstValueSign    <= minusBSign;
                       firstValueInteger <= minusBInt;
                       firstValueDecimal <= minusBDec;
                       secondValueSign   <= sqrtDiscSign;
                       secondValueInteger<= sqrtDiscInt;
                       secondValueDecimal<= sqrtDiscDec;
                       operation         <= SUB;
                       calculationPhase  <= 11;
                   end
                // Phase 11: Latch second numerator
                11: if (isCalculatedFloating) begin
                        secondNumeratorSign <= finalSign;
                        secondNumeratorInt  <= finalResultInteger;
                        secondNumeratorDec  <= finalResultDecimal;
                        calculationPhase <= 12;
                    end
                // Phase 12: Compute 2a = a1 * 2
                12: begin
                       firstValueSign    <= a1Sign;
                       firstValueInteger <= a1Integer;
                       firstValueDecimal <= 0;
                       secondValueSign   <= POS;
                       secondValueInteger<= 2;
                       secondValueDecimal<= 0;
                       operation         <= MUL;
                       calculationPhase  <= 13;
                   end
                // Phase 13: Latch 2a
                13: if (isCalculatedFloating) begin
                       twoASign <= finalSign;
                       twoAInt  <= finalResultInteger;
                       twoADec  <= finalResultDecimal;
                       calculationPhase <= 14;
                   end
                // Phase 14: Compute first x solution = first numerator / (2a)
                14: begin
                       firstValueSign    <= firstNumeratorSign;
                       firstValueInteger <= firstNumeratorInt;
                       firstValueDecimal <= firstNumeratorDec;
                       secondValueSign   <= twoASign;
                       secondValueInteger<= twoAInt;
                       secondValueDecimal<= twoADec;
                       operation         <= DIV;
                       calculationPhase  <= 15;
                   end
                // Phase 15: Latch first x solution
                15: if (isCalculatedFloating) begin
                       firstAnsSign <= finalSign;
                       firstAnsInt  <= finalResultInteger;
                       firstAnsDec  <= finalResultDecimal;
                       calculationPhase <= 16;
                   end
                // Phase 16: Compute (first x)^2
                16: begin
                       firstValueSign    <= firstAnsSign;
                       firstValueInteger <= firstAnsInt;
                       firstValueDecimal <= firstAnsDec;
                       secondValueSign   <= firstAnsSign;
                       secondValueInteger<= firstAnsInt;
                       secondValueDecimal<= firstAnsDec;
                       operation         <= MUL;
                       calculationPhase  <= 17;
                   end
                // Phase 17: Latch (first x)^2
                17: if (isCalculatedFloating) begin
                       firstAnsSquareSign <= finalSign;
                       firstAnsSquareInt  <= finalResultInteger;
                       firstAnsSquareDec  <= finalResultDecimal;
                       calculationPhase <= 18;
                   end
                // Phase 18: Compute ax^2 using a1 coefficient
                18: begin
                       firstValueSign    <= firstAnsSquareSign;
                       firstValueInteger <= firstAnsSquareInt;
                       firstValueDecimal <= firstAnsSquareDec;
                       secondValueSign   <= a1Sign;
                       secondValueInteger<= a1Integer;
                       secondValueDecimal<= 0;
                       operation         <= MUL;
                       calculationPhase  <= 19;
                   end
                // Phase 19: Latch ax^2
                19: if (isCalculatedFloating) begin
                       firstAnsSquareMultiplyASign <= finalSign;
                       firstAnsSquareMultiplyAInt  <= finalResultInteger;
                       firstAnsSquareMultiplyADec  <= finalResultDecimal;
                       calculationPhase <= 20;
                   end
                // Phase 20: Compute bx using b1 coefficient
                20: begin
                       firstValueSign    <= firstAnsSign;
                       firstValueInteger <= firstAnsInt;
                       firstValueDecimal <= firstAnsDec;
                       secondValueSign   <= b1Sign;
                       secondValueInteger<= b1Integer;
                       secondValueDecimal<= 0;
                       operation         <= MUL;
                       calculationPhase  <= 21;
                   end
                // Phase 21: Latch bx
                21: if (isCalculatedFloating) begin
                       firstAnsMultiplyBSign <= finalSign;
                       firstAnsMultiplyBInt  <= finalResultInteger;
                       firstAnsMultiplyBDec  <= finalResultDecimal;
                       calculationPhase <= 22;
                   end
                // Phase 22: Compute (ax^2 + bx)
                22: begin
                       firstValueSign    <= firstAnsSquareMultiplyASign;
                       firstValueInteger <= firstAnsSquareMultiplyAInt;
                       firstValueDecimal <= firstAnsSquareMultiplyADec;
                       secondValueSign   <= firstAnsMultiplyBSign;
                       secondValueInteger<= firstAnsMultiplyBInt;
                       secondValueDecimal<= firstAnsMultiplyBDec;
                       operation         <= ADD;
                       calculationPhase  <= 23;
                   end
                // Phase 23: Latch (ax^2 + bx)
                23: if (isCalculatedFloating) begin
                       firstAnsAPlusBSign <= finalSign;
                       firstAnsAPlusBInt  <= finalResultInteger;
                       firstAnsAPlusBDec  <= finalResultDecimal;
                       calculationPhase <= 24;
                   end
                // Phase 24: Compute y for first solution = (ax^2 + bx) + c1
                24: begin
                       firstValueSign    <= firstAnsAPlusBSign;
                       firstValueInteger <= firstAnsAPlusBInt;
                       firstValueDecimal <= firstAnsAPlusBDec;
                       secondValueSign   <= c1Sign;
                       secondValueInteger<= c1Integer;
                       secondValueDecimal<= 0;
                       operation         <= ADD;
                       calculationPhase  <= 25;
                   end
                // Phase 25: Latch first y result
                25: if (isCalculatedFloating) begin
                       firstAnsYSign <= finalSign;
                       firstAnsYInt  <= finalResultInteger;
                       firstAnsYDec  <= finalResultDecimal;
                       calculationPhase <= 26;
                   end
                // Phase 26: Compute second x solution = second numerator / (2a)
                26: begin
                       firstValueSign    <= secondNumeratorSign;
                       firstValueInteger <= secondNumeratorInt;
                       firstValueDecimal <= secondNumeratorDec;
                       secondValueSign   <= twoASign;
                       secondValueInteger<= twoAInt;
                       secondValueDecimal<= twoADec;
                       operation         <= DIV;
                       calculationPhase  <= 27;
                   end
                // Phase 27: Latch second x solution
                27: if (isCalculatedFloating) begin
                       secondAnsSign <= finalSign;
                       secondAnsInt  <= finalResultInteger;
                       secondAnsDec  <= finalResultDecimal;
                       calculationPhase <= 28;
                   end
                // Phase 28: Compute (second x)^2
                28: begin
                       firstValueSign    <= secondAnsSign;
                       firstValueInteger <= secondAnsInt;
                       firstValueDecimal <= secondAnsDec;
                       secondValueSign   <= secondAnsSign;
                       secondValueInteger<= secondAnsInt;
                       secondValueDecimal<= secondAnsDec;
                       operation         <= MUL;
                       calculationPhase  <= 29;
                   end
                // Phase 29: Latch (second x)^2
                29: if (isCalculatedFloating) begin
                       secondAnsSquareSign <= finalSign;
                       secondAnsSquareInt  <= finalResultInteger;
                       secondAnsSquareDec  <= finalResultDecimal;
                       calculationPhase <= 30;
                   end
                // Phase 30: Compute ax^2 for second solution
                30: begin
                       firstValueSign    <= secondAnsSquareSign;
                       firstValueInteger <= secondAnsSquareInt;
                       firstValueDecimal <= secondAnsSquareDec;
                       secondValueSign   <= a1Sign;
                       secondValueInteger<= a1Integer;
                       secondValueDecimal<= 0;
                       operation         <= MUL;
                       calculationPhase  <= 31;
                   end
                // Phase 31: Latch ax^2 for second solution
                31: if (isCalculatedFloating) begin
                       secondAnsSquareMultiplyASign <= finalSign;
                       secondAnsSquareMultiplyAInt  <= finalResultInteger;
                       secondAnsSquareMultiplyADec  <= finalResultDecimal;
                       calculationPhase <= 32;
                   end
                // Phase 32: Compute bx for second solution using b1
                32: begin
                       firstValueSign    <= secondAnsSign;
                       firstValueInteger <= secondAnsInt;
                       firstValueDecimal <= secondAnsDec;
                       secondValueSign   <= b1Sign;
                       secondValueInteger<= b1Integer;
                       secondValueDecimal<= 0;
                       operation         <= MUL;
                       calculationPhase  <= 33;
                   end
                // Phase 33: Latch bx for second solution
                33: if (isCalculatedFloating) begin
                       secondAnsMultiplyBSign <= finalSign;
                       secondAnsMultiplyBInt  <= finalResultInteger;
                       secondAnsMultiplyBDec  <= finalResultDecimal;
                       calculationPhase <= 34;
                   end
                // Phase 34: Compute (ax^2 + bx) for second solution
                34: begin
                       firstValueSign    <= secondAnsSquareMultiplyASign;
                       firstValueInteger <= secondAnsSquareMultiplyAInt;
                       firstValueDecimal <= secondAnsSquareMultiplyADec;
                       secondValueSign   <= secondAnsMultiplyBSign;
                       secondValueInteger<= secondAnsMultiplyBInt;
                       secondValueDecimal<= secondAnsMultiplyBDec;
                       operation         <= ADD;
                       calculationPhase  <= 35;
                   end
                // Phase 35: Latch (ax^2 + bx) for second solution
                35: if (isCalculatedFloating) begin
                       secondAnsAPlusBSign <= finalSign;
                       secondAnsAPlusBInt  <= finalResultInteger;
                       secondAnsAPlusBDec  <= finalResultDecimal;
                       calculationPhase <= 36;
                   end
                // Phase 36: Compute y for second solution = (ax^2+bx) + c1
                36: begin
                       firstValueSign    <= secondAnsAPlusBSign;
                       firstValueInteger <= secondAnsAPlusBInt;
                       firstValueDecimal <= secondAnsAPlusBDec;
                       secondValueSign   <= c1Sign;
                       secondValueInteger<= c1Integer;
                       secondValueDecimal<= 0;
                       operation         <= ADD;
                       calculationPhase  <= 37;
                   end
                // Phase 37: Latch y for second solution
                37: if (isCalculatedFloating) begin
                       secondAnsYSign <= finalSign;
                       secondAnsYInt  <= finalResultInteger;
                       secondAnsYDec  <= finalResultDecimal;
                       calculationPhase <= 38;
                   end
                // Phase 38: Final assignments and complete calculation
                38: begin
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
                       calculationPhase <= 39;
                   end
                // Phase 39: Final state, waiting for next startCalculate.
                39: begin
                       // No operation.
                   end
                default: ;
            endcase
        end
    end

endmodule
