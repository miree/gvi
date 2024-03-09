module counter_mixed (
	input            rst_i, clk_i,
	output reg[31:0] cnt_o
);

counter_vhd inst(.clk_i(clk_i), .rst_i(rst_i), .cnt_o(cnt_o));

endmodule