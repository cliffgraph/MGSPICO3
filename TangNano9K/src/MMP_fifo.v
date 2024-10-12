`default_nettype none
module MMP_fifo (
	input	wire		i_RST_n,
	input	wire		i_CLK,
	//
	input	wire		i_PUSH_S,
	input	wire[23:0]	i_PUSH_DT,
	input	wire		i_POP_S,
	output	reg[23:0]	o_POP_DT,
	output	wire		o_EMPTY,
	output	wire		o_FULLY
	
);

parameter MAXWORD_RXBUFF = 2047;
reg	[23:0]	mem[MAXWORD_RXBUFF:0];
reg	[10:0]	w_index, w_index_next;	// インデックスは0~2047を循環する
reg	[10:0]	r_index;

assign o_EMPTY = (w_index == r_index) ? 1'b1: 1'b0;
assign o_FULLY = (w_index_next == r_index) ? 1'b1: 1'b0;

always @(posedge i_CLK ) begin
	if (!i_RST_n) begin
		w_index_next <= 11'h01;
		w_index <= 11'h00;
		r_index <= 11'h00;
	end
	else begin
		if( i_PUSH_S ) begin
			mem[w_index] <= i_PUSH_DT;
			w_index <= w_index + 11'h01;
			w_index_next <= w_index_next + 11'h01;
		end
		if( i_POP_S ) begin
			o_POP_DT <= mem[r_index];
			r_index <= r_index + 11'h01;
		end
	end
end

endmodule
`default_nettype wire
