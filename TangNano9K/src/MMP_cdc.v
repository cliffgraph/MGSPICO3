`default_nettype none

//////////////////////////////////////////////////////////////////////////////////////////
module MMP_cdc_F2L (
	input	wire				i_RST_n,
	//
	input	wire				i_CLK_A,
	input	wire signed [15:0]	i_DATA_A,
	//
	input	wire				i_CLK_B,
	output	reg signed [15:0]	o_DATA_B
);

reg signed [15:0]	ff_DATA_buff;
//
reg			ff_ACK_fromB;
reg	[2:0]	ff_ACK_fromB_buff;
wire		cc_ACK = (ff_ACK_fromB_buff[2:1] == 2'b01) ? `HIGH : `LOW;
//
reg			ff_VALID_fromA;
reg	[1:0]	ff_VALID_fromA_buff;
wire		cc_VALID = (ff_VALID_fromA_buff[1:0] == 2'b11) ? `HIGH : `LOW;


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
	else if( cc_ACK == `HIGH ) begin
		ff_VALID_fromA <= `LOW;
	end
	else if( ff_VALID_fromA == `LOW ) begin
		ff_VALID_fromA <= `HIGH;
		ff_DATA_buff <= i_DATA_A;
	end
end


always @(posedge i_CLK_B) begin
	if (!i_RST_n) begin
		ff_VALID_fromA_buff = 2'b00;
		o_DATA_B <= 16'sd0;
		ff_ACK_fromB <= `LOW;
	end
	else begin
		 if( ff_ACK_fromB == `HIGH) begin
			ff_ACK_fromB <= `LOW;
		end
		else if( cc_VALID == `HIGH ) begin
			o_DATA_B <= ff_DATA_buff;
			ff_ACK_fromB <= `HIGH;
			ff_VALID_fromA_buff = 2'b00;
		end
		else begin
			ff_VALID_fromA_buff <= {ff_VALID_fromA_buff[0], ff_VALID_fromA};
		end
	end
end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////
module MMP_cdc_L2F (
	input	wire				i_RST_n,
	//
	input	wire				i_CLK_A,
	input	wire signed [15:0]	i_DATA_A,
	//
	input	wire				i_CLK_B,
	output	reg signed [15:0]	o_DATA_B
);

reg signed [15:0]	ff_DATA_buff;
//
reg			ff_VALID_fromA;
reg	[1:0]	ff_VALID_fromA_buff;
wire		cc_VALID = (ff_VALID_fromA_buff[1:0] == 2'b11) ? `HIGH : `LOW;



always @(posedge i_CLK_A) begin
	if (!i_RST_n) begin
		ff_DATA_buff <= 16'sd0;
		ff_VALID_fromA <= `LOW;
	end
	else begin 
		if( ff_VALID_fromA == `LOW ) begin
			ff_VALID_fromA <= `HIGH;
			ff_DATA_buff <= i_DATA_A;
		end
		else begin
			ff_VALID_fromA = `LOW;
		end
	end
end


always @(posedge i_CLK_B) begin
	if (!i_RST_n) begin
		ff_VALID_fromA_buff = 2'b00;
		o_DATA_B <= 16'sd0;
	end
	else begin
		if( cc_VALID == `HIGH ) begin
			o_DATA_B <= ff_DATA_buff;
			ff_VALID_fromA_buff = 2'b00;
		end
		else begin
			ff_VALID_fromA_buff <= {ff_VALID_fromA_buff[0], ff_VALID_fromA};
		end
	end
end
endmodule


`default_nettype wire