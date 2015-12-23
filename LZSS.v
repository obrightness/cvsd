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

reg             busy        ;
reg     [10:0]  codeword    ;
reg     [11:0]  enc_num     ;
reg             out_valid   ;
reg             finish      ;
reg     [3:0]   state       ;
reg     [31:0]  r_buf       ;
reg     [39:0]  LA_buf      ;
reg     [2:0]   l_r_buf     ;//buf length
reg     [2:0]   l_LA_buf    ;//buf length



reg             n_busy        ;
reg     [10:0]  n_codeword    ;
reg     [11:0]  n_enc_num     ;
reg             n_out_valid   ;
reg             n_finish      ;
reg     [3:0]   n_state       ;
reg     [31:0]  n_r_buf       ;
reg     [39:0]  n_LA_buf      ;
reg     [2:0]   n_l_r_buf     ;//buf length
reg     [2:0]   n_l_LA_buf    ;//buf length


parameter   S_IDLE      =   4'd00;
parameter   S_START     =   4'd01;
parameter   S_COMPARE   =   4'd02;
parameter   S_ENCODE    =   4'd03;
parameter   S_STOP      =   4'd04;
parameter   S_READ      =   4'd06;
parameter   S_PUT       =   4'd07;




//========================combinational==========================
//
always@(*)begin

    n_state =   state;
    case(state)
        S_IDLE:begin
            n_state     =   S_PUT;
        end
        S_PUT:begin
            if({1'b0, l_r_buf} + {1'b0, l_LA_buf} > 4'd4)begin
                n_state =   S_START;
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
                n_state =   S_COMAPRE;
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

    case(state)
        S_IDLE:begin
            n_l_r_buf   =   3'd0;
            n_l_LA_buf  =   3'd0;
            n_LA_buf    =   40'd0;
            n_r_buf     =   32'd0;
            n_busy      =   1'b0;
        end
        S_PUT:begin
            n_busy      =   1'b1;
            n_l_LA_buf  =   ({1'b0, l_LA_buf} + {1'b0, l_r_buf} > 4'd5) ? 3'd5 : (l_LA_buf + l_r_buf);
            case(l_LA_buf)
                3'd0:begin
                    n_LA_buf    =   {8'd0, r_buf};
                    n_r_buf     =   32'd0;
                    n_l_r_buf   =   3'd0;
                end
                3'd1:begin
                    n_LA_buf    =   {r_buf, LA_buf[7:0]};
                    n_r_buf     =   32'd0;
                    n_l_r_buf   =   3'd0;
                end
                3'd2:begin
                    n_LA_buf    =   {r_buf[23:0], LA_buf[15:0]};
                    n_r_buf     =   r_buf >> 24;
                    n_l_r_buf   =   l_r_buf > 2 ?   (l_r_buf - 3'd3) : 3'd0;
                end
                3'd3:begin
                    n_LA_buf    =   {r_buf[15:0], LA_buf[23:0]};
                    n_r_buf     =   r_buf >> 16;
                    n_l_r_buf   =   l_r_buf > 1 ?   (l_r_buf - 3'd2) : 3'd0;
                end
                3'd4:begin
                    n_LA_buf    =   {r_buf[7:0], LA_buf[31:0]};
                    n_r_buf     =   r_buf >> 8;
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
            n_r_buf     =   data;
            n_l_r_buf   =   3'd4;
            if( l_LA_buf == 3'd0 && l_r_buf == 3'd0 )begin
                n_busy      =   3'd0;
            end
            else begin
                n_busy  =   3'd1;
            end
            //TODO::this is not correct!
            if( drop_done == 1'b1 )begin
                n_finish    =   1'b1;
            end
            else begin
                n_finish    =   1'b0;
            end
        end
        S_START:begin

        end
        S_COMPARE:begin

        end
        S_ENCODE:begin
            // TODO:remember to set n_busy here!!!
            //      check n_state's l_r_buf + l_LA_buf

        end
        S_STOP:begin


        end
        default:begin

        end
    endcase 
end




//========================sequential============================
always@(posedge clk or posedge reset)begin
	if(reset)begin
        busy        =   1'd1; 
        codeword    =   11'd0; 
        enc_num     =   12'd0; 
        out_valid   =   1'd0; 
        finish      =   1'd0; 
        state       =   4'd0; 
        r_buf       =   32'd0; 
        LA_buf      =   40'd0; 
        l_r_buf     =   3'd0; 
        l_LA_buf    =   3'd0; 
	end
    else begin
        busy        =   n_busy        ;  
        codeword    =   n_codeword    ;  
        enc_num     =   n_enc_num     ;  
        out_valid   =   n_out_valid   ;  
        finish      =   n_finish      ;  
        state       =   n_state       ;  
        r_buf       =   n_r_buf       ;  
        LA_buf      =   n_LA_buf      ;  
        l_r_buf     =   n_l_r_buf     ;  	
        l_LA_buf    =   n_l_LA_buf    ;  	
        end
    end


endmodule

