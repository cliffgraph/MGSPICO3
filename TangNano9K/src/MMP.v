`default_nettype none
module msx_muse_premo (
	input	wire		i_RST_n,
	input	wire		i_CLK_3M58,			// 3.58MHz
	input	wire		i_CLK_3M072,		// 3.072MHz
// DAC(
	output	wire		o_DAC_WS,			// DAC // 0=Right-Ch, 1=Left-Ch
	output	wire		o_DAC_CLK,			// 
	output	wire		o_DAC1_L_R,			// I2S(16bit+16bit) L:PSG, Rt:SCC
	output	wire		o_DAC2_L_R,			// I2S(16bit+16bit) L:OPLL, R:OPLL+SCC+PSG
// SPI(Pico -> TangNano9K)
	input	wire		i_SPI_CS_n,
	input	wire		i_SPI_CLK,
	input	wire		i_SPI_MOSI,
	output	wire		o_WARN_FULLY,
// Control real chip.
	output	wire		o_PSG_CS_n,
	output	wire		o_OPLL_CS_n,
	output	wire		o_A0,
	output	wire[7:0]	o_ADDRDATA,
// COMM
	input	wire		i_UART_RX,
	output	wire		i_UART_TX,
// LED
	 output	wire		o_SPDIF,
// LED
	output	wire[5:0]	o_LED				// TangNano9K OnBoard LEDx6, `LOW=Turn-On
);

assign	o_LED = 6'b111111;

`define	HIGH	1'b1
`define	LOW		1'b0

//-----------------------------------------------------------------------
// CLOCK
//-----------------------------------------------------------------------
wire clk_17M9;
Gowin_OSC u_osc (
	.oscout		(clk_17M9)
);

wire clk_21M4;
Gowin_rPLL u_rPLL_x6(
	.clkout(clk_21M4),
	.clkin(i_CLK_3M58)
);

wire clk_SND_3M58	= i_CLK_3M58;		// for PSC/OPLL/IKASCC
wire clk_SND_21M4	= clk_21M4;			// for WTS(HRASCC)
wire clk_SYS		= clk_17M9;
wire clk_DAC		= clk_SYS;
wire clk_SPIRX		= clk_SYS;
wire clk_CONTROL	= clk_SYS;
wire clk_SPDIF		= i_CLK_3M072;

//-----------------------------------------------------------------------
// DATA BUS, CONTROL BUS
//-----------------------------------------------------------------------
wire[7:0]	bus_DATA;
wire		bus_A0;
wire		bus_IKASCC_CS_n;
wire		bus_IKASCC_WR_n;
wire[7:0]	bus_IKASCC_ABLO; 			//address bus low(AB7:0), for the SCC
wire[4:0]	bus_IKASCC_ABHI; 			//address bus high(AB15:11), for the mapper
wire		bus_PSG_CS_n;
wire		bus_OPLL_CS_n;

//-----------------------------------------------------------------------
// REAL CHIP CONTROL BUS
//-----------------------------------------------------------------------
assign	o_PSG_CS_n		= bus_PSG_CS_n;
assign	o_OPLL_CS_n		= bus_OPLL_CS_n;
assign	o_A0			= bus_A0;
assign	o_ADDRDATA		= bus_DATA;

//-----------------------------------------------------------------------
// UART
//-----------------------------------------------------------------------
assign i_UART_TX = i_UART_RX;

//-----------------------------------------------------------------------
// SCC(IKASCC)
//-----------------------------------------------------------------------
wire signed [10:0]	snd_IKASCC;

