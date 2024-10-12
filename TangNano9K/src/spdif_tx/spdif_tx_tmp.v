//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9.03 (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Sat Sep 28 23:36:08 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	SPDIF_TX_Top your_instance_name(
		.I_clk(I_clk), //input I_clk
		.I_rst_n(I_rst_n), //input I_rst_n
		.I_audio_d(I_audio_d), //input [15:0] I_audio_d
		.I_validity_bit(I_validity_bit), //input I_validity_bit
		.I_user_bit(I_user_bit), //input I_user_bit
		.I_chan_status_bit(I_chan_status_bit), //input I_chan_status_bit
		.O_audio_d_req(O_audio_d_req), //output O_audio_d_req
		.O_validity_bit_req(O_validity_bit_req), //output O_validity_bit_req
		.O_user_bit_req(O_user_bit_req), //output O_user_bit_req
		.O_chan_status_bit_req(O_chan_status_bit_req), //output O_chan_status_bit_req
		.O_block_start_flag(O_block_start_flag), //output O_block_start_flag
		.O_sub_frame0_flag(O_sub_frame0_flag), //output O_sub_frame0_flag
		.O_sub_frame1_flag(O_sub_frame1_flag), //output O_sub_frame1_flag
		.O_Spdif_tx_data(O_Spdif_tx_data) //output O_Spdif_tx_data
	);

//--------Copy end-------------------
