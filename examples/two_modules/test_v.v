module test_v #(
	parameter portsize = 61
)(
	input            rst_i, clk_a_i, clk_b_i,
	output reg[portsize-1:0] value_o,
	input  reg[portsize-1:0] value_i,
	output reg[portsize-1:0] cnt_a_o,
	output reg[portsize-1:0] cnt_b_o
);

always @ (posedge clk_a_i) cnt_a_o <= cnt_a_o + 1;
always @ (posedge clk_b_i) cnt_b_o <= cnt_b_o + 1;
assign value_o = value_i;
endmodule