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
reg     [2:0]   tmp_largest ;
reg     [7:0]   tmp_largest_pos;

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
reg		[7:0] 	dict[0:255]	;
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
reg		[7:0]	n_dict[0:255] ;
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
            n_state =   S_ENCODE;
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
        n_dict[i-1] =   dict[i-1] ;
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
            tmp_largest =   3'd0;
            tmp_largest_pos = 8'd255;
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
                // 2
                for(dict_pos = 9'd1; dict_pos != dict_size; dict_pos = dict_pos + 9'd1) begin
                    if(dict[dict_pos] == symbol1 && dict[dict_pos-8'd1] == symbol2) begin
                        if(tmp_largest < 3'd2 && l_LA_buf > 3'd1) begin
                            tmp_largest = 3'd2;
                            tmp_largest_pos = dict_pos - 8'd1;
                        end
                    end
                    // 3
                    if(dict[dict_pos] == symbol1 && dict[dict_pos-8'd1] == symbol2 && dict[dict_pos-8'd2] == symbol3) begin
                        if(tmp_largest < 3'd3 && dict_pos >= 8'd2 && l_LA_buf > 3'd2) begin
                            tmp_largest = 3'd3;
                            tmp_largest_pos = dict_pos - 8'd2;
                        end
                    end
                    // 4
                    if(dict[dict_pos] == symbol1 && dict[dict_pos-8'd1] == symbol2 && dict[dict_pos-8'd2] == symbol3 && dict[dict_pos-8'd3] == symbol4) begin
                        if(tmp_largest < 3'd4 && dict_pos >= 8'd3 && l_LA_buf > 3'd3) begin
                            tmp_largest = 3'd4;
                            tmp_largest_pos = dict_pos - 8'd3;
                        end
                    end
                    // 5
                    if(dict[dict_pos] == symbol1 && dict[dict_pos-8'd1] == symbol2 && dict[dict_pos-8'd2] == symbol3 && dict[dict_pos-8'd3] == symbol4 && dict[dict_pos-8'd4] == symbol5) begin
                        if(tmp_largest < 3'd5 && dict_pos >= 8'd4 && l_LA_buf > 3'd4) begin
                            tmp_largest = 3'd5;
                            tmp_largest_pos = dict_pos - 8'd4;
                        end
                    end
                end
                n_largest = tmp_largest;
                n_largest_pos = tmp_largest_pos;
            end
        end
        S_ENCODE:begin
            if(largest == 3'd0) begin
                for(i = 256; i != 1 ; i = i - 1)
                    n_dict[i-1] = dict[i-2];
                n_dict[0] = symbol1;
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
                    n_dict[i-1] = dict[i-3];
                n_dict[1] = symbol1;
                n_dict[0] = symbol2;
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
                    n_dict[i-1] = dict[i-4];
                n_dict[2] = symbol1;
                n_dict[1] = symbol2;
                n_dict[0] = symbol3;
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
                    n_dict[i-1] = dict[i-5];
                n_dict[3] = symbol1;
                n_dict[2] = symbol2;
                n_dict[1] = symbol3;
                n_dict[0] = symbol4;
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
                    n_dict[i-1] = dict[i-6];
                n_dict[4] = symbol1;
                n_dict[3] = symbol2;
                n_dict[2] = symbol3;
                n_dict[1] = symbol4;
                n_dict[0] = symbol5;
                n_dict_size = (dict_size > 9'd250) ? 9'd256 : dict_size + 9'd5;
                
                n_LA_buf = 40'd0;
                n_l_LA_buf = l_LA_buf - 3'd5;

                n_busy = 1'd0;
                n_out_valid = 1'd1;
                n_codeword = {1'd1,largest_pos,2'b11};
                n_enc_num = enc_num + 12'd1;
            end
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
            dict[i-1] <= 8'd0;
	end
    else begin
		tmp_buf	<=	 data_valid ? data : 32'dz;
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
            dict[i-1] <= n_dict[i-1]   ;
    end
end


endmodule

