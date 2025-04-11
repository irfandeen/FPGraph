`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2025 09:27:17 PM
// Design Name: 
// Module Name: scene_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module scene_controller(
    input btnc,
    input btnr,
    input btnl,
    input btnu,
    input btnd,
    input CLOCK,
    input [7:0] x_cor,
    input [7:0] y_cor,
    output  reg [7:0] array_out,
    output [6:0] int_part_A1, int_part_B1, int_part_C1,
                  int_part_A2, int_part_B2, int_part_C2,
                  int_part_A3, int_part_B3, int_part_C3,
    
    output reg    is_negA1 = 0, is_negB1 = 0, is_negC1 = 0,
                  is_negA2 = 0, is_negB2 = 0, is_negC2 = 0,
                  is_negA3 = 0, is_negB3 = 0, is_negC3 = 0,
    output reg [15:0] text_colour = 16'hFFFF,
    output reg [15:0] back_colour = 16'h0000           

    

    );
    
    reg [7:0] pixel_array [0:11][0:17];
    parameter [7:0] start_x = 3;
    parameter [7:0] start_y = 2;
    parameter [7:0] end_x = 92;
    parameter [7:0] end_y = 61;
    
    wire [7:0] x = ((x_cor - 3) / 5 > 17) ? 17 : (x_cor < 3) ? 0 : (x_cor - 3) / 5;
    wire [7:0] y = ((y_cor - 2) / 5 > 11) ? 11 : (y_cor < 2) ? 0 : (y_cor - 2) / 5;
    
    
        
    //debouncing
    // Debounce counter and period 
    reg [23:0] debounceCounter = 0;
    //reg prevPushState = 0;
    localparam DEBOUNCE_PERIOD = 24'd4000000; // 160ms at 25MHz
    reg btnc_press, btnr_press;
    reg btnl_press, btnu_press;
    reg btnd_press;
    reg [4:0] prevPushState;
    
    //states
    parameter [3:0] interstate = 4'd0;
    parameter [3:0] mainmenu_1 = 4'd1;
    parameter [3:0] quadrmenu = 4'd2;
    parameter [3:0] start = 4'd6;
    parameter [3:0] colour = 4'd7;
    parameter [3:0] numpad = 4'd4;
    parameter [3:0] eqnmenu = 4'd5;
    
    //state var
    reg [7:0] state = interstate;
    reg [7:0] nextstate = start;
    reg [7:0] prevstate = interstate;
    reg [7:0] dot_x = 4;
    reg [7:0] dot_y = 7;
    reg [7:0] eqn = 1;
    
  
    //displayed var
    reg [7:0] letter;
    integer i,j;
   
    // Shared across all instances
    reg [4:0] digit_in;
    reg is_deci;
    
    reg addA1, addB1, addC1;
    reg addA2, addB2, addC2;
    reg addA3, addB3, addC3;
    
    reg addD1, addD2, addD3;
    reg is_negD1, is_negD2, is_negD3;
    reg clearD1, clearD2, clearD3;

    
    
    // Bitmaps for pixel drawing
    wire [7:0] b4D1, b3D1, neg_signD1;
    wire [7:0] b4D2, b3D2, neg_signD2;
    wire [7:0] b4D3, b3D3, neg_signD3;
    
    //colours
    //background
    parameter [15:0] black = 16'h0000;
    parameter [15:0] blue = 16'h001F;
    parameter [15:0] grey = 16'h8410;
    parameter [15:0] orange = 16'hFD20;
    
    //text
    parameter [15:0] white = 16'hFFFF;
    parameter [15:0] green = 16'h07E0;
    parameter [15:0] red = 16'hF800;
    parameter [15:0] cyan = 16'h07FF;
    
    reg [1:0] text_state = 0;
    reg [1:0] back_state = 0;

    
    // ----- Instance A1 -----
    //wire [13:0] int_part_A1; wire [6:0] deci_part_A1;
    wire [7:0] b4A1, b3A1, neg_signA1;
    reg clearA1;
    
    // ----- Instance B1 -----
    //wire [13:0] int_part_B1; wire [6:0] deci_part_B1;
    wire [7:0] b4B1, b3B1, neg_signB1;
    reg clearB1;
    
    // ----- Instance C1 -----
    //wire [13:0] int_part_C1; wire [6:0] deci_part_C1;
    wire [7:0] b4C1, b3C1, neg_signC1;
    reg clearC1;
    
    // ----- Instance A2 -----
    //wire [13:0] int_part_A2; wire [6:0] deci_part_A2;
    wire [7:0] b4A2, b3A2, neg_signA2;
    reg clearA2;
    
    // ----- Instance B2 -----
    //wire [13:0] int_part_B2; wire [6:0] deci_part_B2;
    wire [7:0] b4B2, b3B2, neg_signB2;
    reg clearB2;
    
    // ----- Instance C2 -----
    //wire [13:0] int_part_C2; wire [6:0] deci_part_C2;
    wire [7:0] b4C2, b3C2, neg_signC2;
    reg clearC2;
    
    // ----- Instance A3 -----
    //wire [13:0] int_part_A3; wire [6:0] deci_part_A3;
    wire [7:0] b4A3, b3A3, neg_signA3;
    reg clearA3;
    
    // ----- Instance B3 -----
    //wire [13:0] int_part_B3; wire [6:0] deci_part_B3;
    wire [7:0] b4B3, b3B3, neg_signB3;
    reg clearB3;
    
    // ----- Instance C3 -----
   //wire [13:0] int_part_C3; wire [6:0] deci_part_C3;
    wire [7:0] b4C3, b3C3, neg_signC3;
    reg clearC3;
    
    // ----- A1 -----
    num_gen A1 (
        .digit_in(digit_in), .add(addA1), .clear(clearA1), .CLOCK(CLOCK),
        .is_neg(is_negA1),
        .int_part(int_part_A1), .neg_sign(neg_signA1),
        .b4(b4A1), .b3(b3A1)
    );
    
    // ----- B1 -----
    num_gen B1 (
        .digit_in(digit_in), .add(addB1), .clear(clearB1), .CLOCK(CLOCK),
         .is_neg(is_negB1),
        .int_part(int_part_B1), .neg_sign(neg_signB1),
        .b4(b4B1), .b3(b3B1)
    );
    
    // ----- C1 -----
    num_gen C1 (
        .digit_in(digit_in), .add(addC1), .clear(clearC1), .CLOCK(CLOCK),
        .is_neg(is_negC1),
        .int_part(int_part_C1), .neg_sign(neg_signC1),
        .b4(b4C1), .b3(b3C1)
    );
    
    // ----- A2 -----
    num_gen A2 (
        .digit_in(digit_in), .add(addA2), .clear(clearA2), .CLOCK(CLOCK),
        .is_neg(is_negA2),
        .int_part(int_part_A2), .neg_sign(neg_signA2),
        .b4(b4A2), .b3(b3A2)
    );
    
    // ----- B2 -----
    num_gen B2 (
        .digit_in(digit_in), .add(addB2), .clear(clearB2), .CLOCK(CLOCK),
        .is_neg(is_negB2),
        .int_part(int_part_B2), .neg_sign(neg_signB2),
        .b4(b4B2), .b3(b3B2)
    );
    
    // ----- C2 -----
    num_gen C2 (
        .digit_in(digit_in), .add(addC2), .clear(clearC2), .CLOCK(CLOCK),
         .is_neg(is_negC2),
        .int_part(int_part_C2), .neg_sign(neg_signC2),
        .b4(b4C2), .b3(b3C2)
    );
    
    // ----- A3 -----
    num_gen A3 (
        .digit_in(digit_in), .add(addA3), .clear(clearA3), .CLOCK(CLOCK),
        .is_neg(is_negA3),
        .int_part(int_part_A3), .neg_sign(neg_signA3),
        .b4(b4A3), .b3(b3A3)
    );
    
    // ----- B3 -----
    num_gen B3 (
        .digit_in(digit_in), .add(addB3), .clear(clearB3), .CLOCK(CLOCK),
        .is_neg(is_negB3),
        .int_part(int_part_B3), .neg_sign(neg_signB3),
        .b4(b4B3), .b3(b3B3)
    );
    
    // ----- C3 -----
    num_gen C3 (
        .digit_in(digit_in), .add(addC3), .clear(clearC3), .CLOCK(CLOCK),
        .is_neg(is_negC3),
        .int_part(int_part_C3), .neg_sign(neg_signC3),
        .b4(b4C3), .b3(b3C3)
    );
    




    
    
     //Button synchronization and edge detection
        always @(posedge CLOCK) begin
        
             if (debounceCounter == 0) begin
            // No new presses this cycle
            btnu_press <= 0; btnd_press <= 0;
            btnc_press <= 0; btnr_press <= 0; btnl_press <= 0;
        end
        
        if (debounceCounter > 0) begin
            debounceCounter <= debounceCounter - 1;
            btnu_press <= 0; btnd_press <= 0;
            btnc_press <= 0; btnr_press <= 0; btnl_press <= 0;
        end else begin
            // Detect new press per button (rising edge)
            if (btnu && !prevPushState[0]) begin
                btnu_press <= 1;
                debounceCounter <= DEBOUNCE_PERIOD;
            end
            if (btnd && !prevPushState[1]) begin
                btnd_press <= 1;
                debounceCounter <= DEBOUNCE_PERIOD;
            end
            if (btnc && !prevPushState[2]) begin
                btnc_press <= 1;
                debounceCounter <= DEBOUNCE_PERIOD;
            end
            if (btnr && !prevPushState[3]) begin
                btnr_press <= 1;
                debounceCounter <= DEBOUNCE_PERIOD;
            end
            if (btnl && !prevPushState[4]) begin
                btnl_press <= 1;
                debounceCounter <= DEBOUNCE_PERIOD;
            end
        end
        
        // Always update prevPushState at the end
        prevPushState[0] <= btnu;
        prevPushState[1] <= btnd;
        prevPushState[2] <= btnc;
        prevPushState[3] <= btnr;
        prevPushState[4] <= btnl;
 
        end
        
        always @ (posedge CLOCK) begin
        if (state == interstate) begin
         for (i = 0 ; i < 18 ; i = i + 1)begin 
            for (j = 0 ; j < 12 ; j = j + 1) begin
               pixel_array[j][i] <= 8'd36;
            end
         end
         
         state <= nextstate;
         
         //BTN UP
            end else if (btnu_press) begin
            
            case(state)
            
            quadrmenu:begin
            if (dot_y == 5) begin
            pixel_array[dot_y][dot_x] <=8'd36;
            dot_y <= 1;
            dot_x <= 1;
            end else if (dot_y > 5) begin
            pixel_array[dot_y][dot_x] <= 8'd36;
            dot_y <= dot_y - 2;   
            dot_x <= 4;   
            end
            end
            
            
            numpad:begin
            pixel_array[dot_y][dot_x] <= 8'd36;
            dot_y <= (dot_x == 13) ? ((dot_y > 8) ? dot_y - 3 : dot_y) : ((dot_y > 2) ? dot_y - 3 : dot_y);
            end
            
            eqnmenu:begin
            pixel_array[dot_y][dot_x] <= 8'd36;
            dot_y <= (dot_y == 11) ? dot_y - 2 : (dot_y > 3) ? dot_y - 3 : dot_y;
            end
            
            start:begin
            pixel_array[dot_y][dot_x] <= 8'd36;
            dot_y <= (dot_y > 7) ? dot_y - 2 : dot_y;
            end
            
            colour:begin
            pixel_array[dot_y][dot_x] <= 8'd36;
            dot_y <= (dot_y > 4) ? dot_y - 2 : dot_y;
            end
           
            default:state <= interstate;  
            endcase
            
            end
            
            //BTN DOWN
            else if (btnd_press) begin
            case(state)
               
              quadrmenu:begin
              if (dot_y == 1) begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_y <= 5;
              dot_x <= 4;
              end 
              else begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_y <= (dot_y < 9) ? dot_y + 2: dot_y;
              end
              end
              
              
              
              numpad:begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_y <= (dot_y < 11) ? dot_y + 3 : dot_y;
              dot_x <= (dot_x == 9 && dot_y == 8) ? 5 : dot_x;
              end
              
              eqnmenu:begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_y <= (dot_y == 9) ? dot_y + 2 : (dot_y < 9) ? dot_y + 3 : dot_y;
              end
              
              start:begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_y <= (dot_y < 9) ? dot_y + 2 : dot_y;
              end
              
              colour:begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_y <= (dot_y < 8) ? dot_y + 2 : dot_y;
              end
              
              default:state <= interstate;  
            endcase
            end
            
            
            //BTN CNTR
            else if (btnc_press) begin
            
            case(state)
              
              quadrmenu:begin
              if (dot_y == 1 && dot_x ==1) begin
              
              case(eqn)
              1:begin
              is_negA1 <= 0;
              clearA1 <= 1;
              is_negB1 <= 0;
              clearB1 <= 1;
              is_negC1 <= 0;
              clearC1 <= 1;
                          
              end
              2:begin
              is_negA2 <= 0;
              clearA2 <= 1;
              is_negB2 <= 0;
              clearB2 <= 1;
              is_negC2 <= 0;
              clearC2 <= 1;
              
              end
              3:begin
              is_negA3 <= 0;
              clearA3 <= 1;
              is_negB3 <= 0;
              clearB3 <= 1;
              is_negC3 <= 0;
              clearC3 <= 1;
              
              end
              default:;
              endcase
              end
              else if (dot_x == 12 && dot_y == 1) begin
              state <= interstate; nextstate <= eqnmenu;
              dot_x <= 1;
              dot_y <= eqn * 3;
              end

              else begin
               if (dot_y == 5 && dot_x == 4) begin
                   letter <= 6'd10;
               end
               else if (dot_y == 7 && dot_x == 4) begin
                   letter <= 6'd11;
               end
               else if (dot_y == 9 && dot_x == 4) begin
                   letter <= 6'd12;
               end
               
              
               state <= interstate;
               nextstate <= numpad;
               prevstate <= quadrmenu;
               dot_x <= 1;
               dot_y <= 2;
              end
              

              end
              
            
              numpad:begin
              if (dot_x == 13 && dot_y == 8) begin
              dot_x <= 4; dot_y <= 5 + (letter - 10) * 2;
              nextstate <= prevstate;
              state <= interstate;
                         
              end
              else if (dot_x == 5 && dot_y == 11) begin
              digit_in <= 0;
              case(eqn)
              1:begin
              if (letter == 6'd10) begin
              addA1 <= 1;
              end
              if (letter == 6'd11) begin
              addB1 <= 1;
              end
              if (letter == 6'd12) begin
              addC1 <= 1;
              end
                           
              end
              2:begin
              if (letter == 6'd10) begin
              addA2 <= 1;
              end
              if (letter == 6'd11) begin
              addB2 <= 1;
              end
              if (letter == 6'd12) begin
              addC2 <= 1;
              end
              
              end
              3:begin
              if (letter == 6'd10) begin
              addA3 <= 1;
              end
              if (letter == 6'd11) begin
              addB3 <= 1;
              end
              if (letter == 6'd12) begin
              addC3 <= 1;
              end
             
              end
              default:;
              endcase
              end
              
              else if (dot_x == 1 && dot_y == 11) begin
              case(eqn)
                  1: begin
                      if (letter == 6'd10) begin
                          is_negA1 <= 1;
                      end
                      if (letter == 6'd11) begin
                          is_negB1 <= 1;
                      end
                      if (letter == 6'd12) begin
                          is_negC1 <= 1;
                      end
                      
                  end
                  
                  2: begin
                      if (letter == 6'd10) begin
                          is_negA2 <= 1;
                      end
                      if (letter == 6'd11) begin
                          is_negB2 <= 1;
                      end
                      if (letter == 6'd12) begin
                          is_negC2 <= 1;
                      end
                     
                  end
                  
                  3: begin
                      if (letter == 6'd10) begin
                          is_negA3 <= 1;
                      end
                      if (letter == 6'd11) begin
                          is_negB3 <= 1;
                      end
                      if (letter == 6'd12) begin
                          is_negC3 <= 1;
                      end
                      
                  end
                  
                  default: ;
              endcase            
              end
              
              else if (dot_x == 13 && dot_y == 11) begin
              case(eqn)
                  1: begin
                      if (letter == 6'd10) begin
                          clearA1 <= 1;
                          
                          is_negA1 <= 0;
                      end
                      if (letter == 6'd11) begin
                          clearB1 <= 1;
                          
                          is_negB1 <= 0;
                      end
                      if (letter == 6'd12) begin
                          clearC1 <= 1;
                          
                          is_negC1 <= 0;
                      end
                      
                  end
              
                  2: begin
                      if (letter == 6'd10) begin
                          clearA2 <= 1;
                          
                          is_negA2 <= 0;
                      end
                      if (letter == 6'd11) begin
                          clearB2 <= 1;
                          
                          is_negB2 <= 0;
                      end
                      if (letter == 6'd12) begin
                          clearC2 <= 1;
                          
                          is_negC2 <= 0;
                      end
                      
                  end
              
                  3: begin
                      if (letter == 6'd10) begin
                          clearA3 <= 1;
                          
                          is_negA3 <= 0;
                      end
                      if (letter == 6'd11) begin
                          clearB3 <= 1;
                          
                          is_negB3 <= 0;
                      end
                      if (letter == 6'd12) begin
                          clearC3 <= 1;
                          
                          is_negC3 <= 0;
                      end
                      
                  end
              
                  default: ;
              endcase


              end
              
              else begin
              digit_in <= 1 + ((dot_x - 1) / 4) + ((dot_y - 2));
              case(eqn)
                  1: begin
                      if (letter == 6'd10) begin
                          addA1 <= 1;
                      end
                      if (letter == 6'd11) begin
                          addB1 <= 1;
                      end
                      if (letter == 6'd12) begin
                          addC1 <= 1;
                      end
                      
                  end
              
                  2: begin
                      if (letter == 6'd10) begin
                          addA2 <= 1;
                      end
                      if (letter == 6'd11) begin
                          addB2 <= 1;
                      end
                      if (letter == 6'd12) begin
                          addC2 <= 1;
                      end
                      
                  end
              
                  3: begin
                      if (letter == 6'd10) begin
                          addA3 <= 1;
                      end
                      if (letter == 6'd11) begin
                          addB3 <= 1;
                      end
                      if (letter == 6'd12) begin
                          addC3 <= 1;
                      end
                      
                  end
              
                  default: ;
              endcase

              end
              
              end
              
              eqnmenu:begin
              if (dot_y == 11) begin
              state <= interstate;
              nextstate <= start;
              dot_x <= 4;
              dot_y <= 7;
              end else begin

              eqn <= dot_y / 3;
              state <= interstate;
              nextstate <= quadrmenu;
              dot_x <= 1;
              dot_y <= 1;
              end

              end
              
              start:begin
              if (dot_y == 7) begin
              state <= interstate;
              nextstate <= eqnmenu;
              dot_x <= 1;
              dot_y <= 3;
              end
              else if (dot_y == 9) begin
              state <= interstate;
              nextstate <= colour;
              dot_x <= 1;
              dot_y <= 4;
              end
              end
              
              colour:begin
              if (dot_y == 6) begin
              text_state <= (text_state == 2'd3) ? 0 : text_state + 1;
              end
              else if (dot_y == 4) begin
              back_state <= (back_state == 2'd3) ? 0 : back_state + 1;
              end
              else if (dot_y == 8) begin
              state <= interstate;
              nextstate <= start;
              dot_x <= 4;
              dot_y <= 9;
              end
              end
              
              default:state <= interstate;
            endcase
            end
            
            
            //BTN RIGHT
            else if (btnr_press) begin
              case(state)
              quadrmenu:begin
              if (dot_y == 1 && dot_x == 1) begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_x <= 12;
              end
              end
              
             
              numpad:begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_x <= (dot_y == 11 && dot_x == 5) ? dot_x + 8 : (dot_y < 8) ? ((dot_x < 9) ? dot_x + 4 : dot_x) : ((dot_x < 13) ? dot_x + 4 : dot_x);
              end
              
              
              
              default:;
              endcase
            end
            
            
            //BTN LEFT
            else if (btnl_press) begin
              case(state)
              quadrmenu:begin
                if (dot_y == 1 && dot_x == 12) begin
                   pixel_array[dot_y][dot_x] <= 8'd36;
                   dot_x <= 1;
                end

              end
             
           
              
              numpad:begin
              pixel_array[dot_y][dot_x] <= 8'd36;
              dot_x <= (dot_x == 13 && dot_y == 11) ? dot_x - 8 : (dot_x > 1) ? dot_x - 4 : dot_x;
              end
              
              
              default:;
              endcase
            end
            
            else if (state == nextstate) begin
            
            case(state)
            
            quadrmenu: begin
            //reset
            pixel_array[1][3] <= 8'd27;pixel_array[1][4] <= 8'd14;
            pixel_array[1][5] <= 8'd28;pixel_array[1][6] <= 8'd14;
             pixel_array[1][7] <= 8'd29;
            //done
            pixel_array[1][14] <= 8'd13;pixel_array[1][15] <= 8'd24;
            pixel_array[1][16] <= 8'd23;pixel_array[1][17] <= 8'd14;
            //dot
            pixel_array[dot_y][dot_x] <= 8'd37;
            
            
            //y=ax^2+bx+c
            pixel_array[3][2] <= 8'd34;pixel_array[3][3] <= 8'd43;
            pixel_array[3][4] <= 8'd10;pixel_array[3][5] <= 8'd33;
            pixel_array[3][6] <= 8'd42;pixel_array[3][7] <= 8'd2;
            pixel_array[3][8] <= 8'd38;pixel_array[3][9] <= 8'd11;
            pixel_array[3][10] <= 8'd33;pixel_array[3][11] <= 8'd38;
            pixel_array[3][12] <= 8'd12;
            //a=
            pixel_array[5][6] <= 8'd10;pixel_array[5][7] <= 8'd43;
            //b=
            pixel_array[7][6] <= 8'd11;pixel_array[7][7] <= 8'd43;
            //c=
            pixel_array[9][6] <= 8'd12;pixel_array[9][7] <= 8'd43;
            
            
            // DISPLAY THE NUM
            case(eqn)
                1: begin
                    // A1
                    pixel_array[5][9]  <= b4A1; pixel_array[5][10]  <= b3A1;                   
                    pixel_array[5][8]  <= neg_signA1;
            
                    // B1
                    pixel_array[7][9]  <= b4B1; pixel_array[7][10]  <= b3B1;
                    pixel_array[7][8]  <= neg_signB1;
            
                    // C1
                    pixel_array[9][9]  <= b4C1; pixel_array[9][10]  <= b3C1;
                    pixel_array[9][8]  <= neg_signC1;
            
                end
            
                2: begin
                    // A2
                    pixel_array[5][9]  <= b4A2; pixel_array[5][10]  <= b3A2;
                    pixel_array[5][8]  <= neg_signA2;
            
                    // B2
                    pixel_array[7][9]  <= b4B2; pixel_array[7][10]  <= b3B2;
                    pixel_array[7][8]  <= neg_signB2;
            
                    // C2
                    pixel_array[9][9]  <= b4C2; pixel_array[9][10]  <= b3C2;
                    pixel_array[9][8]  <= neg_signC2;
            
                end
            
                3: begin
                    // A3
                    pixel_array[5][9]  <= b4A3; pixel_array[5][10]  <= b3A3;
                    pixel_array[5][8]  <= neg_signA3;
            
                    // B3
                    pixel_array[7][9]  <= b4B3; pixel_array[7][10]  <= b3B3;
                    pixel_array[7][8]  <= neg_signB3;
            
                    // C3
                    pixel_array[9][9]  <= b4C3; pixel_array[9][10]  <= b3C3;
                    pixel_array[9][8]  <= neg_signC3;
            
                end
            
                default: ;
            endcase

            end
        
            
            numpad: begin
            //numbers
            pixel_array[2][3] <= 8'd1;pixel_array[2][7] <= 8'd2;
            pixel_array[2][11] <= 8'd3;pixel_array[5][3] <= 8'd4;
            pixel_array[5][7] <= 8'd5;pixel_array[5][11] <= 8'd6;
            pixel_array[8][3] <= 8'd7;pixel_array[8][7] <= 8'd8;
            pixel_array[8][11] <= 8'd9;pixel_array[11][3] <= 8'd39;
            pixel_array[11][7] <= 8'd0;
            pixel_array[8][15] <= 8'd28;pixel_array[8][16] <= 8'd14;
            pixel_array[8][17] <= 8'd29;pixel_array[11][15] <= 8'd12;
            pixel_array[11][16] <= 8'd21;pixel_array[11][17] <= 8'd27;
            
            //dot
            pixel_array[dot_y][dot_x] <= 8'd37;
            
            addA1 <= 0; addB1 <= 0; addC1 <= 0;
            addA2 <= 0; addB2 <= 0; addC2 <= 0;
            addA3 <= 0; addB3 <= 0; addC3 <= 0;
                   
            
           
            
            //letter
            pixel_array[0][1] <= letter; pixel_array[0][2] <= 8'd43;
            if (letter == 8'd10) begin
            case(eqn)
            1:begin
            pixel_array[0][4] <= b4A1; pixel_array[0][5] <= b3A1;
            pixel_array[0][3] <= neg_signA1;
            end
            
            2:begin
            pixel_array[0][4] <= b4A2; pixel_array[0][5] <= b3A2;
            pixel_array[0][3] <= neg_signA2;
            end
            
            3:begin
            pixel_array[0][4] <= b4A3; pixel_array[0][5] <= b3A3;
            pixel_array[0][3] <= neg_signA3;
            end
            default:;
            endcase
            end
            
            if (letter == 8'd11) begin
                case(eqn)
                    1: begin
                        pixel_array[0][4] <= b4B1; pixel_array[0][5] <= b3B1;
                        pixel_array[0][3] <= neg_signB1;
                    end
            
                    2: begin
                        pixel_array[0][4] <= b4B2; pixel_array[0][5] <= b3B2;
                        pixel_array[0][3] <= neg_signB2;
                    end
            
                    3: begin
                        pixel_array[0][4] <= b4B3; pixel_array[0][5] <= b3B3;
                        pixel_array[0][3] <= neg_signB3;
                    end
                    default: ;
                endcase
            end
            
            if (letter == 8'd12) begin
                case(eqn)
                    1: begin
                        pixel_array[0][4] <= b4C1; pixel_array[0][5] <= b3C1;
                        pixel_array[0][3] <= neg_signC1;
                    end
            
                    2: begin
                        pixel_array[0][4] <= b4C2; pixel_array[0][5] <= b3C2;
                        pixel_array[0][3] <= neg_signC2;
                    end
            
                    3: begin
                        pixel_array[0][4] <= b4C3; pixel_array[0][5] <= b3C3;
                        pixel_array[0][3] <= neg_signC3;
                    end
                    default: ;
                endcase
            end
          
            end
            
            eqnmenu: begin
            
            //dot
            pixel_array[dot_y][dot_x] <= 8'd37;
                        
            //fpgraph
            pixel_array[0][0] <= 8'd15; pixel_array[0][1] <= 8'd25;
            pixel_array[0][2] <= 8'd16; pixel_array[0][3] <= 8'd27;
            pixel_array[0][4] <= 8'd10; pixel_array[0][5] <= 8'd25;
            pixel_array[0][6] <= 8'd17;
           
            //equation 1
            pixel_array[3][3] <= 8'd14; pixel_array[3][4] <= 8'd26;
            pixel_array[3][5] <= 8'd30; pixel_array[3][6] <= 8'd10;
            pixel_array[3][7] <= 8'd29; pixel_array[3][8] <= 8'd18;
            pixel_array[3][9] <= 8'd24; pixel_array[3][10] <= 8'd23;
            pixel_array[3][12] <= 8'd1;
            
            //equation 2
            pixel_array[6][3] <= 8'd14; pixel_array[6][4] <= 8'd26;
            pixel_array[6][5] <= 8'd30; pixel_array[6][6] <= 8'd10;
            pixel_array[6][7] <= 8'd29; pixel_array[6][8] <= 8'd18;
            pixel_array[6][9] <= 8'd24; pixel_array[6][10] <= 8'd23;
             pixel_array[6][12] <= 8'd2;
            
            //equation 3
            pixel_array[9][3] <= 8'd14; pixel_array[9][4] <= 8'd26;
            pixel_array[9][5] <= 8'd30; pixel_array[9][6] <= 8'd10;
            pixel_array[9][7] <= 8'd29; pixel_array[9][8] <= 8'd18;
            pixel_array[9][9] <= 8'd24; pixel_array[9][10] <= 8'd23;
            pixel_array[9][12] <= 8'd3;
            
            //back
            pixel_array[11][3] <= 8'd11; pixel_array[11][4] <= 8'd10;
            pixel_array[11][5] <= 8'd12; pixel_array[11][6] <= 8'd20;
                        
            end
            
            start:begin
            //FP big big
            pixel_array[1][2] <= 8'd45; pixel_array[1][3] <= 8'd45;
             pixel_array[1][4] <= 8'd45;
            pixel_array[1][6] <= 8'd45; pixel_array[1][7] <= 8'd45;
            pixel_array[1][8] <= 8'd45; pixel_array[2][2] <= 8'd45;
            pixel_array[2][6] <= 8'd45; pixel_array[2][9] <= 8'd45;
            pixel_array[3][2] <= 8'd45; pixel_array[3][3] <= 8'd45;
            pixel_array[3][4] <= 8'd45; pixel_array[3][6] <= 8'd45;
            pixel_array[3][7] <= 8'd45; pixel_array[3][8] <= 8'd45;
            pixel_array[4][2] <= 8'd45; pixel_array[4][6] <= 8'd45;
            pixel_array[5][2] <= 8'd45; pixel_array[5][6] <= 8'd45;
            
            //graph
            pixel_array[5][10] <= 8'd16; pixel_array[5][11] <= 8'd27;
            pixel_array[5][12] <= 8'd10; pixel_array[5][13] <= 8'd25;
            pixel_array[5][14] <= 8'd17;
            
            //dot
            pixel_array[dot_y][dot_x] <= 8'd37;
            
            //start
            pixel_array[7][6] <= 8'd28; pixel_array[7][7] <= 8'd29;
            pixel_array[7][8] <= 8'd10; pixel_array[7][9] <= 8'd27;
            pixel_array[7][10] <= 8'd29;
            
            //options
            pixel_array[9][6] <= 8'd24; pixel_array[9][7] <= 8'd25;
            pixel_array[9][8] <= 8'd29; pixel_array[9][9] <= 8'd18;
            pixel_array[9][10] <= 8'd24; pixel_array[9][11] <= 8'd23;
            pixel_array[9][12] <= 8'd28;

            end
            
            colour:begin
            //dot
            pixel_array[dot_y][dot_x] <= 8'd37;
            //colour text
            pixel_array[6][10] <= (text_state == 0) ? 8'd32 : 
            (text_state == 1) ? 8'd16 : 
            (text_state == 2) ? 8'd27 : 8'd12;
            
            //colour back
            pixel_array[3][10] <= (back_state == 0) ? 8'd11 : 
            (back_state == 1) ? 8'd11 : 
            (back_state == 2) ? 8'd16 : 8'd24;
            pixel_array[3][11] <= (back_state == 0 || back_state == 1) ? 8'd21 : 8'd36;
            pixel_array[3][12] <= (back_state == 0) ? 8'd20 :(back_state == 1) ? 8'd30 : 8'd36;
            
            //colour select
            pixel_array[1][3] <= 8'd12; pixel_array[1][4] <= 8'd24;
            pixel_array[1][5] <= 8'd21; pixel_array[1][6] <= 8'd24;
            pixel_array[1][7] <= 8'd30; pixel_array[1][8] <= 8'd27;
            pixel_array[1][11] <= 8'd14; pixel_array[1][10] <= 8'd28;
            pixel_array[1][13] <= 8'd14; pixel_array[1][12] <= 8'd21;
            pixel_array[1][15] <= 8'd29; pixel_array[1][14] <= 8'd12;
            
            //background
            pixel_array[3][3] <= 8'd11; pixel_array[3][4] <= 8'd10;
            pixel_array[3][5] <= 8'd12; pixel_array[3][6] <= 8'd20;
            pixel_array[4][3] <= 8'd16; pixel_array[4][4] <= 8'd27;
            pixel_array[4][5] <= 8'd24; pixel_array[4][6] <= 8'd30;
            pixel_array[4][7] <= 8'd23; pixel_array[4][8] <= 8'd13;
            
            //text
            pixel_array[6][3] <= 8'd29; pixel_array[6][4] <= 8'd14;
            pixel_array[6][5] <= 8'd33; pixel_array[6][6] <= 8'd29;
            
            //back
            pixel_array[8][3] <= 8'd11; pixel_array[8][4] <= 8'd10;
            pixel_array[8][5] <= 8'd13; pixel_array[8][6] <= 8'd20;
            end

            default: state <= interstate;
            endcase
             // Clear all clears
                       clearA1 <= 0; clearB1 <= 0; clearC1 <= 0;
                       clearA2 <= 0; clearB2 <= 0; clearC2 <= 0;
                       clearA3 <= 0; clearB3 <= 0; clearC3 <= 0;
                       
            end
            
           
            
           
        end//end of always block
        
    
   
    
    //end//always
    
    //assign array_out = (x_cor > end_x || y_cor > end_y || x_cor < start_x || y_cor < start_y) ? 0 : pixel_array[0][0];
    always @ (posedge CLOCK) begin
       array_out <= (x_cor > end_x || y_cor > end_y || x_cor < start_x || y_cor < start_y) ? 8'd36 : pixel_array[y][x];
       text_colour <= (text_state == 0) ? white :
        (text_state == 1) ? green : 
        (text_state == 2) ? red : 
        cyan;
        
        back_colour <= (back_state == 0) ? black : 
        (back_state == 1) ? blue :
        (back_state == 2) ? grey : 
        orange;
    end
    
endmodule



