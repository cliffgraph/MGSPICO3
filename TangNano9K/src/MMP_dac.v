`default_nettype none
module MMP_dac ( 
	input	wire				i_RST_n,
	input	wire				i_CLK,
	input	wire signed [15:0]	i_SCC,
	input	wire signed [15:0]	i_PSG,
	input	wire signed [15:0]	i_OPLL,
	input	wire signed [15:0]	i_ALL,
	//
	output	wire				o_DAC_WS,
	output	wire				o_DAC_CLK,
	output	wire				o_DAC1_L_R,
	output	wire				o_DAC2_L_R
);

reg	[14:0]	ff_SCC_OUTPUT_buff;
reg	[14:0]	ff_PSG_OUTPUT_buff;
reg	[14:0]	ff_OPLL_OUTPUT_buff;
reg	[14:0]	ff_ALL_OUTPUT_buff;
reg			ff_SCC_DAC_1bit;
reg			ff_PSG_DAC_1bit;
reg			ff_OPLL_DAC_1bit;
reg			ff_ALL_DAC_1bit;			// cdcを経由しているのは、ff_ALL_DAC_1bitのみ。

reg	[3:0]	ff_16bits_cnt;
reg			ff_dac_ws;


always @(negedge i_CLK) begin
	if (!i_RST_n) begin
		ff_dac_ws 			<= 1'b0;
		ff_16bits_cnt 		<= 4'b0;
		ff_SCC_OUTPUT_buff	<= 15'b0;
		ff_PSG_OUTPUT_buff	<= 15'b0;
		ff_OPLL_OUTPUT_buff <= 15'b0;
		ff_ALL_OUTPUT_buff	<= 15'b0;
		ff_SCC_DAC_1bit	 	<= 1'b0;
		ff_PSG_DAC_1bit 	<= 1'b0;
		ff_OPLL_DAC_1bit 	<= 1'b0;
		ff_ALL_DAC_1bit		<= 1'b0;
	end
	else begin
		ff_16bits_cnt <= ff_16bits_cnt + 1'b1;
		if( ff_16bits_cnt == 4'b1111 ) begin
			ff_dac_ws <= !ff_dac_ws;
			//
			ff_SCC_OUTPUT_buff	<= i_SCC[14:0];
			ff_PSG_OUTPUT_buff	<= i_PSG[14:0];
			ff_OPLL_OUTPUT_buff <= i_OPLL[14:0];
			ff_ALL_OUTPUT_buff	<= i_ALL[14:0];
			ff_SCC_DAC_1bit 	<= i_SCC[15];
			ff_PSG_DAC_1bit 	<= i_PSG[15];
			ff_OPLL_DAC_1bit 	<= i_OPLL[15];
			ff_ALL_DAC_1bit 	<= i_ALL[15];
		end
		else begin
			ff_SCC_OUTPUT_buff	<= ff_SCC_OUTPUT_buff << 1;
			ff_PSG_OUTPUT_buff	<= ff_PSG_OUTPUT_buff << 1;
			ff_OPLL_OUTPUT_buff	<= ff_OPLL_OUTPUT_buff << 1;
			ff_ALL_OUTPUT_buff	<= ff_ALL_OUTPUT_buff << 1;
			ff_SCC_DAC_1bit		<= ff_SCC_OUTPUT_buff[14];
			ff_PSG_DAC_1bit		<= ff_PSG_OUTPUT_buff[14];
			ff_OPLL_DAC_1bit	<= ff_OPLL_OUTPUT_buff[14];
			ff_ALL_DAC_1bit		<= ff_ALL_OUTPUT_buff[14];
		end
	end
end

assign o_DAC_WS		= ff_dac_ws;	// 0=Right-Ch, 1=Left-Ch
assign o_DAC_CLK	= i_CLK;
assign o_DAC1_L_R	= (!ff_dac_ws & ff_SCC_DAC_1bit) | (ff_dac_ws & ff_PSG_DAC_1bit);
assign o_DAC2_L_R	= (!ff_dac_ws & ff_ALL_DAC_1bit) | (ff_dac_ws & ff_OPLL_DAC_1bit);



endmodule
`default_nettype wire