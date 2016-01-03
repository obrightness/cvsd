#include<iostream>
using namespace std;

int main() {

	for(int dict_pos = 4; dict_pos < 256; dict_pos++) {
		cout<<"                else if(dict[8'd"<<dict_pos<<"] == symbol1 && dict[8'd"<<dict_pos-1<<"] == symbol2 && dict[8'd"<<dict_pos-2<<"] == symbol3 && dict[8'd"<<dict_pos-3<<"] == symbol4 && dict[8'd"<<dict_pos-4<<"] == symbol5) begin"<<endl;
		cout<<"                    if(tmp_largest < 3'd5 && l_LA_buf > 3'd4 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
		cout<<"                        tmp_largest = 3'd5;"<<endl;
		cout<<"                        tmp_largest_pos = 8'd"<<dict_pos-4<<";"<<endl;
		cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}

	for(int dict_pos = 3; dict_pos < 256; dict_pos++) {
		cout<<"                else if(dict[8'd"<<dict_pos<<"] == symbol1 && dict[8'd"<<dict_pos-1<<"] == symbol2 && dict[8'd"<<dict_pos-2<<"] == symbol3 && dict[8'd"<<dict_pos-3<<"] == symbol4) begin"<<endl;
		cout<<"                    if(tmp_largest < 3'd4 && l_LA_buf > 3'd3 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
		cout<<"                        tmp_largest = 3'd4;"<<endl;
		cout<<"                        tmp_largest_pos = 8'd"<<dict_pos-3<<";"<<endl;
		cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}


	for(int dict_pos = 2; dict_pos < 256; dict_pos++) {
		cout<<"                else if(dict[8'd"<<dict_pos<<"] == symbol1 && dict[8'd"<<dict_pos-1<<"] == symbol2 && dict[8'd"<<dict_pos-2<<"] == symbol3) begin"<<endl;
		cout<<"                    if(tmp_largest < 3'd3 && l_LA_buf > 3'd2 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
		cout<<"                        tmp_largest = 3'd3;"<<endl;
		cout<<"                        tmp_largest_pos = 8'd"<<dict_pos-2<<";"<<endl;
		cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}

	for(int dict_pos = 1; dict_pos < 256; dict_pos++) {
		cout<<"                else if(dict[8'd"<<dict_pos<<"] == symbol1 && dict[8'd"<<dict_pos-1<<"] == symbol2) begin"<<endl;
		cout<<"                    if(tmp_largest < 3'd2 && l_LA_buf > 3'd1 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
		cout<<"                        tmp_largest = 3'd2;"<<endl;
		cout<<"                        tmp_largest_pos = 8'd"<<dict_pos-1<<";"<<endl;
		cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}
}

