`timescale 1ns / 1ps

module   mgt_control #(
  parameter TMR_INSTANCE         = 0,
  parameter FPGA_TYPE_IS_VIRTEX6 = 0,
  parameter FPGA_TYPE_IS_ARTIX7  = 0,
  parameter ALLOW_TTC_CHARS      = 1,
  parameter ALLOW_RETRY          = 0,
  parameter FRAME_CTRL_TTC       = 1

)
(

  input mgt_startup_done,

  input       ext_pll_reset_i,
  input [3:0] ext_mgt_reset_i,
  input       ext_gtxtest_start_i,
  input       ext_txreset_i,
  input       ext_mgt_realign_i,
  input       ext_txpowerdown_i,
  input [1:0] ext_txpowerdown_mode_i,
  input       ext_txpllpowerdown_i,

  output       pll_reset_o,
  output [3:0] mgt_reset_o,
  output       txreset_o,
  output       mgt_realign_o,
  output       txpowerdown_o,
  output [1:0] txpowerdown_mode_o,
  output       txpllpowerdown_o,
  output       gtxtest_reset_o,
  output       ready_o,

  input clock_40,
  input clock_160,

  input force_not_ready,

  input reset_i
);

  //--------------------------------------------------------------------------------------------------------------------
  // Ready Timer
  //--------------------------------------------------------------------------------------------------------------------

  parameter READY_CNT_MAX = 2**18-1;
  parameter READY_BITS    = $clog2 (READY_CNT_MAX);
  reg [READY_BITS-1:0] ready_cnt = 0;

  always @ (posedge clock_40) begin
    if (~mgt_startup_done || force_not_ready)
      ready_cnt <= 0;
    else if (ready_cnt < READY_CNT_MAX)
      ready_cnt <= ready_cnt + 1'b1;
    else
      ready_cnt <= ready_cnt;
  end

  assign ready_o = (ready_cnt == READY_CNT_MAX);

  //--------------------------------------------------------------------------------------------------------------------
  // Retry
  //--------------------------------------------------------------------------------------------------------------------

  wire startup_done;
  wire retry = (ALLOW_RETRY && startup_done && !mgt_startup_done);

  //--------------------------------------------------------------------------------------------------------------------
  // Startup
  //--------------------------------------------------------------------------------------------------------------------

  parameter STARTUP_RESET_CNT_MAX = 2**22-1;
  parameter STARTUP_RESET_BITS    = $clog2 (STARTUP_RESET_CNT_MAX);

  reg [STARTUP_RESET_BITS-1:0] startup_reset_cnt = 0;

  always @ (posedge clock_40) begin
    if (reset_i || retry)
      startup_reset_cnt <= 0;
    else if (startup_reset_cnt < STARTUP_RESET_CNT_MAX)
      startup_reset_cnt <= startup_reset_cnt + 1'b1;
    else
      startup_reset_cnt <= startup_reset_cnt;
  end


  parameter STABLE_CLOCK_PERIOD = 25;

  `ifdef XILINX_ISIM
    parameter DONT_SUPRESS_STARTUP=0;
  `else
    parameter DONT_SUPRESS_STARTUP=1;
  `endif

  parameter MGT_RESET_CNT0    = DONT_SUPRESS_STARTUP * 4000   * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter MGT_RESET_CNT1    = DONT_SUPRESS_STARTUP * 8000   * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter MGT_RESET_CNT2    = DONT_SUPRESS_STARTUP * 12000  * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter MGT_RESET_CNT3    = DONT_SUPRESS_STARTUP * 14000  * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter PLL_RESET_CNT     = DONT_SUPRESS_STARTUP * 0      * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter PLL_POWERDOWN_CNT = DONT_SUPRESS_STARTUP * 0      * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter TXPOWERDOWN_CNT   = DONT_SUPRESS_STARTUP * 0      * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter GTXTEST_RESET_CNT = DONT_SUPRESS_STARTUP * 16000  * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter TXRESET_CNT       = DONT_SUPRESS_STARTUP * 18000  * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter MGT_REALIGN_CNT   = DONT_SUPRESS_STARTUP * 0      * 1000 / STABLE_CLOCK_PERIOD; // usec
  parameter DONE_CNT          = DONT_SUPRESS_STARTUP * 30000  * 1000 / STABLE_CLOCK_PERIOD; // usec

  assign pll_reset_o    = ext_pll_reset_i      || (startup_reset_cnt <  PLL_RESET_CNT);
  assign mgt_reset_o[0] = ext_mgt_reset_i[0]   || (startup_reset_cnt <  MGT_RESET_CNT0);
  assign mgt_reset_o[1] = ext_mgt_reset_i[1]   || (startup_reset_cnt <  MGT_RESET_CNT1);
  assign mgt_reset_o[2] = ext_mgt_reset_i[2]   || (startup_reset_cnt <  MGT_RESET_CNT2);
  assign mgt_reset_o[3] = ext_mgt_reset_i[3]   || (startup_reset_cnt <  MGT_RESET_CNT3);
  wire gtxtest_start    = ext_gtxtest_start_i  || (startup_reset_cnt == GTXTEST_RESET_CNT);
  wire txreset_o        = ext_txreset_i        || (startup_reset_cnt == TXRESET_CNT);
  wire mgt_realign_o    = ext_mgt_realign_i    || (startup_reset_cnt == MGT_REALIGN_CNT);
  wire txpowerdown_o    = ext_txpowerdown_i    || (startup_reset_cnt <  TXPOWERDOWN_CNT);
  wire txpllpowerdown_o = ext_txpllpowerdown_i || (startup_reset_cnt <  PLL_POWERDOWN_CNT);

  wire [1:0] txpowerdown_mode = {2{txpowerdown_o}} & ext_txpowerdown_mode_i;

  assign startup_done   = (startup_reset_cnt >  DONE_CNT);

  reg [9:0] gtxtest_cnt=1023;
  always @ (posedge clock_40) begin
    if (gtxtest_start)
      gtxtest_cnt <= 0;
    else if (gtxtest_cnt < 1023)
      gtxtest_cnt <= gtxtest_cnt + 1'b1;
    else
      gtxtest_cnt <= gtxtest_cnt;
  end

  assign gtxtest_reset_o = (gtxtest_cnt > 0 && gtxtest_cnt < 256) || (gtxtest_cnt > 511 && gtxtest_cnt < 768);

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------

