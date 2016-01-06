module LZSS(	clk, 
				reset, 
				data, 
				data_valid, 
				drop_done,
				busy, 
				codeword, 
				enc_num, 
				out_valid, 
				finish		);
							
				
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

//=========wire & reg declaration================================
reg     [8:0]   i           ;
//reg     [2:0]   tmp_largest ;
//reg     [7:0]   tmp_largest_pos;

reg             busy        ;
reg     [10:0]  codeword    ;
reg     [11:0]  enc_num     ;
reg             out_valid   ;
reg             finish      ;
reg     [2:0]   state       ;
reg     [31:0]  r_buf       ;
reg		[31:0]	tmp_buf		;
reg     [39:0]  LA_buf      ;
reg     [2:0]   l_r_buf     ;//buf length
reg     [2:0]   l_LA_buf    ;//buf length
reg		[7:0] 	dict_org[0:255]	;
reg     [8:0]   dict_size   ;
reg     [8:0]   dict_pos    ;
reg     [2:0]   largest     ;
reg     [7:0]   largest_pos ;
reg             data_done   ;



reg             n_busy        ;
reg     [10:0]  n_codeword    ;
reg     [11:0]  n_enc_num     ;
reg             n_out_valid   ;
reg             n_finish      ;
reg     [2:0]   n_state       ;
reg     [31:0]  n_r_buf       ;
reg     [39:0]  n_LA_buf      ;
reg     [2:0]   n_l_r_buf     ;//buf length
reg     [2:0]   n_l_LA_buf    ;//buf length
reg		[7:0]	n_dict_org[0:255] ;
reg     [8:0]   n_dict_size   ;
reg     [8:0]   n_dict_pos    ;
reg     [2:0]   n_largest     ;
reg     [7:0]   n_largest_pos ;
reg             n_data_done   ;

wire    [7:0]   symbol1       ;
wire    [7:0]   symbol2       ;
wire    [7:0]   symbol3       ;
wire    [7:0]   symbol4       ;
wire    [7:0]   symbol5       ;
wire    [259:0] dict1         ;
wire    [259:0] dict2         ;
wire    [259:0] dict3         ;
wire    [259:0] dict4         ;
wire    [259:0] dict5         ;

parameter   S_IDLE      =   3'd00;
parameter   S_START     =   3'd01;
parameter   S_COMPARE   =   3'd02;
parameter   S_ENCODE    =   3'd03;
parameter   S_STOP      =   3'd04;
parameter   S_READ      =   3'd05;
parameter   S_PUT       =   3'd06;

assign symbol1 = LA_buf[39:32];
assign symbol2 = LA_buf[31:24];
assign symbol3 = LA_buf[23:16];
assign symbol4 = LA_buf[15:8];
assign symbol5 = LA_buf[7:0];

