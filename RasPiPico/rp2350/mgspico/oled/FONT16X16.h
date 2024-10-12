/*
* Copyright (c) 2024 Harumakkin.
*/
#pragma once
#ifdef __cplusplus
extern "C" {
#endif

extern const uint8_t FONT16X16_CHARBITMAP[] = {
	// '0', 16x16px
	0xf8, 0xfc, 0xfe, 0x0e, 0x0e, 0x06, 0x06, 0x06, 0x06, 0x06, 0x0e, 0x0e, 0xfe, 0xfc, 0xf8, 0x00, 
	0x3f, 0x7f, 0x7f, 0xe0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xe0, 0x7f, 0x7f, 0x3f, 0x00, 

	// '1', 16x16px
	0x00, 0x00, 0x00, 0x20, 0x70, 0x38, 0x1c, 0x0e, 0xfe, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 

	// '2', 16x16px
	0x00, 0x06, 0x06, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0xce, 0xfe, 0xfc, 0x78, 0x00, 
	0x7e, 0xff, 0xff, 0xc3, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc0, 0xc0, 0xc0, 0x00, 

	// '3', 16x16px
	0x06, 0x06, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0xce, 0xfc, 0xfc, 0x78, 0x00, 
	0xc0, 0xc0, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xe3, 0x7f, 0x3f, 0x3e, 0x00, 

	// '4', 16x16px
	0xfe, 0xfe, 0xfe, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0xfe, 0xfe, 0xfe, 0x00, 
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0xff, 0xff, 0x00, 

	// '5', 16x16px
	0x7e, 0xfe, 0xfe, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x06, 0x00, 0x00, 
	0xc0, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xe3, 0x7f, 0x7f, 0x3f, 0x00, 

	// '6', 16x16px
	0xfc, 0xfc, 0xfe, 0x8e, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x06, 0x00, 0x00, 
	0x7f, 0x7f, 0xff, 0xe1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xe3, 0x7f, 0x7f, 0x3f, 0x00, 

	// '7', 16x16px
	0x3e, 0x3e, 0x3e, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0xfe, 0xfe, 0xfe, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 

	// '8', 16x16px
	0x78, 0xfc, 0xfe, 0xce, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0xce, 0xfe, 0xfc, 0x78, 0x00, 
	0x3e, 0x7f, 0x7f, 0xe3, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xe3, 0x7f, 0x7f, 0x3e, 0x00, 

	// '9', 16x16px
	0x7c, 0xfc, 0xfe, 0xce, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0xce, 0xfe, 0xfc, 0xf8, 0x00, 
	0x00, 0xc0, 0xc0, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xe1, 0xff, 0x7f, 0x3f, 0x00, 

	// 'colon', 16x16px
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0x70, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x1c, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

#ifdef __cplusplus
}
#endif


// end of header
