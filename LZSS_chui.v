// -----------------------------------------------------------
// LZSS.v
// -----------------------------------------------------------
//
// Major Function:
//		LZSS Compression Encoder
//
// -----------------------------------------------------------
//
// Created on 2015/12/29 by Alex Chiu.
// Version 2.0
//
// -----------------------------------------------------------
module LZSS(
	clk, 
	reset, 
	data, 
	data_valid, 
	drop_done,
	busy, 
	codeword, 
	enc_num, 
	out_valid, 
	finish
);


// -----------------------------------------------------------
// input/output declaration
// -----------------------------------------------------------
input			clk;
input			reset;
input	[31:0]	data;
input			data_valid;
input			drop_done;
output			busy;
output	[10:0]	codeword;
output	[11:0]	enc_num;
output			out_valid;
output			finish;


// -----------------------------------------------------------
// parameter declaration
// -----------------------------------------------------------
// Main state
parameter MAIN_STATE_IDLE 			= 2'd0;
parameter MAIN_STATE_WAIT_OR_SHIFT_LAB	= 2'd1;
parameter MAIN_STATE_POST_SHIFT_LAB	= 2'd2;
parameter MAIN_STATE_FIND_MATCH 	= 2'd3;

// Host state
parameter HOST_STATE_INIT		= 2'd0;
parameter HOST_STATE_READY		= 2'd2;
parameter HOST_STATE_REFILLE	= 2'd3;

// Verify state
parameter VERIFY_STATE_IDLE		= 2'd0;
parameter VERIFY_STATE_READY 	= 2'd2;
parameter VERIFY_STATE_OUTPUT 	= 2'd3;


// -----------------------------------------------------------
// reg/wire declaration
// -----------------------------------------------------------
integer i;
// output reg
reg				busy_w, busy_r;
reg		[10:0]	codeword_w, codeword_r;
reg		[11:0]	enc_num_w, enc_num_r;
reg				out_valid_w, out_valid_r;
reg				finish_w, finish_r;

// state machine
reg		[1:0]	mainState_w, mainState_r;
reg		[1:0]	verifyState_w, verifyState_r;
reg		[2:0]	shiftCounter_w, shiftCounter_r;

// look ahead buffer
reg		[2:0]	labCounter_w, labCounter_r;
reg		[7:0]	labBank_w [0:7];
reg 	[7:0]	labBank_r [0:7];
reg		[8:0]	remainData_w, remainData_r;
reg		[7:0]	labBuf_w, labBuf_r;
wire	[7:0]	lab [0:4];

// dictionary
reg		[7:0]	dictionary_w [0:255];
reg		[7:0]	dictionary_r [0:255];
reg		[261:0]	dictionaryBound_w, dictionaryBound_r;

// find match
wire	[4:0]	smallMatchResult [0:63];
wire	[6:0]	compareResultLayer0_w [0:15];
reg		[6:0]	compareResultLayer0_r [0:15];
wire	[8:0]	compareResultLayer1 [0:3];
wire	[10:0]	compareResultLayer2;
wire	[10:0]	compareResultFinal;

// pipeline helper
wire			needShift;
reg				keepShift_w, keepShift_r;
reg				pipelineValid_w, pipelineValid_r;

// -----------------------------------------------------------
// function
// -----------------------------------------------------------
function [10:0] translate2Codeword;
	input [10:0] compareResult;
	translate2Codeword = {1'b1, ~(compareResult[9:2]+{6'd0, compareResult[1:0]}+8'd1), compareResult[1:0]};
endfunction


