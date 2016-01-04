#include<iostream>
using namespace std;

int main() {

	for(int dict_pos = 4; dict_pos < 256; dict_pos++) {
		cout<<"                else if(dict5[8'd"<<dict_pos<<"] && dict4[8'd"<<dict_pos-1<<"] && dict3[8'd"<<dict_pos-2<<"] && dict2[8'd"<<dict_pos-3<<"] && dict1[8'd"<<dict_pos-4<<"] ) begin"<<endl;
		cout<<"                    if(tmp_largest < 3'd5 && l_LA_buf > 3'd4 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
		cout<<"                        tmp_largest = 3'd5;"<<endl;
		cout<<"                        tmp_largest_pos = 8'd"<<dict_pos-4<<";"<<endl;
		cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}

	for(int dict_pos = 3; dict_pos < 256; dict_pos++) {
		cout<<"                else if(dict4[8'd"<<dict_pos<<"] && dict3[8'd"<<dict_pos-1<<"] && dict2[8'd"<<dict_pos-2<<"] && dict1[8'd"<<dict_pos-3<<"] ) begin"<<endl;
		cout<<"                    if(tmp_largest < 3'd4 && l_LA_buf > 3'd3 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
		cout<<"                        tmp_largest = 3'd4;"<<endl;
		cout<<"                        tmp_largest_pos = 8'd"<<dict_pos-3<<";"<<endl;
		cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}


	for(int dict_pos = 2; dict_pos < 256; dict_pos++) {
		cout<<"                else if(dict3[8'd"<<dict_pos<<"] && dict2[8'd"<<dict_pos-1<<"] && dict1[8'd"<<dict_pos-2<<"] ) begin"<<endl;
		cout<<"                    if(tmp_largest < 3'd3 && l_LA_buf > 3'd2 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
		cout<<"                        tmp_largest = 3'd3;"<<endl;
		cout<<"                        tmp_largest_pos = 8'd"<<dict_pos-2<<";"<<endl;
		cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}

	for(int dict_pos = 1; dict_pos < 256; dict_pos++) {
		cout<<"                else if(dict2[8'd"<<dict_pos<<"] && dict1[8'd"<<dict_pos-1<<"] ) begin"<<endl;
		cout<<"                    if(tmp_largest < 3'd2 && l_LA_buf > 3'd1 && dict_size > 9'd"<<dict_pos<<") begin"<<endl;
		cout<<"                        tmp_largest = 3'd2;"<<endl;
		cout<<"                        tmp_largest_pos = 8'd"<<dict_pos-1<<";"<<endl;
		cout<<"                    end"<<endl;
		cout<<"                end"<<endl;
	}
    for(int dict_pos = 0; dict_pos < 256; dict_pos++){
        cout<<"assign dict1["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol1) ? 1'b1 : 1'b0;"<<endl;
        cout<<"assign dict2["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol2) ? 1'b1 : 1'b0;"<<endl;
        cout<<"assign dict3["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol3) ? 1'b1 : 1'b0;"<<endl;
        cout<<"assign dict4["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol4) ? 1'b1 : 1'b0;"<<endl;
        cout<<"assign dict5["<<dict_pos<<"] = (dict_org["<<dict_pos<<"]==symbol5) ? 1'b1 : 1'b0;"<<endl;



    }
}

