module game24(
input CLOCK_50,
input [5:0] KEY,
input [9:0] SW,
 inout  wire         PS2_CLK,    // PS/2 Clock
 inout  wire         PS2_DAT,
 // PS/2 Data

// sound
input			AUD_ADCDAT,
inout			AUD_BCLK,
inout			AUD_ADCLRCK,
inout				AUD_DACLRCK,
inout				FPGA_I2C_SDAT,
output				AUD_XCK,
output				AUD_DACDAT,
output				FPGA_I2C_SCLK,
//sound


output [9:0] LEDR,
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
output          VGA_CLK,      
output          VGA_HS,   
output          VGA_VS,       
output          VGA_BLANK_N,      
output          VGA_SYNC_N,
output  [7:0]   VGA_R,        
output  [7:0]   VGA_G,        
output  [7:0]   VGA_B        
);




//game control signals
 wire resetn, next, retry;
 assign resetn = KEY[0];
 assign retry = KEY[1];
 assign next = KEY[2];
//VGA signals
 wire [16:0] address;
 wire [23:0] title_colour, success_colour, fail_colour, error_colour, congrats_colour,
             problem1_colour, problem2_colour, problem3_colour;
 wire [23:0] oColour;
 wire [13:0] oX, oY;
 wire [2:0]  current_problem;


 //VGA signals. Images in ROM
 title1 title_img(.address(address), .clock(CLOCK_50), .q(title_colour));
 fail fail_img(.address(address), .clock(CLOCK_50), .q(fail_colour));
 success success_img(.address(address), .clock(CLOCK_50), .q(success_colour));
 error error_img(.address(address), .clock(CLOCK_50), .q(error_colour));
 problem1 problem1_img(.address(address), .clock(CLOCK_50), .q(problem1_colour));
 problem2 problem2_img(.address(address), .clock(CLOCK_50), .q(problem2_colour));
 problem3 problem3_img(.address(address), .clock(CLOCK_50), .q(problem3_colour));
 congrats congrats_img(.address(address), .clock(CLOCK_50), .q(congrats_colour));




 vga_adapter VGA(
   .resetn(resetn),
   .clock(CLOCK_50),
   .colour(oColour),
   .x(oX),
   .y(oY),
   .plot(writeEn),
   /* Signals for the DAC to drive the monitor. */
   .VGA_R(VGA_R),
   .VGA_G(VGA_G),
   .VGA_B(VGA_B),
   .VGA_HS(VGA_HS),
   .VGA_VS(VGA_VS),
   .VGA_BLANK(VGA_BLANK_N),
   .VGA_SYNC(VGA_SYNC_N),
   .VGA_CLK(VGA_CLK)
);




defparam VGA.RESOLUTION = "320x240";
defparam VGA.MONOCHROME = "FALSE";
defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
defparam VGA.BACKGROUND_IMAGE = "black.mif";








//game data signals
 wire [7:0] given_number1, given_number2, given_number3, given_number4;
 wire  writeEn, display, display_title, title_wait, display_problem, load_and_evaluate, done_reading,
       display_success, display_error, display_fail, display_congrats, inputValid, resultValid, result24;
 wire [7:0] last_data_received;
 wire [13:0] result;
 wire [32:0] timeSpent;


PS2_Comm comm(CLOCK_50, KEY[2:0], SW, PS2_CLK, PS2_DAT, last_data_received);


Hexadecimal_To_Seven_Segment Segment4 (
  .hex_number         (result[3:0]),
  .seven_seg_display  (HEX4)
  );


Hexadecimal_To_Seven_Segment Segment5 (
  .hex_number         (result[7:4]),
  .seven_seg_display  (HEX5)
);
Hexadecimal_To_Seven_Segment Segment0 (
  .hex_number         (timeSpent[3:0]),
  .seven_seg_display  (HEX0)
);
Hexadecimal_To_Seven_Segment Segment1 (
  .hex_number         (timeSpent[7:4]),
  .seven_seg_display  (HEX1)
);
Hexadecimal_To_Seven_Segment Segment2 (
  .hex_number         (timeSpent[11:8]),
  .seven_seg_display  (HEX2)
);
Hexadecimal_To_Seven_Segment Segment3 (
  .hex_number         (timeSpent[15:12]),
  .seven_seg_display  (HEX3)
);

