`timescale 1ns / 1ps

module FloatingPoint(
    input          firstValueSign,
    input          secondValueSign,
    input [13:0]   firstValueInteger, 
    input [13:0]   secondValueInteger,
    input [13:0]   firstValueDecimal,   
    input [13:0]   secondValueDecimal,  
    input [1:0]    operation,
    output         finalSign,
    output [13:0]  finalResultInteger, 
    output [13:0]  finalResultDecimal,
    output reg isCalculated   
);

    // Using 14 fractional bits for 4-digit precision:
    reg signed [28:0] firstValue;
    reg signed [28:0] secondValue;
    
    reg signed [57:0] intermediateResult;
    reg [1:0]         signOverride;
    wire [28:0] finalResultDecimalUnrounded;
    
    localparam ADD         = 0;
    localparam SUB         = 1;
    localparam MUL         = 2;
    localparam DIV         = 3;
    
    localparam POS         = 0;
    localparam NEG         = 1;
    localparam NO_OVERRIDE = 2;
    
    always @(*) begin
        isCalculated = 0;
        signOverride = NO_OVERRIDE;
    
        // Build fixed-point values using 14 fractional bits
        firstValue  = (firstValueInteger << 14) + ((firstValueDecimal << 14) / 10000);
        secondValue = (secondValueInteger << 14) + ((secondValueDecimal << 14) / 10000);
 
        // Evaluate the operation using a case statement with nested if/else
        case (operation)
            ADD: begin
                // Adjust sign for operands if required
                if (firstValueSign == NEG) begin
                    firstValue = -firstValue;
                end
                if (secondValueSign == NEG) begin
                    secondValue = -secondValue;
                end
                // Then add
                intermediateResult = firstValue + secondValue;
                
                // Nested if statements within the ADD branch for sign adjustment
                if (intermediateResult < 0) begin
                    intermediateResult = -intermediateResult;
                    signOverride = NEG;
                end else begin
                    signOverride = POS;
                end
            end
            
            SUB: begin
                // Adjust sign for operands if required
                if (firstValueSign == NEG) begin
                    firstValue = -firstValue;
                end
                if (secondValueSign == NEG) begin
                    secondValue = -secondValue;
                end
                // Then subtract
                intermediateResult = firstValue - secondValue;
                
                // Nested if statements within the SUB branch for sign adjustment
                if (intermediateResult < 0) begin
                    intermediateResult = -intermediateResult;
                    signOverride = NEG;
                end else begin
                    signOverride = POS;
                end
            end
            
            MUL: begin
                intermediateResult = (firstValue * secondValue) >>> 14;
            end
            
            DIV: begin
                intermediateResult = (firstValue << 14) / secondValue;
            end
            
            default: begin
                intermediateResult = 0;
            end
        endcase

        isCalculated = 1; // Set the flag to indicate calculation is done
    end
    
    // Extract the integer portion from bits [27:14]
    assign finalResultInteger = intermediateResult[27:14];
    
    // Extract the fractional portion from bits [13:0] and scale it back
    assign finalResultDecimalUnrounded = ((intermediateResult[13:0] * 10000) >> 14);
    assign finalResultDecimal = finalResultDecimalUnrounded[13:0];
    
    // Final sign is determined by signOverride if set; otherwise, use the XOR of the input signs
    assign finalSign = (signOverride == POS) ? POS :
                       (signOverride == NEG) ? NEG :
                       ((firstValueSign ^ secondValueSign) ? NEG : POS);

endmodule
