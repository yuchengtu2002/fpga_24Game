
module DE1_SoC_Audio_Example (
	// Inputs
	display_success,
	display_congrats,
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input 			display_success;
input				display_congrats;
input		[3:0]	KEY;
input		[9:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;
wire [32:0] audio_out1;
//wire [32:0] audio_out2;

reg [14:0] address1;
//reg [14:0] address2;

//Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;
reg [13:0] soundcount1;
//reg [13:0] soundcount2;
reg sound_en;

reg snd;

initial begin
	address1 = 0;
	soundcount1 = 0;
//	address2 = 0;
//	soundcount2 = 0;
end

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

sound sound1(address1, CLOCK_50,audio_out1);
//sound2 s2(address2, CLOCK_50,audio_out2);

always @(posedge CLOCK_50) begin
	if (!KEY[0] || (!display_success && !display_congrats)) begin
		address1 <= 0;
		soundcount1 <= 0;
	end
	else if (soundcount1 < 14'd9999) begin
		soundcount1 <= soundcount1 + 1;
	end
	else if (soundcount1 == 14'd9999 && address1 < 15'd17880) begin
		address1 <= address1 + 1;
		soundcount1 <= 0;
	end		
end
		
wire [31:0] audio1 = audio_out1 >> 2;
//
//always @(posedge CLOCK_50) begin
//	if (!KEY[0] || !display_congrats) begin
//		address2 <= 0;
//		soundcount2 <= 0;
//	end
//	else if (soundcount2 < 14'd9999) begin
//		soundcount2 <= soundcount2 + 1;
//	end
//	else if (soundcount2 == 14'd9999 && address2 < 15'd22988) begin
//		address2 <= address2 + 1;
//		soundcount2 <= 0;
//	end		
//end
//
//wire [31:0] audio2 = audio_out2 >> 2;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/



assign read_audio_in			= audio_in_available & audio_out_allowed;
assign left_channel_audio_out	= audio1;
assign right_channel_audio_out	= audio1;

//always@(*) begin
//	if (display_congrats) begin
//		left_channel_audio_out	= audio2;
//		right_channel_audio_out	= audio2;
//	end
//	else if (display_success) begin
//		left_channel_audio_out	= audio1;
//		right_channel_audio_out	= audio1;
//	end
//end
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

