`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:54:37 11/07/2018 
// Design Name: 
// Module Name:    Top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Top(
	input RESET,
	input CLK_IN,
	output LED1,
	output LED2,
	 
	input [13:0] Addr,
	inout [15:0] Data,
	input CSn,
	input WEn,
	input OEn,
	
	input [3:0] capture,
	
	input [15:0] DSP_PWM_IN,
	output [15:0] DSP_PWM_OUT,
//	output [7:0] Relay,
//	output [3:0] Light,
	
	input [7:0] FAULT_INPUT,
	output FAULT_XINT
//	input RNW,
//	output Wait,
		
	
	
//		output Adc_Dout_1,
//		input Adc_Din_1,
//		output Adc_CSn_1,
//		output Adc_Dout_2,
//		input Adc_Din_2,
//		output Adc_CSn_2,
//		output Adc_Sclk,
//		output Adc_Rst
   );
	
//	wire [3:0] Light;
//	assign Light = 4'b1111;
	assign FAULT_XINT = FAULT_INPUT[0] & FAULT_INPUT[1];
	 
	wire CLK;
	wire CLK_100M;
	wire CLK_10M;
	wire [2:0] CLK_STATUS;
	wire CLK_LOCKED;
	
	Clock_Management CLK_Management
   (
    .CLK_IN(CLK_IN),
    .CLK_200M(CLK),
    .CLK_100M(CLK_100M),
    .CLK_10M(CLK_10M),
    .RESET(RESET),
    .STATUS(STATUS),
    .LOCKED(LOCKED));
	 
	reg [15:0] data_out_buf; 
	assign Data = (!CSn && !OEn) ? data_out_buf :16'bzzzz_zzzz_zzzz_zzzz;
	
	assign DSP_PWM_OUT = DSP_PWM_IN;

//	reg [15:0] DSP_PWM_OUT;
//	always@(posedge CLK)
//	begin
//		if(RESET)
//			DSP_PWM_OUT <= 16'h0000;
//		else if(!CSn && !WEn && (Addr == 14'h0015))
//			DSP_PWM_OUT <= Data;
//		else
//			DSP_PWM_OUT <= DSP_PWM_OUT;
//	end

	// LED2 Test
	reg [31:0] led_counter;
	always@(posedge CLK)
	begin
		if(RESET)
			led_counter <= 0;
		else if(led_counter >= 199999999)
			led_counter <= 0;
		else
			led_counter <= led_counter + 1;
	end

	reg led_test;
	assign LED2 = led_test;
	always@(posedge CLK)
	begin
		if(led_counter >= 199999999)
			led_test <= ~led_test;
		else
			led_test <= led_test;
	end
	
	// Output register 1
	reg [15:0] OUT_REG_1;
	assign LED1 = OUT_REG_1[0];
	
	always@(posedge CLK)
	begin
		if(RESET)
			OUT_REG_1 <= 16'h0000;
		else if(!CSn && !WEn && (Addr == 14'h0010))
			OUT_REG_1 <= Data;
		else
			OUT_REG_1 <= OUT_REG_1;
	end
	
	
	// Relay register
	reg [15:0] RELAY_REG;
//	assign Relay = RELAY_REG[7:0];

	// Capture Unit
	
	reg cap_pos_event;
	reg [15:0] cap_counter;
	always@(posedge CLK)
	begin
		if(cap_pos_event)
			cap_counter <= 0;
		else
			cap_counter <= cap_counter + 1;
	end
	
	reg [3:0] capture_sample;
	always@(posedge CLK)
	begin
		capture_sample <= capture;
	end
	
	always@(posedge CLK)
	begin
		if(capture[0] && (~capture_sample[0]))
			cap_pos_event <= 1;
		else
			cap_pos_event <= 0;
	end
	
	reg cap_neg_event;
	always@(posedge CLK)
	begin
		if((~capture[0]) && capture_sample[0])
			cap_neg_event <= 1;
		else
			cap_neg_event <= 0;
	end
	
	reg [15:0] cap_stamp_1_z1;
	reg [15:0] cap_stamp_1_z0;
	reg [15:0] cap_prd;
	reg [15:0] cap_pos;
	always@(posedge CLK)
	begin
		if(cap_pos_event)
		begin
			cap_stamp_1_z1 <= cap_stamp_1_z0;
			cap_stamp_1_z0 <= cap_counter;
			cap_prd <= cap_stamp_1_z0 - cap_stamp_1_z1;
			cap_pos <= cap_stamp_2_z0 - cap_stamp_1_z1;
		end
	end
	
	reg [15:0] cap_stamp_2_z1;
	reg [15:0] cap_stamp_2_z0;
	always@(posedge CLK)
	begin
		if(cap_neg_event)
		begin
			cap_stamp_2_z1 <= cap_stamp_2_z0;
			cap_stamp_2_z0 <= cap_counter;
		end
	end
	
	always@(posedge CLK)
	begin
		if(RESET)
			RELAY_REG <= 16'h0000;
		else if(!CSn && !WEn && (Addr == 14'h0040))
			RELAY_REG <= Data;
		else
			RELAY_REG <= RELAY_REG;
	end
	
	// FPGA Status register 1
	reg [15:0] STATUS_REG_1;
	always@(posedge CLK)
	begin
		STATUS_REG_1 <= {8'b0100_0000,FAULT_XINT,CLK_STATUS[2:0],CLK_LOCKED,LED2,LED1,RESET};
	end
	
	always@(posedge CLK)
	begin
		if(RESET)
			data_out_buf <= 16'h0000;
		else if(!CSn && !OEn)
			case (Addr)
				14'h0010: data_out_buf <= OUT_REG_1;
				14'h0015: data_out_buf <= DSP_PWM_OUT;
				14'h0020: data_out_buf <= STATUS_REG_1;
				14'h0021: data_out_buf <= FAULT_INPUT;
				14'h0040: data_out_buf <= RELAY_REG;
				14'h0050: data_out_buf <= cap_stamp_1_z1;
				14'h0051: data_out_buf <= cap_stamp_1_z0;
				14'h0052: data_out_buf <= cap_stamp_2_z1;
				14'h0053: data_out_buf <= cap_stamp_2_z0;
				14'h0054: data_out_buf <= cap_prd;
				14'h0055: data_out_buf <= cap_pos;
				
				default:  data_out_buf <= data_out_buf;
			endcase
		else
			data_out_buf <= 0;
	end	
	
//	wire SOC;
//	wire BUSY;
//	wire Adc_Rst;
//	assign Adc_Rst = 1;
//	
//	assign SOC = OUT_REG_1[4];
//	
//	// Instantiate the module
//	Ext_ADC Ext_Adc_module (
//    .RESET(RESET), 
//    .CLK(CLK_10M), 
//    .SOC(SOC), 
//    .BUSY(BUSY), 
//    .SCLK(Adc_Sclk), 
//    .DIN1(Adc_Din_1), 
//    .DOUT1(Adc_Dout_1), 
//    .CS1(Adc_CSn_1), 
//    .CS2(Adc_CSn_2), 
//    .Addr(Addr), 
//    .Data(Data), 
//    .CSn(CSn), 
//    .WEn(WEn), 
//    .OEn(OEn)
//    );
	 
endmodule