IKASCC #(
	.IMPL_TYPE(2),	// 2 : async,3.58MHz  
	.RAM_BLOCK(1)
) u_IKASCC (
	.i_EMUCLK		(clk_SND_3M58		),
	.i_MCLK_PCEN_n	(1'b0				),
	.i_RST_n		(i_RST_n			),
	.i_CS_n			(bus_IKASCC_CS_n	),
	.i_RD_n			(1'b1				),
	.i_WR_n			(bus_IKASCC_WR_n	),
	.i_ABLO			(bus_IKASCC_ABLO	),
	.i_ABHI			(bus_IKASCC_ABHI	),
	.i_DB			(bus_DATA			),
	.o_DB			(					),
	.o_DB_OE		(					),
	.o_ROMCS_n		(					),
	.o_ROMADDR		(					),
	.o_SOUND		(snd_IKASCC			),	// signed[10:0]
	.o_TEST			(					)
);

//-----------------------------------------------------------------------
// WTS(HRA!SCC)
//-----------------------------------------------------------------------
wire 				bus_WTS_CS_n;
wire 		[14:0]	bus_WTS_ADDR;
wire 		[10:0]	snd_WTS;

scc_for_mgspico3 u_WTS (
	.clk			(clk_SND_21M4	),
	.slot_nreset	(i_RST_n		),
	.slot_a			(bus_WTS_ADDR	),
	.slot_d			(bus_DATA		),
	.slot_nwr		(bus_WTS_CS_n	),
	.sound_out		(snd_WTS		)
);


//-----------------------------------------------------------------------
// PSG(ym2149_audio)
//-----------------------------------------------------------------------
wire signed		[13:0]	snd_PSG;
//
wire 				w_BC_PSG	= (!bus_PSG_CS_n) & (!bus_A0); 
wire 				w_BDIR_PSG	= (!bus_PSG_CS_n);

ym2149_audio u_Ym2149Audio (
	.clk_i			(clk_SND_3M58	),	//  in     std_logic -- system clock
	.en_clk_psg_i	(1'b1			),	//  in     std_logic -- PSG clock enable
	.sel_n_i		(1'b0			),	//  in     std_logic -- divide select, 0=clock-enable/2
	.reset_n_i		(i_RST_n		),	//  in     std_logic -- active low
	.bc_i			(w_BC_PSG		),	//  in     std_logic -- bus control
	.bdir_i			(w_BDIR_PSG		),	//  in     std_logic -- bus direction
	.data_i			(bus_DATA		),	//  in     std_logic_vector(7 downto 0)
	.data_r_o		(),					//  out    std_logic_vector(7 downto 0) -- registered output data
	.ch_a_o			(),					//  out    unsigned(11 downto 0)
	.ch_b_o			(),					//  out    unsigned(11 downto 0)
	.ch_c_o			(),					//  out    unsigned(11 downto 0)
	.mix_audio_o	(),					//  out    unsigned(13 downto 0)
	.pcm14s_o		(snd_PSG		)	//  out    unsigned(13 downto 0)
);

//-----------------------------------------------------------------------
// OPLL(IKAOPLL)
//-----------------------------------------------------------------------
wire	signed [15:0]	opll_sound;
wire	signed [4:0]	opll_movol;
wire	signed [4:0]	opll_rovol;

IKAOPLL #(
    .FULLY_SYNCHRONOUS          (1 ),
    .FAST_RESET                 (1 ),
    .ALTPATCH_CONFIG_MODE       (0 ),
    .USE_PIPELINED_MULTIPLIER   (1 )
) u_IKAOPLL (
	.i_XIN_EMUCLK			(clk_SND_3M58	), //emulator master clock, same as XIN
	.o_XOUT					(),
	.i_phiM_PCEN_n			(`LOW			), //phiM positive edge clock enable(negative logic)
	.i_IC_n					(i_RST_n		),
	.i_ALTPATCH_EN			(`LOW			),
	.i_CS_n					(bus_OPLL_CS_n	),
	.i_WR_n					(bus_OPLL_CS_n	),
	.i_A0					(bus_A0			),
	.i_D					(bus_DATA		),
	.o_D					(), 				//YM2413 uses only two LSBs
	.o_D_OE					(),
	.o_DAC_EN_MO			(),
	.o_DAC_EN_RO			(),
	.o_IMP_NOFLUC_SIGN		(),
	.o_IMP_NOFLUC_MAG		(),
	.o_IMP_FLUC_SIGNED_MO	(),					// signed [8:0]
	.o_IMP_FLUC_SIGNED_RO	(),					// signed [8:0]
    .i_ACC_SIGNED_MOVOL		(opll_movol		),
    .i_ACC_SIGNED_ROVOL		(opll_rovol		),
	.o_ACC_SIGNED_STRB		(),
	.o_ACC_SIGNED			(opll_sound		)	// signed [15:0]
);

//-----------------------------------------------------------------------
// MIXER
//-----------------------------------------------------------------------
wire signed [10:0] 	snd_WTS_w		= (11'h400 <= snd_WTS) ? snd_WTS-11'h400 : snd_WTS+11'h400;
wire signed [15:0]	snd_WTS_x		= {{5{snd_WTS_w[10]}}, snd_WTS_w} * 6'sd8;
wire signed [15:0]	snd_IKASCC_x	= {{5{snd_IKASCC[10]}}, snd_IKASCC} * 6'sd8;
wire signed [15:0]	snd_PSG_x		= snd_PSG / 2'sd2;
wire signed [15:0]	SOUND_SCC_y		= {snd_IKASCC, 5'b0};
wire signed [15:0]	SOUND_PSG_y	 	= {snd_PSG, 2'b0};
wire signed [15:0]	SOUND_OPLL_y	= opll_sound;
wire signed [15:0]	SOUND_ALL_y		= opll_sound + snd_IKASCC_x + snd_PSG_x + snd_WTS_x;

//-----------------------------------------------------------------------
// DAC
//-----------------------------------------------------------------------
wire signed [15:0]	SOUND_DAC_z;

MMP_cdc u_DacCdc (
	.i_RST_n	(i_RST_n		),
	.i_CLK_A	(clk_SND_3M58	),
	.i_DATA		(SOUND_ALL_y	),
	.i_CLK_B	(clk_DAC		),
	.o_DATA		(SOUND_DAC_z	)
);

MMP_dac u_Dac (
	.i_RST_n	(i_RST_n		),
	.i_CLK		(clk_DAC		),
	.i_SCC		(SOUND_SCC_y	),
	.i_PSG		(SOUND_PSG_y	),
	.i_OPLL		(SOUND_OPLL_y	),
	.i_ALL		(SOUND_DAC_z	),
	.o_DAC_WS	(o_DAC_WS		),
	.o_DAC_CLK	(o_DAC_CLK		),
	.o_DAC1_L_R	(o_DAC1_L_R		),
	.o_DAC2_L_R	(o_DAC2_L_R		)
);

//-----------------------------------------------------------------------
// S/PDIF Transmitter
//-----------------------------------------------------------------------
wire signed [15:0]	SOUND_SPDIF_z;
MMP_cdc u_SpdifCdc (
	.i_RST_n	(i_RST_n		),
	.i_CLK_A	(clk_SND_3M58	),
	.i_DATA		(SOUND_ALL_y	),
	.i_CLK_B	(clk_SPDIF	),
	.o_DATA		(SOUND_SPDIF_z	)
);

MMP_spdif u_spdif (
	.i_RST_n		(i_RST_n		),
	.i_CLK_SPDIF	(clk_SPDIF		),
	.i_SOUND		(SOUND_SPDIF_z	),
	.o_SPDIF		(o_SPDIF		)
);

//-----------------------------------------------------------------------
// FIFO BUFFER (SPIで受信した内容を保存するRAM）
//-----------------------------------------------------------------------
reg			fifo_push_s;
reg	[23:0]	fifo_push_dt;
wire		fifo_pop_s;
wire[23:0]	fifo_pop_dt;
wire		fifo_EMPTY;
wire		fifo_FULLY;

MMP_fifo u_MmpMemoryBuff (
	.i_RST_n		(i_RST_n		),
	.i_CLK			(clk_SYS		),
	.i_PUSH_S		(fifo_push_s	),
	.i_PUSH_DT		(fifo_push_dt	),		// wire[23:0]	
	.i_POP_S		(fifo_pop_s		),
	.o_POP_DT		(fifo_pop_dt	),		// reg[23:0]
	.o_EMPTY		(fifo_EMPTY		),
	.o_FULLY		(fifo_FULLY		)
);

assign	o_WARN_FULLY = fifo_FULLY;

//-----------------------------------------------------------------------
// SPI RX
//-----------------------------------------------------------------------
// 24bitを一単位として受信を行います。
// また、送信側は24bit毎に、CS(i_SPI_CS_n)を制御する必要があります
reg	[2:0]	spirx_buff_clk;
reg	[2:0]	spirx_buff_ena;
reg	[2:0]	spirx_buff_dat;
reg	[23:0]	spirx_rsv_data;
wire		spirx_clk_rise;
wire		spirx_ena_rise;
wire		spirx_shift;

// メタステーブル対策のための入力バッファ
always @(posedge clk_SPIRX) begin
	if (!i_RST_n) begin
		spirx_buff_clk <= 3'b111;
		spirx_buff_ena <= 3'b111;
		spirx_buff_dat <= 3'b000;
	end
	else begin
		spirx_buff_clk <= {spirx_buff_clk[1:0], i_SPI_CLK};
		spirx_buff_ena <= {spirx_buff_ena[1:0], i_SPI_CS_n};
		spirx_buff_dat <= {spirx_buff_dat[1:0], i_SPI_MOSI};
	end
end

// エッジ検出
assign spirx_clk_rise = (spirx_buff_clk[2:1] == 2'b01) ? `HIGH : `LOW;
assign spirx_ena_rise = (spirx_buff_ena[2:1] == 2'b01) ? `HIGH : `LOW;
assign spirx_shift = (spirx_clk_rise && !spirx_buff_ena[2]) ? `HIGH : `LOW;

// シリアルデータをパラレルデータに変換
always @(posedge clk_SPIRX) begin
	if (spirx_shift) begin
		spirx_rsv_data <= {spirx_rsv_data[22:0], spirx_buff_dat[2]};
	end
end

// 受信データをFIFOへ格納するする
always @(posedge clk_SPIRX) begin
	if (!i_RST_n) begin
		fifo_push_s <= `LOW;
	end
	else if (spirx_ena_rise) begin
		// RX BUFFER へ格納する
		fifo_push_s <= `HIGH;
		fifo_push_dt <= spirx_rsv_data;
	end
	else begin
		fifo_push_s <= `LOW;
	end
end

//-----------------------------------------------------------------------
// SOUND CONTROL
//-----------------------------------------------------------------------
MMP_control u_MmpControl (
	.i_RST_n		(i_RST_n			),
	.i_CLK			(clk_CONTROL		),
	.o_fifo_pop_s	(fifo_pop_s			),
	.i_fifo_pop_dt	(fifo_pop_dt		),
	.i_fifo_EMPTY	(fifo_EMPTY			),
	.o_DATA			(bus_DATA			),
	.o_A0			(bus_A0				),
	.o_IKASCC_CS_n	(bus_IKASCC_CS_n	),
	.o_IKASCC_WR_n	(bus_IKASCC_WR_n	),
	.o_IKASCC_ABLO	(bus_IKASCC_ABLO	),
	.o_IKASCC_ABHI	(bus_IKASCC_ABHI	),
	.o_WTS_CS_n		(bus_WTS_CS_n		),
	.o_WTS_ADDR		(bus_WTS_ADDR		),
	.o_PSG_CS_n		(bus_PSG_CS_n		),
	.o_OPLL_CS_n	(bus_OPLL_CS_n		),
	.o_OPLL_MOVOL	(opll_movol			),
	.o_OPLL_ROVOL	(opll_rovol			)
);

endmodule
`default_nettype wire

