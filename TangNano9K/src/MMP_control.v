`default_nettype none
module MMP_control (
	input	wire				i_RST_n,
	input	wire				i_CLK,
	//
	output	reg					o_fifo_pop_s,
	input	wire [23:0]			i_fifo_pop_dt,
	input	wire				i_fifo_EMPTY,
	//
	output	reg [7:0]			o_DATA,
	output	reg					o_A0,
	//
	output	reg					o_IKASCC_CS_n,
	output	reg					o_IKASCC_WR_n,
	output	reg [7:0]			o_IKASCC_ABLO, 			//address bus low(AB7:0), for the SCC
	output	reg [4:0]			o_IKASCC_ABHI, 			//address bus high(AB15:11), for the mapper
	//
	output	reg					o_WTS_CS_n,
	output	reg [14:0]			o_WTS_ADDR,
	//
	output	reg					o_PSG_CS_n,
	output	reg					o_OPLL_CS_n,
	output	reg signed [4:0]	o_OPLL_MOVOL,
	output	reg signed [4:0]	o_OPLL_ROVOL
);

parameter [19:0] VSYNC_TIKSC	= 19'd297619;	// 297619tikcs = 1/60[sec], by i_CLK
reg	[19:0]	ff_vsync_tick_cnt;					// VSYNC_TIKSC、までカウントアップする。
reg	[23:0]	ff_poped_dt;
reg	[15:0]	ff_wait_cnt;
reg [7:0]	ff_scc_module;
//
reg [4:0]	ff_STS;					// 状態遷移管理
parameter STS_IDLE 			= 5'd0;
parameter STS_FETCH1		= 5'd1;
parameter STS_FETCH2		= 5'd2;
parameter STS_PROC 			= 5'd3;
parameter STS_PSG_A 		= 5'd4;		// アドレスセット
parameter STS_PSG_AW1 		= 5'd5;		// アドレスセット後のウェイト
parameter STS_PSG_AW2 		= 5'd6;		// アドレスセット後のウェイト
parameter STS_PSG_D 		= 5'd7;		// データセット
parameter STS_PSG_DW1 		= 5'd8;		// データセット後のウェイト
parameter STS_PSG_DW2 		= 5'd9;		// データセット後のウェイト
parameter STS_OPLL_A 		= 5'd10;	// アドレスセット
parameter STS_OPLL_AW1 		= 5'd11;	// アドレスセット後のウェイト
parameter STS_OPLL_AW2 		= 5'd12;	// アドレスセット後のウェイト
parameter STS_OPLL_D 		= 5'd13;	// データセット
parameter STS_OPLL_DW1 		= 5'd14;	// データセット後のウェイト
parameter STS_OPLL_DW2 		= 5'd15;	// データセット後のウェイト
parameter STS_IKASCC_AD 	= 5'd16;	// アドレス＆データセット
parameter STS_IKASCC_ADW1	= 5'd17;	// ウェイト
parameter STS_IKASCC_ADW2	= 5'd18;	// ウェイト
parameter STS_IKASCC_ADW3 	= 5'd19;	// ウェイト WR H
parameter STS_IKASCC_ADW4 	= 5'd20;	// ウェイト CS H
parameter STS_WTS_AD 		= 5'd21;	// アドレス＆データセット
parameter STS_WTS_ADW1		= 5'd22;	// ウェイト
parameter STS_WTS_ADW2		= 5'd23;	// ウェイト
parameter STS_VSYNC_WAIT	= 5'd24;	// VSYNC期間分の時間
parameter STS_OPLL_MOVOL	= 5'd25;	// MOVOLの設定
parameter STS_OPLL_ROVOL	= 5'd26;	// ROVOLの設定
parameter STS_SCC_MODULE	= 5'd27;	// SCCモジュール選択

always @(posedge i_CLK) begin
	if( !i_RST_n ) begin
		o_fifo_pop_s <= `LOW;
		ff_STS <= STS_IDLE;
		ff_wait_cnt <= 16'd0;
		ff_vsync_tick_cnt <= 19'd0;
		o_PSG_CS_n <= `HIGH;
		o_OPLL_CS_n <= `HIGH;
		o_IKASCC_CS_n <= `HIGH;
		o_IKASCC_WR_n <= `HIGH;
		o_WTS_CS_n <= `HIGH;
		o_WTS_ADDR <= 15'd0;
		o_OPLL_MOVOL <= 5'sd4;
		o_OPLL_ROVOL <= -5'sd6;
		ff_scc_module <= 8'd0;	// default SCC is IKASCC(0x00).
//		ff_scc_module <= 8'd1;
	end
	else begin
		if( ff_vsync_tick_cnt < VSYNC_TIKSC) begin 
			ff_vsync_tick_cnt <= ff_vsync_tick_cnt + 19'd1;
		end
		case (ff_STS)
			// アイドル状態。バッファにコマンドが有ればそれを要求する
			STS_IDLE: begin
				if( !i_fifo_EMPTY) begin
					o_fifo_pop_s <= `HIGH;
					ff_STS <= STS_FETCH1;
				end
			end
			STS_FETCH1: begin
				o_fifo_pop_s <= `LOW;
				ff_STS <= STS_FETCH2;
			end
			// バッファからコマンドを受け取る > ff_poped_dt
			STS_FETCH2: begin
				ff_poped_dt <= i_fifo_pop_dt;
				ff_STS <= STS_PROC;
			end
			// コマンドを解析し、音源ごとの状態へ遷移する
			STS_PROC: begin
				case(ff_poped_dt[23:19]) 
					5'b00010:	ff_STS <= STS_VSYNC_WAIT;
					5'b10001:	ff_STS <= STS_PSG_A;
					5'b10010:	ff_STS <= STS_OPLL_A;
					5'b10011:	ff_STS <= (ff_scc_module==8'd0)?STS_IKASCC_AD:STS_WTS_AD;
					5'b11000:	ff_STS <= STS_OPLL_MOVOL;
					5'b11001:	ff_STS <= STS_OPLL_ROVOL;
					5'b11010:	ff_STS <= STS_SCC_MODULE;
					default: begin
						ff_STS <= STS_IDLE;		// 不明コマンドはアイドル状態へ戻る
					end
				endcase
			end
			// PSG --------------------------------------------
			STS_PSG_A: begin
				o_A0 <= 1'b0;	// ADDRESS
				o_DATA[7:0] <= ff_poped_dt[15:8];
				ff_STS <= STS_PSG_AW1;
				ff_wait_cnt <= 16'd0;
			end
			STS_PSG_AW1: begin
				o_PSG_CS_n <= `LOW;
				if( 16'd19 < ff_wait_cnt ) begin
					ff_STS <= STS_PSG_AW2;
					ff_wait_cnt <= 16'd0;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			STS_PSG_AW2: begin
				o_PSG_CS_n <= `HIGH;
				// 約1usのウェイト経過後に、次へ遷移する
				ff_wait_cnt <= ff_wait_cnt + 16'd1;
				if( 16'd19 < ff_wait_cnt ) 
					ff_STS <= STS_PSG_D;
			end
			STS_PSG_D: begin
				o_A0 <= 1'b1;	// DATA
				o_DATA[7:0] <= ff_poped_dt[7:0];
				ff_STS <= STS_PSG_DW1;
				ff_wait_cnt <= 16'd0;
			end
			STS_PSG_DW1: begin
				o_PSG_CS_n <= `LOW;
				if( 16'd19 < ff_wait_cnt ) begin
					ff_STS <= STS_PSG_DW2;
					ff_wait_cnt <= 16'd0;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			STS_PSG_DW2: begin
				o_PSG_CS_n <= `HIGH;
				// 約1usのウェイト経過後に、次へ遷移する
				ff_wait_cnt <= ff_wait_cnt + 16'd1;
				if( 16'd19 < ff_wait_cnt ) 
					ff_STS <= STS_IDLE;
			end
			// OPLL -------------------------------------------
			STS_OPLL_A: begin
				o_A0 <= 1'b0;	// ADDRESS
				o_DATA[7:0] <= ff_poped_dt[15:8];
				ff_STS <= STS_OPLL_AW1;
				ff_wait_cnt <= 16'd0;
			end
			STS_OPLL_AW1: begin
				o_OPLL_CS_n <= `LOW;
				if( 16'd19 < ff_wait_cnt ) begin
					ff_STS <= STS_OPLL_AW2;
					ff_wait_cnt <= 16'd0;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			STS_OPLL_AW2: begin
				o_OPLL_CS_n <= `HIGH;
				// 約3.36usのウェイト経過後に、次へ遷移する
				ff_wait_cnt <= ff_wait_cnt + 16'd1;
				if( 16'd64 < ff_wait_cnt ) 
					ff_STS <= STS_OPLL_D;
			end
			STS_OPLL_D: begin
				o_A0 <= 1'b1;	// DATA
				o_DATA[7:0] <= ff_poped_dt[7:0];
				ff_STS <= STS_OPLL_DW1;
				ff_wait_cnt <= 16'd0;
			end
			STS_OPLL_DW1: begin
				o_OPLL_CS_n <= `LOW;
				if( 16'd19 < ff_wait_cnt ) begin
					ff_STS <= STS_OPLL_DW2;
					ff_wait_cnt <= 16'd0;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			STS_OPLL_DW2: begin
				o_OPLL_CS_n <= `HIGH;
				// 約23.52usのウェイト経過後に、次へ遷移する
				ff_wait_cnt <= ff_wait_cnt + 16'd1;
				if( 16'd447 < ff_wait_cnt ) 
					ff_STS <= STS_IDLE;
			end
			// IKASCC -------------------------------------------
			STS_IKASCC_AD: begin
				o_DATA <= ff_poped_dt[7:0];
				o_IKASCC_ABLO	<= ff_poped_dt[15:8];
				case( ff_poped_dt[18:16] )
					3'b000: o_IKASCC_ABHI <= 5'b10010; // 0x9000
					3'b001: o_IKASCC_ABHI <= 5'b10011; // 0x9800
					3'b010: o_IKASCC_ABHI <= 5'b00000; // 0xb800(reserved for SCC+)
					3'b011: o_IKASCC_ABHI <= 5'b00000; // 0xbf00(reserved for SCC+)
					3'b100: o_IKASCC_ABHI <= 5'b00000; // 0xb000(reserved for SCC+)
					default:o_IKASCC_ABHI <= 5'b00000; 
				endcase
				ff_wait_cnt <= 16'd0;
				ff_STS <= STS_IKASCC_ADW1;
			end
			STS_IKASCC_ADW1: begin
				o_IKASCC_CS_n <= `LOW;
				// 約224nsのウェイト経過後に、次へ遷移する
				if( 16'd4 < ff_wait_cnt ) begin
					ff_STS <= STS_IKASCC_ADW2;
					ff_wait_cnt <= 16'd0;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			STS_IKASCC_ADW2: begin
				o_IKASCC_WR_n <= `LOW;
				// 約259nsのウェイト経過後に、次へ遷移する
				if( 16'd5 < ff_wait_cnt ) begin
					ff_STS <= STS_IKASCC_ADW3;
					ff_wait_cnt <= 16'd0;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			STS_IKASCC_ADW3: begin
				o_IKASCC_WR_n <= `HIGH;
				// 約65nsのウェイト経過後に、次へ遷移する
				if( 16'd2 < ff_wait_cnt ) begin
					ff_STS <= STS_IKASCC_ADW4;
					ff_wait_cnt <= 16'd0;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			STS_IKASCC_ADW4: begin
				o_IKASCC_CS_n <= `HIGH;
				// 約1usのウェイト経過後に、次へ遷移する
				ff_wait_cnt <= ff_wait_cnt + 16'd1;
				if( 16'd18 < ff_wait_cnt ) 
					ff_STS <= STS_IDLE;
			end
			// WTS(HRA!SCC) -------------------------------------------
			STS_WTS_AD: begin
				o_DATA <= ff_poped_dt[7:0];
				case( ff_poped_dt[18:16] )
					3'b000: o_WTS_ADDR <= {3'b001, 4'b0000, ff_poped_dt[15:8]}; // 0x9000
					3'b001: o_WTS_ADDR <= {3'b001, 4'b1000, ff_poped_dt[15:8]}; // 0x9800
					3'b010: o_WTS_ADDR <= {3'b011, 4'b1000, ff_poped_dt[15:8]}; // 0xb800 (for SCC+)
					3'b011: o_WTS_ADDR <= {3'b011, 4'b1111, ff_poped_dt[15:8]}; // 0xbf00 (for SCC+)
					3'b100: o_WTS_ADDR <= {3'b011, 4'b0000, ff_poped_dt[15:8]}; // 0xb000 (for SCC+)
					default:o_WTS_ADDR <= 15'd0; 
				endcase
				ff_wait_cnt <= 16'd0;
				ff_STS <= STS_WTS_ADW1;
			end
			STS_WTS_ADW1: begin
				o_WTS_CS_n <= `LOW;
				if( 16'd18 < ff_wait_cnt ) begin
					ff_STS <= STS_WTS_ADW2;
					ff_wait_cnt <= 16'd0;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			STS_WTS_ADW2: begin
				o_WTS_CS_n <= `HIGH;
				if( 16'd18 < ff_wait_cnt ) begin
					ff_STS <= STS_IDLE;
				end
				else begin
					ff_wait_cnt <= ff_wait_cnt + 16'd1;
				end
			end
			// -----------------------------------------------
			STS_VSYNC_WAIT: begin
				// // VSYNC_TIKSCまでカウントアップされるまで本状態を維持する
				// if( ff_vsync_tick_cnt == VSYNC_TIKSC) begin 
				// 	ff_vsync_tick_cnt <= 19'd0;
				// 	ff_STS <= STS_IDLE;
				// end
				//
				// ↑Pico側がVSYNC分の時間をおいて送信しているので、
				// 現バージョンはコメント化して本機能は使用しないこととする
				//
				ff_STS <= STS_IDLE;
			end
			STS_OPLL_MOVOL: begin
				o_OPLL_MOVOL <= ff_poped_dt[4:0];
				ff_STS <= STS_IDLE;
			end
			STS_OPLL_ROVOL: begin
				o_OPLL_ROVOL <= ff_poped_dt[4:0];
				ff_STS <= STS_IDLE;
			end
			STS_SCC_MODULE: begin
				ff_scc_module <= ff_poped_dt[7:0];
				ff_STS <= STS_IDLE;
			end
		endcase
	end
end



endmodule
`default_nettype wire