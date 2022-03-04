module counter_v (
	input            rst_i, clk_i,
	output reg[31:0] cnt_o
);

always @ (posedge clk_i)
	if (rst_i)
		cnt_o <= 0;
	else begin
		cnt_o <= cnt_o + 1;
	end 
endmodule