// -----------------------------------------------------------
// Combinational Logic
// -----------------------------------------------------------
// helper wire
assign needShift = compareResultLayer0_w[0][2] | compareResultLayer0_w[1][2] | compareResultLayer0_w[2][2] | compareResultLayer0_w[3][2] | 
				   compareResultLayer0_w[4][2] | compareResultLayer0_w[5][2] | compareResultLayer0_w[6][2] | compareResultLayer0_w[7][2] | 
				   compareResultLayer0_w[8][2] | compareResultLayer0_w[9][2] | compareResultLayer0_w[10][2] | compareResultLayer0_w[11][2] | 
				   compareResultLayer0_w[12][2] | compareResultLayer0_w[13][2] | compareResultLayer0_w[14][2] | compareResultLayer0_w[15][2];

// output assign /////
assign busy = busy_r;
assign codeword = codeword_r;
assign enc_num = enc_num_r;
assign out_valid = out_valid_r;
assign finish = finish_r;


// main state machine /////
always@(*) begin
	mainState_w = mainState_r;
	shiftCounter_w = shiftCounter_r;
	keepShift_w = keepShift_r;
	pipelineValid_w = pipelineValid_r;
	case (mainState_r)
		MAIN_STATE_IDLE: begin
			if (labCounter_r == 3'd4) begin
				mainState_w = MAIN_STATE_FIND_MATCH;
			end
		end
		MAIN_STATE_WAIT_OR_SHIFT_LAB: begin
			if (keepShift_r) begin
				// check if codeword length is 2
				if (compareResultFinal[1:0] == 2'b00) begin
					mainState_w = MAIN_STATE_FIND_MATCH;
				end else begin
					mainState_w = MAIN_STATE_POST_SHIFT_LAB;
					shiftCounter_w = {1'b0, compareResultFinal[1:0]} - 3'b1;
				end
			end else begin
				// encode next symbol
				mainState_w = MAIN_STATE_FIND_MATCH;
			end
			pipelineValid_w = 1'b0;
		end
		MAIN_STATE_POST_SHIFT_LAB: begin
			if (shiftCounter_r == 3'd0) begin
				mainState_w = MAIN_STATE_FIND_MATCH;
			end else begin
				shiftCounter_w = shiftCounter_r - 3'd1;
			end
		end
		MAIN_STATE_FIND_MATCH: begin
			if (needShift) begin
				mainState_w = MAIN_STATE_WAIT_OR_SHIFT_LAB;
			end else begin
				mainState_w = MAIN_STATE_FIND_MATCH;
			end
			keepShift_w = needShift;
			pipelineValid_w = 1'b1;
		end
		default: begin
		end
	endcase
end


// verify state machine /////
always@(*) begin
	verifyState_w = verifyState_r;
	out_valid_w = out_valid_r;
	codeword_w = codeword_r;
	enc_num_w = enc_num_r;
	finish_w = finish_r;
	case (verifyState_r)
		VERIFY_STATE_IDLE: begin
			if (labCounter_r == 3'd4) begin
				verifyState_w = VERIFY_STATE_READY;
			end			
		end
		VERIFY_STATE_READY: begin
			if (pipelineValid_r) begin
				verifyState_w = VERIFY_STATE_OUTPUT;
				out_valid_w = 1'b1;
				codeword_w = (compareResultFinal[10])? translate2Codeword(compareResultFinal):{1'b0, labBuf_r, 2'b00};
				enc_num_w = enc_num_r + 12'd1;
			end
		end
		VERIFY_STATE_OUTPUT: begin
			if (pipelineValid_r) begin
				verifyState_w = VERIFY_STATE_OUTPUT;
				out_valid_w = (~remainData_r[0])? 1'b0:1'b1;
				codeword_w = (compareResultFinal[10])? translate2Codeword(compareResultFinal):{1'b0, labBuf_r, 2'b00};
				enc_num_w = enc_num_r + 12'd1;
			end else begin
				verifyState_w = VERIFY_STATE_READY;
				out_valid_w = 1'b0;
			end
			finish_w = (~remainData_r[0]);
		end
		default: begin
		end
	endcase
end

// look ahead buffer bank /////
always@(*) begin
	labCounter_w = labCounter_r + 3'd1;
	labBuf_w = labBank_r[0];

	labBank_w[0] = labBank_r[1];
	labBank_w[1] = labBank_r[2];
	labBank_w[2] = labBank_r[3];
	labBank_w[3] = labBank_r[4];
	labBank_w[4] = (data_valid)? data[31:24]:labBank_r[5];
	labBank_w[5] = (data_valid)? data[23:16]:labBank_r[6];
	labBank_w[6] = (data_valid)? data[15:8]:labBank_r[7];
	labBank_w[7] = (data_valid)? data[7:0]:labBank_r[7];
	
	if (drop_done && ~data_valid) begin
		remainData_w = remainData_r >> 1;
	end else begin
		remainData_w = remainData_r;
	end
	
	if (labCounter_r[1:0] == 2'd3 && ~drop_done) begin
		busy_w = 1'b0;
	end else begin
		busy_w = 1'b1;
	end
end

// dictionary /////
always@(*) begin
	dictionaryBound_w = {1'b1, dictionaryBound_r[261:1]};
	for (i = 0; i < 255; i = i + 1) begin
		dictionary_w[i] = dictionary_r[i+1];
	end
	dictionary_w[255] = labBank_r[0];
end

// find match /////
PartialSmallMatcher sm(.lab({labBank_r[0], labBank_r[1], labBank_r[2], labBank_r[3]}),
					   .labMask(remainData_r[4:1]),
					   .subDictionary({dictionary_r[252],
					   				   dictionary_r[253],
					   				   dictionary_r[254],
					   				   dictionary_r[255]}),
					   .dictionaryMask(dictionaryBound_r[255:252]),
					   .result(smallMatchResult[63]));

generate
	genvar s;
	for (s = 0; s < 63; s = s + 1) begin:smallMatcher_gen
		SmallMatcher sm(.lab({labBank_r[0], labBank_r[1], labBank_r[2], labBank_r[3], labBank_r[4]}),
						.labMask(remainData_r[5:1]),
						.subDictionary({dictionary_r[0+s*4],
										dictionary_r[1+s*4],
										dictionary_r[2+s*4],
										dictionary_r[3+s*4],
										dictionary_r[4+s*4],
										dictionary_r[5+s*4],
										dictionary_r[6+s*4],
										dictionary_r[7+s*4]}),
						.dictionaryMask(dictionaryBound_r[3+s*4:0+s*4]),
						.result(smallMatchResult[s])); // [4:0]
	end
	for (s = 0; s < 16; s = s + 1) begin:compareLayer0_gen
		Argmax #(.INPUT_WIDTH(5)) argmax(.in0(smallMatchResult[s*4+4'd0]),
					  					 .in1(smallMatchResult[s*4+4'd1]),
					  					 .in2(smallMatchResult[s*4+4'd2]),
					  					 .in3(smallMatchResult[s*4+4'd3]),
					  					 .out(compareResultLayer0_w[s])); // [6:0]
	end
	for (s = 0; s < 4; s = s + 1) begin:compareLayer1_gen
		Argmax #(.INPUT_WIDTH(7)) argmax(.in0(compareResultLayer0_r[s*4+4'd0]),
					  					 .in1(compareResultLayer0_r[s*4+4'd1]),
					  					 .in2(compareResultLayer0_r[s*4+4'd2]),
					  					 .in3(compareResultLayer0_r[s*4+4'd3]),
					  					 .out(compareResultLayer1[s])); // [8:0]
	end
	Argmax #(.INPUT_WIDTH(9)) argmax(.in0(compareResultLayer1[0]),
				  					 .in1(compareResultLayer1[1]),
				  					 .in2(compareResultLayer1[2]),
				  					 .in3(compareResultLayer1[3]),
				  					 .out(compareResultLayer2)); // [10:0]
endgenerate
assign compareResultFinal = {compareResultLayer2[2], compareResultLayer2[10:3], compareResultLayer2[1:0]};



// -----------------------------------------------------------
// Sequential Logic
// -----------------------------------------------------------
always@(posedge clk or posedge reset) begin
	if(reset)begin
		// state machines /////
		mainState_r			<= MAIN_STATE_IDLE;
		verifyState_r		<= VERIFY_STATE_IDLE;
		shiftCounter_r		<= 3'd0;

		// look ahead buffer /////
		labCounter_r		<= 3'd7;
		for (i = 0; i < 8; i = i + 1) begin
			labBank_r[i]	<= 8'd0;
		end
		remainData_r		<= 9'b1_1111_1111;
		labBuf_r			<= 8'd0;

		// host /////
		busy_r				<= 1'b1;

		// verify /////
		out_valid_r			<= 1'b0;
		codeword_r			<= 11'd0;
		enc_num_r			<= 12'b0;
		finish_r			<= 1'b0;

		// dictionary /////
		dictionaryBound_r	<= 262'h0;
		for (i = 0; i < 256; i = i + 1) begin
			dictionary_r[i]	<= 8'd0;
		end

		// find match
		keepShift_r			<= 1'b0;
		for (i = 0; i < 16; i = i + 1) begin
			compareResultLayer0_r[i]	<= 7'b0;
		end

		// pipeline helper
		pipelineValid_r		<= 1'b0;

	end else begin
		// state machines /////
		mainState_r			<= mainState_w;
		verifyState_r		<= verifyState_w;
		shiftCounter_r		<= shiftCounter_w;

		// look ahead buffer /////
		labCounter_r		<= labCounter_w;
		for (i = 0; i < 8; i = i + 1) begin
			labBank_r[i]	<= labBank_w[i];
		end
		remainData_r		<= remainData_w;
		labBuf_r			<= labBuf_w;

		// host /////
		busy_r				<= busy_w;

		// verify /////
		out_valid_r			<= out_valid_w;
		codeword_r			<= codeword_w;
		enc_num_r			<= enc_num_w;
		finish_r			<= finish_w;

		// dictionary /////
		dictionaryBound_r	<= dictionaryBound_w;
		for (i = 0; i < 256; i = i + 1) begin
			dictionary_r[i]	<= dictionary_w[i];
		end

		// find match
		keepShift_r			<= keepShift_w;
		for (i = 0; i < 16; i = i + 1) begin
			compareResultLayer0_r[i]	<= compareResultLayer0_w[i];
		end

		// pipeline helper
		pipelineValid_r		<= pipelineValid_w;
	end
end

endmodule



// -----------------------------------------------------------
// SmallMatcher
// -----------------------------------------------------------
//
// Major Function:
//		Find longest prefix match in sub-dictionary
//
// -----------------------------------------------------------
module SmallMatcher(
	lab,
	labMask,
	subDictionary,
	dictionaryMask,
	result
);

input	[8*5-1:0]	lab; // {lab[0], lab[1], ... , lab[4]}
input	[4:0]		labMask;
input 	[8*8-1:0]	subDictionary; // {dict[0], dict[1] dict[2], ... , dict[7]}
input	[3:0]		dictionaryMask;
output	[4:0]		result; // {2'POSITION, 1'FLAG, 2'LENGTH}

// parameter
parameter MATCH_2_SYMBOLS = 2'b00;
parameter MATCH_3_SYMBOLS = 2'b01;
parameter MATCH_4_SYMBOLS = 2'b10;
parameter MATCH_5_SYMBOLS = 2'b11;

// reg & wire
wire [7:0]	subDictionary_w [0:7];
wire [7:0]	lab_w [0:4];

wire [4:0]	matchResult0_w; // lab[0]... == subDictionary[0]...
wire [4:0]	matchResult1_w; // lab[0]... == subDictionary[1]...
wire [4:0]	matchResult2_w; // lab[0]... == subDictionary[2]...
wire [4:0]	matchResult3_w; // lab[0]... == subDictionary[3]...

reg	[4:0]	result0_w, result1_w, result2_w, result3_w;

wire [4:0]	tempResult0_w, tempResult1_w;

reg	[4:0]	result_w, result_r;

// combinational circuit
generate
	genvar j;
	for (j = 0; j < 8; j = j + 1) begin:subDict_gen
		assign subDictionary_w[j] = subDictionary[63-j*8:56-j*8];
	end


	for (j = 0; j < 5; j = j + 1) begin:lab_gen
		assign lab_w[j] = lab[39-j*8:32-j*8];
	end

	for (j = 0; j < 5; j = j + 1) begin: matchResult_gen
		assign matchResult0_w[j] = (lab_w[j] == subDictionary_w[0+j]) & labMask[j] & dictionaryMask[0];
		assign matchResult1_w[j] = (lab_w[j] == subDictionary_w[1+j]) & labMask[j] & dictionaryMask[1];
		assign matchResult2_w[j] = (lab_w[j] == subDictionary_w[2+j]) & labMask[j] & dictionaryMask[2];
		assign matchResult3_w[j] = (lab_w[j] == subDictionary_w[3+j]) & labMask[j] & dictionaryMask[3];
	end
endgenerate

always@(*) begin
	case (matchResult0_w)
		5'b11111: result0_w = {2'b00, 1'b1, MATCH_5_SYMBOLS};
		5'b01111: result0_w = {2'b00, 1'b1, MATCH_4_SYMBOLS};
		5'b00111: result0_w = {2'b00, 1'b1, MATCH_3_SYMBOLS};
		5'b10111: result0_w = {2'b00, 1'b1, MATCH_3_SYMBOLS};
		5'b00011: result0_w = {2'b00, 1'b1, MATCH_2_SYMBOLS};
		5'b01011: result0_w = {2'b00, 1'b1, MATCH_2_SYMBOLS};
		5'b10011: result0_w = {2'b00, 1'b1, MATCH_2_SYMBOLS};
		5'b11011: result0_w = {2'b00, 1'b1, MATCH_2_SYMBOLS};
		default: result0_w = {2'b00, 1'b0, 2'b00};
	endcase
end

always@(*) begin
	case (matchResult1_w)
		5'b11111: result1_w = {2'b01, 1'b1, MATCH_5_SYMBOLS};
		5'b01111: result1_w = {2'b01, 1'b1, MATCH_4_SYMBOLS};
		5'b00111: result1_w = {2'b01, 1'b1, MATCH_3_SYMBOLS};
		5'b10111: result1_w = {2'b01, 1'b1, MATCH_3_SYMBOLS};
		5'b00011: result1_w = {2'b01, 1'b1, MATCH_2_SYMBOLS};
		5'b01011: result1_w = {2'b01, 1'b1, MATCH_2_SYMBOLS};
		5'b10011: result1_w = {2'b01, 1'b1, MATCH_2_SYMBOLS};
		5'b11011: result1_w = {2'b01, 1'b1, MATCH_2_SYMBOLS};
		default: result1_w = {2'b01, 1'b0, 2'b00};
	endcase
end

always@(*) begin
	case (matchResult2_w)
		5'b11111: result2_w = {2'b10, 1'b1, MATCH_5_SYMBOLS};
		5'b01111: result2_w = {2'b10, 1'b1, MATCH_4_SYMBOLS};
		5'b00111: result2_w = {2'b10, 1'b1, MATCH_3_SYMBOLS};
		5'b10111: result2_w = {2'b10, 1'b1, MATCH_3_SYMBOLS};
		5'b00011: result2_w = {2'b10, 1'b1, MATCH_2_SYMBOLS};
		5'b01011: result2_w = {2'b10, 1'b1, MATCH_2_SYMBOLS};
		5'b10011: result2_w = {2'b10, 1'b1, MATCH_2_SYMBOLS};
		5'b11011: result2_w = {2'b10, 1'b1, MATCH_2_SYMBOLS};
		default: result2_w = {2'b10, 1'b0, 2'b00};
	endcase
end

always@(*) begin
	case (matchResult3_w)
		5'b11111: result3_w = {2'b11, 1'b1, MATCH_5_SYMBOLS};
		5'b01111: result3_w = {2'b11, 1'b1, MATCH_4_SYMBOLS};
		5'b00111: result3_w = {2'b11, 1'b1, MATCH_3_SYMBOLS};
		5'b10111: result3_w = {2'b11, 1'b1, MATCH_3_SYMBOLS};
		5'b00011: result3_w = {2'b11, 1'b1, MATCH_2_SYMBOLS};
		5'b01011: result3_w = {2'b11, 1'b1, MATCH_2_SYMBOLS};
		5'b10011: result3_w = {2'b11, 1'b1, MATCH_2_SYMBOLS};
		5'b11011: result3_w = {2'b11, 1'b1, MATCH_2_SYMBOLS};
		default: result3_w = {2'b11, 1'b0, 2'b00};
	endcase
end

assign tempResult0_w = (result0_w[2:0] > result1_w[2:0])? result0_w:result1_w;
assign tempResult1_w = (result2_w[2:0] > result3_w[2:0])? result2_w:result3_w;
assign result = (tempResult0_w[2:0] > tempResult1_w[2:0])? tempResult0_w:tempResult1_w;

endmodule




// -----------------------------------------------------------
// PartialSmallMatcher
// -----------------------------------------------------------
//
// Major Function:
//		Find longest prefix match in sub-dictionary, partial-
//   dictionary version.
//
// -----------------------------------------------------------
module PartialSmallMatcher(
	lab,
	labMask,
	subDictionary,
	dictionaryMask,
	result
);

input	[8*4-1:0]	lab; // {lab[0], lab[1], ... , lab[3]}
input	[3:0]		labMask;
input 	[8*4-1:0]	subDictionary; // {dict[0], dict[1] dict[2], ... , dict[7]}
input	[3:0]		dictionaryMask;
output	[4:0]		result; // {2'POSITION, 1'FLAG, 2'LENGTH}

// parameter
parameter MATCH_2_SYMBOLS = 2'b00;
parameter MATCH_3_SYMBOLS = 2'b01;
parameter MATCH_4_SYMBOLS = 2'b10;
parameter MATCH_5_SYMBOLS = 2'b11;

// reg & wire
wire [7:0]	subDictionary_w [0:3];
wire [7:0]	lab_w [0:3];

wire [3:0]	matchResult0_w; // lab[0]... == subDictionary[0]...
wire [3:0]	matchResult1_w; // lab[0]... == subDictionary[1]...
wire [3:0]	matchResult2_w; // lab[0]... == subDictionary[2]...
wire [3:0]	matchResult3_w; // lab[0]... == subDictionary[3]...

reg	[4:0]	result0_w, result1_w, result2_w, result3_w;

wire [4:0]	tempResult_w;

reg	[4:0]	result_w, result_r;

// combinational circuit
generate
	genvar j;
	for (j = 0; j < 4; j = j + 1) begin:subDict_gen
		assign subDictionary_w[j] = subDictionary[31-j*8:24-j*8];
	end


	for (j = 0; j < 4; j = j + 1) begin:lab_gen
		assign lab_w[j] = lab[31-j*8:24-j*8];
	end
endgenerate

assign matchResult0_w[0] = (lab_w[0] == subDictionary_w[0]) & labMask[0] & dictionaryMask[0];
assign matchResult0_w[1] = (lab_w[1] == subDictionary_w[1]) & labMask[1] & dictionaryMask[0];
assign matchResult0_w[2] = (lab_w[2] == subDictionary_w[2]) & labMask[2] & dictionaryMask[0];
assign matchResult0_w[3] = (lab_w[3] == subDictionary_w[3]) & labMask[3] & dictionaryMask[0];

assign matchResult1_w[0] = (lab_w[0] == subDictionary_w[1]) & labMask[0] & dictionaryMask[1];
assign matchResult1_w[1] = (lab_w[1] == subDictionary_w[2]) & labMask[1] & dictionaryMask[1];
assign matchResult1_w[2] = (lab_w[2] == subDictionary_w[3]) & labMask[2] & dictionaryMask[1];
assign matchResult1_w[3] = 1'b0;

assign matchResult2_w[0] = (lab_w[0] == subDictionary_w[2]) & labMask[0] & dictionaryMask[2];
assign matchResult2_w[1] = (lab_w[1] == subDictionary_w[3]) & labMask[1] & dictionaryMask[2];
assign matchResult2_w[2] = 1'b0;
assign matchResult2_w[3] = 1'b0;

assign matchResult3_w[0] = (lab_w[0] == subDictionary_w[3]) & labMask[0] & dictionaryMask[3]; // uselessssss
assign matchResult3_w[1] = 1'b0;
assign matchResult3_w[2] = 1'b0;
assign matchResult3_w[3] = 1'b0;

always@(*) begin
	case (matchResult0_w)
		4'b1111: result0_w = {2'b00, 1'b1, MATCH_4_SYMBOLS};
		4'b0111: result0_w = {2'b00, 1'b1, MATCH_3_SYMBOLS};
		4'b0011: result0_w = {2'b00, 1'b1, MATCH_2_SYMBOLS};
		4'b1011: result0_w = {2'b00, 1'b1, MATCH_2_SYMBOLS};
		default: result0_w = {2'b00, 1'b0, 2'b00};
	endcase
end

always@(*) begin
	if (matchResult1_w == 4'b0111) begin
		result1_w = {2'b01, 1'b1, MATCH_3_SYMBOLS};
	end else if (matchResult1_w == 4'b0011) begin
		result1_w = {2'b01, 1'b1, MATCH_2_SYMBOLS};
	end else begin
		result1_w = {2'b01, 1'b0, 2'b00};
	end
end

always@(*) begin
	if (matchResult2_w == 4'b0011) begin
		result2_w = {2'b10, 1'b1, MATCH_2_SYMBOLS};
	end else begin
		result2_w = {2'b10, 1'b0, 2'b00};
	end
end

assign tempResult_w = (result1_w[2:0] > result2_w[2:0])? result1_w:result2_w;
assign result = (result0_w[2:0] > tempResult_w[2:0])? result0_w:tempResult_w;

endmodule




// -----------------------------------------------------------
// 4-input Argmax
// -----------------------------------------------------------
//
// Major Function:
//		return argmax(i) in[i] 
//
// -----------------------------------------------------------
module Argmax(
	in0,
	in1,
	in2,
	in3,
	out
);

parameter INPUT_WIDTH = 5;

input [INPUT_WIDTH-1:0]	in0;
input [INPUT_WIDTH-1:0]	in1;
input [INPUT_WIDTH-1:0]	in2;
input [INPUT_WIDTH-1:0]	in3;
output [INPUT_WIDTH+1:0] out;

wire [3:0] temp0;
wire [3:0] temp1;
wire [1:0] out_idx;
reg [INPUT_WIDTH+1:0] out;

assign temp0 = (in0[2:0] > in1[2:0])? {1'b0, in0[2:0]}:{1'b1, in1[2:0]};
assign temp1 = (in2[2:0] > in3[2:0])? {1'b0, in2[2:0]}:{1'b1, in3[2:0]};
assign out_idx = (temp0[2:0] > temp1[2:0])? {1'b0, temp0[3]}:{1'b1, temp1[3]};

always@(*) begin
	case(out_idx)
		2'b00: out = {out_idx, in0};
		2'b01: out = {out_idx, in1};
		2'b10: out = {out_idx, in2};
		2'b11: out = {out_idx, in3};
	endcase
end

endmodule

