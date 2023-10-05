module fifo( 
	clk, 
	din, 
	rd_en, 
	wr_en, 
	dout, 
	rst,
	empty, 
	full,
	prog_full 
	); 

parameter SIZE = 64;

input  clk, rd_en, wr_en, rst;
output empty, full, prog_full;
input      [63:0] din;
output reg [63:0] dout; // internal registers 

reg [63:0] FIFO[0:SIZE-1]; 
integer  readCounter = 0, writeCounter = 0; 
assign empty = (readCounter==writeCounter)? 1'b1:1'b0; 
assign full = ((writeCounter+1)%SIZE==readCounter)? 1'b1:1'b0; 
assign prog_full = full;
always @ (posedge clk) 
begin 
	if (rst) begin 
		readCounter = 0; 
		writeCounter = 0; 
	end 
	else begin
		if (rd_en==1'b1 && empty==1'b0) begin 
			dout = FIFO[readCounter];
			readCounter = (readCounter+1)%SIZE; 
		end 
		if (wr_en==1'b1 && full==1'b0) begin
			FIFO[writeCounter] = din; 
			writeCounter = (writeCounter+1)%SIZE; 
		end 
	end;
end 

endmodule