assign dict1[0] = (dict_org[0]==symbol1) ? 1'b1 : 1'b0;
assign dict2[0] = (dict_org[0]==symbol2) ? 1'b1 : 1'b0;
assign dict3[0] = (dict_org[0]==symbol3) ? 1'b1 : 1'b0;
assign dict4[0] = (dict_org[0]==symbol4) ? 1'b1 : 1'b0;
assign dict5[0] = (dict_org[0]==symbol5) ? 1'b1 : 1'b0;
assign dict1[1] = (dict_org[1]==symbol1) ? 1'b1 : 1'b0;
assign dict2[1] = (dict_org[1]==symbol2) ? 1'b1 : 1'b0;
assign dict3[1] = (dict_org[1]==symbol3) ? 1'b1 : 1'b0;
assign dict4[1] = (dict_org[1]==symbol4) ? 1'b1 : 1'b0;
assign dict5[1] = (dict_org[1]==symbol5) ? 1'b1 : 1'b0;
assign dict1[2] = (dict_org[2]==symbol1) ? 1'b1 : 1'b0;
assign dict2[2] = (dict_org[2]==symbol2) ? 1'b1 : 1'b0;
assign dict3[2] = (dict_org[2]==symbol3) ? 1'b1 : 1'b0;
assign dict4[2] = (dict_org[2]==symbol4) ? 1'b1 : 1'b0;
assign dict5[2] = (dict_org[2]==symbol5) ? 1'b1 : 1'b0;
assign dict1[3] = (dict_org[3]==symbol1) ? 1'b1 : 1'b0;
assign dict2[3] = (dict_org[3]==symbol2) ? 1'b1 : 1'b0;
assign dict3[3] = (dict_org[3]==symbol3) ? 1'b1 : 1'b0;
assign dict4[3] = (dict_org[3]==symbol4) ? 1'b1 : 1'b0;
assign dict5[3] = (dict_org[3]==symbol5) ? 1'b1 : 1'b0;
assign dict1[4] = (dict_org[4]==symbol1) ? 1'b1 : 1'b0;
assign dict2[4] = (dict_org[4]==symbol2) ? 1'b1 : 1'b0;
assign dict3[4] = (dict_org[4]==symbol3) ? 1'b1 : 1'b0;
assign dict4[4] = (dict_org[4]==symbol4) ? 1'b1 : 1'b0;
assign dict5[4] = (dict_org[4]==symbol5) ? 1'b1 : 1'b0;
assign dict1[5] = (dict_org[5]==symbol1) ? 1'b1 : 1'b0;
assign dict2[5] = (dict_org[5]==symbol2) ? 1'b1 : 1'b0;
assign dict3[5] = (dict_org[5]==symbol3) ? 1'b1 : 1'b0;
assign dict4[5] = (dict_org[5]==symbol4) ? 1'b1 : 1'b0;
assign dict5[5] = (dict_org[5]==symbol5) ? 1'b1 : 1'b0;
assign dict1[6] = (dict_org[6]==symbol1) ? 1'b1 : 1'b0;
assign dict2[6] = (dict_org[6]==symbol2) ? 1'b1 : 1'b0;
assign dict3[6] = (dict_org[6]==symbol3) ? 1'b1 : 1'b0;
assign dict4[6] = (dict_org[6]==symbol4) ? 1'b1 : 1'b0;
assign dict5[6] = (dict_org[6]==symbol5) ? 1'b1 : 1'b0;
assign dict1[7] = (dict_org[7]==symbol1) ? 1'b1 : 1'b0;
assign dict2[7] = (dict_org[7]==symbol2) ? 1'b1 : 1'b0;
assign dict3[7] = (dict_org[7]==symbol3) ? 1'b1 : 1'b0;
assign dict4[7] = (dict_org[7]==symbol4) ? 1'b1 : 1'b0;
assign dict5[7] = (dict_org[7]==symbol5) ? 1'b1 : 1'b0;
assign dict1[8] = (dict_org[8]==symbol1) ? 1'b1 : 1'b0;
assign dict2[8] = (dict_org[8]==symbol2) ? 1'b1 : 1'b0;
assign dict3[8] = (dict_org[8]==symbol3) ? 1'b1 : 1'b0;
assign dict4[8] = (dict_org[8]==symbol4) ? 1'b1 : 1'b0;
assign dict5[8] = (dict_org[8]==symbol5) ? 1'b1 : 1'b0;
assign dict1[9] = (dict_org[9]==symbol1) ? 1'b1 : 1'b0;
assign dict2[9] = (dict_org[9]==symbol2) ? 1'b1 : 1'b0;
assign dict3[9] = (dict_org[9]==symbol3) ? 1'b1 : 1'b0;
assign dict4[9] = (dict_org[9]==symbol4) ? 1'b1 : 1'b0;
assign dict5[9] = (dict_org[9]==symbol5) ? 1'b1 : 1'b0;
assign dict1[10] = (dict_org[10]==symbol1) ? 1'b1 : 1'b0;
assign dict2[10] = (dict_org[10]==symbol2) ? 1'b1 : 1'b0;
assign dict3[10] = (dict_org[10]==symbol3) ? 1'b1 : 1'b0;
assign dict4[10] = (dict_org[10]==symbol4) ? 1'b1 : 1'b0;
assign dict5[10] = (dict_org[10]==symbol5) ? 1'b1 : 1'b0;
assign dict1[11] = (dict_org[11]==symbol1) ? 1'b1 : 1'b0;
assign dict2[11] = (dict_org[11]==symbol2) ? 1'b1 : 1'b0;
assign dict3[11] = (dict_org[11]==symbol3) ? 1'b1 : 1'b0;
assign dict4[11] = (dict_org[11]==symbol4) ? 1'b1 : 1'b0;
assign dict5[11] = (dict_org[11]==symbol5) ? 1'b1 : 1'b0;
assign dict1[12] = (dict_org[12]==symbol1) ? 1'b1 : 1'b0;
assign dict2[12] = (dict_org[12]==symbol2) ? 1'b1 : 1'b0;
assign dict3[12] = (dict_org[12]==symbol3) ? 1'b1 : 1'b0;
assign dict4[12] = (dict_org[12]==symbol4) ? 1'b1 : 1'b0;
assign dict5[12] = (dict_org[12]==symbol5) ? 1'b1 : 1'b0;
assign dict1[13] = (dict_org[13]==symbol1) ? 1'b1 : 1'b0;
assign dict2[13] = (dict_org[13]==symbol2) ? 1'b1 : 1'b0;
assign dict3[13] = (dict_org[13]==symbol3) ? 1'b1 : 1'b0;
assign dict4[13] = (dict_org[13]==symbol4) ? 1'b1 : 1'b0;
assign dict5[13] = (dict_org[13]==symbol5) ? 1'b1 : 1'b0;
assign dict1[14] = (dict_org[14]==symbol1) ? 1'b1 : 1'b0;
assign dict2[14] = (dict_org[14]==symbol2) ? 1'b1 : 1'b0;
assign dict3[14] = (dict_org[14]==symbol3) ? 1'b1 : 1'b0;
assign dict4[14] = (dict_org[14]==symbol4) ? 1'b1 : 1'b0;
assign dict5[14] = (dict_org[14]==symbol5) ? 1'b1 : 1'b0;
assign dict1[15] = (dict_org[15]==symbol1) ? 1'b1 : 1'b0;
assign dict2[15] = (dict_org[15]==symbol2) ? 1'b1 : 1'b0;
assign dict3[15] = (dict_org[15]==symbol3) ? 1'b1 : 1'b0;
assign dict4[15] = (dict_org[15]==symbol4) ? 1'b1 : 1'b0;
assign dict5[15] = (dict_org[15]==symbol5) ? 1'b1 : 1'b0;
assign dict1[16] = (dict_org[16]==symbol1) ? 1'b1 : 1'b0;
assign dict2[16] = (dict_org[16]==symbol2) ? 1'b1 : 1'b0;
assign dict3[16] = (dict_org[16]==symbol3) ? 1'b1 : 1'b0;
assign dict4[16] = (dict_org[16]==symbol4) ? 1'b1 : 1'b0;
assign dict5[16] = (dict_org[16]==symbol5) ? 1'b1 : 1'b0;
assign dict1[17] = (dict_org[17]==symbol1) ? 1'b1 : 1'b0;
assign dict2[17] = (dict_org[17]==symbol2) ? 1'b1 : 1'b0;
assign dict3[17] = (dict_org[17]==symbol3) ? 1'b1 : 1'b0;
assign dict4[17] = (dict_org[17]==symbol4) ? 1'b1 : 1'b0;
assign dict5[17] = (dict_org[17]==symbol5) ? 1'b1 : 1'b0;
assign dict1[18] = (dict_org[18]==symbol1) ? 1'b1 : 1'b0;
assign dict2[18] = (dict_org[18]==symbol2) ? 1'b1 : 1'b0;
assign dict3[18] = (dict_org[18]==symbol3) ? 1'b1 : 1'b0;
assign dict4[18] = (dict_org[18]==symbol4) ? 1'b1 : 1'b0;
assign dict5[18] = (dict_org[18]==symbol5) ? 1'b1 : 1'b0;
assign dict1[19] = (dict_org[19]==symbol1) ? 1'b1 : 1'b0;
assign dict2[19] = (dict_org[19]==symbol2) ? 1'b1 : 1'b0;
assign dict3[19] = (dict_org[19]==symbol3) ? 1'b1 : 1'b0;
assign dict4[19] = (dict_org[19]==symbol4) ? 1'b1 : 1'b0;
assign dict5[19] = (dict_org[19]==symbol5) ? 1'b1 : 1'b0;
assign dict1[20] = (dict_org[20]==symbol1) ? 1'b1 : 1'b0;
assign dict2[20] = (dict_org[20]==symbol2) ? 1'b1 : 1'b0;
assign dict3[20] = (dict_org[20]==symbol3) ? 1'b1 : 1'b0;
assign dict4[20] = (dict_org[20]==symbol4) ? 1'b1 : 1'b0;
assign dict5[20] = (dict_org[20]==symbol5) ? 1'b1 : 1'b0;
assign dict1[21] = (dict_org[21]==symbol1) ? 1'b1 : 1'b0;
assign dict2[21] = (dict_org[21]==symbol2) ? 1'b1 : 1'b0;
assign dict3[21] = (dict_org[21]==symbol3) ? 1'b1 : 1'b0;
assign dict4[21] = (dict_org[21]==symbol4) ? 1'b1 : 1'b0;
assign dict5[21] = (dict_org[21]==symbol5) ? 1'b1 : 1'b0;
assign dict1[22] = (dict_org[22]==symbol1) ? 1'b1 : 1'b0;
assign dict2[22] = (dict_org[22]==symbol2) ? 1'b1 : 1'b0;
assign dict3[22] = (dict_org[22]==symbol3) ? 1'b1 : 1'b0;
assign dict4[22] = (dict_org[22]==symbol4) ? 1'b1 : 1'b0;
assign dict5[22] = (dict_org[22]==symbol5) ? 1'b1 : 1'b0;
assign dict1[23] = (dict_org[23]==symbol1) ? 1'b1 : 1'b0;
assign dict2[23] = (dict_org[23]==symbol2) ? 1'b1 : 1'b0;
assign dict3[23] = (dict_org[23]==symbol3) ? 1'b1 : 1'b0;
assign dict4[23] = (dict_org[23]==symbol4) ? 1'b1 : 1'b0;
assign dict5[23] = (dict_org[23]==symbol5) ? 1'b1 : 1'b0;
assign dict1[24] = (dict_org[24]==symbol1) ? 1'b1 : 1'b0;
assign dict2[24] = (dict_org[24]==symbol2) ? 1'b1 : 1'b0;
assign dict3[24] = (dict_org[24]==symbol3) ? 1'b1 : 1'b0;
assign dict4[24] = (dict_org[24]==symbol4) ? 1'b1 : 1'b0;
assign dict5[24] = (dict_org[24]==symbol5) ? 1'b1 : 1'b0;
assign dict1[25] = (dict_org[25]==symbol1) ? 1'b1 : 1'b0;
assign dict2[25] = (dict_org[25]==symbol2) ? 1'b1 : 1'b0;
assign dict3[25] = (dict_org[25]==symbol3) ? 1'b1 : 1'b0;
assign dict4[25] = (dict_org[25]==symbol4) ? 1'b1 : 1'b0;
assign dict5[25] = (dict_org[25]==symbol5) ? 1'b1 : 1'b0;
assign dict1[26] = (dict_org[26]==symbol1) ? 1'b1 : 1'b0;
assign dict2[26] = (dict_org[26]==symbol2) ? 1'b1 : 1'b0;
assign dict3[26] = (dict_org[26]==symbol3) ? 1'b1 : 1'b0;
assign dict4[26] = (dict_org[26]==symbol4) ? 1'b1 : 1'b0;
assign dict5[26] = (dict_org[26]==symbol5) ? 1'b1 : 1'b0;
assign dict1[27] = (dict_org[27]==symbol1) ? 1'b1 : 1'b0;
assign dict2[27] = (dict_org[27]==symbol2) ? 1'b1 : 1'b0;
assign dict3[27] = (dict_org[27]==symbol3) ? 1'b1 : 1'b0;
assign dict4[27] = (dict_org[27]==symbol4) ? 1'b1 : 1'b0;
assign dict5[27] = (dict_org[27]==symbol5) ? 1'b1 : 1'b0;
assign dict1[28] = (dict_org[28]==symbol1) ? 1'b1 : 1'b0;
assign dict2[28] = (dict_org[28]==symbol2) ? 1'b1 : 1'b0;
assign dict3[28] = (dict_org[28]==symbol3) ? 1'b1 : 1'b0;
assign dict4[28] = (dict_org[28]==symbol4) ? 1'b1 : 1'b0;
assign dict5[28] = (dict_org[28]==symbol5) ? 1'b1 : 1'b0;
assign dict1[29] = (dict_org[29]==symbol1) ? 1'b1 : 1'b0;
assign dict2[29] = (dict_org[29]==symbol2) ? 1'b1 : 1'b0;
assign dict3[29] = (dict_org[29]==symbol3) ? 1'b1 : 1'b0;
assign dict4[29] = (dict_org[29]==symbol4) ? 1'b1 : 1'b0;
assign dict5[29] = (dict_org[29]==symbol5) ? 1'b1 : 1'b0;
assign dict1[30] = (dict_org[30]==symbol1) ? 1'b1 : 1'b0;
assign dict2[30] = (dict_org[30]==symbol2) ? 1'b1 : 1'b0;
assign dict3[30] = (dict_org[30]==symbol3) ? 1'b1 : 1'b0;
assign dict4[30] = (dict_org[30]==symbol4) ? 1'b1 : 1'b0;
assign dict5[30] = (dict_org[30]==symbol5) ? 1'b1 : 1'b0;
assign dict1[31] = (dict_org[31]==symbol1) ? 1'b1 : 1'b0;
assign dict2[31] = (dict_org[31]==symbol2) ? 1'b1 : 1'b0;
assign dict3[31] = (dict_org[31]==symbol3) ? 1'b1 : 1'b0;
assign dict4[31] = (dict_org[31]==symbol4) ? 1'b1 : 1'b0;
assign dict5[31] = (dict_org[31]==symbol5) ? 1'b1 : 1'b0;
assign dict1[32] = (dict_org[32]==symbol1) ? 1'b1 : 1'b0;
assign dict2[32] = (dict_org[32]==symbol2) ? 1'b1 : 1'b0;
assign dict3[32] = (dict_org[32]==symbol3) ? 1'b1 : 1'b0;
assign dict4[32] = (dict_org[32]==symbol4) ? 1'b1 : 1'b0;
assign dict5[32] = (dict_org[32]==symbol5) ? 1'b1 : 1'b0;
assign dict1[33] = (dict_org[33]==symbol1) ? 1'b1 : 1'b0;
assign dict2[33] = (dict_org[33]==symbol2) ? 1'b1 : 1'b0;
assign dict3[33] = (dict_org[33]==symbol3) ? 1'b1 : 1'b0;
assign dict4[33] = (dict_org[33]==symbol4) ? 1'b1 : 1'b0;
assign dict5[33] = (dict_org[33]==symbol5) ? 1'b1 : 1'b0;
assign dict1[34] = (dict_org[34]==symbol1) ? 1'b1 : 1'b0;
assign dict2[34] = (dict_org[34]==symbol2) ? 1'b1 : 1'b0;
assign dict3[34] = (dict_org[34]==symbol3) ? 1'b1 : 1'b0;
assign dict4[34] = (dict_org[34]==symbol4) ? 1'b1 : 1'b0;
assign dict5[34] = (dict_org[34]==symbol5) ? 1'b1 : 1'b0;
assign dict1[35] = (dict_org[35]==symbol1) ? 1'b1 : 1'b0;
assign dict2[35] = (dict_org[35]==symbol2) ? 1'b1 : 1'b0;
assign dict3[35] = (dict_org[35]==symbol3) ? 1'b1 : 1'b0;
assign dict4[35] = (dict_org[35]==symbol4) ? 1'b1 : 1'b0;
assign dict5[35] = (dict_org[35]==symbol5) ? 1'b1 : 1'b0;
assign dict1[36] = (dict_org[36]==symbol1) ? 1'b1 : 1'b0;
assign dict2[36] = (dict_org[36]==symbol2) ? 1'b1 : 1'b0;
assign dict3[36] = (dict_org[36]==symbol3) ? 1'b1 : 1'b0;
assign dict4[36] = (dict_org[36]==symbol4) ? 1'b1 : 1'b0;
assign dict5[36] = (dict_org[36]==symbol5) ? 1'b1 : 1'b0;
assign dict1[37] = (dict_org[37]==symbol1) ? 1'b1 : 1'b0;
assign dict2[37] = (dict_org[37]==symbol2) ? 1'b1 : 1'b0;
assign dict3[37] = (dict_org[37]==symbol3) ? 1'b1 : 1'b0;
assign dict4[37] = (dict_org[37]==symbol4) ? 1'b1 : 1'b0;
assign dict5[37] = (dict_org[37]==symbol5) ? 1'b1 : 1'b0;
assign dict1[38] = (dict_org[38]==symbol1) ? 1'b1 : 1'b0;
assign dict2[38] = (dict_org[38]==symbol2) ? 1'b1 : 1'b0;
assign dict3[38] = (dict_org[38]==symbol3) ? 1'b1 : 1'b0;
assign dict4[38] = (dict_org[38]==symbol4) ? 1'b1 : 1'b0;
assign dict5[38] = (dict_org[38]==symbol5) ? 1'b1 : 1'b0;
assign dict1[39] = (dict_org[39]==symbol1) ? 1'b1 : 1'b0;
assign dict2[39] = (dict_org[39]==symbol2) ? 1'b1 : 1'b0;
assign dict3[39] = (dict_org[39]==symbol3) ? 1'b1 : 1'b0;
assign dict4[39] = (dict_org[39]==symbol4) ? 1'b1 : 1'b0;
assign dict5[39] = (dict_org[39]==symbol5) ? 1'b1 : 1'b0;
assign dict1[40] = (dict_org[40]==symbol1) ? 1'b1 : 1'b0;
assign dict2[40] = (dict_org[40]==symbol2) ? 1'b1 : 1'b0;
assign dict3[40] = (dict_org[40]==symbol3) ? 1'b1 : 1'b0;
assign dict4[40] = (dict_org[40]==symbol4) ? 1'b1 : 1'b0;
assign dict5[40] = (dict_org[40]==symbol5) ? 1'b1 : 1'b0;
assign dict1[41] = (dict_org[41]==symbol1) ? 1'b1 : 1'b0;
assign dict2[41] = (dict_org[41]==symbol2) ? 1'b1 : 1'b0;
assign dict3[41] = (dict_org[41]==symbol3) ? 1'b1 : 1'b0;
assign dict4[41] = (dict_org[41]==symbol4) ? 1'b1 : 1'b0;
assign dict5[41] = (dict_org[41]==symbol5) ? 1'b1 : 1'b0;
assign dict1[42] = (dict_org[42]==symbol1) ? 1'b1 : 1'b0;
assign dict2[42] = (dict_org[42]==symbol2) ? 1'b1 : 1'b0;
assign dict3[42] = (dict_org[42]==symbol3) ? 1'b1 : 1'b0;
assign dict4[42] = (dict_org[42]==symbol4) ? 1'b1 : 1'b0;
assign dict5[42] = (dict_org[42]==symbol5) ? 1'b1 : 1'b0;
assign dict1[43] = (dict_org[43]==symbol1) ? 1'b1 : 1'b0;
assign dict2[43] = (dict_org[43]==symbol2) ? 1'b1 : 1'b0;
assign dict3[43] = (dict_org[43]==symbol3) ? 1'b1 : 1'b0;
assign dict4[43] = (dict_org[43]==symbol4) ? 1'b1 : 1'b0;
assign dict5[43] = (dict_org[43]==symbol5) ? 1'b1 : 1'b0;
assign dict1[44] = (dict_org[44]==symbol1) ? 1'b1 : 1'b0;
assign dict2[44] = (dict_org[44]==symbol2) ? 1'b1 : 1'b0;
assign dict3[44] = (dict_org[44]==symbol3) ? 1'b1 : 1'b0;
assign dict4[44] = (dict_org[44]==symbol4) ? 1'b1 : 1'b0;
assign dict5[44] = (dict_org[44]==symbol5) ? 1'b1 : 1'b0;
assign dict1[45] = (dict_org[45]==symbol1) ? 1'b1 : 1'b0;
assign dict2[45] = (dict_org[45]==symbol2) ? 1'b1 : 1'b0;
assign dict3[45] = (dict_org[45]==symbol3) ? 1'b1 : 1'b0;
assign dict4[45] = (dict_org[45]==symbol4) ? 1'b1 : 1'b0;
assign dict5[45] = (dict_org[45]==symbol5) ? 1'b1 : 1'b0;
assign dict1[46] = (dict_org[46]==symbol1) ? 1'b1 : 1'b0;
assign dict2[46] = (dict_org[46]==symbol2) ? 1'b1 : 1'b0;
assign dict3[46] = (dict_org[46]==symbol3) ? 1'b1 : 1'b0;
assign dict4[46] = (dict_org[46]==symbol4) ? 1'b1 : 1'b0;
assign dict5[46] = (dict_org[46]==symbol5) ? 1'b1 : 1'b0;
assign dict1[47] = (dict_org[47]==symbol1) ? 1'b1 : 1'b0;
assign dict2[47] = (dict_org[47]==symbol2) ? 1'b1 : 1'b0;
assign dict3[47] = (dict_org[47]==symbol3) ? 1'b1 : 1'b0;
assign dict4[47] = (dict_org[47]==symbol4) ? 1'b1 : 1'b0;
assign dict5[47] = (dict_org[47]==symbol5) ? 1'b1 : 1'b0;
assign dict1[48] = (dict_org[48]==symbol1) ? 1'b1 : 1'b0;
assign dict2[48] = (dict_org[48]==symbol2) ? 1'b1 : 1'b0;
assign dict3[48] = (dict_org[48]==symbol3) ? 1'b1 : 1'b0;
assign dict4[48] = (dict_org[48]==symbol4) ? 1'b1 : 1'b0;
assign dict5[48] = (dict_org[48]==symbol5) ? 1'b1 : 1'b0;
assign dict1[49] = (dict_org[49]==symbol1) ? 1'b1 : 1'b0;
assign dict2[49] = (dict_org[49]==symbol2) ? 1'b1 : 1'b0;
assign dict3[49] = (dict_org[49]==symbol3) ? 1'b1 : 1'b0;
assign dict4[49] = (dict_org[49]==symbol4) ? 1'b1 : 1'b0;
assign dict5[49] = (dict_org[49]==symbol5) ? 1'b1 : 1'b0;
assign dict1[50] = (dict_org[50]==symbol1) ? 1'b1 : 1'b0;
assign dict2[50] = (dict_org[50]==symbol2) ? 1'b1 : 1'b0;
assign dict3[50] = (dict_org[50]==symbol3) ? 1'b1 : 1'b0;
assign dict4[50] = (dict_org[50]==symbol4) ? 1'b1 : 1'b0;
assign dict5[50] = (dict_org[50]==symbol5) ? 1'b1 : 1'b0;
assign dict1[51] = (dict_org[51]==symbol1) ? 1'b1 : 1'b0;
assign dict2[51] = (dict_org[51]==symbol2) ? 1'b1 : 1'b0;
assign dict3[51] = (dict_org[51]==symbol3) ? 1'b1 : 1'b0;
assign dict4[51] = (dict_org[51]==symbol4) ? 1'b1 : 1'b0;
assign dict5[51] = (dict_org[51]==symbol5) ? 1'b1 : 1'b0;
assign dict1[52] = (dict_org[52]==symbol1) ? 1'b1 : 1'b0;
assign dict2[52] = (dict_org[52]==symbol2) ? 1'b1 : 1'b0;
assign dict3[52] = (dict_org[52]==symbol3) ? 1'b1 : 1'b0;
assign dict4[52] = (dict_org[52]==symbol4) ? 1'b1 : 1'b0;
assign dict5[52] = (dict_org[52]==symbol5) ? 1'b1 : 1'b0;
assign dict1[53] = (dict_org[53]==symbol1) ? 1'b1 : 1'b0;
assign dict2[53] = (dict_org[53]==symbol2) ? 1'b1 : 1'b0;
assign dict3[53] = (dict_org[53]==symbol3) ? 1'b1 : 1'b0;
assign dict4[53] = (dict_org[53]==symbol4) ? 1'b1 : 1'b0;
assign dict5[53] = (dict_org[53]==symbol5) ? 1'b1 : 1'b0;
assign dict1[54] = (dict_org[54]==symbol1) ? 1'b1 : 1'b0;
assign dict2[54] = (dict_org[54]==symbol2) ? 1'b1 : 1'b0;
assign dict3[54] = (dict_org[54]==symbol3) ? 1'b1 : 1'b0;
assign dict4[54] = (dict_org[54]==symbol4) ? 1'b1 : 1'b0;
assign dict5[54] = (dict_org[54]==symbol5) ? 1'b1 : 1'b0;
assign dict1[55] = (dict_org[55]==symbol1) ? 1'b1 : 1'b0;
assign dict2[55] = (dict_org[55]==symbol2) ? 1'b1 : 1'b0;
assign dict3[55] = (dict_org[55]==symbol3) ? 1'b1 : 1'b0;
assign dict4[55] = (dict_org[55]==symbol4) ? 1'b1 : 1'b0;
assign dict5[55] = (dict_org[55]==symbol5) ? 1'b1 : 1'b0;
assign dict1[56] = (dict_org[56]==symbol1) ? 1'b1 : 1'b0;
assign dict2[56] = (dict_org[56]==symbol2) ? 1'b1 : 1'b0;
assign dict3[56] = (dict_org[56]==symbol3) ? 1'b1 : 1'b0;
assign dict4[56] = (dict_org[56]==symbol4) ? 1'b1 : 1'b0;
assign dict5[56] = (dict_org[56]==symbol5) ? 1'b1 : 1'b0;
assign dict1[57] = (dict_org[57]==symbol1) ? 1'b1 : 1'b0;
assign dict2[57] = (dict_org[57]==symbol2) ? 1'b1 : 1'b0;
assign dict3[57] = (dict_org[57]==symbol3) ? 1'b1 : 1'b0;
assign dict4[57] = (dict_org[57]==symbol4) ? 1'b1 : 1'b0;
assign dict5[57] = (dict_org[57]==symbol5) ? 1'b1 : 1'b0;
assign dict1[58] = (dict_org[58]==symbol1) ? 1'b1 : 1'b0;
assign dict2[58] = (dict_org[58]==symbol2) ? 1'b1 : 1'b0;
assign dict3[58] = (dict_org[58]==symbol3) ? 1'b1 : 1'b0;
assign dict4[58] = (dict_org[58]==symbol4) ? 1'b1 : 1'b0;
assign dict5[58] = (dict_org[58]==symbol5) ? 1'b1 : 1'b0;
assign dict1[59] = (dict_org[59]==symbol1) ? 1'b1 : 1'b0;
assign dict2[59] = (dict_org[59]==symbol2) ? 1'b1 : 1'b0;
assign dict3[59] = (dict_org[59]==symbol3) ? 1'b1 : 1'b0;
assign dict4[59] = (dict_org[59]==symbol4) ? 1'b1 : 1'b0;
assign dict5[59] = (dict_org[59]==symbol5) ? 1'b1 : 1'b0;
assign dict1[60] = (dict_org[60]==symbol1) ? 1'b1 : 1'b0;
assign dict2[60] = (dict_org[60]==symbol2) ? 1'b1 : 1'b0;
assign dict3[60] = (dict_org[60]==symbol3) ? 1'b1 : 1'b0;
assign dict4[60] = (dict_org[60]==symbol4) ? 1'b1 : 1'b0;
assign dict5[60] = (dict_org[60]==symbol5) ? 1'b1 : 1'b0;
assign dict1[61] = (dict_org[61]==symbol1) ? 1'b1 : 1'b0;
assign dict2[61] = (dict_org[61]==symbol2) ? 1'b1 : 1'b0;
assign dict3[61] = (dict_org[61]==symbol3) ? 1'b1 : 1'b0;
assign dict4[61] = (dict_org[61]==symbol4) ? 1'b1 : 1'b0;
assign dict5[61] = (dict_org[61]==symbol5) ? 1'b1 : 1'b0;
assign dict1[62] = (dict_org[62]==symbol1) ? 1'b1 : 1'b0;
assign dict2[62] = (dict_org[62]==symbol2) ? 1'b1 : 1'b0;
assign dict3[62] = (dict_org[62]==symbol3) ? 1'b1 : 1'b0;
assign dict4[62] = (dict_org[62]==symbol4) ? 1'b1 : 1'b0;
assign dict5[62] = (dict_org[62]==symbol5) ? 1'b1 : 1'b0;
assign dict1[63] = (dict_org[63]==symbol1) ? 1'b1 : 1'b0;
assign dict2[63] = (dict_org[63]==symbol2) ? 1'b1 : 1'b0;
assign dict3[63] = (dict_org[63]==symbol3) ? 1'b1 : 1'b0;
assign dict4[63] = (dict_org[63]==symbol4) ? 1'b1 : 1'b0;
assign dict5[63] = (dict_org[63]==symbol5) ? 1'b1 : 1'b0;
assign dict1[64] = (dict_org[64]==symbol1) ? 1'b1 : 1'b0;
assign dict2[64] = (dict_org[64]==symbol2) ? 1'b1 : 1'b0;
assign dict3[64] = (dict_org[64]==symbol3) ? 1'b1 : 1'b0;
assign dict4[64] = (dict_org[64]==symbol4) ? 1'b1 : 1'b0;
assign dict5[64] = (dict_org[64]==symbol5) ? 1'b1 : 1'b0;
assign dict1[65] = (dict_org[65]==symbol1) ? 1'b1 : 1'b0;
assign dict2[65] = (dict_org[65]==symbol2) ? 1'b1 : 1'b0;
assign dict3[65] = (dict_org[65]==symbol3) ? 1'b1 : 1'b0;
assign dict4[65] = (dict_org[65]==symbol4) ? 1'b1 : 1'b0;
assign dict5[65] = (dict_org[65]==symbol5) ? 1'b1 : 1'b0;
assign dict1[66] = (dict_org[66]==symbol1) ? 1'b1 : 1'b0;
assign dict2[66] = (dict_org[66]==symbol2) ? 1'b1 : 1'b0;
assign dict3[66] = (dict_org[66]==symbol3) ? 1'b1 : 1'b0;
assign dict4[66] = (dict_org[66]==symbol4) ? 1'b1 : 1'b0;
assign dict5[66] = (dict_org[66]==symbol5) ? 1'b1 : 1'b0;
assign dict1[67] = (dict_org[67]==symbol1) ? 1'b1 : 1'b0;
assign dict2[67] = (dict_org[67]==symbol2) ? 1'b1 : 1'b0;
assign dict3[67] = (dict_org[67]==symbol3) ? 1'b1 : 1'b0;
assign dict4[67] = (dict_org[67]==symbol4) ? 1'b1 : 1'b0;
assign dict5[67] = (dict_org[67]==symbol5) ? 1'b1 : 1'b0;
assign dict1[68] = (dict_org[68]==symbol1) ? 1'b1 : 1'b0;
assign dict2[68] = (dict_org[68]==symbol2) ? 1'b1 : 1'b0;
assign dict3[68] = (dict_org[68]==symbol3) ? 1'b1 : 1'b0;
assign dict4[68] = (dict_org[68]==symbol4) ? 1'b1 : 1'b0;
assign dict5[68] = (dict_org[68]==symbol5) ? 1'b1 : 1'b0;
assign dict1[69] = (dict_org[69]==symbol1) ? 1'b1 : 1'b0;
assign dict2[69] = (dict_org[69]==symbol2) ? 1'b1 : 1'b0;
assign dict3[69] = (dict_org[69]==symbol3) ? 1'b1 : 1'b0;
assign dict4[69] = (dict_org[69]==symbol4) ? 1'b1 : 1'b0;
assign dict5[69] = (dict_org[69]==symbol5) ? 1'b1 : 1'b0;
assign dict1[70] = (dict_org[70]==symbol1) ? 1'b1 : 1'b0;
assign dict2[70] = (dict_org[70]==symbol2) ? 1'b1 : 1'b0;
assign dict3[70] = (dict_org[70]==symbol3) ? 1'b1 : 1'b0;
assign dict4[70] = (dict_org[70]==symbol4) ? 1'b1 : 1'b0;
assign dict5[70] = (dict_org[70]==symbol5) ? 1'b1 : 1'b0;
assign dict1[71] = (dict_org[71]==symbol1) ? 1'b1 : 1'b0;
assign dict2[71] = (dict_org[71]==symbol2) ? 1'b1 : 1'b0;
assign dict3[71] = (dict_org[71]==symbol3) ? 1'b1 : 1'b0;
assign dict4[71] = (dict_org[71]==symbol4) ? 1'b1 : 1'b0;
assign dict5[71] = (dict_org[71]==symbol5) ? 1'b1 : 1'b0;
assign dict1[72] = (dict_org[72]==symbol1) ? 1'b1 : 1'b0;
assign dict2[72] = (dict_org[72]==symbol2) ? 1'b1 : 1'b0;
assign dict3[72] = (dict_org[72]==symbol3) ? 1'b1 : 1'b0;
assign dict4[72] = (dict_org[72]==symbol4) ? 1'b1 : 1'b0;
assign dict5[72] = (dict_org[72]==symbol5) ? 1'b1 : 1'b0;
assign dict1[73] = (dict_org[73]==symbol1) ? 1'b1 : 1'b0;
assign dict2[73] = (dict_org[73]==symbol2) ? 1'b1 : 1'b0;
assign dict3[73] = (dict_org[73]==symbol3) ? 1'b1 : 1'b0;
assign dict4[73] = (dict_org[73]==symbol4) ? 1'b1 : 1'b0;
assign dict5[73] = (dict_org[73]==symbol5) ? 1'b1 : 1'b0;
assign dict1[74] = (dict_org[74]==symbol1) ? 1'b1 : 1'b0;
assign dict2[74] = (dict_org[74]==symbol2) ? 1'b1 : 1'b0;
assign dict3[74] = (dict_org[74]==symbol3) ? 1'b1 : 1'b0;
assign dict4[74] = (dict_org[74]==symbol4) ? 1'b1 : 1'b0;
assign dict5[74] = (dict_org[74]==symbol5) ? 1'b1 : 1'b0;
assign dict1[75] = (dict_org[75]==symbol1) ? 1'b1 : 1'b0;
assign dict2[75] = (dict_org[75]==symbol2) ? 1'b1 : 1'b0;
assign dict3[75] = (dict_org[75]==symbol3) ? 1'b1 : 1'b0;
assign dict4[75] = (dict_org[75]==symbol4) ? 1'b1 : 1'b0;
assign dict5[75] = (dict_org[75]==symbol5) ? 1'b1 : 1'b0;
assign dict1[76] = (dict_org[76]==symbol1) ? 1'b1 : 1'b0;
assign dict2[76] = (dict_org[76]==symbol2) ? 1'b1 : 1'b0;
assign dict3[76] = (dict_org[76]==symbol3) ? 1'b1 : 1'b0;
assign dict4[76] = (dict_org[76]==symbol4) ? 1'b1 : 1'b0;
assign dict5[76] = (dict_org[76]==symbol5) ? 1'b1 : 1'b0;
assign dict1[77] = (dict_org[77]==symbol1) ? 1'b1 : 1'b0;
assign dict2[77] = (dict_org[77]==symbol2) ? 1'b1 : 1'b0;
assign dict3[77] = (dict_org[77]==symbol3) ? 1'b1 : 1'b0;
assign dict4[77] = (dict_org[77]==symbol4) ? 1'b1 : 1'b0;
assign dict5[77] = (dict_org[77]==symbol5) ? 1'b1 : 1'b0;
assign dict1[78] = (dict_org[78]==symbol1) ? 1'b1 : 1'b0;
assign dict2[78] = (dict_org[78]==symbol2) ? 1'b1 : 1'b0;
assign dict3[78] = (dict_org[78]==symbol3) ? 1'b1 : 1'b0;
assign dict4[78] = (dict_org[78]==symbol4) ? 1'b1 : 1'b0;
assign dict5[78] = (dict_org[78]==symbol5) ? 1'b1 : 1'b0;
assign dict1[79] = (dict_org[79]==symbol1) ? 1'b1 : 1'b0;
assign dict2[79] = (dict_org[79]==symbol2) ? 1'b1 : 1'b0;
assign dict3[79] = (dict_org[79]==symbol3) ? 1'b1 : 1'b0;
assign dict4[79] = (dict_org[79]==symbol4) ? 1'b1 : 1'b0;
assign dict5[79] = (dict_org[79]==symbol5) ? 1'b1 : 1'b0;
assign dict1[80] = (dict_org[80]==symbol1) ? 1'b1 : 1'b0;
assign dict2[80] = (dict_org[80]==symbol2) ? 1'b1 : 1'b0;
assign dict3[80] = (dict_org[80]==symbol3) ? 1'b1 : 1'b0;
assign dict4[80] = (dict_org[80]==symbol4) ? 1'b1 : 1'b0;
assign dict5[80] = (dict_org[80]==symbol5) ? 1'b1 : 1'b0;
assign dict1[81] = (dict_org[81]==symbol1) ? 1'b1 : 1'b0;
assign dict2[81] = (dict_org[81]==symbol2) ? 1'b1 : 1'b0;
assign dict3[81] = (dict_org[81]==symbol3) ? 1'b1 : 1'b0;
assign dict4[81] = (dict_org[81]==symbol4) ? 1'b1 : 1'b0;
assign dict5[81] = (dict_org[81]==symbol5) ? 1'b1 : 1'b0;
assign dict1[82] = (dict_org[82]==symbol1) ? 1'b1 : 1'b0;
assign dict2[82] = (dict_org[82]==symbol2) ? 1'b1 : 1'b0;
assign dict3[82] = (dict_org[82]==symbol3) ? 1'b1 : 1'b0;
assign dict4[82] = (dict_org[82]==symbol4) ? 1'b1 : 1'b0;
assign dict5[82] = (dict_org[82]==symbol5) ? 1'b1 : 1'b0;
assign dict1[83] = (dict_org[83]==symbol1) ? 1'b1 : 1'b0;
assign dict2[83] = (dict_org[83]==symbol2) ? 1'b1 : 1'b0;
assign dict3[83] = (dict_org[83]==symbol3) ? 1'b1 : 1'b0;
assign dict4[83] = (dict_org[83]==symbol4) ? 1'b1 : 1'b0;
assign dict5[83] = (dict_org[83]==symbol5) ? 1'b1 : 1'b0;
assign dict1[84] = (dict_org[84]==symbol1) ? 1'b1 : 1'b0;
assign dict2[84] = (dict_org[84]==symbol2) ? 1'b1 : 1'b0;
assign dict3[84] = (dict_org[84]==symbol3) ? 1'b1 : 1'b0;
assign dict4[84] = (dict_org[84]==symbol4) ? 1'b1 : 1'b0;
assign dict5[84] = (dict_org[84]==symbol5) ? 1'b1 : 1'b0;
assign dict1[85] = (dict_org[85]==symbol1) ? 1'b1 : 1'b0;
assign dict2[85] = (dict_org[85]==symbol2) ? 1'b1 : 1'b0;
assign dict3[85] = (dict_org[85]==symbol3) ? 1'b1 : 1'b0;
assign dict4[85] = (dict_org[85]==symbol4) ? 1'b1 : 1'b0;
assign dict5[85] = (dict_org[85]==symbol5) ? 1'b1 : 1'b0;
assign dict1[86] = (dict_org[86]==symbol1) ? 1'b1 : 1'b0;
assign dict2[86] = (dict_org[86]==symbol2) ? 1'b1 : 1'b0;
assign dict3[86] = (dict_org[86]==symbol3) ? 1'b1 : 1'b0;
assign dict4[86] = (dict_org[86]==symbol4) ? 1'b1 : 1'b0;
assign dict5[86] = (dict_org[86]==symbol5) ? 1'b1 : 1'b0;
assign dict1[87] = (dict_org[87]==symbol1) ? 1'b1 : 1'b0;
assign dict2[87] = (dict_org[87]==symbol2) ? 1'b1 : 1'b0;
assign dict3[87] = (dict_org[87]==symbol3) ? 1'b1 : 1'b0;
assign dict4[87] = (dict_org[87]==symbol4) ? 1'b1 : 1'b0;
assign dict5[87] = (dict_org[87]==symbol5) ? 1'b1 : 1'b0;
assign dict1[88] = (dict_org[88]==symbol1) ? 1'b1 : 1'b0;
assign dict2[88] = (dict_org[88]==symbol2) ? 1'b1 : 1'b0;
assign dict3[88] = (dict_org[88]==symbol3) ? 1'b1 : 1'b0;
assign dict4[88] = (dict_org[88]==symbol4) ? 1'b1 : 1'b0;
assign dict5[88] = (dict_org[88]==symbol5) ? 1'b1 : 1'b0;
assign dict1[89] = (dict_org[89]==symbol1) ? 1'b1 : 1'b0;
assign dict2[89] = (dict_org[89]==symbol2) ? 1'b1 : 1'b0;
assign dict3[89] = (dict_org[89]==symbol3) ? 1'b1 : 1'b0;
assign dict4[89] = (dict_org[89]==symbol4) ? 1'b1 : 1'b0;
assign dict5[89] = (dict_org[89]==symbol5) ? 1'b1 : 1'b0;
assign dict1[90] = (dict_org[90]==symbol1) ? 1'b1 : 1'b0;
assign dict2[90] = (dict_org[90]==symbol2) ? 1'b1 : 1'b0;
assign dict3[90] = (dict_org[90]==symbol3) ? 1'b1 : 1'b0;
assign dict4[90] = (dict_org[90]==symbol4) ? 1'b1 : 1'b0;
assign dict5[90] = (dict_org[90]==symbol5) ? 1'b1 : 1'b0;
assign dict1[91] = (dict_org[91]==symbol1) ? 1'b1 : 1'b0;
assign dict2[91] = (dict_org[91]==symbol2) ? 1'b1 : 1'b0;
assign dict3[91] = (dict_org[91]==symbol3) ? 1'b1 : 1'b0;
assign dict4[91] = (dict_org[91]==symbol4) ? 1'b1 : 1'b0;
assign dict5[91] = (dict_org[91]==symbol5) ? 1'b1 : 1'b0;
assign dict1[92] = (dict_org[92]==symbol1) ? 1'b1 : 1'b0;
assign dict2[92] = (dict_org[92]==symbol2) ? 1'b1 : 1'b0;
assign dict3[92] = (dict_org[92]==symbol3) ? 1'b1 : 1'b0;
assign dict4[92] = (dict_org[92]==symbol4) ? 1'b1 : 1'b0;
assign dict5[92] = (dict_org[92]==symbol5) ? 1'b1 : 1'b0;
assign dict1[93] = (dict_org[93]==symbol1) ? 1'b1 : 1'b0;
assign dict2[93] = (dict_org[93]==symbol2) ? 1'b1 : 1'b0;
assign dict3[93] = (dict_org[93]==symbol3) ? 1'b1 : 1'b0;
assign dict4[93] = (dict_org[93]==symbol4) ? 1'b1 : 1'b0;
assign dict5[93] = (dict_org[93]==symbol5) ? 1'b1 : 1'b0;
assign dict1[94] = (dict_org[94]==symbol1) ? 1'b1 : 1'b0;
assign dict2[94] = (dict_org[94]==symbol2) ? 1'b1 : 1'b0;
assign dict3[94] = (dict_org[94]==symbol3) ? 1'b1 : 1'b0;
assign dict4[94] = (dict_org[94]==symbol4) ? 1'b1 : 1'b0;
assign dict5[94] = (dict_org[94]==symbol5) ? 1'b1 : 1'b0;
assign dict1[95] = (dict_org[95]==symbol1) ? 1'b1 : 1'b0;
assign dict2[95] = (dict_org[95]==symbol2) ? 1'b1 : 1'b0;
assign dict3[95] = (dict_org[95]==symbol3) ? 1'b1 : 1'b0;
assign dict4[95] = (dict_org[95]==symbol4) ? 1'b1 : 1'b0;
assign dict5[95] = (dict_org[95]==symbol5) ? 1'b1 : 1'b0;
assign dict1[96] = (dict_org[96]==symbol1) ? 1'b1 : 1'b0;
assign dict2[96] = (dict_org[96]==symbol2) ? 1'b1 : 1'b0;
assign dict3[96] = (dict_org[96]==symbol3) ? 1'b1 : 1'b0;
assign dict4[96] = (dict_org[96]==symbol4) ? 1'b1 : 1'b0;
assign dict5[96] = (dict_org[96]==symbol5) ? 1'b1 : 1'b0;
assign dict1[97] = (dict_org[97]==symbol1) ? 1'b1 : 1'b0;
assign dict2[97] = (dict_org[97]==symbol2) ? 1'b1 : 1'b0;
assign dict3[97] = (dict_org[97]==symbol3) ? 1'b1 : 1'b0;
assign dict4[97] = (dict_org[97]==symbol4) ? 1'b1 : 1'b0;
assign dict5[97] = (dict_org[97]==symbol5) ? 1'b1 : 1'b0;
assign dict1[98] = (dict_org[98]==symbol1) ? 1'b1 : 1'b0;
assign dict2[98] = (dict_org[98]==symbol2) ? 1'b1 : 1'b0;
assign dict3[98] = (dict_org[98]==symbol3) ? 1'b1 : 1'b0;
assign dict4[98] = (dict_org[98]==symbol4) ? 1'b1 : 1'b0;
assign dict5[98] = (dict_org[98]==symbol5) ? 1'b1 : 1'b0;
assign dict1[99] = (dict_org[99]==symbol1) ? 1'b1 : 1'b0;
assign dict2[99] = (dict_org[99]==symbol2) ? 1'b1 : 1'b0;
assign dict3[99] = (dict_org[99]==symbol3) ? 1'b1 : 1'b0;
assign dict4[99] = (dict_org[99]==symbol4) ? 1'b1 : 1'b0;
assign dict5[99] = (dict_org[99]==symbol5) ? 1'b1 : 1'b0;
assign dict1[100] = (dict_org[100]==symbol1) ? 1'b1 : 1'b0;
assign dict2[100] = (dict_org[100]==symbol2) ? 1'b1 : 1'b0;
assign dict3[100] = (dict_org[100]==symbol3) ? 1'b1 : 1'b0;
assign dict4[100] = (dict_org[100]==symbol4) ? 1'b1 : 1'b0;
assign dict5[100] = (dict_org[100]==symbol5) ? 1'b1 : 1'b0;
assign dict1[101] = (dict_org[101]==symbol1) ? 1'b1 : 1'b0;
assign dict2[101] = (dict_org[101]==symbol2) ? 1'b1 : 1'b0;
assign dict3[101] = (dict_org[101]==symbol3) ? 1'b1 : 1'b0;
assign dict4[101] = (dict_org[101]==symbol4) ? 1'b1 : 1'b0;
assign dict5[101] = (dict_org[101]==symbol5) ? 1'b1 : 1'b0;
assign dict1[102] = (dict_org[102]==symbol1) ? 1'b1 : 1'b0;
assign dict2[102] = (dict_org[102]==symbol2) ? 1'b1 : 1'b0;
assign dict3[102] = (dict_org[102]==symbol3) ? 1'b1 : 1'b0;
assign dict4[102] = (dict_org[102]==symbol4) ? 1'b1 : 1'b0;
assign dict5[102] = (dict_org[102]==symbol5) ? 1'b1 : 1'b0;
assign dict1[103] = (dict_org[103]==symbol1) ? 1'b1 : 1'b0;
assign dict2[103] = (dict_org[103]==symbol2) ? 1'b1 : 1'b0;
assign dict3[103] = (dict_org[103]==symbol3) ? 1'b1 : 1'b0;
assign dict4[103] = (dict_org[103]==symbol4) ? 1'b1 : 1'b0;
assign dict5[103] = (dict_org[103]==symbol5) ? 1'b1 : 1'b0;
assign dict1[104] = (dict_org[104]==symbol1) ? 1'b1 : 1'b0;
assign dict2[104] = (dict_org[104]==symbol2) ? 1'b1 : 1'b0;
assign dict3[104] = (dict_org[104]==symbol3) ? 1'b1 : 1'b0;
assign dict4[104] = (dict_org[104]==symbol4) ? 1'b1 : 1'b0;
assign dict5[104] = (dict_org[104]==symbol5) ? 1'b1 : 1'b0;
assign dict1[105] = (dict_org[105]==symbol1) ? 1'b1 : 1'b0;
assign dict2[105] = (dict_org[105]==symbol2) ? 1'b1 : 1'b0;
assign dict3[105] = (dict_org[105]==symbol3) ? 1'b1 : 1'b0;
assign dict4[105] = (dict_org[105]==symbol4) ? 1'b1 : 1'b0;
assign dict5[105] = (dict_org[105]==symbol5) ? 1'b1 : 1'b0;
assign dict1[106] = (dict_org[106]==symbol1) ? 1'b1 : 1'b0;
assign dict2[106] = (dict_org[106]==symbol2) ? 1'b1 : 1'b0;
assign dict3[106] = (dict_org[106]==symbol3) ? 1'b1 : 1'b0;
assign dict4[106] = (dict_org[106]==symbol4) ? 1'b1 : 1'b0;
assign dict5[106] = (dict_org[106]==symbol5) ? 1'b1 : 1'b0;
assign dict1[107] = (dict_org[107]==symbol1) ? 1'b1 : 1'b0;
assign dict2[107] = (dict_org[107]==symbol2) ? 1'b1 : 1'b0;
assign dict3[107] = (dict_org[107]==symbol3) ? 1'b1 : 1'b0;
assign dict4[107] = (dict_org[107]==symbol4) ? 1'b1 : 1'b0;
assign dict5[107] = (dict_org[107]==symbol5) ? 1'b1 : 1'b0;
assign dict1[108] = (dict_org[108]==symbol1) ? 1'b1 : 1'b0;
assign dict2[108] = (dict_org[108]==symbol2) ? 1'b1 : 1'b0;
assign dict3[108] = (dict_org[108]==symbol3) ? 1'b1 : 1'b0;
assign dict4[108] = (dict_org[108]==symbol4) ? 1'b1 : 1'b0;
assign dict5[108] = (dict_org[108]==symbol5) ? 1'b1 : 1'b0;
assign dict1[109] = (dict_org[109]==symbol1) ? 1'b1 : 1'b0;
assign dict2[109] = (dict_org[109]==symbol2) ? 1'b1 : 1'b0;
assign dict3[109] = (dict_org[109]==symbol3) ? 1'b1 : 1'b0;
assign dict4[109] = (dict_org[109]==symbol4) ? 1'b1 : 1'b0;
assign dict5[109] = (dict_org[109]==symbol5) ? 1'b1 : 1'b0;
assign dict1[110] = (dict_org[110]==symbol1) ? 1'b1 : 1'b0;
assign dict2[110] = (dict_org[110]==symbol2) ? 1'b1 : 1'b0;
assign dict3[110] = (dict_org[110]==symbol3) ? 1'b1 : 1'b0;
assign dict4[110] = (dict_org[110]==symbol4) ? 1'b1 : 1'b0;
assign dict5[110] = (dict_org[110]==symbol5) ? 1'b1 : 1'b0;
assign dict1[111] = (dict_org[111]==symbol1) ? 1'b1 : 1'b0;
assign dict2[111] = (dict_org[111]==symbol2) ? 1'b1 : 1'b0;
assign dict3[111] = (dict_org[111]==symbol3) ? 1'b1 : 1'b0;
assign dict4[111] = (dict_org[111]==symbol4) ? 1'b1 : 1'b0;
assign dict5[111] = (dict_org[111]==symbol5) ? 1'b1 : 1'b0;
assign dict1[112] = (dict_org[112]==symbol1) ? 1'b1 : 1'b0;
assign dict2[112] = (dict_org[112]==symbol2) ? 1'b1 : 1'b0;
assign dict3[112] = (dict_org[112]==symbol3) ? 1'b1 : 1'b0;
assign dict4[112] = (dict_org[112]==symbol4) ? 1'b1 : 1'b0;
assign dict5[112] = (dict_org[112]==symbol5) ? 1'b1 : 1'b0;
assign dict1[113] = (dict_org[113]==symbol1) ? 1'b1 : 1'b0;
assign dict2[113] = (dict_org[113]==symbol2) ? 1'b1 : 1'b0;
assign dict3[113] = (dict_org[113]==symbol3) ? 1'b1 : 1'b0;
assign dict4[113] = (dict_org[113]==symbol4) ? 1'b1 : 1'b0;
assign dict5[113] = (dict_org[113]==symbol5) ? 1'b1 : 1'b0;
assign dict1[114] = (dict_org[114]==symbol1) ? 1'b1 : 1'b0;
assign dict2[114] = (dict_org[114]==symbol2) ? 1'b1 : 1'b0;
assign dict3[114] = (dict_org[114]==symbol3) ? 1'b1 : 1'b0;
assign dict4[114] = (dict_org[114]==symbol4) ? 1'b1 : 1'b0;
assign dict5[114] = (dict_org[114]==symbol5) ? 1'b1 : 1'b0;
assign dict1[115] = (dict_org[115]==symbol1) ? 1'b1 : 1'b0;
assign dict2[115] = (dict_org[115]==symbol2) ? 1'b1 : 1'b0;
assign dict3[115] = (dict_org[115]==symbol3) ? 1'b1 : 1'b0;
assign dict4[115] = (dict_org[115]==symbol4) ? 1'b1 : 1'b0;
assign dict5[115] = (dict_org[115]==symbol5) ? 1'b1 : 1'b0;
assign dict1[116] = (dict_org[116]==symbol1) ? 1'b1 : 1'b0;
assign dict2[116] = (dict_org[116]==symbol2) ? 1'b1 : 1'b0;
assign dict3[116] = (dict_org[116]==symbol3) ? 1'b1 : 1'b0;
assign dict4[116] = (dict_org[116]==symbol4) ? 1'b1 : 1'b0;
assign dict5[116] = (dict_org[116]==symbol5) ? 1'b1 : 1'b0;
assign dict1[117] = (dict_org[117]==symbol1) ? 1'b1 : 1'b0;
assign dict2[117] = (dict_org[117]==symbol2) ? 1'b1 : 1'b0;
assign dict3[117] = (dict_org[117]==symbol3) ? 1'b1 : 1'b0;
assign dict4[117] = (dict_org[117]==symbol4) ? 1'b1 : 1'b0;
assign dict5[117] = (dict_org[117]==symbol5) ? 1'b1 : 1'b0;
assign dict1[118] = (dict_org[118]==symbol1) ? 1'b1 : 1'b0;
assign dict2[118] = (dict_org[118]==symbol2) ? 1'b1 : 1'b0;
assign dict3[118] = (dict_org[118]==symbol3) ? 1'b1 : 1'b0;
assign dict4[118] = (dict_org[118]==symbol4) ? 1'b1 : 1'b0;
assign dict5[118] = (dict_org[118]==symbol5) ? 1'b1 : 1'b0;
assign dict1[119] = (dict_org[119]==symbol1) ? 1'b1 : 1'b0;
assign dict2[119] = (dict_org[119]==symbol2) ? 1'b1 : 1'b0;
assign dict3[119] = (dict_org[119]==symbol3) ? 1'b1 : 1'b0;
assign dict4[119] = (dict_org[119]==symbol4) ? 1'b1 : 1'b0;
assign dict5[119] = (dict_org[119]==symbol5) ? 1'b1 : 1'b0;
assign dict1[120] = (dict_org[120]==symbol1) ? 1'b1 : 1'b0;
assign dict2[120] = (dict_org[120]==symbol2) ? 1'b1 : 1'b0;
assign dict3[120] = (dict_org[120]==symbol3) ? 1'b1 : 1'b0;
assign dict4[120] = (dict_org[120]==symbol4) ? 1'b1 : 1'b0;
assign dict5[120] = (dict_org[120]==symbol5) ? 1'b1 : 1'b0;
assign dict1[121] = (dict_org[121]==symbol1) ? 1'b1 : 1'b0;
assign dict2[121] = (dict_org[121]==symbol2) ? 1'b1 : 1'b0;
assign dict3[121] = (dict_org[121]==symbol3) ? 1'b1 : 1'b0;
assign dict4[121] = (dict_org[121]==symbol4) ? 1'b1 : 1'b0;
assign dict5[121] = (dict_org[121]==symbol5) ? 1'b1 : 1'b0;
assign dict1[122] = (dict_org[122]==symbol1) ? 1'b1 : 1'b0;
assign dict2[122] = (dict_org[122]==symbol2) ? 1'b1 : 1'b0;
assign dict3[122] = (dict_org[122]==symbol3) ? 1'b1 : 1'b0;
assign dict4[122] = (dict_org[122]==symbol4) ? 1'b1 : 1'b0;
assign dict5[122] = (dict_org[122]==symbol5) ? 1'b1 : 1'b0;
assign dict1[123] = (dict_org[123]==symbol1) ? 1'b1 : 1'b0;
assign dict2[123] = (dict_org[123]==symbol2) ? 1'b1 : 1'b0;
assign dict3[123] = (dict_org[123]==symbol3) ? 1'b1 : 1'b0;
assign dict4[123] = (dict_org[123]==symbol4) ? 1'b1 : 1'b0;
assign dict5[123] = (dict_org[123]==symbol5) ? 1'b1 : 1'b0;
assign dict1[124] = (dict_org[124]==symbol1) ? 1'b1 : 1'b0;
assign dict2[124] = (dict_org[124]==symbol2) ? 1'b1 : 1'b0;
assign dict3[124] = (dict_org[124]==symbol3) ? 1'b1 : 1'b0;
assign dict4[124] = (dict_org[124]==symbol4) ? 1'b1 : 1'b0;
assign dict5[124] = (dict_org[124]==symbol5) ? 1'b1 : 1'b0;
assign dict1[125] = (dict_org[125]==symbol1) ? 1'b1 : 1'b0;
assign dict2[125] = (dict_org[125]==symbol2) ? 1'b1 : 1'b0;
assign dict3[125] = (dict_org[125]==symbol3) ? 1'b1 : 1'b0;
assign dict4[125] = (dict_org[125]==symbol4) ? 1'b1 : 1'b0;
assign dict5[125] = (dict_org[125]==symbol5) ? 1'b1 : 1'b0;
assign dict1[126] = (dict_org[126]==symbol1) ? 1'b1 : 1'b0;
assign dict2[126] = (dict_org[126]==symbol2) ? 1'b1 : 1'b0;
assign dict3[126] = (dict_org[126]==symbol3) ? 1'b1 : 1'b0;
assign dict4[126] = (dict_org[126]==symbol4) ? 1'b1 : 1'b0;
assign dict5[126] = (dict_org[126]==symbol5) ? 1'b1 : 1'b0;
assign dict1[127] = (dict_org[127]==symbol1) ? 1'b1 : 1'b0;
assign dict2[127] = (dict_org[127]==symbol2) ? 1'b1 : 1'b0;
assign dict3[127] = (dict_org[127]==symbol3) ? 1'b1 : 1'b0;
assign dict4[127] = (dict_org[127]==symbol4) ? 1'b1 : 1'b0;
assign dict5[127] = (dict_org[127]==symbol5) ? 1'b1 : 1'b0;
assign dict1[128] = (dict_org[128]==symbol1) ? 1'b1 : 1'b0;
assign dict2[128] = (dict_org[128]==symbol2) ? 1'b1 : 1'b0;
assign dict3[128] = (dict_org[128]==symbol3) ? 1'b1 : 1'b0;
assign dict4[128] = (dict_org[128]==symbol4) ? 1'b1 : 1'b0;
assign dict5[128] = (dict_org[128]==symbol5) ? 1'b1 : 1'b0;
assign dict1[129] = (dict_org[129]==symbol1) ? 1'b1 : 1'b0;
assign dict2[129] = (dict_org[129]==symbol2) ? 1'b1 : 1'b0;
assign dict3[129] = (dict_org[129]==symbol3) ? 1'b1 : 1'b0;
assign dict4[129] = (dict_org[129]==symbol4) ? 1'b1 : 1'b0;
assign dict5[129] = (dict_org[129]==symbol5) ? 1'b1 : 1'b0;
assign dict1[130] = (dict_org[130]==symbol1) ? 1'b1 : 1'b0;
assign dict2[130] = (dict_org[130]==symbol2) ? 1'b1 : 1'b0;
assign dict3[130] = (dict_org[130]==symbol3) ? 1'b1 : 1'b0;
assign dict4[130] = (dict_org[130]==symbol4) ? 1'b1 : 1'b0;
assign dict5[130] = (dict_org[130]==symbol5) ? 1'b1 : 1'b0;
assign dict1[131] = (dict_org[131]==symbol1) ? 1'b1 : 1'b0;
assign dict2[131] = (dict_org[131]==symbol2) ? 1'b1 : 1'b0;
assign dict3[131] = (dict_org[131]==symbol3) ? 1'b1 : 1'b0;
assign dict4[131] = (dict_org[131]==symbol4) ? 1'b1 : 1'b0;
assign dict5[131] = (dict_org[131]==symbol5) ? 1'b1 : 1'b0;
assign dict1[132] = (dict_org[132]==symbol1) ? 1'b1 : 1'b0;
assign dict2[132] = (dict_org[132]==symbol2) ? 1'b1 : 1'b0;
assign dict3[132] = (dict_org[132]==symbol3) ? 1'b1 : 1'b0;
assign dict4[132] = (dict_org[132]==symbol4) ? 1'b1 : 1'b0;
assign dict5[132] = (dict_org[132]==symbol5) ? 1'b1 : 1'b0;
assign dict1[133] = (dict_org[133]==symbol1) ? 1'b1 : 1'b0;
assign dict2[133] = (dict_org[133]==symbol2) ? 1'b1 : 1'b0;
assign dict3[133] = (dict_org[133]==symbol3) ? 1'b1 : 1'b0;
assign dict4[133] = (dict_org[133]==symbol4) ? 1'b1 : 1'b0;
assign dict5[133] = (dict_org[133]==symbol5) ? 1'b1 : 1'b0;
assign dict1[134] = (dict_org[134]==symbol1) ? 1'b1 : 1'b0;
assign dict2[134] = (dict_org[134]==symbol2) ? 1'b1 : 1'b0;
assign dict3[134] = (dict_org[134]==symbol3) ? 1'b1 : 1'b0;
assign dict4[134] = (dict_org[134]==symbol4) ? 1'b1 : 1'b0;
assign dict5[134] = (dict_org[134]==symbol5) ? 1'b1 : 1'b0;
assign dict1[135] = (dict_org[135]==symbol1) ? 1'b1 : 1'b0;
assign dict2[135] = (dict_org[135]==symbol2) ? 1'b1 : 1'b0;
assign dict3[135] = (dict_org[135]==symbol3) ? 1'b1 : 1'b0;
assign dict4[135] = (dict_org[135]==symbol4) ? 1'b1 : 1'b0;
assign dict5[135] = (dict_org[135]==symbol5) ? 1'b1 : 1'b0;
assign dict1[136] = (dict_org[136]==symbol1) ? 1'b1 : 1'b0;
assign dict2[136] = (dict_org[136]==symbol2) ? 1'b1 : 1'b0;
assign dict3[136] = (dict_org[136]==symbol3) ? 1'b1 : 1'b0;
assign dict4[136] = (dict_org[136]==symbol4) ? 1'b1 : 1'b0;
assign dict5[136] = (dict_org[136]==symbol5) ? 1'b1 : 1'b0;
assign dict1[137] = (dict_org[137]==symbol1) ? 1'b1 : 1'b0;
assign dict2[137] = (dict_org[137]==symbol2) ? 1'b1 : 1'b0;
assign dict3[137] = (dict_org[137]==symbol3) ? 1'b1 : 1'b0;
assign dict4[137] = (dict_org[137]==symbol4) ? 1'b1 : 1'b0;
assign dict5[137] = (dict_org[137]==symbol5) ? 1'b1 : 1'b0;
assign dict1[138] = (dict_org[138]==symbol1) ? 1'b1 : 1'b0;
assign dict2[138] = (dict_org[138]==symbol2) ? 1'b1 : 1'b0;
assign dict3[138] = (dict_org[138]==symbol3) ? 1'b1 : 1'b0;
assign dict4[138] = (dict_org[138]==symbol4) ? 1'b1 : 1'b0;
assign dict5[138] = (dict_org[138]==symbol5) ? 1'b1 : 1'b0;
assign dict1[139] = (dict_org[139]==symbol1) ? 1'b1 : 1'b0;
assign dict2[139] = (dict_org[139]==symbol2) ? 1'b1 : 1'b0;
assign dict3[139] = (dict_org[139]==symbol3) ? 1'b1 : 1'b0;
assign dict4[139] = (dict_org[139]==symbol4) ? 1'b1 : 1'b0;
assign dict5[139] = (dict_org[139]==symbol5) ? 1'b1 : 1'b0;
assign dict1[140] = (dict_org[140]==symbol1) ? 1'b1 : 1'b0;
assign dict2[140] = (dict_org[140]==symbol2) ? 1'b1 : 1'b0;
assign dict3[140] = (dict_org[140]==symbol3) ? 1'b1 : 1'b0;
assign dict4[140] = (dict_org[140]==symbol4) ? 1'b1 : 1'b0;
assign dict5[140] = (dict_org[140]==symbol5) ? 1'b1 : 1'b0;
assign dict1[141] = (dict_org[141]==symbol1) ? 1'b1 : 1'b0;
assign dict2[141] = (dict_org[141]==symbol2) ? 1'b1 : 1'b0;
assign dict3[141] = (dict_org[141]==symbol3) ? 1'b1 : 1'b0;
assign dict4[141] = (dict_org[141]==symbol4) ? 1'b1 : 1'b0;
assign dict5[141] = (dict_org[141]==symbol5) ? 1'b1 : 1'b0;
assign dict1[142] = (dict_org[142]==symbol1) ? 1'b1 : 1'b0;
assign dict2[142] = (dict_org[142]==symbol2) ? 1'b1 : 1'b0;
assign dict3[142] = (dict_org[142]==symbol3) ? 1'b1 : 1'b0;
assign dict4[142] = (dict_org[142]==symbol4) ? 1'b1 : 1'b0;
assign dict5[142] = (dict_org[142]==symbol5) ? 1'b1 : 1'b0;
assign dict1[143] = (dict_org[143]==symbol1) ? 1'b1 : 1'b0;
assign dict2[143] = (dict_org[143]==symbol2) ? 1'b1 : 1'b0;
assign dict3[143] = (dict_org[143]==symbol3) ? 1'b1 : 1'b0;
assign dict4[143] = (dict_org[143]==symbol4) ? 1'b1 : 1'b0;
assign dict5[143] = (dict_org[143]==symbol5) ? 1'b1 : 1'b0;
assign dict1[144] = (dict_org[144]==symbol1) ? 1'b1 : 1'b0;
assign dict2[144] = (dict_org[144]==symbol2) ? 1'b1 : 1'b0;
assign dict3[144] = (dict_org[144]==symbol3) ? 1'b1 : 1'b0;
assign dict4[144] = (dict_org[144]==symbol4) ? 1'b1 : 1'b0;
assign dict5[144] = (dict_org[144]==symbol5) ? 1'b1 : 1'b0;
assign dict1[145] = (dict_org[145]==symbol1) ? 1'b1 : 1'b0;
assign dict2[145] = (dict_org[145]==symbol2) ? 1'b1 : 1'b0;
assign dict3[145] = (dict_org[145]==symbol3) ? 1'b1 : 1'b0;
assign dict4[145] = (dict_org[145]==symbol4) ? 1'b1 : 1'b0;
assign dict5[145] = (dict_org[145]==symbol5) ? 1'b1 : 1'b0;
assign dict1[146] = (dict_org[146]==symbol1) ? 1'b1 : 1'b0;
assign dict2[146] = (dict_org[146]==symbol2) ? 1'b1 : 1'b0;
assign dict3[146] = (dict_org[146]==symbol3) ? 1'b1 : 1'b0;
assign dict4[146] = (dict_org[146]==symbol4) ? 1'b1 : 1'b0;
assign dict5[146] = (dict_org[146]==symbol5) ? 1'b1 : 1'b0;
assign dict1[147] = (dict_org[147]==symbol1) ? 1'b1 : 1'b0;
assign dict2[147] = (dict_org[147]==symbol2) ? 1'b1 : 1'b0;
assign dict3[147] = (dict_org[147]==symbol3) ? 1'b1 : 1'b0;
assign dict4[147] = (dict_org[147]==symbol4) ? 1'b1 : 1'b0;
assign dict5[147] = (dict_org[147]==symbol5) ? 1'b1 : 1'b0;
assign dict1[148] = (dict_org[148]==symbol1) ? 1'b1 : 1'b0;
assign dict2[148] = (dict_org[148]==symbol2) ? 1'b1 : 1'b0;
assign dict3[148] = (dict_org[148]==symbol3) ? 1'b1 : 1'b0;
assign dict4[148] = (dict_org[148]==symbol4) ? 1'b1 : 1'b0;
assign dict5[148] = (dict_org[148]==symbol5) ? 1'b1 : 1'b0;
assign dict1[149] = (dict_org[149]==symbol1) ? 1'b1 : 1'b0;
assign dict2[149] = (dict_org[149]==symbol2) ? 1'b1 : 1'b0;
assign dict3[149] = (dict_org[149]==symbol3) ? 1'b1 : 1'b0;
assign dict4[149] = (dict_org[149]==symbol4) ? 1'b1 : 1'b0;
assign dict5[149] = (dict_org[149]==symbol5) ? 1'b1 : 1'b0;
assign dict1[150] = (dict_org[150]==symbol1) ? 1'b1 : 1'b0;
assign dict2[150] = (dict_org[150]==symbol2) ? 1'b1 : 1'b0;
assign dict3[150] = (dict_org[150]==symbol3) ? 1'b1 : 1'b0;
assign dict4[150] = (dict_org[150]==symbol4) ? 1'b1 : 1'b0;
assign dict5[150] = (dict_org[150]==symbol5) ? 1'b1 : 1'b0;
assign dict1[151] = (dict_org[151]==symbol1) ? 1'b1 : 1'b0;
assign dict2[151] = (dict_org[151]==symbol2) ? 1'b1 : 1'b0;
assign dict3[151] = (dict_org[151]==symbol3) ? 1'b1 : 1'b0;
assign dict4[151] = (dict_org[151]==symbol4) ? 1'b1 : 1'b0;
assign dict5[151] = (dict_org[151]==symbol5) ? 1'b1 : 1'b0;
assign dict1[152] = (dict_org[152]==symbol1) ? 1'b1 : 1'b0;
assign dict2[152] = (dict_org[152]==symbol2) ? 1'b1 : 1'b0;
assign dict3[152] = (dict_org[152]==symbol3) ? 1'b1 : 1'b0;
assign dict4[152] = (dict_org[152]==symbol4) ? 1'b1 : 1'b0;
assign dict5[152] = (dict_org[152]==symbol5) ? 1'b1 : 1'b0;
assign dict1[153] = (dict_org[153]==symbol1) ? 1'b1 : 1'b0;
assign dict2[153] = (dict_org[153]==symbol2) ? 1'b1 : 1'b0;
assign dict3[153] = (dict_org[153]==symbol3) ? 1'b1 : 1'b0;
assign dict4[153] = (dict_org[153]==symbol4) ? 1'b1 : 1'b0;
assign dict5[153] = (dict_org[153]==symbol5) ? 1'b1 : 1'b0;
assign dict1[154] = (dict_org[154]==symbol1) ? 1'b1 : 1'b0;
assign dict2[154] = (dict_org[154]==symbol2) ? 1'b1 : 1'b0;
assign dict3[154] = (dict_org[154]==symbol3) ? 1'b1 : 1'b0;
assign dict4[154] = (dict_org[154]==symbol4) ? 1'b1 : 1'b0;
assign dict5[154] = (dict_org[154]==symbol5) ? 1'b1 : 1'b0;
assign dict1[155] = (dict_org[155]==symbol1) ? 1'b1 : 1'b0;
assign dict2[155] = (dict_org[155]==symbol2) ? 1'b1 : 1'b0;
assign dict3[155] = (dict_org[155]==symbol3) ? 1'b1 : 1'b0;
assign dict4[155] = (dict_org[155]==symbol4) ? 1'b1 : 1'b0;
assign dict5[155] = (dict_org[155]==symbol5) ? 1'b1 : 1'b0;
assign dict1[156] = (dict_org[156]==symbol1) ? 1'b1 : 1'b0;
assign dict2[156] = (dict_org[156]==symbol2) ? 1'b1 : 1'b0;
assign dict3[156] = (dict_org[156]==symbol3) ? 1'b1 : 1'b0;
assign dict4[156] = (dict_org[156]==symbol4) ? 1'b1 : 1'b0;
assign dict5[156] = (dict_org[156]==symbol5) ? 1'b1 : 1'b0;
assign dict1[157] = (dict_org[157]==symbol1) ? 1'b1 : 1'b0;
assign dict2[157] = (dict_org[157]==symbol2) ? 1'b1 : 1'b0;
assign dict3[157] = (dict_org[157]==symbol3) ? 1'b1 : 1'b0;
assign dict4[157] = (dict_org[157]==symbol4) ? 1'b1 : 1'b0;
assign dict5[157] = (dict_org[157]==symbol5) ? 1'b1 : 1'b0;
assign dict1[158] = (dict_org[158]==symbol1) ? 1'b1 : 1'b0;
assign dict2[158] = (dict_org[158]==symbol2) ? 1'b1 : 1'b0;
assign dict3[158] = (dict_org[158]==symbol3) ? 1'b1 : 1'b0;
assign dict4[158] = (dict_org[158]==symbol4) ? 1'b1 : 1'b0;
assign dict5[158] = (dict_org[158]==symbol5) ? 1'b1 : 1'b0;
assign dict1[159] = (dict_org[159]==symbol1) ? 1'b1 : 1'b0;
assign dict2[159] = (dict_org[159]==symbol2) ? 1'b1 : 1'b0;
assign dict3[159] = (dict_org[159]==symbol3) ? 1'b1 : 1'b0;
assign dict4[159] = (dict_org[159]==symbol4) ? 1'b1 : 1'b0;
assign dict5[159] = (dict_org[159]==symbol5) ? 1'b1 : 1'b0;
assign dict1[160] = (dict_org[160]==symbol1) ? 1'b1 : 1'b0;
assign dict2[160] = (dict_org[160]==symbol2) ? 1'b1 : 1'b0;
assign dict3[160] = (dict_org[160]==symbol3) ? 1'b1 : 1'b0;
assign dict4[160] = (dict_org[160]==symbol4) ? 1'b1 : 1'b0;
assign dict5[160] = (dict_org[160]==symbol5) ? 1'b1 : 1'b0;
assign dict1[161] = (dict_org[161]==symbol1) ? 1'b1 : 1'b0;
assign dict2[161] = (dict_org[161]==symbol2) ? 1'b1 : 1'b0;
assign dict3[161] = (dict_org[161]==symbol3) ? 1'b1 : 1'b0;
assign dict4[161] = (dict_org[161]==symbol4) ? 1'b1 : 1'b0;
assign dict5[161] = (dict_org[161]==symbol5) ? 1'b1 : 1'b0;
assign dict1[162] = (dict_org[162]==symbol1) ? 1'b1 : 1'b0;
assign dict2[162] = (dict_org[162]==symbol2) ? 1'b1 : 1'b0;
assign dict3[162] = (dict_org[162]==symbol3) ? 1'b1 : 1'b0;
assign dict4[162] = (dict_org[162]==symbol4) ? 1'b1 : 1'b0;
assign dict5[162] = (dict_org[162]==symbol5) ? 1'b1 : 1'b0;
assign dict1[163] = (dict_org[163]==symbol1) ? 1'b1 : 1'b0;
assign dict2[163] = (dict_org[163]==symbol2) ? 1'b1 : 1'b0;
assign dict3[163] = (dict_org[163]==symbol3) ? 1'b1 : 1'b0;
assign dict4[163] = (dict_org[163]==symbol4) ? 1'b1 : 1'b0;
assign dict5[163] = (dict_org[163]==symbol5) ? 1'b1 : 1'b0;
assign dict1[164] = (dict_org[164]==symbol1) ? 1'b1 : 1'b0;
assign dict2[164] = (dict_org[164]==symbol2) ? 1'b1 : 1'b0;
assign dict3[164] = (dict_org[164]==symbol3) ? 1'b1 : 1'b0;
assign dict4[164] = (dict_org[164]==symbol4) ? 1'b1 : 1'b0;
assign dict5[164] = (dict_org[164]==symbol5) ? 1'b1 : 1'b0;
assign dict1[165] = (dict_org[165]==symbol1) ? 1'b1 : 1'b0;
assign dict2[165] = (dict_org[165]==symbol2) ? 1'b1 : 1'b0;
assign dict3[165] = (dict_org[165]==symbol3) ? 1'b1 : 1'b0;
assign dict4[165] = (dict_org[165]==symbol4) ? 1'b1 : 1'b0;
assign dict5[165] = (dict_org[165]==symbol5) ? 1'b1 : 1'b0;
assign dict1[166] = (dict_org[166]==symbol1) ? 1'b1 : 1'b0;
assign dict2[166] = (dict_org[166]==symbol2) ? 1'b1 : 1'b0;
assign dict3[166] = (dict_org[166]==symbol3) ? 1'b1 : 1'b0;
assign dict4[166] = (dict_org[166]==symbol4) ? 1'b1 : 1'b0;
assign dict5[166] = (dict_org[166]==symbol5) ? 1'b1 : 1'b0;
assign dict1[167] = (dict_org[167]==symbol1) ? 1'b1 : 1'b0;
assign dict2[167] = (dict_org[167]==symbol2) ? 1'b1 : 1'b0;
assign dict3[167] = (dict_org[167]==symbol3) ? 1'b1 : 1'b0;
assign dict4[167] = (dict_org[167]==symbol4) ? 1'b1 : 1'b0;
assign dict5[167] = (dict_org[167]==symbol5) ? 1'b1 : 1'b0;
assign dict1[168] = (dict_org[168]==symbol1) ? 1'b1 : 1'b0;
assign dict2[168] = (dict_org[168]==symbol2) ? 1'b1 : 1'b0;
assign dict3[168] = (dict_org[168]==symbol3) ? 1'b1 : 1'b0;
assign dict4[168] = (dict_org[168]==symbol4) ? 1'b1 : 1'b0;
assign dict5[168] = (dict_org[168]==symbol5) ? 1'b1 : 1'b0;
assign dict1[169] = (dict_org[169]==symbol1) ? 1'b1 : 1'b0;
assign dict2[169] = (dict_org[169]==symbol2) ? 1'b1 : 1'b0;
assign dict3[169] = (dict_org[169]==symbol3) ? 1'b1 : 1'b0;
assign dict4[169] = (dict_org[169]==symbol4) ? 1'b1 : 1'b0;
assign dict5[169] = (dict_org[169]==symbol5) ? 1'b1 : 1'b0;
assign dict1[170] = (dict_org[170]==symbol1) ? 1'b1 : 1'b0;
assign dict2[170] = (dict_org[170]==symbol2) ? 1'b1 : 1'b0;
assign dict3[170] = (dict_org[170]==symbol3) ? 1'b1 : 1'b0;
assign dict4[170] = (dict_org[170]==symbol4) ? 1'b1 : 1'b0;
assign dict5[170] = (dict_org[170]==symbol5) ? 1'b1 : 1'b0;
assign dict1[171] = (dict_org[171]==symbol1) ? 1'b1 : 1'b0;
assign dict2[171] = (dict_org[171]==symbol2) ? 1'b1 : 1'b0;
assign dict3[171] = (dict_org[171]==symbol3) ? 1'b1 : 1'b0;
assign dict4[171] = (dict_org[171]==symbol4) ? 1'b1 : 1'b0;
assign dict5[171] = (dict_org[171]==symbol5) ? 1'b1 : 1'b0;
assign dict1[172] = (dict_org[172]==symbol1) ? 1'b1 : 1'b0;
assign dict2[172] = (dict_org[172]==symbol2) ? 1'b1 : 1'b0;
assign dict3[172] = (dict_org[172]==symbol3) ? 1'b1 : 1'b0;
assign dict4[172] = (dict_org[172]==symbol4) ? 1'b1 : 1'b0;
assign dict5[172] = (dict_org[172]==symbol5) ? 1'b1 : 1'b0;
assign dict1[173] = (dict_org[173]==symbol1) ? 1'b1 : 1'b0;
assign dict2[173] = (dict_org[173]==symbol2) ? 1'b1 : 1'b0;
assign dict3[173] = (dict_org[173]==symbol3) ? 1'b1 : 1'b0;
assign dict4[173] = (dict_org[173]==symbol4) ? 1'b1 : 1'b0;
assign dict5[173] = (dict_org[173]==symbol5) ? 1'b1 : 1'b0;
assign dict1[174] = (dict_org[174]==symbol1) ? 1'b1 : 1'b0;
assign dict2[174] = (dict_org[174]==symbol2) ? 1'b1 : 1'b0;
assign dict3[174] = (dict_org[174]==symbol3) ? 1'b1 : 1'b0;
assign dict4[174] = (dict_org[174]==symbol4) ? 1'b1 : 1'b0;
assign dict5[174] = (dict_org[174]==symbol5) ? 1'b1 : 1'b0;
assign dict1[175] = (dict_org[175]==symbol1) ? 1'b1 : 1'b0;
assign dict2[175] = (dict_org[175]==symbol2) ? 1'b1 : 1'b0;
assign dict3[175] = (dict_org[175]==symbol3) ? 1'b1 : 1'b0;
assign dict4[175] = (dict_org[175]==symbol4) ? 1'b1 : 1'b0;
assign dict5[175] = (dict_org[175]==symbol5) ? 1'b1 : 1'b0;
assign dict1[176] = (dict_org[176]==symbol1) ? 1'b1 : 1'b0;
assign dict2[176] = (dict_org[176]==symbol2) ? 1'b1 : 1'b0;
assign dict3[176] = (dict_org[176]==symbol3) ? 1'b1 : 1'b0;
assign dict4[176] = (dict_org[176]==symbol4) ? 1'b1 : 1'b0;
assign dict5[176] = (dict_org[176]==symbol5) ? 1'b1 : 1'b0;
assign dict1[177] = (dict_org[177]==symbol1) ? 1'b1 : 1'b0;
assign dict2[177] = (dict_org[177]==symbol2) ? 1'b1 : 1'b0;
assign dict3[177] = (dict_org[177]==symbol3) ? 1'b1 : 1'b0;
assign dict4[177] = (dict_org[177]==symbol4) ? 1'b1 : 1'b0;
assign dict5[177] = (dict_org[177]==symbol5) ? 1'b1 : 1'b0;
assign dict1[178] = (dict_org[178]==symbol1) ? 1'b1 : 1'b0;
assign dict2[178] = (dict_org[178]==symbol2) ? 1'b1 : 1'b0;
assign dict3[178] = (dict_org[178]==symbol3) ? 1'b1 : 1'b0;
assign dict4[178] = (dict_org[178]==symbol4) ? 1'b1 : 1'b0;
assign dict5[178] = (dict_org[178]==symbol5) ? 1'b1 : 1'b0;
assign dict1[179] = (dict_org[179]==symbol1) ? 1'b1 : 1'b0;
assign dict2[179] = (dict_org[179]==symbol2) ? 1'b1 : 1'b0;
assign dict3[179] = (dict_org[179]==symbol3) ? 1'b1 : 1'b0;
assign dict4[179] = (dict_org[179]==symbol4) ? 1'b1 : 1'b0;
assign dict5[179] = (dict_org[179]==symbol5) ? 1'b1 : 1'b0;
assign dict1[180] = (dict_org[180]==symbol1) ? 1'b1 : 1'b0;
assign dict2[180] = (dict_org[180]==symbol2) ? 1'b1 : 1'b0;
assign dict3[180] = (dict_org[180]==symbol3) ? 1'b1 : 1'b0;
assign dict4[180] = (dict_org[180]==symbol4) ? 1'b1 : 1'b0;
assign dict5[180] = (dict_org[180]==symbol5) ? 1'b1 : 1'b0;
assign dict1[181] = (dict_org[181]==symbol1) ? 1'b1 : 1'b0;
assign dict2[181] = (dict_org[181]==symbol2) ? 1'b1 : 1'b0;
assign dict3[181] = (dict_org[181]==symbol3) ? 1'b1 : 1'b0;
assign dict4[181] = (dict_org[181]==symbol4) ? 1'b1 : 1'b0;
assign dict5[181] = (dict_org[181]==symbol5) ? 1'b1 : 1'b0;
assign dict1[182] = (dict_org[182]==symbol1) ? 1'b1 : 1'b0;
assign dict2[182] = (dict_org[182]==symbol2) ? 1'b1 : 1'b0;
assign dict3[182] = (dict_org[182]==symbol3) ? 1'b1 : 1'b0;
assign dict4[182] = (dict_org[182]==symbol4) ? 1'b1 : 1'b0;
assign dict5[182] = (dict_org[182]==symbol5) ? 1'b1 : 1'b0;
assign dict1[183] = (dict_org[183]==symbol1) ? 1'b1 : 1'b0;
assign dict2[183] = (dict_org[183]==symbol2) ? 1'b1 : 1'b0;
assign dict3[183] = (dict_org[183]==symbol3) ? 1'b1 : 1'b0;
assign dict4[183] = (dict_org[183]==symbol4) ? 1'b1 : 1'b0;
assign dict5[183] = (dict_org[183]==symbol5) ? 1'b1 : 1'b0;
assign dict1[184] = (dict_org[184]==symbol1) ? 1'b1 : 1'b0;
assign dict2[184] = (dict_org[184]==symbol2) ? 1'b1 : 1'b0;
assign dict3[184] = (dict_org[184]==symbol3) ? 1'b1 : 1'b0;
assign dict4[184] = (dict_org[184]==symbol4) ? 1'b1 : 1'b0;
assign dict5[184] = (dict_org[184]==symbol5) ? 1'b1 : 1'b0;
assign dict1[185] = (dict_org[185]==symbol1) ? 1'b1 : 1'b0;
assign dict2[185] = (dict_org[185]==symbol2) ? 1'b1 : 1'b0;
assign dict3[185] = (dict_org[185]==symbol3) ? 1'b1 : 1'b0;
assign dict4[185] = (dict_org[185]==symbol4) ? 1'b1 : 1'b0;
assign dict5[185] = (dict_org[185]==symbol5) ? 1'b1 : 1'b0;
assign dict1[186] = (dict_org[186]==symbol1) ? 1'b1 : 1'b0;
assign dict2[186] = (dict_org[186]==symbol2) ? 1'b1 : 1'b0;
assign dict3[186] = (dict_org[186]==symbol3) ? 1'b1 : 1'b0;
assign dict4[186] = (dict_org[186]==symbol4) ? 1'b1 : 1'b0;
assign dict5[186] = (dict_org[186]==symbol5) ? 1'b1 : 1'b0;
assign dict1[187] = (dict_org[187]==symbol1) ? 1'b1 : 1'b0;
assign dict2[187] = (dict_org[187]==symbol2) ? 1'b1 : 1'b0;
assign dict3[187] = (dict_org[187]==symbol3) ? 1'b1 : 1'b0;
assign dict4[187] = (dict_org[187]==symbol4) ? 1'b1 : 1'b0;
assign dict5[187] = (dict_org[187]==symbol5) ? 1'b1 : 1'b0;
assign dict1[188] = (dict_org[188]==symbol1) ? 1'b1 : 1'b0;
assign dict2[188] = (dict_org[188]==symbol2) ? 1'b1 : 1'b0;
assign dict3[188] = (dict_org[188]==symbol3) ? 1'b1 : 1'b0;
assign dict4[188] = (dict_org[188]==symbol4) ? 1'b1 : 1'b0;
assign dict5[188] = (dict_org[188]==symbol5) ? 1'b1 : 1'b0;
assign dict1[189] = (dict_org[189]==symbol1) ? 1'b1 : 1'b0;
assign dict2[189] = (dict_org[189]==symbol2) ? 1'b1 : 1'b0;
assign dict3[189] = (dict_org[189]==symbol3) ? 1'b1 : 1'b0;
assign dict4[189] = (dict_org[189]==symbol4) ? 1'b1 : 1'b0;
assign dict5[189] = (dict_org[189]==symbol5) ? 1'b1 : 1'b0;
assign dict1[190] = (dict_org[190]==symbol1) ? 1'b1 : 1'b0;
assign dict2[190] = (dict_org[190]==symbol2) ? 1'b1 : 1'b0;
assign dict3[190] = (dict_org[190]==symbol3) ? 1'b1 : 1'b0;
assign dict4[190] = (dict_org[190]==symbol4) ? 1'b1 : 1'b0;
assign dict5[190] = (dict_org[190]==symbol5) ? 1'b1 : 1'b0;
assign dict1[191] = (dict_org[191]==symbol1) ? 1'b1 : 1'b0;
assign dict2[191] = (dict_org[191]==symbol2) ? 1'b1 : 1'b0;
assign dict3[191] = (dict_org[191]==symbol3) ? 1'b1 : 1'b0;
assign dict4[191] = (dict_org[191]==symbol4) ? 1'b1 : 1'b0;
assign dict5[191] = (dict_org[191]==symbol5) ? 1'b1 : 1'b0;
assign dict1[192] = (dict_org[192]==symbol1) ? 1'b1 : 1'b0;
assign dict2[192] = (dict_org[192]==symbol2) ? 1'b1 : 1'b0;
assign dict3[192] = (dict_org[192]==symbol3) ? 1'b1 : 1'b0;
assign dict4[192] = (dict_org[192]==symbol4) ? 1'b1 : 1'b0;
assign dict5[192] = (dict_org[192]==symbol5) ? 1'b1 : 1'b0;
assign dict1[193] = (dict_org[193]==symbol1) ? 1'b1 : 1'b0;
assign dict2[193] = (dict_org[193]==symbol2) ? 1'b1 : 1'b0;
assign dict3[193] = (dict_org[193]==symbol3) ? 1'b1 : 1'b0;
assign dict4[193] = (dict_org[193]==symbol4) ? 1'b1 : 1'b0;
assign dict5[193] = (dict_org[193]==symbol5) ? 1'b1 : 1'b0;
assign dict1[194] = (dict_org[194]==symbol1) ? 1'b1 : 1'b0;
assign dict2[194] = (dict_org[194]==symbol2) ? 1'b1 : 1'b0;
assign dict3[194] = (dict_org[194]==symbol3) ? 1'b1 : 1'b0;
assign dict4[194] = (dict_org[194]==symbol4) ? 1'b1 : 1'b0;
assign dict5[194] = (dict_org[194]==symbol5) ? 1'b1 : 1'b0;
assign dict1[195] = (dict_org[195]==symbol1) ? 1'b1 : 1'b0;
assign dict2[195] = (dict_org[195]==symbol2) ? 1'b1 : 1'b0;
assign dict3[195] = (dict_org[195]==symbol3) ? 1'b1 : 1'b0;
assign dict4[195] = (dict_org[195]==symbol4) ? 1'b1 : 1'b0;
assign dict5[195] = (dict_org[195]==symbol5) ? 1'b1 : 1'b0;
assign dict1[196] = (dict_org[196]==symbol1) ? 1'b1 : 1'b0;
assign dict2[196] = (dict_org[196]==symbol2) ? 1'b1 : 1'b0;
assign dict3[196] = (dict_org[196]==symbol3) ? 1'b1 : 1'b0;
assign dict4[196] = (dict_org[196]==symbol4) ? 1'b1 : 1'b0;
assign dict5[196] = (dict_org[196]==symbol5) ? 1'b1 : 1'b0;
assign dict1[197] = (dict_org[197]==symbol1) ? 1'b1 : 1'b0;
assign dict2[197] = (dict_org[197]==symbol2) ? 1'b1 : 1'b0;
assign dict3[197] = (dict_org[197]==symbol3) ? 1'b1 : 1'b0;
assign dict4[197] = (dict_org[197]==symbol4) ? 1'b1 : 1'b0;
assign dict5[197] = (dict_org[197]==symbol5) ? 1'b1 : 1'b0;
assign dict1[198] = (dict_org[198]==symbol1) ? 1'b1 : 1'b0;
assign dict2[198] = (dict_org[198]==symbol2) ? 1'b1 : 1'b0;
assign dict3[198] = (dict_org[198]==symbol3) ? 1'b1 : 1'b0;
assign dict4[198] = (dict_org[198]==symbol4) ? 1'b1 : 1'b0;
assign dict5[198] = (dict_org[198]==symbol5) ? 1'b1 : 1'b0;
assign dict1[199] = (dict_org[199]==symbol1) ? 1'b1 : 1'b0;
assign dict2[199] = (dict_org[199]==symbol2) ? 1'b1 : 1'b0;
assign dict3[199] = (dict_org[199]==symbol3) ? 1'b1 : 1'b0;
assign dict4[199] = (dict_org[199]==symbol4) ? 1'b1 : 1'b0;
assign dict5[199] = (dict_org[199]==symbol5) ? 1'b1 : 1'b0;
assign dict1[200] = (dict_org[200]==symbol1) ? 1'b1 : 1'b0;
assign dict2[200] = (dict_org[200]==symbol2) ? 1'b1 : 1'b0;
assign dict3[200] = (dict_org[200]==symbol3) ? 1'b1 : 1'b0;
assign dict4[200] = (dict_org[200]==symbol4) ? 1'b1 : 1'b0;
assign dict5[200] = (dict_org[200]==symbol5) ? 1'b1 : 1'b0;
assign dict1[201] = (dict_org[201]==symbol1) ? 1'b1 : 1'b0;
assign dict2[201] = (dict_org[201]==symbol2) ? 1'b1 : 1'b0;
assign dict3[201] = (dict_org[201]==symbol3) ? 1'b1 : 1'b0;
assign dict4[201] = (dict_org[201]==symbol4) ? 1'b1 : 1'b0;
assign dict5[201] = (dict_org[201]==symbol5) ? 1'b1 : 1'b0;
assign dict1[202] = (dict_org[202]==symbol1) ? 1'b1 : 1'b0;
assign dict2[202] = (dict_org[202]==symbol2) ? 1'b1 : 1'b0;
assign dict3[202] = (dict_org[202]==symbol3) ? 1'b1 : 1'b0;
assign dict4[202] = (dict_org[202]==symbol4) ? 1'b1 : 1'b0;
assign dict5[202] = (dict_org[202]==symbol5) ? 1'b1 : 1'b0;
assign dict1[203] = (dict_org[203]==symbol1) ? 1'b1 : 1'b0;
assign dict2[203] = (dict_org[203]==symbol2) ? 1'b1 : 1'b0;
assign dict3[203] = (dict_org[203]==symbol3) ? 1'b1 : 1'b0;
assign dict4[203] = (dict_org[203]==symbol4) ? 1'b1 : 1'b0;
assign dict5[203] = (dict_org[203]==symbol5) ? 1'b1 : 1'b0;
assign dict1[204] = (dict_org[204]==symbol1) ? 1'b1 : 1'b0;
assign dict2[204] = (dict_org[204]==symbol2) ? 1'b1 : 1'b0;
assign dict3[204] = (dict_org[204]==symbol3) ? 1'b1 : 1'b0;
assign dict4[204] = (dict_org[204]==symbol4) ? 1'b1 : 1'b0;
assign dict5[204] = (dict_org[204]==symbol5) ? 1'b1 : 1'b0;
assign dict1[205] = (dict_org[205]==symbol1) ? 1'b1 : 1'b0;
assign dict2[205] = (dict_org[205]==symbol2) ? 1'b1 : 1'b0;
assign dict3[205] = (dict_org[205]==symbol3) ? 1'b1 : 1'b0;
assign dict4[205] = (dict_org[205]==symbol4) ? 1'b1 : 1'b0;
assign dict5[205] = (dict_org[205]==symbol5) ? 1'b1 : 1'b0;
assign dict1[206] = (dict_org[206]==symbol1) ? 1'b1 : 1'b0;
assign dict2[206] = (dict_org[206]==symbol2) ? 1'b1 : 1'b0;
assign dict3[206] = (dict_org[206]==symbol3) ? 1'b1 : 1'b0;
assign dict4[206] = (dict_org[206]==symbol4) ? 1'b1 : 1'b0;
assign dict5[206] = (dict_org[206]==symbol5) ? 1'b1 : 1'b0;
assign dict1[207] = (dict_org[207]==symbol1) ? 1'b1 : 1'b0;
assign dict2[207] = (dict_org[207]==symbol2) ? 1'b1 : 1'b0;
assign dict3[207] = (dict_org[207]==symbol3) ? 1'b1 : 1'b0;
assign dict4[207] = (dict_org[207]==symbol4) ? 1'b1 : 1'b0;
assign dict5[207] = (dict_org[207]==symbol5) ? 1'b1 : 1'b0;
assign dict1[208] = (dict_org[208]==symbol1) ? 1'b1 : 1'b0;
assign dict2[208] = (dict_org[208]==symbol2) ? 1'b1 : 1'b0;
assign dict3[208] = (dict_org[208]==symbol3) ? 1'b1 : 1'b0;
assign dict4[208] = (dict_org[208]==symbol4) ? 1'b1 : 1'b0;
assign dict5[208] = (dict_org[208]==symbol5) ? 1'b1 : 1'b0;
assign dict1[209] = (dict_org[209]==symbol1) ? 1'b1 : 1'b0;
assign dict2[209] = (dict_org[209]==symbol2) ? 1'b1 : 1'b0;
assign dict3[209] = (dict_org[209]==symbol3) ? 1'b1 : 1'b0;
assign dict4[209] = (dict_org[209]==symbol4) ? 1'b1 : 1'b0;
assign dict5[209] = (dict_org[209]==symbol5) ? 1'b1 : 1'b0;
assign dict1[210] = (dict_org[210]==symbol1) ? 1'b1 : 1'b0;
assign dict2[210] = (dict_org[210]==symbol2) ? 1'b1 : 1'b0;
assign dict3[210] = (dict_org[210]==symbol3) ? 1'b1 : 1'b0;
assign dict4[210] = (dict_org[210]==symbol4) ? 1'b1 : 1'b0;
assign dict5[210] = (dict_org[210]==symbol5) ? 1'b1 : 1'b0;
assign dict1[211] = (dict_org[211]==symbol1) ? 1'b1 : 1'b0;
assign dict2[211] = (dict_org[211]==symbol2) ? 1'b1 : 1'b0;
assign dict3[211] = (dict_org[211]==symbol3) ? 1'b1 : 1'b0;
assign dict4[211] = (dict_org[211]==symbol4) ? 1'b1 : 1'b0;
assign dict5[211] = (dict_org[211]==symbol5) ? 1'b1 : 1'b0;
assign dict1[212] = (dict_org[212]==symbol1) ? 1'b1 : 1'b0;
assign dict2[212] = (dict_org[212]==symbol2) ? 1'b1 : 1'b0;
assign dict3[212] = (dict_org[212]==symbol3) ? 1'b1 : 1'b0;
assign dict4[212] = (dict_org[212]==symbol4) ? 1'b1 : 1'b0;
assign dict5[212] = (dict_org[212]==symbol5) ? 1'b1 : 1'b0;
assign dict1[213] = (dict_org[213]==symbol1) ? 1'b1 : 1'b0;
assign dict2[213] = (dict_org[213]==symbol2) ? 1'b1 : 1'b0;
assign dict3[213] = (dict_org[213]==symbol3) ? 1'b1 : 1'b0;
assign dict4[213] = (dict_org[213]==symbol4) ? 1'b1 : 1'b0;
assign dict5[213] = (dict_org[213]==symbol5) ? 1'b1 : 1'b0;
assign dict1[214] = (dict_org[214]==symbol1) ? 1'b1 : 1'b0;
assign dict2[214] = (dict_org[214]==symbol2) ? 1'b1 : 1'b0;
assign dict3[214] = (dict_org[214]==symbol3) ? 1'b1 : 1'b0;
assign dict4[214] = (dict_org[214]==symbol4) ? 1'b1 : 1'b0;
assign dict5[214] = (dict_org[214]==symbol5) ? 1'b1 : 1'b0;
assign dict1[215] = (dict_org[215]==symbol1) ? 1'b1 : 1'b0;
assign dict2[215] = (dict_org[215]==symbol2) ? 1'b1 : 1'b0;
assign dict3[215] = (dict_org[215]==symbol3) ? 1'b1 : 1'b0;
assign dict4[215] = (dict_org[215]==symbol4) ? 1'b1 : 1'b0;
assign dict5[215] = (dict_org[215]==symbol5) ? 1'b1 : 1'b0;
assign dict1[216] = (dict_org[216]==symbol1) ? 1'b1 : 1'b0;
assign dict2[216] = (dict_org[216]==symbol2) ? 1'b1 : 1'b0;
assign dict3[216] = (dict_org[216]==symbol3) ? 1'b1 : 1'b0;
assign dict4[216] = (dict_org[216]==symbol4) ? 1'b1 : 1'b0;
assign dict5[216] = (dict_org[216]==symbol5) ? 1'b1 : 1'b0;
assign dict1[217] = (dict_org[217]==symbol1) ? 1'b1 : 1'b0;
assign dict2[217] = (dict_org[217]==symbol2) ? 1'b1 : 1'b0;
assign dict3[217] = (dict_org[217]==symbol3) ? 1'b1 : 1'b0;
assign dict4[217] = (dict_org[217]==symbol4) ? 1'b1 : 1'b0;
assign dict5[217] = (dict_org[217]==symbol5) ? 1'b1 : 1'b0;
assign dict1[218] = (dict_org[218]==symbol1) ? 1'b1 : 1'b0;
assign dict2[218] = (dict_org[218]==symbol2) ? 1'b1 : 1'b0;
assign dict3[218] = (dict_org[218]==symbol3) ? 1'b1 : 1'b0;
assign dict4[218] = (dict_org[218]==symbol4) ? 1'b1 : 1'b0;
assign dict5[218] = (dict_org[218]==symbol5) ? 1'b1 : 1'b0;
assign dict1[219] = (dict_org[219]==symbol1) ? 1'b1 : 1'b0;
assign dict2[219] = (dict_org[219]==symbol2) ? 1'b1 : 1'b0;
assign dict3[219] = (dict_org[219]==symbol3) ? 1'b1 : 1'b0;
assign dict4[219] = (dict_org[219]==symbol4) ? 1'b1 : 1'b0;
assign dict5[219] = (dict_org[219]==symbol5) ? 1'b1 : 1'b0;
assign dict1[220] = (dict_org[220]==symbol1) ? 1'b1 : 1'b0;
assign dict2[220] = (dict_org[220]==symbol2) ? 1'b1 : 1'b0;
assign dict3[220] = (dict_org[220]==symbol3) ? 1'b1 : 1'b0;
assign dict4[220] = (dict_org[220]==symbol4) ? 1'b1 : 1'b0;
assign dict5[220] = (dict_org[220]==symbol5) ? 1'b1 : 1'b0;
assign dict1[221] = (dict_org[221]==symbol1) ? 1'b1 : 1'b0;
assign dict2[221] = (dict_org[221]==symbol2) ? 1'b1 : 1'b0;
assign dict3[221] = (dict_org[221]==symbol3) ? 1'b1 : 1'b0;
assign dict4[221] = (dict_org[221]==symbol4) ? 1'b1 : 1'b0;
assign dict5[221] = (dict_org[221]==symbol5) ? 1'b1 : 1'b0;
assign dict1[222] = (dict_org[222]==symbol1) ? 1'b1 : 1'b0;
assign dict2[222] = (dict_org[222]==symbol2) ? 1'b1 : 1'b0;
assign dict3[222] = (dict_org[222]==symbol3) ? 1'b1 : 1'b0;
assign dict4[222] = (dict_org[222]==symbol4) ? 1'b1 : 1'b0;
assign dict5[222] = (dict_org[222]==symbol5) ? 1'b1 : 1'b0;
assign dict1[223] = (dict_org[223]==symbol1) ? 1'b1 : 1'b0;
assign dict2[223] = (dict_org[223]==symbol2) ? 1'b1 : 1'b0;
assign dict3[223] = (dict_org[223]==symbol3) ? 1'b1 : 1'b0;
assign dict4[223] = (dict_org[223]==symbol4) ? 1'b1 : 1'b0;
assign dict5[223] = (dict_org[223]==symbol5) ? 1'b1 : 1'b0;
assign dict1[224] = (dict_org[224]==symbol1) ? 1'b1 : 1'b0;
assign dict2[224] = (dict_org[224]==symbol2) ? 1'b1 : 1'b0;
assign dict3[224] = (dict_org[224]==symbol3) ? 1'b1 : 1'b0;
assign dict4[224] = (dict_org[224]==symbol4) ? 1'b1 : 1'b0;
assign dict5[224] = (dict_org[224]==symbol5) ? 1'b1 : 1'b0;
assign dict1[225] = (dict_org[225]==symbol1) ? 1'b1 : 1'b0;
assign dict2[225] = (dict_org[225]==symbol2) ? 1'b1 : 1'b0;
assign dict3[225] = (dict_org[225]==symbol3) ? 1'b1 : 1'b0;
assign dict4[225] = (dict_org[225]==symbol4) ? 1'b1 : 1'b0;
assign dict5[225] = (dict_org[225]==symbol5) ? 1'b1 : 1'b0;
assign dict1[226] = (dict_org[226]==symbol1) ? 1'b1 : 1'b0;
assign dict2[226] = (dict_org[226]==symbol2) ? 1'b1 : 1'b0;
assign dict3[226] = (dict_org[226]==symbol3) ? 1'b1 : 1'b0;
assign dict4[226] = (dict_org[226]==symbol4) ? 1'b1 : 1'b0;
assign dict5[226] = (dict_org[226]==symbol5) ? 1'b1 : 1'b0;
assign dict1[227] = (dict_org[227]==symbol1) ? 1'b1 : 1'b0;
assign dict2[227] = (dict_org[227]==symbol2) ? 1'b1 : 1'b0;
assign dict3[227] = (dict_org[227]==symbol3) ? 1'b1 : 1'b0;
assign dict4[227] = (dict_org[227]==symbol4) ? 1'b1 : 1'b0;
assign dict5[227] = (dict_org[227]==symbol5) ? 1'b1 : 1'b0;
assign dict1[228] = (dict_org[228]==symbol1) ? 1'b1 : 1'b0;
assign dict2[228] = (dict_org[228]==symbol2) ? 1'b1 : 1'b0;
assign dict3[228] = (dict_org[228]==symbol3) ? 1'b1 : 1'b0;
assign dict4[228] = (dict_org[228]==symbol4) ? 1'b1 : 1'b0;
assign dict5[228] = (dict_org[228]==symbol5) ? 1'b1 : 1'b0;
assign dict1[229] = (dict_org[229]==symbol1) ? 1'b1 : 1'b0;
assign dict2[229] = (dict_org[229]==symbol2) ? 1'b1 : 1'b0;
assign dict3[229] = (dict_org[229]==symbol3) ? 1'b1 : 1'b0;
assign dict4[229] = (dict_org[229]==symbol4) ? 1'b1 : 1'b0;
assign dict5[229] = (dict_org[229]==symbol5) ? 1'b1 : 1'b0;
assign dict1[230] = (dict_org[230]==symbol1) ? 1'b1 : 1'b0;
assign dict2[230] = (dict_org[230]==symbol2) ? 1'b1 : 1'b0;
assign dict3[230] = (dict_org[230]==symbol3) ? 1'b1 : 1'b0;
assign dict4[230] = (dict_org[230]==symbol4) ? 1'b1 : 1'b0;
assign dict5[230] = (dict_org[230]==symbol5) ? 1'b1 : 1'b0;
assign dict1[231] = (dict_org[231]==symbol1) ? 1'b1 : 1'b0;
assign dict2[231] = (dict_org[231]==symbol2) ? 1'b1 : 1'b0;
assign dict3[231] = (dict_org[231]==symbol3) ? 1'b1 : 1'b0;
assign dict4[231] = (dict_org[231]==symbol4) ? 1'b1 : 1'b0;
assign dict5[231] = (dict_org[231]==symbol5) ? 1'b1 : 1'b0;
assign dict1[232] = (dict_org[232]==symbol1) ? 1'b1 : 1'b0;
assign dict2[232] = (dict_org[232]==symbol2) ? 1'b1 : 1'b0;
assign dict3[232] = (dict_org[232]==symbol3) ? 1'b1 : 1'b0;
assign dict4[232] = (dict_org[232]==symbol4) ? 1'b1 : 1'b0;
assign dict5[232] = (dict_org[232]==symbol5) ? 1'b1 : 1'b0;
assign dict1[233] = (dict_org[233]==symbol1) ? 1'b1 : 1'b0;
assign dict2[233] = (dict_org[233]==symbol2) ? 1'b1 : 1'b0;
assign dict3[233] = (dict_org[233]==symbol3) ? 1'b1 : 1'b0;
assign dict4[233] = (dict_org[233]==symbol4) ? 1'b1 : 1'b0;
assign dict5[233] = (dict_org[233]==symbol5) ? 1'b1 : 1'b0;
assign dict1[234] = (dict_org[234]==symbol1) ? 1'b1 : 1'b0;
assign dict2[234] = (dict_org[234]==symbol2) ? 1'b1 : 1'b0;
assign dict3[234] = (dict_org[234]==symbol3) ? 1'b1 : 1'b0;
assign dict4[234] = (dict_org[234]==symbol4) ? 1'b1 : 1'b0;
assign dict5[234] = (dict_org[234]==symbol5) ? 1'b1 : 1'b0;
assign dict1[235] = (dict_org[235]==symbol1) ? 1'b1 : 1'b0;
assign dict2[235] = (dict_org[235]==symbol2) ? 1'b1 : 1'b0;
assign dict3[235] = (dict_org[235]==symbol3) ? 1'b1 : 1'b0;
assign dict4[235] = (dict_org[235]==symbol4) ? 1'b1 : 1'b0;
assign dict5[235] = (dict_org[235]==symbol5) ? 1'b1 : 1'b0;
assign dict1[236] = (dict_org[236]==symbol1) ? 1'b1 : 1'b0;
assign dict2[236] = (dict_org[236]==symbol2) ? 1'b1 : 1'b0;
assign dict3[236] = (dict_org[236]==symbol3) ? 1'b1 : 1'b0;
assign dict4[236] = (dict_org[236]==symbol4) ? 1'b1 : 1'b0;
assign dict5[236] = (dict_org[236]==symbol5) ? 1'b1 : 1'b0;
assign dict1[237] = (dict_org[237]==symbol1) ? 1'b1 : 1'b0;
assign dict2[237] = (dict_org[237]==symbol2) ? 1'b1 : 1'b0;
assign dict3[237] = (dict_org[237]==symbol3) ? 1'b1 : 1'b0;
assign dict4[237] = (dict_org[237]==symbol4) ? 1'b1 : 1'b0;
assign dict5[237] = (dict_org[237]==symbol5) ? 1'b1 : 1'b0;
assign dict1[238] = (dict_org[238]==symbol1) ? 1'b1 : 1'b0;
assign dict2[238] = (dict_org[238]==symbol2) ? 1'b1 : 1'b0;
assign dict3[238] = (dict_org[238]==symbol3) ? 1'b1 : 1'b0;
assign dict4[238] = (dict_org[238]==symbol4) ? 1'b1 : 1'b0;
assign dict5[238] = (dict_org[238]==symbol5) ? 1'b1 : 1'b0;
assign dict1[239] = (dict_org[239]==symbol1) ? 1'b1 : 1'b0;
assign dict2[239] = (dict_org[239]==symbol2) ? 1'b1 : 1'b0;
assign dict3[239] = (dict_org[239]==symbol3) ? 1'b1 : 1'b0;
assign dict4[239] = (dict_org[239]==symbol4) ? 1'b1 : 1'b0;
assign dict5[239] = (dict_org[239]==symbol5) ? 1'b1 : 1'b0;
assign dict1[240] = (dict_org[240]==symbol1) ? 1'b1 : 1'b0;
assign dict2[240] = (dict_org[240]==symbol2) ? 1'b1 : 1'b0;
assign dict3[240] = (dict_org[240]==symbol3) ? 1'b1 : 1'b0;
assign dict4[240] = (dict_org[240]==symbol4) ? 1'b1 : 1'b0;
assign dict5[240] = (dict_org[240]==symbol5) ? 1'b1 : 1'b0;
assign dict1[241] = (dict_org[241]==symbol1) ? 1'b1 : 1'b0;
assign dict2[241] = (dict_org[241]==symbol2) ? 1'b1 : 1'b0;
assign dict3[241] = (dict_org[241]==symbol3) ? 1'b1 : 1'b0;
assign dict4[241] = (dict_org[241]==symbol4) ? 1'b1 : 1'b0;
assign dict5[241] = (dict_org[241]==symbol5) ? 1'b1 : 1'b0;
assign dict1[242] = (dict_org[242]==symbol1) ? 1'b1 : 1'b0;
assign dict2[242] = (dict_org[242]==symbol2) ? 1'b1 : 1'b0;
assign dict3[242] = (dict_org[242]==symbol3) ? 1'b1 : 1'b0;
assign dict4[242] = (dict_org[242]==symbol4) ? 1'b1 : 1'b0;
assign dict5[242] = (dict_org[242]==symbol5) ? 1'b1 : 1'b0;
assign dict1[243] = (dict_org[243]==symbol1) ? 1'b1 : 1'b0;
assign dict2[243] = (dict_org[243]==symbol2) ? 1'b1 : 1'b0;
assign dict3[243] = (dict_org[243]==symbol3) ? 1'b1 : 1'b0;
assign dict4[243] = (dict_org[243]==symbol4) ? 1'b1 : 1'b0;
assign dict5[243] = (dict_org[243]==symbol5) ? 1'b1 : 1'b0;
assign dict1[244] = (dict_org[244]==symbol1) ? 1'b1 : 1'b0;
assign dict2[244] = (dict_org[244]==symbol2) ? 1'b1 : 1'b0;
assign dict3[244] = (dict_org[244]==symbol3) ? 1'b1 : 1'b0;
assign dict4[244] = (dict_org[244]==symbol4) ? 1'b1 : 1'b0;
assign dict5[244] = (dict_org[244]==symbol5) ? 1'b1 : 1'b0;
assign dict1[245] = (dict_org[245]==symbol1) ? 1'b1 : 1'b0;
assign dict2[245] = (dict_org[245]==symbol2) ? 1'b1 : 1'b0;
assign dict3[245] = (dict_org[245]==symbol3) ? 1'b1 : 1'b0;
assign dict4[245] = (dict_org[245]==symbol4) ? 1'b1 : 1'b0;
assign dict5[245] = (dict_org[245]==symbol5) ? 1'b1 : 1'b0;
assign dict1[246] = (dict_org[246]==symbol1) ? 1'b1 : 1'b0;
assign dict2[246] = (dict_org[246]==symbol2) ? 1'b1 : 1'b0;
assign dict3[246] = (dict_org[246]==symbol3) ? 1'b1 : 1'b0;
assign dict4[246] = (dict_org[246]==symbol4) ? 1'b1 : 1'b0;
assign dict5[246] = (dict_org[246]==symbol5) ? 1'b1 : 1'b0;
assign dict1[247] = (dict_org[247]==symbol1) ? 1'b1 : 1'b0;
assign dict2[247] = (dict_org[247]==symbol2) ? 1'b1 : 1'b0;
assign dict3[247] = (dict_org[247]==symbol3) ? 1'b1 : 1'b0;
assign dict4[247] = (dict_org[247]==symbol4) ? 1'b1 : 1'b0;
assign dict5[247] = (dict_org[247]==symbol5) ? 1'b1 : 1'b0;
assign dict1[248] = (dict_org[248]==symbol1) ? 1'b1 : 1'b0;
assign dict2[248] = (dict_org[248]==symbol2) ? 1'b1 : 1'b0;
assign dict3[248] = (dict_org[248]==symbol3) ? 1'b1 : 1'b0;
assign dict4[248] = (dict_org[248]==symbol4) ? 1'b1 : 1'b0;
assign dict5[248] = (dict_org[248]==symbol5) ? 1'b1 : 1'b0;
assign dict1[249] = (dict_org[249]==symbol1) ? 1'b1 : 1'b0;
assign dict2[249] = (dict_org[249]==symbol2) ? 1'b1 : 1'b0;
assign dict3[249] = (dict_org[249]==symbol3) ? 1'b1 : 1'b0;
assign dict4[249] = (dict_org[249]==symbol4) ? 1'b1 : 1'b0;
assign dict5[249] = (dict_org[249]==symbol5) ? 1'b1 : 1'b0;
assign dict1[250] = (dict_org[250]==symbol1) ? 1'b1 : 1'b0;
assign dict2[250] = (dict_org[250]==symbol2) ? 1'b1 : 1'b0;
assign dict3[250] = (dict_org[250]==symbol3) ? 1'b1 : 1'b0;
assign dict4[250] = (dict_org[250]==symbol4) ? 1'b1 : 1'b0;
assign dict5[250] = (dict_org[250]==symbol5) ? 1'b1 : 1'b0;
assign dict1[251] = (dict_org[251]==symbol1) ? 1'b1 : 1'b0;
assign dict2[251] = (dict_org[251]==symbol2) ? 1'b1 : 1'b0;
assign dict3[251] = (dict_org[251]==symbol3) ? 1'b1 : 1'b0;
assign dict4[251] = (dict_org[251]==symbol4) ? 1'b1 : 1'b0;
assign dict5[251] = (dict_org[251]==symbol5) ? 1'b1 : 1'b0;
assign dict1[252] = (dict_org[252]==symbol1) ? 1'b1 : 1'b0;
assign dict2[252] = (dict_org[252]==symbol2) ? 1'b1 : 1'b0;
assign dict3[252] = (dict_org[252]==symbol3) ? 1'b1 : 1'b0;
assign dict4[252] = (dict_org[252]==symbol4) ? 1'b1 : 1'b0;
assign dict5[252] = (dict_org[252]==symbol5) ? 1'b1 : 1'b0;
assign dict1[253] = (dict_org[253]==symbol1) ? 1'b1 : 1'b0;
assign dict2[253] = (dict_org[253]==symbol2) ? 1'b1 : 1'b0;
assign dict3[253] = (dict_org[253]==symbol3) ? 1'b1 : 1'b0;
assign dict4[253] = (dict_org[253]==symbol4) ? 1'b1 : 1'b0;
assign dict5[253] = (dict_org[253]==symbol5) ? 1'b1 : 1'b0;
assign dict1[254] = (dict_org[254]==symbol1) ? 1'b1 : 1'b0;
assign dict2[254] = (dict_org[254]==symbol2) ? 1'b1 : 1'b0;
assign dict3[254] = (dict_org[254]==symbol3) ? 1'b1 : 1'b0;
assign dict4[254] = (dict_org[254]==symbol4) ? 1'b1 : 1'b0;
assign dict5[254] = (dict_org[254]==symbol5) ? 1'b1 : 1'b0;
assign dict1[255] = (dict_org[255]==symbol1) ? 1'b1 : 1'b0;
assign dict2[255] = (dict_org[255]==symbol2) ? 1'b1 : 1'b0;
assign dict3[255] = (dict_org[255]==symbol3) ? 1'b1 : 1'b0;
assign dict4[255] = (dict_org[255]==symbol4) ? 1'b1 : 1'b0;
assign dict5[255] = (dict_org[255]==symbol5) ? 1'b1 : 1'b0;
assign dict1[259:256] = 4'b0;
assign dict2[259:256] = 4'b0;
assign dict3[259:256] = 4'b0;
assign dict4[259:256] = 4'b0;
assign dict5[259:256] = 4'b0;


