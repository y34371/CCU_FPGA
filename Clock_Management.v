// file: Clock_Management.v
// 
// (c) Copyright 2008 - 2011 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
// "Output    Output      Phase     Duty      Pk-to-Pk        Phase"
// "Clock    Freq (MHz) (degrees) Cycle (%) Jitter (ps)  Error (ps)"
//----------------------------------------------------------------------------
// CLK_OUT1___200.000______0.000______50.0______300.000____150.000
// CLK_OUT2___100.000______0.000______50.0______200.000____150.000
// CLK_OUT3____10.000______0.000______50.0_____2200.000____150.000
//
//----------------------------------------------------------------------------
// "Input Clock   Freq (MHz)    Input Jitter (UI)"
//----------------------------------------------------------------------------
// __primary_________100.000____________0.010

`timescale 1ps/1ps

(* CORE_GENERATION_INFO = "Clock_Management,clk_wiz_v3_6,{component_name=Clock_Management,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,feedback_source=FDBK_AUTO,primtype_sel=DCM_SP,num_out_clk=3,clkin1_period=10.0,clkin2_period=10.0,use_power_down=false,use_reset=true,use_locked=true,use_inclk_stopped=false,use_status=true,use_freeze=false,use_clk_valid=false,feedback_type=SINGLE,clock_mgr_type=AUTO,manual_override=false}" *)
module Clock_Management
 (// Clock in ports
  input         CLK_IN,
  // Clock out ports
  output        CLK_200M,
  output        CLK_100M,
  output        CLK_10M,
  // Status and control signals
  input         RESET,
  output [2:0]  STATUS,
  output        LOCKED
 );

  // Input buffering
  //------------------------------------
  IBUFG clkin1_buf
   (.O (clkin1),
    .I (CLK_IN));


  // Clocking primitive
  //------------------------------------

  // Instantiation of the DCM primitive
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused
  wire        psdone_unused;
  wire        locked_int;
  wire [7:0]  status_int;
  wire clkfb;
  wire clk0;
  wire clk2x;
  wire clkfx;

  DCM_SP
  #(.CLKDV_DIVIDE          (10.000),
    .CLKFX_DIVIDE          (20),
    .CLKFX_MULTIPLY        (2),
    .CLKIN_DIVIDE_BY_2     ("FALSE"),
    .CLKIN_PERIOD          (10.0),
    .CLKOUT_PHASE_SHIFT    ("NONE"),
    .CLK_FEEDBACK          ("2X"),
    .DESKEW_ADJUST         ("SYSTEM_SYNCHRONOUS"),
    .PHASE_SHIFT           (0),
    .STARTUP_WAIT          ("FALSE"))
  dcm_sp_inst
    // Input clock
   (.CLKIN                 (clkin1),
    .CLKFB                 (clkfb),
    // Output clocks
    .CLK0                  (clk0),
    .CLK90                 (),
    .CLK180                (),
    .CLK270                (),
    .CLK2X                 (clk2x),
    .CLK2X180              (),
    .CLKFX                 (clkfx),
    .CLKFX180              (),
    .CLKDV                 (),
    // Ports for dynamic phase shift
    .PSCLK                 (1'b0),
    .PSEN                  (1'b0),
    .PSINCDEC              (1'b0),
    .PSDONE                (),
    // Other control and status signals
    .LOCKED                (locked_int),
    .STATUS                (status_int),
 
    .RST                   (RESET),
    // Unused pin- tie low
    .DSSEN                 (1'b0));

    assign LOCKED = locked_int;
    assign STATUS = status_int[2:0];

  // Output buffering
  //-----------------------------------
  BUFG clkf_buf
   (.O (clkfb),
    .I (clk2x));

  BUFG clkout1_buf
   (.O   (CLK_200M),
    .I   (clk2x));


  BUFG clkout2_buf
   (.O   (CLK_100M),
    .I   (clk0));

  BUFG clkout3_buf
   (.O   (CLK_10M),
    .I   (clkfx));



endmodule
