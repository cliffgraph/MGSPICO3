`default_nettype none
module MMP_spdif (
	input	wire				i_RST_n,
	input	wire				i_CLK_SPDIF,
	input	wire signed [15:0]	i_SOUND,
	output	wire				o_SPDIF
);

reg[15:0]	ff_ALL_OUTPUT_SPDIF_16bit;
wire		SPDIF_chan_status_bit_req;
wire		SPDIF_block_start_flag;
wire		SPDIF_O_sub_frame1_flag;
wire		SPDIF_O_sub_frame0_flag;
wire		SPDIF_O_audio_d_req;

reg			ff_SPDIF_STATUS_1bit;
reg	[7:0]	spdif_status_bit_index;
reg [191:0] spdif_status_table_LR[1:0];
reg			spdif_status_bit_index_LR;

always @(posedge i_CLK_SPDIF) begin
	if( SPDIF_O_audio_d_req ) ff_ALL_OUTPUT_SPDIF_16bit <= i_SOUND;
end

always @(posedge i_CLK_SPDIF) begin
	if( SPDIF_O_sub_frame0_flag && !SPDIF_O_sub_frame1_flag)		spdif_status_bit_index_LR <= 1'b0;
	else if( !SPDIF_O_sub_frame0_flag && SPDIF_O_sub_frame1_flag )	spdif_status_bit_index_LR <= 1'b1;
end
wire picup = spdif_status_table_LR[spdif_status_bit_index_LR][8'd191-spdif_status_bit_index];

always @(posedge i_CLK_SPDIF) begin
	if (!i_RST_n || SPDIF_block_start_flag) begin
		ff_SPDIF_STATUS_1bit		<= 1'b0;
		spdif_status_bit_index		<= 8'd0;
		//                                                                  LR   48
		spdif_status_table_LR[0][191:0] <= 192'b0_0_1_000_00_0000000_0_0100_1000_0100_11_00_0100_0000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_00;
		spdif_status_table_LR[1][191:0] <= 192'b0_0_1_000_00_0000000_0_0100_0100_0100_11_00_0100_0000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_0000000000_00;
	end
	else begin
		ff_SPDIF_STATUS_1bit <= picup;
		if( spdif_status_bit_index_LR ) begin
			if( spdif_status_bit_index == 8'd191) begin
				spdif_status_bit_index <= 8'd0;
			end
			else begin
				spdif_status_bit_index <= spdif_status_bit_index + 8'd1;
			end
		end
	end
end

SPDIF_TX_Top u_spdif_tx (
	.I_clk					(i_CLK_SPDIF						),	// input I_clk
	.I_rst_n				(i_RST_n						),	// input I_rst_n
	.I_audio_d				(ff_ALL_OUTPUT_SPDIF_16bit		),	// input [15:0] I_audio_d
	.I_validity_bit			(1'b0							),	// input I_validity_bit
	.I_user_bit				(1'b0							),	// input I_user_bit
	.I_chan_status_bit		(ff_SPDIF_STATUS_1bit			),	// input I_chan_status_bit
	.O_audio_d_req			(SPDIF_O_audio_d_req			),	// output O_audio_d_req
	.O_validity_bit_req		(),									// output O_validity_bit_req
	.O_user_bit_req			(),									// output O_user_bit_req
	.O_chan_status_bit_req	(SPDIF_chan_status_bit_req		),	// output O_chan_status_bit_req
	.O_block_start_flag		(SPDIF_block_start_flag			),	// output O_block_start_flag
	.O_sub_frame0_flag		(SPDIF_O_sub_frame0_flag		),	// output O_sub_frame0_flag
	.O_sub_frame1_flag		(SPDIF_O_sub_frame1_flag		),	// output O_sub_frame1_flag
	.O_Spdif_tx_data		(o_SPDIF						) 	// output O_Spdif_tx_data
);

endmodule
`default_nettype wire