wire [8:0] dict_size1 = dict_size;
wire [8:0] dict_size2 = dict_size > 9'd63   ? dict_size : 9'd00;
wire [8:0] dict_size3 = dict_size > 9'd127  ? dict_size : 9'd00;
wire [8:0] dict_size4 = dict_size > 9'd191  ? dict_size : 9'd00;
wire [3:0] isMatch5;
wire [3:0] isMatch4;
wire [3:0] isMatch3;
wire [3:0] isMatch2;
wire [8:0] pos5[3:0];
wire [8:0] pos4[3:0];
wire [8:0] pos3[3:0];
wire [8:0] pos2[3:0];
wire isMatch5b;
wire isMatch4b;
wire isMatch3b;
wire isMatch2b;
wire [8:0] pos5b; 
wire [8:0] pos4b; 
wire [8:0] pos3b; 
wire [8:0] pos2b; 


Match5Small m5s1(dict1[67:0], dict2[67:0], dict3[67:0], dict4[67:0], dict5[67:0], dict_size1, l_LA_buf, isMatch5[0], pos5[0]);
Match5Small m5s2(dict1[131:64], dict2[131:64], dict3[131:64], dict4[131:64], dict5[131:64], dict_size2, l_LA_buf, isMatch5[1], pos5[1]);
Match5Small m5s3(dict1[195:128], dict2[195:128], dict3[195:128], dict4[195:128], dict5[195:128], dict_size3, l_LA_buf, isMatch5[2], pos5[2]);
Match5Small m5s4(dict1[259:192], dict2[259:192], dict3[259:192], dict4[259:192], dict5[259:192], dict_size4, l_LA_buf, isMatch5[3], pos5[3]);
Match4Small m4s1(dict1[66:0], dict2[66:0], dict3[66:0], dict4[66:0], dict_size1, l_LA_buf, isMatch4[0], pos4[0]);
Match4Small m4s2(dict1[130:64], dict2[130:64], dict3[130:64], dict4[130:64], dict_size2, l_LA_buf, isMatch4[1], pos4[1]);
Match4Small m4s3(dict1[194:128], dict2[194:128], dict3[194:128], dict4[194:128], dict_size3, l_LA_buf, isMatch4[2], pos4[2]);
Match4Small m4s4(dict1[258:192], dict2[258:192], dict3[258:192], dict4[258:192], dict_size4, l_LA_buf, isMatch4[3], pos4[3]);
Match3Small m3s1(dict1[65:0], dict2[65:0], dict3[65:0], dict_size1, l_LA_buf, isMatch3[0], pos3[0]);
Match3Small m3s2(dict1[129:64], dict2[129:64], dict3[129:64], dict_size2, l_LA_buf, isMatch3[1], pos3[1]);
Match3Small m3s3(dict1[193:128], dict2[193:128], dict3[193:128], dict_size3, l_LA_buf, isMatch3[2], pos3[2]);
Match3Small m3s4(dict1[257:192], dict2[257:192], dict3[257:192], dict_size4, l_LA_buf, isMatch3[3], pos3[3]);
Match2Small m2s1(dict1[64:0], dict2[64:0], dict_size1, l_LA_buf, isMatch2[0], pos2[0]);
Match2Small m2s2(dict1[128:64], dict2[128:64], dict_size2, l_LA_buf, isMatch2[1], pos2[1]);
Match2Small m2s3(dict1[192:128], dict2[192:128], dict_size3, l_LA_buf, isMatch2[2], pos2[2]);
Match2Small m2s4(dict1[256:192], dict2[256:192], dict_size4, l_LA_buf, isMatch2[3], pos2[3]);