DE1_SoC_Audio_Example sound_unit(
	// Inputs
	.display_success(display_success),
	.display_congrats(display_congrats),
	.CLOCK_50(CLOCK_50),
	.KEY(KEY[3:0]),
	.AUD_ADCDAT(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK(AUD_BCLK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	.AUD_DACLRCK(AUD_DACLRCK),

	.FPGA_I2C_SDAT(FPGA_I2C_SDAT),

	// Outputs
	.AUD_XCK(AUD_XCK),
	.AUD_DACDAT(AUD_DACDAT),

	.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
	.SW(SW[9:0])
);


//overall game control path
gameControl control_unit(
 .iClock(CLOCK_50),
 .iResetn(resetn),
 .iNext(next),
 .iRetry(retry),
 .iInputInvalid(!inputValid),
 .iResultValid(resultValid),
 .iResultIs24(result24),
 .display(display),
 .display_title(display_title),
 .display_problem(display_problem),
 .load_and_evaluate(load_and_evaluate),
 .display_success(display_success),
 .display_error(display_error),
 .display_fail(display_fail),
 .display_congrats(display_congrats),
 .current_problem(current_problem)
);




//oveall game datapath
gameData datapath_unit(
 .iClock(CLOCK_50),
 .iResetn(resetn),
 .iNext(next),
 .display(display),
 .display_title(display_title),
 .load_and_evaluate(load_and_evaluate),
 .display_success(display_success),
 .display_error(display_error),
 .display_fail(display_fail),
 .display_congrats(display_congrats),
 .display_problem(display_problem),
 .current_problem(current_problem),
 .title_colour(title_colour),
 .success_colour(success_colour),
 .fail_colour(fail_colour),
 .error_colour(error_colour),
 .congrats_colour(congrats_colour),
 .problem1_colour(problem1_colour),
 .problem2_colour(problem2_colour),
 .problem3_colour(problem3_colour),
 .givenNum1(given_number1),
 .givenNum2(given_number2),
 .givenNum3(given_number3),
 .givenNum4(given_number4),
 .oColour(oColour),
 .ox(oX),
 .oy(oY),
 .address(address),
 .writeEn(writeEn)
);




calcFSM Calculation(
 .clock(CLOCK_50),
 .reset(resetn),
 .retry(retry),
 .next(next),
 .last_data_received(last_data_received),
 .given_number1(given_number1),
 .given_number2(given_number2),
 .given_number3(given_number3),
 .given_number4(given_number4),
 .resultValid(resultValid),
 .inputValid(inputValid),
 .result(result),
 .result24(result24)
);
//state display
assign  LEDR[0] = display_title,
       LEDR[1] = display_problem,
       LEDR[2] = load_and_evaluate,
       LEDR[3] = display_success,
       LEDR[4] = display_error,
       LEDR[5] = display_fail,
       LEDR[6] = display_congrats,
       LEDR[7] = inputValid,
       LEDR[8] = resultValid,
       LEDR[9] = display;


clearTime ct(CLOCK_50, resetn, display_title,display_congrats, timeSpent);




endmodule




module gameControl (
 input iClock, iResetn, iNext, iRetry, iInputInvalid, iResultValid, iResultIs24,
 output reg display, display_title, title_wait, display_problem, load_and_evaluate,
           display_success, display_error, display_fail, display_congrats,
 output reg [2:0] current_problem
);
  reg counted = 1'b0;


initial current_problem = 3'd0;




localparam
 TITLE = 4'd0,
 TITLE_WAIT = 4'd1,
 PROBLEM = 4'd2,
 SUCCESS = 4'd5,
 ERROR = 4'd6,
 FAIL = 4'd7,
 CONGRATS = 4'd8;




reg [4:0] current_state = 4'd0, next_state;








always @* begin
case (current_state)
    TITLE: next_state = (!iNext) ? TITLE_WAIT : TITLE;
    TITLE_WAIT: next_state = (iNext) ? PROBLEM : TITLE_WAIT;
    PROBLEM: begin
       if (iInputInvalid) next_state = ERROR;
       else if (iResultValid) begin
           if (!iResultIs24) next_state = FAIL;
           else if (iResultIs24) begin
              if (current_problem == 3'd4) next_state = CONGRATS;
              else next_state = SUCCESS;
           end
        end
       else next_state = PROBLEM;
    end
    ERROR: next_state = !iRetry ? PROBLEM : ERROR;
    FAIL: next_state = !iRetry ? PROBLEM : FAIL;
    SUCCESS: begin
       if (!iRetry) next_state = PROBLEM;
       else if (!iNext) begin
           next_state = PROBLEM;
       end
       else next_state = SUCCESS;
    end
    CONGRATS: next_state = CONGRATS;
    default: next_state = TITLE;
endcase
end




always @(posedge iClock) begin
 if (!iResetn) begin
    current_state <= TITLE;
    current_problem <= 3'd0;
 end else begin
    current_state <= next_state;
    if (current_state == SUCCESS && !counted && !iNext) begin
        counted <= 1'b1;
        current_problem <= current_problem + 1;
     end else if (current_state == PROBLEM) counted <= 1'b0;
 end
end








always @* begin
 display = 0;
 display_title = 0;
 title_wait = 0;
 display_problem = 0;
 load_and_evaluate = 0;
 display_success = 0;
 display_error = 0;
 display_fail = 0;
 display_congrats = 0;




 case (current_state)
    TITLE: begin
       display = 1;
       display_title = 1;
    end
    TITLE_WAIT: begin
      display = 0;
      title_wait = 1;
    end
    PROBLEM: begin
       display = 1;
       display_problem = 1;
       load_and_evaluate = 1;
    end
    SUCCESS: begin
       display = 1;
       display_success = 1;
    end
    ERROR: begin
       display = 1;
       display_error = 1;
    end
    FAIL: begin
       display = 1;
       display_fail = 1;
    end
    CONGRATS: begin
       display = 1;
       display_congrats = 1;
    end
    default: display_title = 1;
   endcase
end
endmodule








module gameData (
 input iClock, iResetn, iNext, display, display_title, load_and_evaluate,
       display_success, display_fail, display_error, display_congrats, display_problem,
 input [2:0]    current_problem,
 input [23:0]   title_colour, success_colour, fail_colour, error_colour,
                congrats_colour, problem1_colour, problem2_colour, problem3_colour,
 output reg [7:0] givenNum1, givenNum2, givenNum3, givenNum4,
 output reg [23:0] oColour,
 output reg [13:0] ox, oy,
 output reg [16:0] address,
 output reg writeEn
);




 parameter MAX_X = 320, MAX_Y = 240;




 always @(posedge iClock) begin
    if (!iResetn) begin
    address <= 0;
    ox <= 0;
    oy <= 0;
    writeEn <= 0;
 end else begin
    if (display) begin
       writeEn <= 1;
       ox <= address % MAX_X;
       oy <= address / MAX_X;
       if (display_title) oColour <= title_colour;
       else if (display_success) oColour <= success_colour;
       else if (display_fail) oColour <= fail_colour;
       else if (display_error) oColour <= error_colour;
       else if (display_congrats) oColour <= congrats_colour;
       else if (display_problem) begin
          if (current_problem == 3'd0) oColour <= problem1_colour;
          else if (current_problem == 3'd2) oColour <= problem2_colour;
          else if (current_problem == 3'd4) oColour <= problem3_colour;
       end
       else oColour <= 0;
       if (address < (MAX_X * MAX_Y - 1)) begin
          address <= address + 1;
       end else begin
          address <= 0;
          writeEn <= 0;
          end
       end
    if (display_problem || load_and_evaluate) begin
       if (current_problem == 3'd0) begin
          givenNum1 <= 8'h16;
          givenNum2 <= 8'h26;
          givenNum3 <= 8'h1e;
          givenNum4 <= 8'h25;
       end
       else if (current_problem == 3'd2) begin
          givenNum1 <= 8'h1e;
          givenNum2 <= 8'h1e;
          givenNum3 <= 8'h1e;
          givenNum4 <= 8'h46;
       end
       else if (current_problem == 3'd4) begin
          givenNum1 <= 8'h16;
          givenNum2 <= 8'h1e;
          givenNum3 <= 8'h3d;
          givenNum4 <= 8'h3d;
       end
    end else if (display_title) begin
       givenNum1 <= 8'h0;
       givenNum2 <= 8'h0;
       givenNum3 <= 8'h0;
       givenNum4 <= 8'h0;
    end
 end
 end
endmodule








module calcControl(
 input clock, reset, retry, next, closing,
 input [7:0] last_data_received,
 input [7:0] given_number1, given_number2, given_number3, given_number4,
 output reg num, op, open, close, evaluating, finished, inputValid, idling
);


 localparam idle = 4'd0,
            read_number = 4'd1,
            read_operator = 4'd2,
            finish = 4'd3,
            error = 4'd4,
            open_bracket = 4'd5,
            close_bracket = 4'd6,
            evaluate = 4'd7,
            read_operator_wait = 4'd8,
            evaluate_wait = 4'd9;
 reg [3:0] current_state = 0, next_state;
 reg [7:0] opencount = 0, closecount = 0;
 reg [1:0] givennumber1 = 0, givennumber2 = 0, givennumber3 = 0, givennumber4 = 0;




 always @(*) begin
    case (current_state)
       idle: begin
          next_state = (last_data_received == 8'hf0) ? read_number : idle;
       end
       read_number: begin
          if (last_data_received == 8'hf0) begin
             next_state = read_number;
          end
          else if (last_data_received == given_number1 & givennumber1 < 1) begin
             next_state = evaluate;
          end
          else if (last_data_received == given_number2 & givennumber2 < 1) begin
             next_state = evaluate;
          end
          else if (last_data_received == given_number3 & givennumber3 < 1) begin
             next_state = evaluate;
          end
          else if (last_data_received == given_number4 & givennumber4 < 1) begin
             next_state = evaluate;
          end
          else if (last_data_received == 8'h44) begin
             next_state = open_bracket;
          end
          else begin
             next_state = error;
          end
       end
       read_operator: begin
          if (last_data_received == 8'hf0) begin
             next_state = read_operator;
          end
          else if (last_data_received == 8'h1c | last_data_received == 8'h23 | last_data_received == 8'h1b | last_data_received == 8'h3a) begin
             next_state = read_operator_wait;
          end
          else if (last_data_received == 8'h21) begin
             next_state = close_bracket;
          end
          else if (last_data_received == 8'h5a) begin
             if (opencount == closecount & givennumber1 == 1'b1 & givennumber2 == 1'b1 & givennumber3 == 1'b1 & givennumber4 == 1'b1) begin
                next_state = finish;
             end
             else begin
                next_state = error;
             end
          end
          else begin
             next_state = error;
          end
       end
       read_operator_wait: next_state = (last_data_received == 8'hf0) ? read_number : read_operator_wait;
       finish: next_state = (next == 1'b0) ? idle : finish;
       error: next_state = (next == 1'b0) ? idle : error;
       evaluate: next_state = (last_data_received == 8'hf0) ? read_operator : evaluate;
       open_bracket: begin
          next_state = read_operator_wait;
       end
       close_bracket: begin
          if (closecount + 1 > opencount) begin
             next_state = error;
          end
          else begin
             next_state = evaluate_wait;
          end
       end
       evaluate_wait: begin
          next_state = (closing == 1'b1) ? evaluate_wait : evaluate;
       end
    endcase
 end
 always@(*) begin
    evaluating = 1'b0;
    num = 1'b0;
    op = 1'b0;
    open = 1'b0;
    close = 1'b0;
    inputValid = 1'b1;
    finished = 1'b0;
    idling = 1'b0;
    case (current_state)
       idle: idling = 1'b1;
       read_number: num = 1'b1;
       read_operator: op = 1'b1;
       open_bracket: open = 1'b1;
       close_bracket: close = 1'b1;
       evaluate_wait: close = 1'b1;
       finish: finished = 1'b1;
       evaluate: evaluating = 1'b1;
       error: inputValid = 1'b0;
    endcase
 end
  
 always@(posedge clock) begin
    if (reset == 1'b0 | retry == 1'b0) begin
       current_state <= idle;
       opencount <= 8'b0;
       closecount <= 8'b0;
       givennumber1 <= 0;
       givennumber2 <= 0;
       givennumber3 <= 0;
       givennumber4 <= 0;
    end
    else begin
       current_state <= next_state;
       if (current_state == idle) begin
          opencount <= 8'b0;
          closecount <= 8'b0;
          givennumber1 <= 0;
          givennumber2 <= 0;
          givennumber3 <= 0;
          givennumber4 <= 0;
       end
       else if (current_state == open_bracket) begin
          opencount <= opencount + 1;
       end
       else if (current_state == close_bracket) begin
          closecount <= closecount + 1;
       end
        else if (current_state == read_number) begin
           if ((last_data_received == given_number1 && givennumber1 != 1'b1) || (last_data_received == given_number1 & givennumber1 == 1'b1 && given_number1 != given_number2 && given_number1 != given_number3 && given_number1 != given_number4)) begin
              givennumber1 <= givennumber1+1;
           end
           else if ((last_data_received == given_number2 && givennumber2 != 1'b1) || (last_data_received == given_number2 & givennumber2 == 1'b1 && given_number2 != given_number3 && given_number2 != given_number4)) begin
              givennumber2 <= givennumber2+1;
           end
           else if ((last_data_received == given_number3 && givennumber3 != 1'b1) || (last_data_received == given_number3 & givennumber3 == 1'b1 && given_number3 != given_number4)) begin
              givennumber3 <= givennumber3+1;
           end
           else if (last_data_received == given_number4) begin
              givennumber4 <= givennumber4+1;
           end
       end
    end
 end
endmodule












module calcData(
 input clock, reset,num, op, evaluating, open, close, finished, idling,
 input [7:0] last_data_received,
 output reg signed [13:0] result,
 output reg resultValid = 1'b0, inputValid = 1'b1, closing = 1'b0, result24
);
 reg signed [13:0] numstack[0:4];
 reg [2:0] operatorstack[0:3]; // 0 = add, 1 = subtract, 2 = multiply, 3 = divide
 integer i;
 reg [2:0] numcount;
 reg [2:0] opcount;
 reg [7:0] opencount[0:4];
 reg signed [13:0] alu_result;
 reg alu_input_valid;
 initial begin
    numcount = 3'b0;
    opcount = 3'b0;
    for (i = 0; i < 5; i = i + 1) begin
       numstack[i] <= 14'b0;
       opencount[i] <= 8'b0;
    end
    for (i = 0; i < 4; i = i + 1) begin
       operatorstack[i] <= 3'b0;
    end
    resultValid <= 1'b0;
    inputValid <= 1'b1;
    result24<= 1'b0;
 end
 always @(posedge clock) begin
    if (idling == 1'b1) begin
       closing <= 1'b0;
       inputValid <= 1'b1;
       numcount <= 2'b0;
       opcount <= 2'b0;
       resultValid = 1'b0;
       result <= 13'b0;
       result24<= 1'b0;
       for (i = 0; i < 4; i = i + 1) begin
          numstack[i] <= 14'd0;
          opencount[i] <= 8'b0;
       end
       for (i = 0; i < 3; i = i + 1) begin
          operatorstack[i] <= 2'b0;
       end
    end
    if (num == 1'b1) begin
       if (last_data_received != 8'h44) begin
          if (last_data_received == 8'h16) begin
             numstack[numcount] <= 14'd1;
          end
          else if (last_data_received == 8'h1e) begin
             numstack[numcount] <= 14'd2;
          end
          else if (last_data_received == 8'h26) begin
             numstack[numcount] <= 14'd3;
          end
          else if (last_data_received == 8'h25) begin
             numstack[numcount] <= 14'd4;
          end
          else if (last_data_received == 8'h2e) begin
             numstack[numcount] <= 14'd5;
          end
          else if (last_data_received == 8'h36) begin
             numstack[numcount] <= 14'd6;
          end
          else if (last_data_received == 8'h3d) begin
             numstack[numcount] <= 14'd7;
          end
          else if (last_data_received == 8'h3e) begin
             numstack[numcount] <= 14'd8;
          end
          else if (last_data_received == 8'h46) begin
             numstack[numcount] <= 14'd9;
          end 
       end
    end
    if (evaluating == 1'b1) begin
       if(numstack[numcount] != 14'd0 | operatorstack[opcount] != 2'b00) begin
          if (opencount[numcount] == 8'b0) begin
             if (operatorstack[opcount] == 2'b10) begin
                numstack[numcount-1] <= numstack[numcount-1] * numstack[numcount];
                numstack[numcount] <= 14'd0;
                operatorstack[opcount] <= 2'b00;
             end
             else if (operatorstack[opcount] == 2'b11) begin
                numstack[numcount-1] <= numstack[numcount-1] / numstack[numcount];
                numstack[numcount] <= 14'd0;
                if (numstack[numcount-1] % numstack[numcount] != 0) begin
                   inputValid <= 1'b0;
                end
                operatorstack[opcount] <= 2'b00;
             end
             else if (operatorstack[opcount] == 2'b01) begin
                numstack[numcount] <= -1 * numstack[numcount];
                operatorstack[opcount] <= 2'b00;
                numcount <= numcount + 1;
                opcount <=  opcount + 1;
             end
             else begin
                numcount <= numcount + 1;
                opcount <=  opcount + 1;
             end
          end
          else begin
             numcount <= numcount + 1;
             opcount <=  opcount + 1;
          end
       end
    end
    if (op == 1'b1) begin
       if (last_data_received != 8'h21) begin
          if (last_data_received == 8'h1c) begin
             operatorstack[opcount] <= 2'b00;
          end
          else if (last_data_received == 8'h1b) begin
             operatorstack[opcount] <= 2'b01;
          end
          else if (last_data_received == 8'h3a) begin
             operatorstack[opcount] <= 2'b10;
          end
          else if (last_data_received == 8'h23) begin
             operatorstack[opcount] <= 2'b11;
          end
       end
    end
    if (open == 1'b1) begin
       opencount[numcount] <= opencount[numcount] + 1;
    end
    if (close == 1'b1) begin
       if (numcount != 0 && opencount[numcount] == 8'b0) begin
          closing <= 1'b1;
          numstack[numcount-1] <= alu_result;
          numstack[numcount] <= 14'd0;
          inputValid <= alu_input_valid;
          numcount <= numcount - 1;
          opcount <= opcount - 1;
          operatorstack[opcount] <= 2'b00;
       end
       else if (closing == 1'b1) begin
          closing <= 1'b0;
          opencount[numcount] <= opencount[numcount] - 1;
          if (opencount[numcount] > 8'b00000001 | operatorstack[opcount] == 2'b0 ) begin
             numcount <= numcount +1;
             opcount <= opcount + 1;
          end       
       end
    end
    if (finished) begin
       if (numcount != 0) begin
          numstack[numcount-1] <= alu_result;
          numstack[numcount] <= 14'd0;
          inputValid <= alu_input_valid;
          operatorstack[opcount] <= 2'b00;
          numcount <= numcount - 1;
          opcount <= opcount - 1;
       end
       else begin
          resultValid = 1'b1;
          result <= numstack[numcount];
          result24 <= (numstack[numcount] == 14'd24);
       end
    end
 end




 always @(*) begin // ALU
    alu_input_valid = 1'b1;
    case(operatorstack[opcount])
       0: alu_result = numstack[numcount-1] + numstack[numcount];
       1: alu_result = numstack[numcount-1] - numstack[numcount];
       2: alu_result = numstack[numcount-1] * numstack[numcount];
       3: begin
             alu_result = numstack[numcount-1] / numstack[numcount];
             if (numstack[numcount-1] % numstack[numcount] != 0) begin
                alu_input_valid = 1'b0;
             end
          end
    endcase
 end
  


endmodule
module calcFSM (
 input clock, reset, retry, next,
 input [7:0] last_data_received,
 input [7:0] given_number1, given_number2, given_number3, given_number4,
 output resultValid, inputValid,
 output signed [13:0] result,
 output result24
);
 wire closing, num, op, open, close, evaluating, finished, validInput, input_valid, idling;
 calcControl u1 (clock, reset, retry, next, closing, last_data_received, given_number1, given_number2, given_number3, given_number4, num, op, open, close, evaluating, finished, validInput, idling);
 calcData u2 (clock, reset, num, op, evaluating, open, close, finished, idling, last_data_received, result, resultValid, input_valid, closing, result24);


 assign inputValid = (input_valid == 1'b1 & validInput == 1'b1);


endmodule


module clearTime(  
   input ClockIn,
   input Reset,
   input display_title,
   input display_congrats,
   output [32:0] CounterValue
);
   wire Enable2;


   RateDivider rd(ClockIn, Reset, Enable2);
   DisplayCounter dc1(ClockIn, Reset, Enable2, display_title, display_congrats, CounterValue);
endmodule






module RateDivider (
   input ClockIn,
   input Reset,
   output Enable
);


   wire [$clog2(50000000-1):0] f1;
	reg [$clog2(50000000-1):0] a = 0;


   assign f1 = 50000000-1;


	always @(posedge ClockIn) begin
		if (!Reset || a == 0)
			 a <= f1;
		else
			 a <= a - 1;
	end


	 assign Enable = (a == 0) ? 1:0;


endmodule


  
module DisplayCounter (
   input Clock,
   input Reset,
   input EnableDC,
   input display_title,
   input display_congrats,
   output reg [32:0] CounterValue
);


   always @(posedge Clock) begin
       if (!Reset | display_title)
           CounterValue <= 0;
       else if (!display_congrats)
           CounterValue <= CounterValue + EnableDC;
       else
         CounterValue <= CounterValue;
   end
endmodule


