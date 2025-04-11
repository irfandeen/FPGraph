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

    
    // DEBUG ONLY
    output reg [5:0] calculationPhaseDebug,
    output reg       isCalculatedRootDebug,
    output reg       sqrtDiscSignDebug,
    output reg [13:0] sqrtDiscIntDebug, sqrtDiscDecDebug,
    output reg       firstAnsSignDebug,
    output reg firstNumeratorSignDebug,
    output reg [13:0] firstNumeratorIntDebug, firstNumeratorDecDebug,
    output reg [13:0] twoAIntDebug, minusBIntDebug,
    output reg twoASignDebug, minusBSignDebug
    // DEBUG ONLY
    
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
    reg signed [14:0] minusBIntSigned;
    // (No decimal part for -b)
    
    // 2a value
    reg        twoASign;
    reg [13:0] twoAInt;
    reg signed [14:0] twoAIntSigned;
    // (No decimal part for 2a)
    
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

    //1Mhz Clock
    wire clk1Mhz;

    // Instantiate the flexible_clock module with CLK_DIV = 50000 to get 1kHz output:
    flexible_clock #(.CLK_DIV(50)) clk_gen (
        .clk_in(basysClock),
        .clk_out(clk1Mhz)
    );
    
    // Control: Calculation Phase
    reg [5:0] calculationPhase = 39;
    reg prevStartCalculate = 0;
    
    /* Main Sequential Calculation */
    always @(posedge clk1Mhz) begin
        
        // DEBUG signals
        calculationPhaseDebug <= calculationPhase;
        isCalculatedRootDebug <= isCalculatedRoot;
        sqrtDiscSignDebug <= sqrtDiscSign;
        sqrtDiscIntDebug <= sqrtDiscInt;
        sqrtDiscDecDebug <= sqrtDiscDec;
        firstAnsSignDebug <= firstAnsSign;
        firstNumeratorSignDebug <= firstNumeratorSign;
        firstNumeratorIntDebug <= firstNumeratorInt;
        firstNumeratorDecDebug <= firstNumeratorDec;
        twoAIntDebug <= twoAInt;
        twoASignDebug <= twoASign;
        minusBIntDebug <= minusBInt;
        minusBSignDebug <= minusBSign;
        
        
        prevStartCalculate <= startCalculate;
        if (startCalculate && !prevStartCalculate) begin
            calculationPhase <= 0;
            isCalculated     <= NOT_CALCULATED;
        end else begin
            case (calculationPhase)
                // Phase 0: Compute coefficients (combine sign and integer value)
                0: begin
                    a1 <= (a1Sign == POS) ? a1Integer : -a1Integer;
                    b1 <= (b1Sign == POS) ? b1Integer : -b1Integer;
                    c1 <= (c1Sign == POS) ? c1Integer : -c1Integer;
                    a2 <= (a2Sign == POS) ? a2Integer : -a2Integer;
                    b2 <= (b2Sign == POS) ? b2Integer : -b2Integer;
                    c2 <= (c2Sign == POS) ? c2Integer : -c2Integer;
                    calculationPhase <= 1;
                end
                // Phase 1: Calculate discriminant
                1: begin
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
                        calculationPhase <= 37;
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
                5: begin
                    if (isCalculatedRoot) begin
                        sqrtDiscSign <= sqrtResultSign;
                        sqrtDiscInt  <= sqrtResultInteger;
                        sqrtDiscDec  <= sqrtResultDecimal;
                        sqrtStart    <= 0;
                        minusBIntSigned <= b2 - b1;
                        calculationPhase <= 6;
                    end
                end
                // Phase 6: Compute -b (using b1 - b2)
                6: begin
                    if (minusBIntSigned >= 0) begin
                        minusBInt <= minusBIntSigned;
                        minusBSign <= POS;
                    end else begin
                        minusBInt <= -minusBIntSigned;
                        minusBSign <= NEG;
                    end
                    // (No decimal part for -b)
                    calculationPhase <= 7;
                end
                // Phase 7: Compute first numerator = (-b + sqrt)
                7: begin
                    firstValueSign    <= minusBSign;
                    firstValueInteger <= minusBInt;
                    firstValueDecimal <= 0;
                    secondValueSign   <= sqrtDiscSign;
                    secondValueInteger<= sqrtDiscInt;
                    secondValueDecimal<= sqrtDiscDec;
                    operation         <= ADD;
                    calculationPhase  <= 8;
                end
                // Phase 8: Latch first numerator
                8: begin
                    if (isCalculatedFloating) begin
                        firstNumeratorSign <= finalSign;
                        firstNumeratorInt  <= finalResultInteger;
                        firstNumeratorDec  <= finalResultDecimal;
                        calculationPhase <= 9;
                    end
                end
                // Phase 9: Compute second numerator = (-b - sqrt)
                9: begin
                    firstValueSign    <= minusBSign;
                    firstValueInteger <= minusBInt;
                    firstValueDecimal <= 0;
                    secondValueSign   <= sqrtDiscSign;
                    secondValueInteger<= sqrtDiscInt;
                    secondValueDecimal<= sqrtDiscDec;
                    operation         <= SUB;
                    calculationPhase  <= 10;
                end
                // Phase 10: Latch second numerator
                10: begin
                    if (isCalculatedFloating) begin
                        secondNumeratorSign <= finalSign;
                        secondNumeratorInt  <= finalResultInteger;
                        secondNumeratorDec  <= finalResultDecimal;
                        twoAIntSigned <= (a1 - a2) * 2;
                        calculationPhase <= 11;
                    end
                end
                // Phase 11: Compute 2a = (a1 - a2) * 2
                11: begin
                    // (No decimal part for 2a)
                    if (twoAIntSigned >= 0) begin
                        twoAInt <= twoAIntSigned[13:0];
                        twoASign <= POS;
                        end
                    else begin
                        twoAInt <= -twoAIntSigned;
                        twoASign <= NEG;
                        end

                    calculationPhase <= 12;
                end
                // Phase 12: Compute first x solution = first numerator / (2a)
                12: begin
                    firstValueSign    <= firstNumeratorSign;
                    firstValueInteger <= firstNumeratorInt;
                    firstValueDecimal <= firstNumeratorDec;
                    secondValueSign   <= twoASign;
                    secondValueInteger<= twoAInt;
                    secondValueDecimal<= 0;
                    operation         <= DIV;
                    calculationPhase  <= 13;
                end
                // Phase 13: Latch first x solution
                13: begin
                    if (isCalculatedFloating) begin
                        firstAnsSign <= finalSign;
                        firstAnsInt  <= finalResultInteger;
                        firstAnsDec  <= finalResultDecimal;
                        calculationPhase <= 14;
                    end
                end
                // Phase 14: Compute (first x)^2
                14: begin
                    firstValueSign    <= firstAnsSign;
                    firstValueInteger <= firstAnsInt;
                    firstValueDecimal <= firstAnsDec;
                    secondValueSign   <= firstAnsSign;
                    secondValueInteger<= firstAnsInt;
                    secondValueDecimal<= firstAnsDec;
                    operation         <= MUL;
                    calculationPhase  <= 15;
                end
                // Phase 15: Latch (first x)^2
                15: begin
                    if (isCalculatedFloating) begin
                        firstAnsSquareSign <= finalSign;
                        firstAnsSquareInt  <= finalResultInteger;
                        firstAnsSquareDec  <= finalResultDecimal;
                        calculationPhase <= 16;
                    end
                end
                // Phase 16: Compute a1*x^2
                16: begin
                    firstValueSign    <= firstAnsSquareSign;
                    firstValueInteger <= firstAnsSquareInt;
                    firstValueDecimal <= firstAnsSquareDec;
                    secondValueSign   <= a1Sign;
                    secondValueInteger<= a1Integer;
                    secondValueDecimal<= 0;
                    operation         <= MUL;
                    calculationPhase  <= 17;
                end
                // Phase 17: Latch a1*x^2
                17: begin
                    if (isCalculatedFloating) begin
                        firstAnsSquareMultiplyASign <= finalSign;
                        firstAnsSquareMultiplyAInt  <= finalResultInteger;
                        firstAnsSquareMultiplyADec  <= finalResultDecimal;
                        calculationPhase <= 18;
                    end
                end
                // Phase 18: Compute b1*x
                18: begin
                    firstValueSign    <= firstAnsSign;
                    firstValueInteger <= firstAnsInt;
                    firstValueDecimal <= firstAnsDec;
                    secondValueSign   <= b1Sign;
                    secondValueInteger<= b1Integer;
                    secondValueDecimal<= 0;
                    operation         <= MUL;
                    calculationPhase  <= 19;
                end
                // Phase 19: Latch b1*x
                19: begin
                    if (isCalculatedFloating) begin
                        firstAnsMultiplyBSign <= finalSign;
                        firstAnsMultiplyBInt  <= finalResultInteger;
                        firstAnsMultiplyBDec  <= finalResultDecimal;
                        calculationPhase <= 20;
                    end
                end
                // Phase 20: Compute (a1*x^2 + b1*x)
                20: begin
                    firstValueSign    <= firstAnsSquareMultiplyASign;
                    firstValueInteger <= firstAnsSquareMultiplyAInt;
                    firstValueDecimal <= firstAnsSquareMultiplyADec;
                    secondValueSign   <= firstAnsMultiplyBSign;
                    secondValueInteger<= firstAnsMultiplyBInt;
                    secondValueDecimal<= firstAnsMultiplyBDec;
                    operation         <= ADD;
                    calculationPhase  <= 21;
                end
                // Phase 21: Latch (a1*x^2 + b1*x)
                21: begin
                    if (isCalculatedFloating) begin
                        firstAnsAPlusBSign <= finalSign;
                        firstAnsAPlusBInt  <= finalResultInteger;
                        firstAnsAPlusBDec  <= finalResultDecimal;
                        calculationPhase <= 22;
                    end
                end
                // Phase 22: Compute y1 = (a1*x^2 + b1*x) + c1
                22: begin
                    firstValueSign    <= firstAnsAPlusBSign;
                    firstValueInteger <= firstAnsAPlusBInt;
                    firstValueDecimal <= firstAnsAPlusBDec;
                    secondValueSign   <= c1Sign;
                    secondValueInteger<= c1Integer;
                    secondValueDecimal<= 0;
                    operation         <= ADD;
                    calculationPhase  <= 23;
                end
                // Phase 23: Latch y1
                23: begin
                    if (isCalculatedFloating) begin
                        firstAnsYSign <= finalSign;
                        firstAnsYInt  <= finalResultInteger;
                        firstAnsYDec  <= finalResultDecimal;
                        calculationPhase <= 24;
                    end
                end
                // Phase 24: Compute second x solution = second numerator / (2a)
                24: begin
                    firstValueSign    <= secondNumeratorSign;
                    firstValueInteger <= secondNumeratorInt;
                    firstValueDecimal <= secondNumeratorDec;
                    secondValueSign   <= twoASign;
                    secondValueInteger<= twoAInt;
                    secondValueDecimal<= 0;
                    operation         <= DIV;
                    calculationPhase  <= 25;
                end
                // Phase 25: Latch second x solution
                25: begin
                    if (isCalculatedFloating) begin
                        secondAnsSign <= finalSign;
                        secondAnsInt  <= finalResultInteger;
                        secondAnsDec  <= finalResultDecimal;
                        calculationPhase <= 26;
                    end
                end
                // Phase 26: Compute (second x)^2
                26: begin
                    firstValueSign    <= secondAnsSign;
                    firstValueInteger <= secondAnsInt;
                    firstValueDecimal <= secondAnsDec;
                    secondValueSign   <= secondAnsSign;
                    secondValueInteger<= secondAnsInt;
                    secondValueDecimal<= secondAnsDec;
                    operation         <= MUL;
                    calculationPhase  <= 27;
                end
                // Phase 27: Latch (second x)^2
                27: begin
                    if (isCalculatedFloating) begin
                        secondAnsSquareSign <= finalSign;
                        secondAnsSquareInt  <= finalResultInteger;
                        secondAnsSquareDec  <= finalResultDecimal;
                        calculationPhase <= 28;
                    end
                end
                // Phase 28: Compute a1*(second x)^2
                28: begin
                    firstValueSign    <= secondAnsSquareSign;
                    firstValueInteger <= secondAnsSquareInt;
                    firstValueDecimal <= secondAnsSquareDec;
                    secondValueSign   <= a1Sign;
                    secondValueInteger<= a1Integer;
                    secondValueDecimal<= 0;
                    operation         <= MUL;
                    calculationPhase  <= 29;
                end
                // Phase 29: Latch a1*(second x)^2
                29: begin
                    if (isCalculatedFloating) begin
                        secondAnsSquareMultiplyASign <= finalSign;
                        secondAnsSquareMultiplyAInt  <= finalResultInteger;
                        secondAnsSquareMultiplyADec  <= finalResultDecimal;
                        calculationPhase <= 30;
                    end
                end
                // Phase 30: Compute b1*(second x)
                30: begin
                    firstValueSign    <= secondAnsSign;
                    firstValueInteger <= secondAnsInt;
                    firstValueDecimal <= secondAnsDec;
                    secondValueSign   <= b1Sign;
                    secondValueInteger<= b1Integer;
                    secondValueDecimal<= 0;
                    operation         <= MUL;
                    calculationPhase  <= 31;
                end
                // Phase 31: Latch b1*(second x)
                31: begin
                    if (isCalculatedFloating) begin
                        secondAnsMultiplyBSign <= finalSign;
                        secondAnsMultiplyBInt  <= finalResultInteger;
                        secondAnsMultiplyBDec  <= finalResultDecimal;
                        calculationPhase <= 32;
                    end
                end
                // Phase 32: Compute (a1*(second x)^2 + b1*(second x))
                32: begin
                    firstValueSign    <= secondAnsSquareMultiplyASign;
                    firstValueInteger <= secondAnsSquareMultiplyAInt;
                    firstValueDecimal <= secondAnsSquareMultiplyADec;
                    secondValueSign   <= secondAnsMultiplyBSign;
                    secondValueInteger<= secondAnsMultiplyBInt;
                    secondValueDecimal<= secondAnsMultiplyBDec;
                    operation         <= ADD;
                    calculationPhase  <= 33;
                end
                // Phase 33: Latch (a1*(second x)^2 + b1*(second x))
                33: begin
                    if (isCalculatedFloating) begin
                        secondAnsAPlusBSign <= finalSign;
                        secondAnsAPlusBInt  <= finalResultInteger;
                        secondAnsAPlusBDec  <= finalResultDecimal;
                        calculationPhase <= 34;
                    end
                end
                // Phase 34: Compute y2 = (a1*(second x)^2 + b1*(second x)) + c1
                34: begin
                    firstValueSign    <= secondAnsAPlusBSign;
                    firstValueInteger <= secondAnsAPlusBInt;
                    firstValueDecimal <= secondAnsAPlusBDec;
                    secondValueSign   <= c1Sign;
                    secondValueInteger<= c1Integer;
                    secondValueDecimal<= 0;
                    operation         <= ADD;
                    calculationPhase  <= 35;
                end
                // Phase 35: Latch y2
                35: begin
                    if (isCalculatedFloating) begin
                        secondAnsYSign <= finalSign;
                        secondAnsYInt  <= finalResultInteger;
                        secondAnsYDec  <= finalResultDecimal;
                        calculationPhase <= 36;
                    end
                end
                // Phase 36: Final assignments
                36: begin
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
                    calculationPhase <= 37;
                end
                // Phase 37: Final state, waiting for next startCalculate.
                37: begin
                    // No operation.
                end
                default: ;
            endcase
        end
    end

endmodule