MatchBig mb1(isMatch5[0], pos5[0], isMatch5[1], pos5[1], isMatch5[2], pos5[2], isMatch5[3], pos5[3], dict_size, isMatch5b, pos5b);
MatchBig mb2(isMatch4[0], pos4[0], isMatch4[1], pos4[1], isMatch4[2], pos4[2], isMatch4[3], pos4[3], dict_size, isMatch4b, pos4b);
MatchBig mb3(isMatch3[0], pos3[0], isMatch3[1], pos3[1], isMatch3[2], pos3[2], isMatch3[3], pos3[3], dict_size, isMatch3b, pos3b);
MatchBig mb4(isMatch2[0], pos2[0], isMatch2[1], pos2[1], isMatch2[2], pos2[2], isMatch2[3], pos2[3], dict_size, isMatch2b, pos2b);


//========================combinational==========================
//
always@(*)begin
    n_state =   state;
    case(state)
        S_IDLE:begin
            n_state     =   S_PUT;
        end
        S_PUT:begin
            if( data_done == 1'b1 )begin
                if( l_LA_buf == 3'd0 )begin
                    n_state =   S_STOP;
                end
                else begin
                    n_state =   S_COMPARE;
                end
            end
            else if({1'b0, l_r_buf} + {1'b0, l_LA_buf} > 4'd4)begin
                n_state =   S_COMPARE;
            end
            else begin
                n_state =   S_READ;
            end
        end
        S_READ:begin
            n_state =   S_PUT;
        end
        S_START:begin
            if( l_LA_buf == 3'd0 )begin
                n_state =   S_STOP;
            end
            else begin
                n_state =   S_COMPARE;
            end
        end
        S_COMPARE:begin
            n_state =   S_PUT;
        end
        S_ENCODE:begin
            n_state =   S_PUT;
        end
        S_STOP:begin
            n_state =   state;
        end
        default:begin
            n_state =   state;
        end
    endcase 
end


always@(*)begin
    n_busy        =   busy        ;  
    n_codeword    =   codeword    ;  
    n_enc_num     =   enc_num     ;  
    n_out_valid   =   out_valid   ;  
    n_finish      =   finish      ;  
    n_r_buf       =   r_buf       ;  
    n_LA_buf      =   LA_buf      ;  
    n_l_r_buf     =   l_r_buf     ;    
    n_l_LA_buf    =   l_LA_buf    ;    
    n_dict_size   =   dict_size   ;
    n_dict_pos    =   dict_pos    ;
    n_largest     =   largest     ;
    n_largest_pos =   largest_pos ;
    n_data_done   =   data_done   ;

    for(i = 256; i != 0; i = i - 1)
        n_dict_org[i-1] =   dict_org[i-1] ;
    case(state)
        S_IDLE:begin
            n_l_r_buf   =   3'd0;
            n_l_LA_buf  =   3'd0;
            n_LA_buf    =   40'd0;
            n_r_buf     =   32'd0;
            n_busy      =   1'b0;
            n_dict_size =   9'd0;
        end
        S_PUT:begin
            n_busy      =   1'b1;
            n_l_LA_buf  =   ({1'b0, l_LA_buf} + {1'b0, l_r_buf} > 4'd5) ? 3'd5 : (l_LA_buf + l_r_buf);
            n_dict_pos  =   8'd1;
            n_largest   =   3'd0;
            n_largest_pos = 8'd255;
            //tmp_largest =   3'd0;
            //tmp_largest_pos = 8'd255;
            n_out_valid = 1'd0;
            case(l_LA_buf)
                3'd0:begin
                    n_LA_buf    =   {r_buf, 8'd0};
                    n_r_buf     =   32'd0;
                    n_l_r_buf   =   3'd0;
                end
                3'd1:begin
                    n_LA_buf    =   {LA_buf[39:32], r_buf};
                    n_r_buf     =   32'd0;
                    n_l_r_buf   =   3'd0;
                end
                3'd2:begin
                    n_LA_buf    =   {LA_buf[39:24], r_buf[31:8]};
                    n_r_buf     =   r_buf << 24;
                    n_l_r_buf   =   l_r_buf > 2 ?   (l_r_buf - 3'd3) : 3'd0;
                end
                3'd3:begin
                    n_LA_buf    =   {LA_buf[39:16], r_buf[31:16]};
                    n_r_buf     =   r_buf << 16;
                    n_l_r_buf   =   l_r_buf > 1 ?   (l_r_buf - 3'd2) : 3'd0;
                end
                3'd4:begin
                    n_LA_buf    =   {LA_buf[39:8], r_buf[31:24]};
                    n_r_buf     =   r_buf << 8;
                    n_l_r_buf   =   l_r_buf > 0 ?   (l_r_buf - 3'd1) : 3'd0;
                end
                default:begin
                    n_LA_buf    =   LA_buf;
                    n_r_buf     =   r_buf;
                    n_l_r_buf   =   l_r_buf;
                end
            endcase
        end
        S_READ:begin
            n_r_buf		=	tmp_buf;	
            n_l_r_buf   =   3'd4;
            if( l_LA_buf == 3'd0 && l_r_buf == 3'd0 )begin
                n_busy      =   3'd0;
            end
            else begin
                n_busy  =   3'd1;
            end
            if( drop_done == 1'b1 )begin
                n_data_done =   1'b1;
            end
            else begin
                n_data_done =   1'b0;
            end
        end
        S_COMPARE:begin
            if(dict_size > 9'd0) begin
                if(isMatch5b == 1'b1) begin
                    for(i = 256; i != 5 ; i = i - 1)
                        n_dict_org[i-1] = dict_org[i-6];
                    n_dict_org[4] = symbol1;
                    n_dict_org[3] = symbol2;
                    n_dict_org[2] = symbol3;
                    n_dict_org[1] = symbol4;
                    n_dict_org[0] = symbol5;
                    n_dict_size = (dict_size > 9'd250) ? 9'd256 : dict_size + 9'd5;

                    n_LA_buf = 40'd0;
                    n_l_LA_buf = l_LA_buf - 3'd5;

                    n_busy = 1'd0;
                    n_out_valid = 1'd1;
                    n_codeword = {1'd1,pos5b[7:0]-8'd4,2'b11};
                    n_enc_num = enc_num + 12'd1;

                end
                else if(isMatch4b == 1'b1) begin
                    for(i = 256; i != 4 ; i = i - 1)
                        n_dict_org[i-1] = dict_org[i-5];
                    n_dict_org[3] = symbol1;
                    n_dict_org[2] = symbol2;
                    n_dict_org[1] = symbol3;
                    n_dict_org[0] = symbol4;
                    n_dict_size = (dict_size > 9'd251) ? 9'd256 : dict_size + 9'd4;

                    n_LA_buf = {LA_buf[7:0], 32'd0};
                    n_l_LA_buf = l_LA_buf - 3'd4;

                    if(l_r_buf + l_LA_buf - 3'd4 > 3'd4)
                        n_busy = 1'd1;
                    else
                        n_busy = 1'd0;

                    n_out_valid = 1'd1;
                    n_codeword = {1'd1,pos4b[7:0]-8'd3,2'b10};
                    n_enc_num = enc_num + 12'd1;

                end
                else if(isMatch3b == 1'b1) begin
                    for(i = 256; i != 3 ; i = i - 1)
                        n_dict_org[i-1] = dict_org[i-4];
                    n_dict_org[2] = symbol1;
                    n_dict_org[1] = symbol2;
                    n_dict_org[0] = symbol3;
                    n_dict_size = (dict_size > 9'd252) ? 9'd256 : dict_size + 9'd3;

                    n_LA_buf = {LA_buf[15:0], 24'd0};
                    n_l_LA_buf = l_LA_buf - 3'd3;

                    if(l_r_buf + l_LA_buf - 3'd3 > 3'd4)
                        n_busy = 1'd1;
                    else
                        n_busy = 1'd0;

                    n_out_valid = 1'd1;
                    n_codeword = {1'd1, pos3b[7:0]-8'd2,2'b01};
                    n_enc_num = enc_num + 12'd1;
                end
                else if(isMatch2b == 1'b1) begin
                    for(i = 256; i != 2 ; i = i - 1)
                        n_dict_org[i-1] = dict_org[i-3];
                    n_dict_org[1] = symbol1;
                    n_dict_org[0] = symbol2;
                    n_dict_size = (dict_size > 9'd253) ? 9'd256 : dict_size + 9'd2;

                    n_LA_buf = {LA_buf[23:0], 16'd0};
                    n_l_LA_buf = l_LA_buf - 3'd2;

                    if(l_r_buf + l_LA_buf - 3'd2 > 3'd4)
                        n_busy = 1'd1;
                    else
                        n_busy = 1'd0;

                    n_out_valid = 1'd1;
                    n_codeword = {1'd1,pos2b[7:0]-8'd1,2'b00};
                    n_enc_num = enc_num + 12'd1;

                end
                else begin
                    for(i = 256; i != 1 ; i = i - 1)
                        n_dict_org[i-1] = dict_org[i-2];
                    n_dict_org[0] = symbol1;
                    n_dict_size = (dict_size > 9'd254) ? 9'd256 : dict_size + 9'd1;

                    n_LA_buf = {LA_buf[31:0], 8'd0};
                    n_l_LA_buf = l_LA_buf - 3'd1;

                    if(l_r_buf + l_LA_buf - 3'd1 > 3'd4)
                        n_busy = 1'd1;
                    else
                        n_busy = 1'd0;

                    n_out_valid = 1'd1;
                    n_codeword = {1'd0,symbol1,2'dx};
                    n_enc_num = enc_num + 12'd1;
                end
            end
            else begin
                for(i = 256; i != 1 ; i = i - 1)
                    n_dict_org[i-1] = dict_org[i-2];
                n_dict_org[0] = symbol1;
                n_dict_size = (dict_size > 9'd254) ? 9'd256 : dict_size + 9'd1;

                n_LA_buf = {LA_buf[31:0], 8'd0};
                n_l_LA_buf = l_LA_buf - 3'd1;

                if(l_r_buf + l_LA_buf - 3'd1 > 3'd4)
                    n_busy = 1'd1;
                else
                    n_busy = 1'd0;

                n_out_valid = 1'd1;
                n_codeword = {1'd0,symbol1,2'dx};
                n_enc_num = enc_num + 12'd1;
            end

        end
        S_ENCODE:begin
            /*    if(largest == 3'd0) begin
                for(i = 256; i != 1 ; i = i - 1)
                    n_dict_org[i-1] = dict_org[i-2];
                n_dict_org[0] = symbol1;
                n_dict_size = (dict_size > 9'd254) ? 9'd256 : dict_size + 9'd1;

                n_LA_buf = {LA_buf[31:0], 8'd0};
                n_l_LA_buf = l_LA_buf - 3'd1;

                if(l_r_buf + l_LA_buf - 3'd1 > 3'd4)
                    n_busy = 1'd1;
                else
                    n_busy = 1'd0;

                n_out_valid = 1'd1;
                n_codeword = {1'd0,symbol1,2'dx};
                n_enc_num = enc_num + 12'd1;
            end
            else if(largest == 3'd2) begin
                for(i = 256; i != 2 ; i = i - 1)
                    n_dict_org[i-1] = dict_org[i-3];
                n_dict_org[1] = symbol1;
                n_dict_org[0] = symbol2;
                n_dict_size = (dict_size > 9'd253) ? 9'd256 : dict_size + 9'd2;
                
                n_LA_buf = {LA_buf[23:0], 16'd0};
                n_l_LA_buf = l_LA_buf - 3'd2;

                if(l_r_buf + l_LA_buf - 3'd2 > 3'd4)
                    n_busy = 1'd1;
                else
                    n_busy = 1'd0;

                n_out_valid = 1'd1;
                n_codeword = {1'd1,largest_pos,2'b00};
                n_enc_num = enc_num + 12'd1;
            end
            else if(largest == 3'd3) begin
                for(i = 256; i != 3 ; i = i - 1)
                    n_dict_org[i-1] = dict_org[i-4];
                n_dict_org[2] = symbol1;
                n_dict_org[1] = symbol2;
                n_dict_org[0] = symbol3;
                n_dict_size = (dict_size > 9'd252) ? 9'd256 : dict_size + 9'd3;
                
                n_LA_buf = {LA_buf[15:0], 24'd0};
                n_l_LA_buf = l_LA_buf - 3'd3;

                if(l_r_buf + l_LA_buf - 3'd3 > 3'd4)
                    n_busy = 1'd1;
                else
                    n_busy = 1'd0;

                n_out_valid = 1'd1;
                n_codeword = {1'd1,largest_pos,2'b01};
                n_enc_num = enc_num + 12'd1;
            end
            else if(largest == 3'd4) begin
                for(i = 256; i != 4 ; i = i - 1)
                    n_dict_org[i-1] = dict_org[i-5];
                n_dict_org[3] = symbol1;
                n_dict_org[2] = symbol2;
                n_dict_org[1] = symbol3;
                n_dict_org[0] = symbol4;
                n_dict_size = (dict_size > 9'd251) ? 9'd256 : dict_size + 9'd4;
                
                n_LA_buf = {LA_buf[7:0], 32'd0};
                n_l_LA_buf = l_LA_buf - 3'd4;

                if(l_r_buf + l_LA_buf - 3'd4 > 3'd4)
                    n_busy = 1'd1;
                else
                    n_busy = 1'd0;

                n_out_valid = 1'd1;
                n_codeword = {1'd1,largest_pos,2'b10};
                n_enc_num = enc_num + 12'd1;
            end
            else if(largest == 3'd5) begin
                for(i = 256; i != 5 ; i = i - 1)
                    n_dict_org[i-1] = dict_org[i-6];
                n_dict_org[4] = symbol1;
                n_dict_org[3] = symbol2;
                n_dict_org[2] = symbol3;
                n_dict_org[1] = symbol4;
                n_dict_org[0] = symbol5;
                n_dict_size = (dict_size > 9'd250) ? 9'd256 : dict_size + 9'd5;
                
                n_LA_buf = 40'd0;
                n_l_LA_buf = l_LA_buf - 3'd5;

                n_busy = 1'd0;
                n_out_valid = 1'd1;
                n_codeword = {1'd1,largest_pos,2'b11};
                n_enc_num = enc_num + 12'd1;
            end
            */
        end
        S_STOP:begin
            n_finish    =   1'b1;
        end
        default:begin
        end
    endcase 
end




//========================sequential============================
always@(posedge clk or posedge reset)begin
	if(reset)begin
        busy        <=   1'd1; 
        codeword    <=   11'd0; 
        enc_num     <=   12'd0; 
        out_valid   <=   1'd0; 
        finish      <=   1'd0; 
        state       <=   3'd0; 
        r_buf       <=   32'd0; 
        LA_buf      <=   40'd0; 
        l_r_buf     <=   3'd0; 
        l_LA_buf    <=   3'd0; 
		tmp_buf	    <=	 32'd0;
        dict_size   <=   9'd0;
        dict_pos    <=   9'd0;
        largest     <=   3'd0;
        largest_pos <=   8'd0;
        data_done   <=   1'b0;
        for(i = 256; i != 0; i = i - 1)
            dict_org[i-1] <= 8'd0;
	end
    else begin
		tmp_buf	    <=	 data          ;
        busy        <=   n_busy        ;  
        codeword    <=   n_codeword    ;  
        enc_num     <=   n_enc_num     ;  
        out_valid   <=   n_out_valid   ;  
        finish      <=   n_finish      ;  
        state       <=   n_state       ;  
        r_buf       <=   n_r_buf       ;  
        LA_buf      <=   n_LA_buf      ;  
        l_r_buf     <=   n_l_r_buf     ;  	
        l_LA_buf    <=   n_l_LA_buf    ;  	
        dict_size   <=   n_dict_size   ;
        dict_pos    <=   n_dict_pos    ;
        largest     <=   n_largest     ;
        largest_pos <=   n_largest_pos ;
        data_done   <=   n_data_done   ;
        for(i = 256; i != 0; i = i - 1)
            dict_org[i-1] <= n_dict_org[i-1]   ;
    end
end


endmodule


module Match5Small(dict1, dict2, dict3, dict4, dict5, dict_size, l_LA_buf, isMatch, pos);

input [67:0]    dict1;
input [67:0]    dict2;
input [67:0]    dict3;
input [67:0]    dict4;
input [67:0]    dict5;
input [8:0]     dict_size;
input [2:0]     l_LA_buf;
output          isMatch;
output [8:0]    pos;


reg isMatch;
reg [8:0] pos;

always@(*)begin

    if(dict1[8'd4] && dict2[8'd3] && dict3[8'd2] && dict4[8'd1] && dict5[8'd0] ) begin
        isMatch = 1'b1;
        pos = 9'd4;
    end
    else if(dict1[8'd5] && dict2[8'd4] && dict3[8'd3] && dict4[8'd2] && dict5[8'd1] ) begin
        isMatch = 1'b1;
        pos = 9'd5;
    end
    else if(dict1[8'd6] && dict2[8'd5] && dict3[8'd4] && dict4[8'd3] && dict5[8'd2] ) begin
        isMatch = 1'b1;
        pos = 9'd6;
    end
    else if(dict1[8'd7] && dict2[8'd6] && dict3[8'd5] && dict4[8'd4] && dict5[8'd3] ) begin
        isMatch = 1'b1;
        pos = 9'd7;
    end
    else if(dict1[8'd8] && dict2[8'd7] && dict3[8'd6] && dict4[8'd5] && dict5[8'd4] ) begin
        isMatch = 1'b1;
        pos = 9'd8;
    end
    else if(dict1[8'd9] && dict2[8'd8] && dict3[8'd7] && dict4[8'd6] && dict5[8'd5] ) begin
        isMatch = 1'b1;
        pos = 9'd9;
    end
    else if(dict1[8'd10] && dict2[8'd9] && dict3[8'd8] && dict4[8'd7] && dict5[8'd6] ) begin
        isMatch = 1'b1;
        pos = 9'd10;
    end
    else if(dict1[8'd11] && dict2[8'd10] && dict3[8'd9] && dict4[8'd8] && dict5[8'd7] ) begin
        isMatch = 1'b1;
        pos = 9'd11;
    end
    else if(dict1[8'd12] && dict2[8'd11] && dict3[8'd10] && dict4[8'd9] && dict5[8'd8] ) begin
        isMatch = 1'b1;
        pos = 9'd12;
    end
    else if(dict1[8'd13] && dict2[8'd12] && dict3[8'd11] && dict4[8'd10] && dict5[8'd9] ) begin
        isMatch = 1'b1;
        pos = 9'd13;
    end
    else if(dict1[8'd14] && dict2[8'd13] && dict3[8'd12] && dict4[8'd11] && dict5[8'd10] ) begin
        isMatch = 1'b1;
        pos = 9'd14;
    end
    else if(dict1[8'd15] && dict2[8'd14] && dict3[8'd13] && dict4[8'd12] && dict5[8'd11] ) begin
        isMatch = 1'b1;
        pos = 9'd15;
    end
    else if(dict1[8'd16] && dict2[8'd15] && dict3[8'd14] && dict4[8'd13] && dict5[8'd12] ) begin
        isMatch = 1'b1;
        pos = 9'd16;
    end
    else if(dict1[8'd17] && dict2[8'd16] && dict3[8'd15] && dict4[8'd14] && dict5[8'd13] ) begin
        isMatch = 1'b1;
        pos = 9'd17;
    end
    else if(dict1[8'd18] && dict2[8'd17] && dict3[8'd16] && dict4[8'd15] && dict5[8'd14] ) begin
        isMatch = 1'b1;
        pos = 9'd18;
    end
    else if(dict1[8'd19] && dict2[8'd18] && dict3[8'd17] && dict4[8'd16] && dict5[8'd15] ) begin
        isMatch = 1'b1;
        pos = 9'd19;
    end
    else if(dict1[8'd20] && dict2[8'd19] && dict3[8'd18] && dict4[8'd17] && dict5[8'd16] ) begin
        isMatch = 1'b1;
        pos = 9'd20;
    end
    else if(dict1[8'd21] && dict2[8'd20] && dict3[8'd19] && dict4[8'd18] && dict5[8'd17] ) begin
        isMatch = 1'b1;
        pos = 9'd21;
    end
    else if(dict1[8'd22] && dict2[8'd21] && dict3[8'd20] && dict4[8'd19] && dict5[8'd18] ) begin
        isMatch = 1'b1;
        pos = 9'd22;
    end
    else if(dict1[8'd23] && dict2[8'd22] && dict3[8'd21] && dict4[8'd20] && dict5[8'd19] ) begin
        isMatch = 1'b1;
        pos = 9'd23;
    end
    else if(dict1[8'd24] && dict2[8'd23] && dict3[8'd22] && dict4[8'd21] && dict5[8'd20] ) begin
        isMatch = 1'b1;
        pos = 9'd24;
    end
    else if(dict1[8'd25] && dict2[8'd24] && dict3[8'd23] && dict4[8'd22] && dict5[8'd21] ) begin
        isMatch = 1'b1;
        pos = 9'd25;
    end
    else if(dict1[8'd26] && dict2[8'd25] && dict3[8'd24] && dict4[8'd23] && dict5[8'd22] ) begin
        isMatch = 1'b1;
        pos = 9'd26;
    end
    else if(dict1[8'd27] && dict2[8'd26] && dict3[8'd25] && dict4[8'd24] && dict5[8'd23] ) begin
        isMatch = 1'b1;
        pos = 9'd27;
    end
    else if(dict1[8'd28] && dict2[8'd27] && dict3[8'd26] && dict4[8'd25] && dict5[8'd24] ) begin
        isMatch = 1'b1;
        pos = 9'd28;
    end
    else if(dict1[8'd29] && dict2[8'd28] && dict3[8'd27] && dict4[8'd26] && dict5[8'd25] ) begin
        isMatch = 1'b1;
        pos = 9'd29;
    end
    else if(dict1[8'd30] && dict2[8'd29] && dict3[8'd28] && dict4[8'd27] && dict5[8'd26] ) begin
        isMatch = 1'b1;
        pos = 9'd30;
    end
    else if(dict1[8'd31] && dict2[8'd30] && dict3[8'd29] && dict4[8'd28] && dict5[8'd27] ) begin
        isMatch = 1'b1;
        pos = 9'd31;
    end
    else if(dict1[8'd32] && dict2[8'd31] && dict3[8'd30] && dict4[8'd29] && dict5[8'd28] ) begin
        isMatch = 1'b1;
        pos = 9'd32;
    end
    else if(dict1[8'd33] && dict2[8'd32] && dict3[8'd31] && dict4[8'd30] && dict5[8'd29] ) begin
        isMatch = 1'b1;
        pos = 9'd33;
    end
    else if(dict1[8'd34] && dict2[8'd33] && dict3[8'd32] && dict4[8'd31] && dict5[8'd30] ) begin
        isMatch = 1'b1;
        pos = 9'd34;
    end
    else if(dict1[8'd35] && dict2[8'd34] && dict3[8'd33] && dict4[8'd32] && dict5[8'd31] ) begin
        isMatch = 1'b1;
        pos = 9'd35;
    end
    else if(dict1[8'd36] && dict2[8'd35] && dict3[8'd34] && dict4[8'd33] && dict5[8'd32] ) begin
        isMatch = 1'b1;
        pos = 9'd36;
    end
    else if(dict1[8'd37] && dict2[8'd36] && dict3[8'd35] && dict4[8'd34] && dict5[8'd33] ) begin
        isMatch = 1'b1;
        pos = 9'd37;
    end
    else if(dict1[8'd38] && dict2[8'd37] && dict3[8'd36] && dict4[8'd35] && dict5[8'd34] ) begin
        isMatch = 1'b1;
        pos = 9'd38;
    end
    else if(dict1[8'd39] && dict2[8'd38] && dict3[8'd37] && dict4[8'd36] && dict5[8'd35] ) begin
        isMatch = 1'b1;
        pos = 9'd39;
    end
    else if(dict1[8'd40] && dict2[8'd39] && dict3[8'd38] && dict4[8'd37] && dict5[8'd36] ) begin
        isMatch = 1'b1;
        pos = 9'd40;
    end
    else if(dict1[8'd41] && dict2[8'd40] && dict3[8'd39] && dict4[8'd38] && dict5[8'd37] ) begin
        isMatch = 1'b1;
        pos = 9'd41;
    end
    else if(dict1[8'd42] && dict2[8'd41] && dict3[8'd40] && dict4[8'd39] && dict5[8'd38] ) begin
        isMatch = 1'b1;
        pos = 9'd42;
    end
    else if(dict1[8'd43] && dict2[8'd42] && dict3[8'd41] && dict4[8'd40] && dict5[8'd39] ) begin
        isMatch = 1'b1;
        pos = 9'd43;
    end
    else if(dict1[8'd44] && dict2[8'd43] && dict3[8'd42] && dict4[8'd41] && dict5[8'd40] ) begin
        isMatch = 1'b1;
        pos = 9'd44;
    end
    else if(dict1[8'd45] && dict2[8'd44] && dict3[8'd43] && dict4[8'd42] && dict5[8'd41] ) begin
        isMatch = 1'b1;
        pos = 9'd45;
    end
    else if(dict1[8'd46] && dict2[8'd45] && dict3[8'd44] && dict4[8'd43] && dict5[8'd42] ) begin
        isMatch = 1'b1;
        pos = 9'd46;
    end
    else if(dict1[8'd47] && dict2[8'd46] && dict3[8'd45] && dict4[8'd44] && dict5[8'd43] ) begin
        isMatch = 1'b1;
        pos = 9'd47;
    end
    else if(dict1[8'd48] && dict2[8'd47] && dict3[8'd46] && dict4[8'd45] && dict5[8'd44] ) begin
        isMatch = 1'b1;
        pos = 9'd48;
    end
    else if(dict1[8'd49] && dict2[8'd48] && dict3[8'd47] && dict4[8'd46] && dict5[8'd45] ) begin
        isMatch = 1'b1;
        pos = 9'd49;
    end
    else if(dict1[8'd50] && dict2[8'd49] && dict3[8'd48] && dict4[8'd47] && dict5[8'd46] ) begin
        isMatch = 1'b1;
        pos = 9'd50;
    end
    else if(dict1[8'd51] && dict2[8'd50] && dict3[8'd49] && dict4[8'd48] && dict5[8'd47] ) begin
        isMatch = 1'b1;
        pos = 9'd51;
    end
    else if(dict1[8'd52] && dict2[8'd51] && dict3[8'd50] && dict4[8'd49] && dict5[8'd48] ) begin
        isMatch = 1'b1;
        pos = 9'd52;
    end
    else if(dict1[8'd53] && dict2[8'd52] && dict3[8'd51] && dict4[8'd50] && dict5[8'd49] ) begin
        isMatch = 1'b1;
        pos = 9'd53;
    end
    else if(dict1[8'd54] && dict2[8'd53] && dict3[8'd52] && dict4[8'd51] && dict5[8'd50] ) begin
        isMatch = 1'b1;
        pos = 9'd54;
    end
    else if(dict1[8'd55] && dict2[8'd54] && dict3[8'd53] && dict4[8'd52] && dict5[8'd51] ) begin
        isMatch = 1'b1;
        pos = 9'd55;
    end
    else if(dict1[8'd56] && dict2[8'd55] && dict3[8'd54] && dict4[8'd53] && dict5[8'd52] ) begin
        isMatch = 1'b1;
        pos = 9'd56;
    end
    else if(dict1[8'd57] && dict2[8'd56] && dict3[8'd55] && dict4[8'd54] && dict5[8'd53] ) begin
        isMatch = 1'b1;
        pos = 9'd57;
    end
    else if(dict1[8'd58] && dict2[8'd57] && dict3[8'd56] && dict4[8'd55] && dict5[8'd54] ) begin
        isMatch = 1'b1;
        pos = 9'd58;
    end
    else if(dict1[8'd59] && dict2[8'd58] && dict3[8'd57] && dict4[8'd56] && dict5[8'd55] ) begin
        isMatch = 1'b1;
        pos = 9'd59;
    end
    else if(dict1[8'd60] && dict2[8'd59] && dict3[8'd58] && dict4[8'd57] && dict5[8'd56] ) begin
        isMatch = 1'b1;
        pos = 9'd60;
    end
    else if(dict1[8'd61] && dict2[8'd60] && dict3[8'd59] && dict4[8'd58] && dict5[8'd57] ) begin
        isMatch = 1'b1;
        pos = 9'd61;
    end
    else if(dict1[8'd62] && dict2[8'd61] && dict3[8'd60] && dict4[8'd59] && dict5[8'd58] ) begin
        isMatch = 1'b1;
        pos = 9'd62;
    end
    else if(dict1[8'd63] && dict2[8'd62] && dict3[8'd61] && dict4[8'd60] && dict5[8'd59] ) begin
        isMatch = 1'b1;
        pos = 9'd63;
    end
    else if(dict1[8'd64] && dict2[8'd63] && dict3[8'd62] && dict4[8'd61] && dict5[8'd60] ) begin
        isMatch = 1'b1;
        pos = 9'd64;
    end
    else if(dict1[8'd65] && dict2[8'd64] && dict3[8'd63] && dict4[8'd62] && dict5[8'd61] ) begin
        isMatch = 1'b1;
        pos = 9'd65;
    end
    else if(dict1[8'd66] && dict2[8'd65] && dict3[8'd64] && dict4[8'd63] && dict5[8'd62] ) begin
        isMatch = 1'b1;
        pos = 9'd66;
    end
    else if(dict1[8'd67] && dict2[8'd66] && dict3[8'd65] && dict4[8'd64] && dict5[8'd63] ) begin
        isMatch = 1'b1;
        pos = 9'd67;
    end
    else begin
        isMatch = 1'b0;
        pos = 9'd00;

    end
end



endmodule



module Match4Small(dict1, dict2, dict3, dict4, dict_size, l_LA_buf, isMatch, pos);

input [66:0]    dict1;
input [66:0]    dict2;
input [66:0]    dict3;
input [66:0]    dict4;
input [8:0]     dict_size;
input [2:0]     l_LA_buf;
output          isMatch;
output [8:0]    pos;


reg isMatch;
reg [8:0] pos;

always@(*)begin

    if(dict1[8'd3] && dict2[8'd2] && dict3[8'd1] && dict4[8'd0] ) begin
        isMatch = 1'b1;
        pos = 9'd3;
    end
    else if(dict1[8'd4] && dict2[8'd3] && dict3[8'd2] && dict4[8'd1] ) begin
        isMatch = 1'b1;
        pos = 9'd4;
    end
    else if(dict1[8'd5] && dict2[8'd4] && dict3[8'd3] && dict4[8'd2] ) begin
        isMatch = 1'b1;
        pos = 9'd5;
    end
    else if(dict1[8'd6] && dict2[8'd5] && dict3[8'd4] && dict4[8'd3] ) begin
        isMatch = 1'b1;
        pos = 9'd6;
    end
    else if(dict1[8'd7] && dict2[8'd6] && dict3[8'd5] && dict4[8'd4] ) begin
        isMatch = 1'b1;
        pos = 9'd7;
    end
    else if(dict1[8'd8] && dict2[8'd7] && dict3[8'd6] && dict4[8'd5] ) begin
        isMatch = 1'b1;
        pos = 9'd8;
    end
    else if(dict1[8'd9] && dict2[8'd8] && dict3[8'd7] && dict4[8'd6] ) begin
        isMatch = 1'b1;
        pos = 9'd9;
    end
    else if(dict1[8'd10] && dict2[8'd9] && dict3[8'd8] && dict4[8'd7] ) begin
        isMatch = 1'b1;
        pos = 9'd10;
    end
    else if(dict1[8'd11] && dict2[8'd10] && dict3[8'd9] && dict4[8'd8] ) begin
        isMatch = 1'b1;
        pos = 9'd11;
    end
    else if(dict1[8'd12] && dict2[8'd11] && dict3[8'd10] && dict4[8'd9] ) begin
        isMatch = 1'b1;
        pos = 9'd12;
    end
    else if(dict1[8'd13] && dict2[8'd12] && dict3[8'd11] && dict4[8'd10] ) begin
        isMatch = 1'b1;
        pos = 9'd13;
    end
    else if(dict1[8'd14] && dict2[8'd13] && dict3[8'd12] && dict4[8'd11] ) begin
        isMatch = 1'b1;
        pos = 9'd14;
    end
    else if(dict1[8'd15] && dict2[8'd14] && dict3[8'd13] && dict4[8'd12] ) begin
        isMatch = 1'b1;
        pos = 9'd15;
    end
    else if(dict1[8'd16] && dict2[8'd15] && dict3[8'd14] && dict4[8'd13] ) begin
        isMatch = 1'b1;
        pos = 9'd16;
    end
    else if(dict1[8'd17] && dict2[8'd16] && dict3[8'd15] && dict4[8'd14] ) begin
        isMatch = 1'b1;
        pos = 9'd17;
    end
    else if(dict1[8'd18] && dict2[8'd17] && dict3[8'd16] && dict4[8'd15] ) begin
        isMatch = 1'b1;
        pos = 9'd18;
    end
    else if(dict1[8'd19] && dict2[8'd18] && dict3[8'd17] && dict4[8'd16] ) begin
        isMatch = 1'b1;
        pos = 9'd19;
    end
    else if(dict1[8'd20] && dict2[8'd19] && dict3[8'd18] && dict4[8'd17] ) begin
        isMatch = 1'b1;
        pos = 9'd20;
    end
    else if(dict1[8'd21] && dict2[8'd20] && dict3[8'd19] && dict4[8'd18] ) begin
        isMatch = 1'b1;
        pos = 9'd21;
    end
    else if(dict1[8'd22] && dict2[8'd21] && dict3[8'd20] && dict4[8'd19] ) begin
        isMatch = 1'b1;
        pos = 9'd22;
    end
    else if(dict1[8'd23] && dict2[8'd22] && dict3[8'd21] && dict4[8'd20] ) begin
        isMatch = 1'b1;
        pos = 9'd23;
    end
    else if(dict1[8'd24] && dict2[8'd23] && dict3[8'd22] && dict4[8'd21] ) begin
        isMatch = 1'b1;
        pos = 9'd24;
    end
    else if(dict1[8'd25] && dict2[8'd24] && dict3[8'd23] && dict4[8'd22] ) begin
        isMatch = 1'b1;
        pos = 9'd25;
    end
    else if(dict1[8'd26] && dict2[8'd25] && dict3[8'd24] && dict4[8'd23] ) begin
        isMatch = 1'b1;
        pos = 9'd26;
    end
    else if(dict1[8'd27] && dict2[8'd26] && dict3[8'd25] && dict4[8'd24] ) begin
        isMatch = 1'b1;
        pos = 9'd27;
    end
    else if(dict1[8'd28] && dict2[8'd27] && dict3[8'd26] && dict4[8'd25] ) begin
        isMatch = 1'b1;
        pos = 9'd28;
    end
    else if(dict1[8'd29] && dict2[8'd28] && dict3[8'd27] && dict4[8'd26] ) begin
        isMatch = 1'b1;
        pos = 9'd29;
    end
    else if(dict1[8'd30] && dict2[8'd29] && dict3[8'd28] && dict4[8'd27] ) begin
        isMatch = 1'b1;
        pos = 9'd30;
    end
    else if(dict1[8'd31] && dict2[8'd30] && dict3[8'd29] && dict4[8'd28] ) begin
        isMatch = 1'b1;
        pos = 9'd31;
    end
    else if(dict1[8'd32] && dict2[8'd31] && dict3[8'd30] && dict4[8'd29] ) begin
        isMatch = 1'b1;
        pos = 9'd32;
    end
    else if(dict1[8'd33] && dict2[8'd32] && dict3[8'd31] && dict4[8'd30] ) begin
        isMatch = 1'b1;
        pos = 9'd33;
    end
    else if(dict1[8'd34] && dict2[8'd33] && dict3[8'd32] && dict4[8'd31] ) begin
        isMatch = 1'b1;
        pos = 9'd34;
    end
    else if(dict1[8'd35] && dict2[8'd34] && dict3[8'd33] && dict4[8'd32] ) begin
        isMatch = 1'b1;
        pos = 9'd35;
    end
    else if(dict1[8'd36] && dict2[8'd35] && dict3[8'd34] && dict4[8'd33] ) begin
        isMatch = 1'b1;
        pos = 9'd36;
    end
    else if(dict1[8'd37] && dict2[8'd36] && dict3[8'd35] && dict4[8'd34] ) begin
        isMatch = 1'b1;
        pos = 9'd37;
    end
    else if(dict1[8'd38] && dict2[8'd37] && dict3[8'd36] && dict4[8'd35] ) begin
        isMatch = 1'b1;
        pos = 9'd38;
    end
    else if(dict1[8'd39] && dict2[8'd38] && dict3[8'd37] && dict4[8'd36] ) begin
        isMatch = 1'b1;
        pos = 9'd39;
    end
    else if(dict1[8'd40] && dict2[8'd39] && dict3[8'd38] && dict4[8'd37] ) begin
        isMatch = 1'b1;
        pos = 9'd40;
    end
    else if(dict1[8'd41] && dict2[8'd40] && dict3[8'd39] && dict4[8'd38] ) begin
        isMatch = 1'b1;
        pos = 9'd41;
    end
    else if(dict1[8'd42] && dict2[8'd41] && dict3[8'd40] && dict4[8'd39] ) begin
        isMatch = 1'b1;
        pos = 9'd42;
    end
    else if(dict1[8'd43] && dict2[8'd42] && dict3[8'd41] && dict4[8'd40] ) begin
        isMatch = 1'b1;
        pos = 9'd43;
    end
    else if(dict1[8'd44] && dict2[8'd43] && dict3[8'd42] && dict4[8'd41] ) begin
        isMatch = 1'b1;
        pos = 9'd44;
    end
    else if(dict1[8'd45] && dict2[8'd44] && dict3[8'd43] && dict4[8'd42] ) begin
        isMatch = 1'b1;
        pos = 9'd45;
    end
    else if(dict1[8'd46] && dict2[8'd45] && dict3[8'd44] && dict4[8'd43] ) begin
        isMatch = 1'b1;
        pos = 9'd46;
    end
    else if(dict1[8'd47] && dict2[8'd46] && dict3[8'd45] && dict4[8'd44] ) begin
        isMatch = 1'b1;
        pos = 9'd47;
    end
    else if(dict1[8'd48] && dict2[8'd47] && dict3[8'd46] && dict4[8'd45] ) begin
        isMatch = 1'b1;
        pos = 9'd48;
    end
    else if(dict1[8'd49] && dict2[8'd48] && dict3[8'd47] && dict4[8'd46] ) begin
        isMatch = 1'b1;
        pos = 9'd49;
    end
    else if(dict1[8'd50] && dict2[8'd49] && dict3[8'd48] && dict4[8'd47] ) begin
        isMatch = 1'b1;
        pos = 9'd50;
    end
    else if(dict1[8'd51] && dict2[8'd50] && dict3[8'd49] && dict4[8'd48] ) begin
        isMatch = 1'b1;
        pos = 9'd51;
    end
    else if(dict1[8'd52] && dict2[8'd51] && dict3[8'd50] && dict4[8'd49] ) begin
        isMatch = 1'b1;
        pos = 9'd52;
    end
    else if(dict1[8'd53] && dict2[8'd52] && dict3[8'd51] && dict4[8'd50] ) begin
        isMatch = 1'b1;
        pos = 9'd53;
    end
    else if(dict1[8'd54] && dict2[8'd53] && dict3[8'd52] && dict4[8'd51] ) begin
        isMatch = 1'b1;
        pos = 9'd54;
    end
    else if(dict1[8'd55] && dict2[8'd54] && dict3[8'd53] && dict4[8'd52] ) begin
        isMatch = 1'b1;
        pos = 9'd55;
    end
    else if(dict1[8'd56] && dict2[8'd55] && dict3[8'd54] && dict4[8'd53] ) begin
        isMatch = 1'b1;
        pos = 9'd56;
    end
    else if(dict1[8'd57] && dict2[8'd56] && dict3[8'd55] && dict4[8'd54] ) begin
        isMatch = 1'b1;
        pos = 9'd57;
    end
    else if(dict1[8'd58] && dict2[8'd57] && dict3[8'd56] && dict4[8'd55] ) begin
        isMatch = 1'b1;
        pos = 9'd58;
    end
    else if(dict1[8'd59] && dict2[8'd58] && dict3[8'd57] && dict4[8'd56] ) begin
        isMatch = 1'b1;
        pos = 9'd59;
    end
    else if(dict1[8'd60] && dict2[8'd59] && dict3[8'd58] && dict4[8'd57] ) begin
        isMatch = 1'b1;
        pos = 9'd60;
    end
    else if(dict1[8'd61] && dict2[8'd60] && dict3[8'd59] && dict4[8'd58] ) begin
        isMatch = 1'b1;
        pos = 9'd61;
    end
    else if(dict1[8'd62] && dict2[8'd61] && dict3[8'd60] && dict4[8'd59] ) begin
        isMatch = 1'b1;
        pos = 9'd62;
    end
    else if(dict1[8'd63] && dict2[8'd62] && dict3[8'd61] && dict4[8'd60] ) begin
        isMatch = 1'b1;
        pos = 9'd63;
    end
    else if(dict1[8'd64] && dict2[8'd63] && dict3[8'd62] && dict4[8'd61] ) begin
        isMatch = 1'b1;
        pos = 9'd64;
    end
    else if(dict1[8'd65] && dict2[8'd64] && dict3[8'd63] && dict4[8'd62] ) begin
        isMatch = 1'b1;
        pos = 9'd65;
    end
    else if(dict1[8'd66] && dict2[8'd65] && dict3[8'd64] && dict4[8'd63] ) begin
        isMatch = 1'b1;
        pos = 9'd66;
    end
    else begin
        isMatch = 1'b0;
        pos = 9'd00;
    end
end
endmodule

module Match3Small(dict1, dict2, dict3, dict_size, l_LA_buf, isMatch, pos);

input [65:0]    dict1;
input [65:0]    dict2;
input [65:0]    dict3;
input [8:0]     dict_size;
input [2:0]     l_LA_buf;
output          isMatch;
output [8:0]    pos;


reg isMatch;
reg [8:0] pos;

always@(*)begin

    if(dict1[8'd2] && dict2[8'd1] && dict3[8'd0] ) begin
        isMatch = 1'b1;
        pos = 9'd2;
    end
    else if(dict1[8'd3] && dict2[8'd2] && dict3[8'd1] ) begin
        isMatch = 1'b1;
        pos = 9'd3;
    end
    else if(dict1[8'd4] && dict2[8'd3] && dict3[8'd2] ) begin
        isMatch = 1'b1;
        pos = 9'd4;
    end
    else if(dict1[8'd5] && dict2[8'd4] && dict3[8'd3] ) begin
        isMatch = 1'b1;
        pos = 9'd5;
    end
    else if(dict1[8'd6] && dict2[8'd5] && dict3[8'd4] ) begin
        isMatch = 1'b1;
        pos = 9'd6;
    end
    else if(dict1[8'd7] && dict2[8'd6] && dict3[8'd5] ) begin
        isMatch = 1'b1;
        pos = 9'd7;
    end
    else if(dict1[8'd8] && dict2[8'd7] && dict3[8'd6] ) begin
        isMatch = 1'b1;
        pos = 9'd8;
    end
    else if(dict1[8'd9] && dict2[8'd8] && dict3[8'd7] ) begin
        isMatch = 1'b1;
        pos = 9'd9;
    end
    else if(dict1[8'd10] && dict2[8'd9] && dict3[8'd8] ) begin
        isMatch = 1'b1;
        pos = 9'd10;
    end
    else if(dict1[8'd11] && dict2[8'd10] && dict3[8'd9] ) begin
        isMatch = 1'b1;
        pos = 9'd11;
    end
    else if(dict1[8'd12] && dict2[8'd11] && dict3[8'd10] ) begin
        isMatch = 1'b1;
        pos = 9'd12;
    end
    else if(dict1[8'd13] && dict2[8'd12] && dict3[8'd11] ) begin
        isMatch = 1'b1;
        pos = 9'd13;
    end
    else if(dict1[8'd14] && dict2[8'd13] && dict3[8'd12] ) begin
        isMatch = 1'b1;
        pos = 9'd14;
    end
    else if(dict1[8'd15] && dict2[8'd14] && dict3[8'd13] ) begin
        isMatch = 1'b1;
        pos = 9'd15;
    end
    else if(dict1[8'd16] && dict2[8'd15] && dict3[8'd14] ) begin
        isMatch = 1'b1;
        pos = 9'd16;
    end
    else if(dict1[8'd17] && dict2[8'd16] && dict3[8'd15] ) begin
        isMatch = 1'b1;
        pos = 9'd17;
    end
    else if(dict1[8'd18] && dict2[8'd17] && dict3[8'd16] ) begin
        isMatch = 1'b1;
        pos = 9'd18;
    end
    else if(dict1[8'd19] && dict2[8'd18] && dict3[8'd17] ) begin
        isMatch = 1'b1;
        pos = 9'd19;
    end
    else if(dict1[8'd20] && dict2[8'd19] && dict3[8'd18] ) begin
        isMatch = 1'b1;
        pos = 9'd20;
    end
    else if(dict1[8'd21] && dict2[8'd20] && dict3[8'd19] ) begin
        isMatch = 1'b1;
        pos = 9'd21;
    end
    else if(dict1[8'd22] && dict2[8'd21] && dict3[8'd20] ) begin
        isMatch = 1'b1;
        pos = 9'd22;
    end
    else if(dict1[8'd23] && dict2[8'd22] && dict3[8'd21] ) begin
        isMatch = 1'b1;
        pos = 9'd23;
    end
    else if(dict1[8'd24] && dict2[8'd23] && dict3[8'd22] ) begin
        isMatch = 1'b1;
        pos = 9'd24;
    end
    else if(dict1[8'd25] && dict2[8'd24] && dict3[8'd23] ) begin
        isMatch = 1'b1;
        pos = 9'd25;
    end
    else if(dict1[8'd26] && dict2[8'd25] && dict3[8'd24] ) begin
        isMatch = 1'b1;
        pos = 9'd26;
    end
    else if(dict1[8'd27] && dict2[8'd26] && dict3[8'd25] ) begin
        isMatch = 1'b1;
        pos = 9'd27;
    end
    else if(dict1[8'd28] && dict2[8'd27] && dict3[8'd26] ) begin
        isMatch = 1'b1;
        pos = 9'd28;
    end
    else if(dict1[8'd29] && dict2[8'd28] && dict3[8'd27] ) begin
        isMatch = 1'b1;
        pos = 9'd29;
    end
    else if(dict1[8'd30] && dict2[8'd29] && dict3[8'd28] ) begin
        isMatch = 1'b1;
        pos = 9'd30;
    end
    else if(dict1[8'd31] && dict2[8'd30] && dict3[8'd29] ) begin
        isMatch = 1'b1;
        pos = 9'd31;
    end
    else if(dict1[8'd32] && dict2[8'd31] && dict3[8'd30] ) begin
        isMatch = 1'b1;
        pos = 9'd32;
    end
    else if(dict1[8'd33] && dict2[8'd32] && dict3[8'd31] ) begin
        isMatch = 1'b1;
        pos = 9'd33;
    end
    else if(dict1[8'd34] && dict2[8'd33] && dict3[8'd32] ) begin
        isMatch = 1'b1;
        pos = 9'd34;
    end
    else if(dict1[8'd35] && dict2[8'd34] && dict3[8'd33] ) begin
        isMatch = 1'b1;
        pos = 9'd35;
    end
    else if(dict1[8'd36] && dict2[8'd35] && dict3[8'd34] ) begin
        isMatch = 1'b1;
        pos = 9'd36;
    end
    else if(dict1[8'd37] && dict2[8'd36] && dict3[8'd35] ) begin
        isMatch = 1'b1;
        pos = 9'd37;
    end
    else if(dict1[8'd38] && dict2[8'd37] && dict3[8'd36] ) begin
        isMatch = 1'b1;
        pos = 9'd38;
    end
    else if(dict1[8'd39] && dict2[8'd38] && dict3[8'd37] ) begin
        isMatch = 1'b1;
        pos = 9'd39;
    end
    else if(dict1[8'd40] && dict2[8'd39] && dict3[8'd38] ) begin
        isMatch = 1'b1;
        pos = 9'd40;
    end
    else if(dict1[8'd41] && dict2[8'd40] && dict3[8'd39] ) begin
        isMatch = 1'b1;
        pos = 9'd41;
    end
    else if(dict1[8'd42] && dict2[8'd41] && dict3[8'd40] ) begin
        isMatch = 1'b1;
        pos = 9'd42;
    end
    else if(dict1[8'd43] && dict2[8'd42] && dict3[8'd41] ) begin
        isMatch = 1'b1;
        pos = 9'd43;
    end
    else if(dict1[8'd44] && dict2[8'd43] && dict3[8'd42] ) begin
        isMatch = 1'b1;
        pos = 9'd44;
    end
    else if(dict1[8'd45] && dict2[8'd44] && dict3[8'd43] ) begin
        isMatch = 1'b1;
        pos = 9'd45;
    end
    else if(dict1[8'd46] && dict2[8'd45] && dict3[8'd44] ) begin
        isMatch = 1'b1;
        pos = 9'd46;
    end
    else if(dict1[8'd47] && dict2[8'd46] && dict3[8'd45] ) begin
        isMatch = 1'b1;
        pos = 9'd47;
    end
    else if(dict1[8'd48] && dict2[8'd47] && dict3[8'd46] ) begin
        isMatch = 1'b1;
        pos = 9'd48;
    end
    else if(dict1[8'd49] && dict2[8'd48] && dict3[8'd47] ) begin
        isMatch = 1'b1;
        pos = 9'd49;
    end
    else if(dict1[8'd50] && dict2[8'd49] && dict3[8'd48] ) begin
        isMatch = 1'b1;
        pos = 9'd50;
    end
    else if(dict1[8'd51] && dict2[8'd50] && dict3[8'd49] ) begin
        isMatch = 1'b1;
        pos = 9'd51;
    end
    else if(dict1[8'd52] && dict2[8'd51] && dict3[8'd50] ) begin
        isMatch = 1'b1;
        pos = 9'd52;
    end
    else if(dict1[8'd53] && dict2[8'd52] && dict3[8'd51] ) begin
        isMatch = 1'b1;
        pos = 9'd53;
    end
    else if(dict1[8'd54] && dict2[8'd53] && dict3[8'd52] ) begin
        isMatch = 1'b1;
        pos = 9'd54;
    end
    else if(dict1[8'd55] && dict2[8'd54] && dict3[8'd53] ) begin
        isMatch = 1'b1;
        pos = 9'd55;
    end
    else if(dict1[8'd56] && dict2[8'd55] && dict3[8'd54] ) begin
        isMatch = 1'b1;
        pos = 9'd56;
    end
    else if(dict1[8'd57] && dict2[8'd56] && dict3[8'd55] ) begin
        isMatch = 1'b1;
        pos = 9'd57;
    end
    else if(dict1[8'd58] && dict2[8'd57] && dict3[8'd56] ) begin
        isMatch = 1'b1;
        pos = 9'd58;
    end
    else if(dict1[8'd59] && dict2[8'd58] && dict3[8'd57] ) begin
        isMatch = 1'b1;
        pos = 9'd59;
    end
    else if(dict1[8'd60] && dict2[8'd59] && dict3[8'd58] ) begin
        isMatch = 1'b1;
        pos = 9'd60;
    end
    else if(dict1[8'd61] && dict2[8'd60] && dict3[8'd59] ) begin
        isMatch = 1'b1;
        pos = 9'd61;
    end
    else if(dict1[8'd62] && dict2[8'd61] && dict3[8'd60] ) begin
        isMatch = 1'b1;
        pos = 9'd62;
    end
    else if(dict1[8'd63] && dict2[8'd62] && dict3[8'd61] ) begin
        isMatch = 1'b1;
        pos = 9'd63;
    end
    else if(dict1[8'd64] && dict2[8'd63] && dict3[8'd62] ) begin
        isMatch = 1'b1;
        pos = 9'd64;
    end
    else if(dict1[8'd65] && dict2[8'd64] && dict3[8'd63] ) begin
        isMatch = 1'b1;
        pos = 9'd65;
    end
    else begin
        isMatch = 1'b0;
        pos = 9'd00;
    end
end
endmodule

module Match2Small(dict1, dict2, dict_size, l_LA_buf, isMatch, pos);

input [64:0]    dict1;
input [64:0]    dict2;
input [8:0]     dict_size;
input [2:0]     l_LA_buf;
output          isMatch;
output [8:0]    pos;


reg isMatch;
reg [8:0] pos;

always@(*)begin

    if(dict1[8'd1] && dict2[8'd0] ) begin
        isMatch = 1'b1;
        pos = 9'd1;
    end
    else if(dict1[8'd2] && dict2[8'd1] ) begin
        isMatch = 1'b1;
        pos = 9'd2;
    end
    else if(dict1[8'd3] && dict2[8'd2] ) begin
        isMatch = 1'b1;
        pos = 9'd3;
    end
    else if(dict1[8'd4] && dict2[8'd3] ) begin
        isMatch = 1'b1;
        pos = 9'd4;
    end
    else if(dict1[8'd5] && dict2[8'd4] ) begin
        isMatch = 1'b1;
        pos = 9'd5;
    end
    else if(dict1[8'd6] && dict2[8'd5] ) begin
        isMatch = 1'b1;
        pos = 9'd6;
    end
    else if(dict1[8'd7] && dict2[8'd6] ) begin
        isMatch = 1'b1;
        pos = 9'd7;
    end
    else if(dict1[8'd8] && dict2[8'd7] ) begin
        isMatch = 1'b1;
        pos = 9'd8;
    end
    else if(dict1[8'd9] && dict2[8'd8] ) begin
        isMatch = 1'b1;
        pos = 9'd9;
    end
    else if(dict1[8'd10] && dict2[8'd9] ) begin
        isMatch = 1'b1;
        pos = 9'd10;
    end
    else if(dict1[8'd11] && dict2[8'd10] ) begin
        isMatch = 1'b1;
        pos = 9'd11;
    end
    else if(dict1[8'd12] && dict2[8'd11] ) begin
        isMatch = 1'b1;
        pos = 9'd12;
    end
    else if(dict1[8'd13] && dict2[8'd12] ) begin
        isMatch = 1'b1;
        pos = 9'd13;
    end
    else if(dict1[8'd14] && dict2[8'd13] ) begin
        isMatch = 1'b1;
        pos = 9'd14;
    end
    else if(dict1[8'd15] && dict2[8'd14] ) begin
        isMatch = 1'b1;
        pos = 9'd15;
    end
    else if(dict1[8'd16] && dict2[8'd15] ) begin
        isMatch = 1'b1;
        pos = 9'd16;
    end
    else if(dict1[8'd17] && dict2[8'd16] ) begin
        isMatch = 1'b1;
        pos = 9'd17;
    end
    else if(dict1[8'd18] && dict2[8'd17] ) begin
        isMatch = 1'b1;
        pos = 9'd18;
    end
    else if(dict1[8'd19] && dict2[8'd18] ) begin
        isMatch = 1'b1;
        pos = 9'd19;
    end
    else if(dict1[8'd20] && dict2[8'd19] ) begin
        isMatch = 1'b1;
        pos = 9'd20;
    end
    else if(dict1[8'd21] && dict2[8'd20] ) begin
        isMatch = 1'b1;
        pos = 9'd21;
    end
    else if(dict1[8'd22] && dict2[8'd21] ) begin
        isMatch = 1'b1;
        pos = 9'd22;
    end
    else if(dict1[8'd23] && dict2[8'd22] ) begin
        isMatch = 1'b1;
        pos = 9'd23;
    end
    else if(dict1[8'd24] && dict2[8'd23] ) begin
        isMatch = 1'b1;
        pos = 9'd24;
    end
    else if(dict1[8'd25] && dict2[8'd24] ) begin
        isMatch = 1'b1;
        pos = 9'd25;
    end
    else if(dict1[8'd26] && dict2[8'd25] ) begin
        isMatch = 1'b1;
        pos = 9'd26;
    end
    else if(dict1[8'd27] && dict2[8'd26] ) begin
        isMatch = 1'b1;
        pos = 9'd27;
    end
    else if(dict1[8'd28] && dict2[8'd27] ) begin
        isMatch = 1'b1;
        pos = 9'd28;
    end
    else if(dict1[8'd29] && dict2[8'd28] ) begin
        isMatch = 1'b1;
        pos = 9'd29;
    end
    else if(dict1[8'd30] && dict2[8'd29] ) begin
        isMatch = 1'b1;
        pos = 9'd30;
    end
    else if(dict1[8'd31] && dict2[8'd30] ) begin
        isMatch = 1'b1;
        pos = 9'd31;
    end
    else if(dict1[8'd32] && dict2[8'd31] ) begin
        isMatch = 1'b1;
        pos = 9'd32;
    end
    else if(dict1[8'd33] && dict2[8'd32] ) begin
        isMatch = 1'b1;
        pos = 9'd33;
    end
    else if(dict1[8'd34] && dict2[8'd33] ) begin
        isMatch = 1'b1;
        pos = 9'd34;
    end
    else if(dict1[8'd35] && dict2[8'd34] ) begin
        isMatch = 1'b1;
        pos = 9'd35;
    end
    else if(dict1[8'd36] && dict2[8'd35] ) begin
        isMatch = 1'b1;
        pos = 9'd36;
    end
    else if(dict1[8'd37] && dict2[8'd36] ) begin
        isMatch = 1'b1;
        pos = 9'd37;
    end
    else if(dict1[8'd38] && dict2[8'd37] ) begin
        isMatch = 1'b1;
        pos = 9'd38;
    end
    else if(dict1[8'd39] && dict2[8'd38] ) begin
        isMatch = 1'b1;
        pos = 9'd39;
    end
    else if(dict1[8'd40] && dict2[8'd39] ) begin
        isMatch = 1'b1;
        pos = 9'd40;
    end
    else if(dict1[8'd41] && dict2[8'd40] ) begin
        isMatch = 1'b1;
        pos = 9'd41;
    end
    else if(dict1[8'd42] && dict2[8'd41] ) begin
        isMatch = 1'b1;
        pos = 9'd42;
    end
    else if(dict1[8'd43] && dict2[8'd42] ) begin
        isMatch = 1'b1;
        pos = 9'd43;
    end
    else if(dict1[8'd44] && dict2[8'd43] ) begin
        isMatch = 1'b1;
        pos = 9'd44;
    end
    else if(dict1[8'd45] && dict2[8'd44] ) begin
        isMatch = 1'b1;
        pos = 9'd45;
    end
    else if(dict1[8'd46] && dict2[8'd45] ) begin
        isMatch = 1'b1;
        pos = 9'd46;
    end
    else if(dict1[8'd47] && dict2[8'd46] ) begin
        isMatch = 1'b1;
        pos = 9'd47;
    end
    else if(dict1[8'd48] && dict2[8'd47] ) begin
        isMatch = 1'b1;
        pos = 9'd48;
    end
    else if(dict1[8'd49] && dict2[8'd48] ) begin
        isMatch = 1'b1;
        pos = 9'd49;
    end
    else if(dict1[8'd50] && dict2[8'd49] ) begin
        isMatch = 1'b1;
        pos = 9'd50;
    end
    else if(dict1[8'd51] && dict2[8'd50] ) begin
        isMatch = 1'b1;
        pos = 9'd51;
    end
    else if(dict1[8'd52] && dict2[8'd51] ) begin
        isMatch = 1'b1;
        pos = 9'd52;
    end
    else if(dict1[8'd53] && dict2[8'd52] ) begin
        isMatch = 1'b1;
        pos = 9'd53;
    end
    else if(dict1[8'd54] && dict2[8'd53] ) begin
        isMatch = 1'b1;
        pos = 9'd54;
    end
    else if(dict1[8'd55] && dict2[8'd54] ) begin
        isMatch = 1'b1;
        pos = 9'd55;
    end
    else if(dict1[8'd56] && dict2[8'd55] ) begin
        isMatch = 1'b1;
        pos = 9'd56;
    end
    else if(dict1[8'd57] && dict2[8'd56] ) begin
        isMatch = 1'b1;
        pos = 9'd57;
    end
    else if(dict1[8'd58] && dict2[8'd57] ) begin
        isMatch = 1'b1;
        pos = 9'd58;
    end
    else if(dict1[8'd59] && dict2[8'd58] ) begin
        isMatch = 1'b1;
        pos = 9'd59;
    end
    else if(dict1[8'd60] && dict2[8'd59] ) begin
        isMatch = 1'b1;
        pos = 9'd60;
    end
    else if(dict1[8'd61] && dict2[8'd60] ) begin
        isMatch = 1'b1;
        pos = 9'd61;
    end
    else if(dict1[8'd62] && dict2[8'd61] ) begin
        isMatch = 1'b1;
        pos = 9'd62;
    end
    else if(dict1[8'd63] && dict2[8'd62] ) begin
        isMatch = 1'b1;
        pos = 9'd63;
    end
    else if(dict1[8'd64] && dict2[8'd63] ) begin
        isMatch = 1'b1;
        pos = 9'd64;
    end
    else begin
        isMatch = 1'b0;
        pos = 9'd00;
    end
end
endmodule

module MatchBig(match1, pos1, match2, pos2, match3, pos3, match4, pos4, dict_size, isMatch, pos);

input match1, match2, match3, match4;
input [8:0] pos1, pos2, pos3, pos4, dict_size;

output isMatch;
output [8:0] pos;

reg isMatch;
reg [8:0] pos;

always@(*)begin
    if( match1 == 1'b1 && pos1 < dict_size )begin
        isMatch = 1'b1;
        pos = pos1;
    end
    else if( match2 == 1'b1 && pos2 < dict_size )begin
        isMatch = 1'b1;
        pos = pos2+9'd64;
    end
    else if( match3 == 1'b1 && pos3 < dict_size ) begin
        isMatch = 1'b1;
        pos = pos3+9'd128;
    end
    else if( match4 == 1'b1 && pos4 < dict_size ) begin
        isMatch = 1'b1;
        pos = pos4+9'd192;
    end
    else begin
        isMatch = 1'b0;
        pos = 9'd0;
    end
end
endmodule



