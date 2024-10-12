//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.9.03 (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Fri Aug  2 00:11:23 2024

module Gowin_OSC (
	output oscout
);

OSC osc_inst (
    .OSCOUT(oscout)
);

defparam osc_inst.FREQ_DIV = 14;	// 250/14 => 17.9MHz 
defparam osc_inst.DEVICE = "GW1NR-9C";

endmodule //Gowin_OSC
