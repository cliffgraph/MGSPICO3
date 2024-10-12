`default_nettype none
module MMP_cdc (
	input	wire				i_RST_n,
	//
	input	wire				i_CLK_A,
	input	wire signed [15:0]	i_DATA,
	//
	input	wire				i_CLK_B,
	output	reg signed [15:0]	o_DATA
);

reg signed [15:0]	ff_DATA_buff;
//
reg			ff_ACK_fromB;
reg	[2:0]	ff_ACK_fromB_buff;
wire		ff_ACK = (ff_ACK_fromB_buff[2:1] == 2'b01) ? `HIGH : `LOW;
//
reg			ff_VALID_fromA;
reg	[2:0]	ff_VALID_fromA_buff;
wire		ff_VALID = (ff_VALID_fromA_buff[2:1] == 2'b01) ? `HIGH : `LOW;


always @(posedge i_CLK_A) begin
	if (!i_RST_n) begin
		ff_ACK_fromB_buff = 3'b000;
	end	
	else begin
		ff_ACK_fromB_buff <= {ff_ACK_fromB_buff[1:0], ff_ACK_fromB};
	end
end

always @(posedge i_CLK_A) begin
	if (!i_RST_n) begin
		ff_DATA_buff <= 16'sd0;
		ff_VALID_fromA <= `LOW;
	end
	else if( ff_ACK == `HIGH ) begin
		ff_VALID_fromA <= `LOW;
	end
	else if( ff_VALID_fromA == `LOW ) begin
		ff_DATA_buff <= i_DATA;
		ff_VALID_fromA <= `HIGH;
	end
end


always @(posedge i_CLK_B) begin
	if (!i_RST_n) begin
		ff_VALID_fromA_buff = 3'b000;
		o_DATA <= 16'sd0;
		ff_ACK_fromB <= `LOW;
	end
	else begin
		 if( ff_ACK_fromB == `HIGH) begin
			ff_ACK_fromB <= `LOW;
		end
		else if( ff_VALID == `HIGH ) begin
			o_DATA <= ff_DATA_buff;
			ff_ACK_fromB <= `HIGH;
			ff_VALID_fromA_buff = 3'b000;
		end
		else begin
			ff_VALID_fromA_buff <= {ff_VALID_fromA_buff[1:0], ff_VALID_fromA};
		end
	end
end

endmodule
`default_nettype wire