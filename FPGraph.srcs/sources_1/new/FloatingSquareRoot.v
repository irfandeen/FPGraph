`timescale 1ns / 1ps

module FloatingSquareRoot(
    input basysClock,
    input startCalculate,
    input sign,
    input [13:0] xInteger,
    input [13:0] xDecimal,
    output reg [13:0] resultInteger,
    output reg [13:0] resultDecimal,
    output resultSign,
    output reg isCalculated

    /*
    //DEBUG ONLY
    //output  [23:0] finalResultIntegerDebug,
    //output  [23:0] finalResultDecimalDebug,
    //output  isFloatingCalculatedDebug,
    //output reg [3:0] stateDebug,
    //output reg [3:0] innerStateDebug
    //DEBUG ONLY
    */
);

    localparam ADD         = 0;
    localparam SUB         = 1;
    localparam MUL         = 2;
    localparam DIV         = 3;
    
    localparam POS         = 0;
    localparam NEG         = 1;
    localparam NO_OVERRIDE = 2;

    reg firstValueSign  = POS;
    reg secondValueSign = POS;
    reg [13:0] firstValueInteger;
    reg [13:0] firstValueDecimal;
    reg [13:0] secondValueInteger;
    reg [13:0] secondValueDecimal;
    reg [1:0]  operation;

    wire       finalSign;
    wire [13:0] finalResultInteger;
    wire [13:0] finalResultDecimal;
    wire        isFloatingCalculated;
    
    //DEBUG ONLY
    //assign isFloatingCalulcatedDebug = isFloatingCalculated;
    //assign finalResultIntegerDebug = finalResultInteger;
    //assign finalResultDecimalDebug = finalResultDecimal;
    //DEBUG ONLY

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
        .isCalculated(isFloatingCalculated)
    );

    assign resultSign = POS;

    reg prevStartCalculate = 0;
    reg [3:0] state      = 12;
    reg [3:0] innerState = 0;        
    reg [13:0] guessInteger = 1;
    reg [13:0] guessDecimal;
    reg [13:0] xDividedByGuessInteger;
    reg [13:0] xDividedByGuessDecimal;
    reg [13:0] xPlusXDividedByGuessInteger;
    reg [13:0] xPlusXDividedByGuessDecimal;

    always @(posedge basysClock) begin
        //DEBUG ONLY
        //stateDebug <= state;
        //innerStateDebug <= innerState;
        //DEBUG ONLY

        prevStartCalculate <= startCalculate;
        if (prevStartCalculate == 0 && startCalculate == 1) begin
            state         <= 0;
            isCalculated  <= 0;
            resultInteger <= 0;
            resultDecimal <= 0;
            guessInteger  <= 1;
            guessDecimal  <= 0;
            innerState    <= 0;
        end

        case (state)
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9: begin
                if (innerState == 0) begin
                    firstValueInteger  <= xInteger;
                    firstValueDecimal  <= xDecimal;
                    secondValueInteger <= guessInteger;
                    secondValueDecimal <= guessDecimal;
                    operation          <= DIV;
                    innerState         <= 1;
                end
                else if (innerState == 1 && isFloatingCalculated == 1) begin
                    xDividedByGuessInteger <= finalResultInteger;
                    xDividedByGuessDecimal <= finalResultDecimal;
                    innerState             <= 2;
                end
                else if (innerState == 2) begin
                    firstValueInteger  <= xDividedByGuessInteger;
                    firstValueDecimal  <= xDividedByGuessDecimal;
                    secondValueInteger <= guessInteger;
                    secondValueDecimal <= guessDecimal;
                    operation          <= ADD;
                    innerState         <= 3;
                end
                else if (innerState == 3 && isFloatingCalculated == 1) begin
                    xPlusXDividedByGuessInteger <= finalResultInteger;
                    xPlusXDividedByGuessDecimal <= finalResultDecimal;
                    innerState                  <= 4;
                end
                else if (innerState == 4) begin
                    firstValueInteger  <= xPlusXDividedByGuessInteger;
                    firstValueDecimal  <= xPlusXDividedByGuessDecimal;
                    secondValueInteger <= 2;
                    secondValueDecimal <= 0;
                    operation          <= DIV;
                    innerState         <= 5;
                end
                else if (innerState == 5 && isFloatingCalculated == 1) begin
                    guessInteger <= finalResultInteger;
                    guessDecimal <= finalResultDecimal;
                    innerState   <= 0;
                    state        <= state + 1;
                end
            end

            10: begin
                resultInteger <= guessInteger;
                resultDecimal <= guessDecimal;
                state <= 11;
            end

            11: begin
                isCalculated <= 1;
                state <= 12;
            end
            
            12: begin
            //Do nothing
            end

            default: begin
                state <= 12;
            end
        endcase
    end

endmodule
