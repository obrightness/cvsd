#include<iostream>
using namespace std;

int main() {

	for(int dict_pos = 4; dict_pos < 69; dict_pos++) {
		cout<<"                else if(dict1[8'd"<<dict_pos<<"] && dict2[8'd"<<dict_pos-1<<"] && dict3[8'd"<<dict_pos-2<<"] && dict4[8'd"<<dict_pos-3<<"] && dict5[8'd"<<dict_pos-4<<"] ) begin"<<endl;
		//cout<<"                    if( l_LA_buf > 3'd4 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
        cout<<"                         isMatch = 1'b1;"<<endl;
        cout<<"                         pos = 9'd"<<dict_pos<<";"<<endl;    
        //cout<<"                         for(i = 256; i != 5 ; i = i - 1)"<<endl;                                
        //cout<<"                             n_dict_org[i-1] = dict_org[i-6];" <<endl;
        //cout<<"                         n_dict_org[4] = symbol1;"<<endl;
        //cout<<"                         n_dict_org[3] = symbol2;"<<endl;
        //cout<<"                         n_dict_org[2] = symbol3;"<<endl;
        //cout<<"                         n_dict_org[1] = symbol4;"<<endl;
        //cout<<"                         n_dict_org[0] = symbol5;"<<endl;
        //cout<<"                         n_dict_size = (dict_size > 9'd250) ? 9'd256 : dict_size + 9'd5;"<<endl;
        //cout<<endl;
        //cout<<"                         n_LA_buf = {40'd0};"<<endl;
        //cout<<"                         n_l_LA_buf = l_LA_buf - 3'd5;"<<endl;
        //cout<<"                         n_busy = 1'd0;"<<endl;
        //cout<<"                         n_out_valid = 1'd1;"<<endl;
        //cout<<"                         n_codeword = {1'd1,8'd"<<dict_pos-4<<",2'b11};"<<endl;
        //cout<<"                         n_enc_num = enc_num + 12'd1;"<<endl;
		//cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}

	for(int dict_pos = 3; dict_pos < 68; dict_pos++) {
		cout<<"                else if(dict1[8'd"<<dict_pos<<"] && dict2[8'd"<<dict_pos-1<<"] && dict3[8'd"<<dict_pos-2<<"] && dict4[8'd"<<dict_pos-3<<"] ) begin"<<endl;
		//cout<<"                    if( l_LA_buf > 3'd3 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
        cout<<"                         isMatch = 1'b1;"<<endl;
        cout<<"                         pos = 9'd"<<dict_pos<<";"<<endl;    
        //cout<<"                         for(i = 256; i != 4 ; i = i - 1)"<<endl;                                
        //cout<<"                             n_dict_org[i-1] = dict_org[i-5];" <<endl;
        //cout<<"                         n_dict_org[3] = symbol1;"<<endl;
        //cout<<"                         n_dict_org[2] = symbol2;"<<endl;
        //cout<<"                         n_dict_org[1] = symbol3;"<<endl;
        //cout<<"                         n_dict_org[0] = symbol4;"<<endl;
        //cout<<"                         n_dict_size = (dict_size > 9'd251) ? 9'd256 : dict_size + 9'd4;"<<endl;
        //cout<<endl;
        //cout<<"                         n_LA_buf = {LA_buf[7:0], 32'd0};"<<endl;
        //cout<<"                         n_l_LA_buf = l_LA_buf - 3'd4;"<<endl;
        //cout<<"                         if(l_r_buf + l_LA_buf - 3'd4 > 3'd4)"<<endl;
        //cout<<"                             n_busy = 1'd1;"<<endl;
        //cout<<"                         else"<<endl;
        //cout<<"                             n_busy = 1'd0;"<<endl;
        //cout<<endl;
        //cout<<"                         n_out_valid = 1'd1;"<<endl;
        //cout<<"                         n_codeword = {1'd1,8'd"<<dict_pos-3<<",2'b10};"<<endl;
        //cout<<"                         n_enc_num = enc_num + 12'd1;"<<endl;
		//cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}


	for(int dict_pos = 2; dict_pos < 67; dict_pos++) {
		cout<<"                else if(dict1[8'd"<<dict_pos<<"] && dict2[8'd"<<dict_pos-1<<"] && dict3[8'd"<<dict_pos-2<<"] ) begin"<<endl;
		//cout<<"                    if( l_LA_buf > 3'd2 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
        cout<<"                         isMatch = 1'b1;"<<endl;
        cout<<"                         pos = 9'd"<<dict_pos<<";"<<endl;    
        //cout<<"                         for(i = 256; i != 3 ; i = i - 1)"<<endl;                                
        //cout<<"                             n_dict_org[i-1] = dict_org[i-4];" <<endl;
        //cout<<"                         n_dict_org[2] = symbol1;"<<endl;
        //cout<<"                         n_dict_org[1] = symbol2;"<<endl;
        //cout<<"                         n_dict_org[0] = symbol3;"<<endl;
        //cout<<"                         n_dict_size = (dict_size > 9'd252) ? 9'd256 : dict_size + 9'd3;"<<endl;
        //cout<<endl;
        //cout<<"                         n_LA_buf = {LA_buf[15:0], 24'd0};"<<endl;
        //cout<<"                         n_l_LA_buf = l_LA_buf - 3'd3;"<<endl;
        //cout<<"                         if(l_r_buf + l_LA_buf - 3'd3 > 3'd4)"<<endl;
        //cout<<"                             n_busy = 1'd1;"<<endl;
        //cout<<"                         else"<<endl;
        //cout<<"                             n_busy = 1'd0;"<<endl;
        //cout<<endl;
        //cout<<"                         n_out_valid = 1'd1;"<<endl;
        //cout<<"                         n_codeword = {1'd1,8'd"<<dict_pos-2<<",2'b01};"<<endl;
        //cout<<"                         n_enc_num = enc_num + 12'd1;"<<endl;
		//cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}

	for(int dict_pos = 1; dict_pos < 66; dict_pos++) {
		cout<<"                else if(dict1[8'd"<<dict_pos<<"] && dict2[8'd"<<dict_pos-1<<"] ) begin"<<endl;
		//cout<<"                    if( l_LA_buf > 3'd1 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
        cout<<"                         isMatch = 1'b1;"<<endl;
        cout<<"                         pos = 9'd"<<dict_pos<<";"<<endl;    
        //cout<<"                         for(i = 256; i != 2 ; i = i - 1)"<<endl;                                
        //cout<<"                             n_dict_org[i-1] = dict_org[i-3];" <<endl;
        //cout<<"                         n_dict_org[1] = symbol1;"<<endl;
        //cout<<"                         n_dict_org[0] = symbol2;"<<endl;
        //cout<<"                         n_dict_size = (dict_size > 9'd253) ? 9'd256 : dict_size + 9'd2;"<<endl;
        //cout<<endl;
        //cout<<"                         n_LA_buf = {LA_buf[23:0], 16'd0};"<<endl;
        //cout<<"                         n_l_LA_buf = l_LA_buf - 3'd2;"<<endl;
        //cout<<"                         if(l_r_buf + l_LA_buf - 3'd2 > 3'd4)"<<endl;
        //cout<<"                             n_busy = 1'd1;"<<endl;
        //cout<<"                         else"<<endl;
        //cout<<"                             n_busy = 1'd0;"<<endl;
        //cout<<endl;
        //cout<<"                         n_out_valid = 1'd1;"<<endl;
        //cout<<"                         n_codeword = {1'd1,8'd"<<dict_pos-1<<",2'b00};"<<endl;
        //cout<<"                         n_enc_num = enc_num + 12'd1;"<<endl;
		//cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}
        //cout<<"                else begin"<<endl;
        //cout<<"                     for(i = 256; i != 1 ; i = i - 1)"<<endl;                                
        //cout<<"                         n_dict_org[i-1] = dict_org[i-2];" <<endl;
        //cout<<"                     n_dict_org[0] = symbol1;"<<endl;
        //cout<<"                     n_dict_size = (dict_size > 9'd254) ? 9'd256 : dict_size + 9'd1;"<<endl;
        //cout<<endl;
        //cout<<"                     n_LA_buf = {LA_buf[31:0], 8'd0};"<<endl;
        //cout<<"                     n_l_LA_buf = l_LA_buf - 3'd1;"<<endl;
        //cout<<"                     if(l_r_buf + l_LA_buf - 3'd1 > 3'd4)"<<endl;
        //cout<<"                         n_busy = 1'd1;"<<endl;
        //cout<<"                     else"<<endl;
        //cout<<"                         n_busy = 1'd0;"<<endl;
        //cout<<endl;
        //cout<<"                     n_out_valid = 1'd1;"<<endl;
        //cout<<"                     n_codeword = {1'd0, symbol1, 2'bxx};"<<endl;
        //cout<<"                     n_enc_num = enc_num + 12'd1;"<<endl;
        //cout<<"                end"<<endl;
    for(int dict_pos = 0; dict_pos < 256; dict_pos++){
        //cout<<"assign dict1["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol1) ? 1'b1 : 1'b0;"<<endl;
        //cout<<"assign dict2["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol2) ? 1'b1 : 1'b0;"<<endl;
        //cout<<"assign dict3["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol3) ? 1'b1 : 1'b0;"<<endl;
        //cout<<"assign dict4["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol4) ? 1'b1 : 1'b0;"<<endl;
        //cout<<"assign dict5["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol5) ? 1'b1 : 1'b0;"<<endl;



    }
}
