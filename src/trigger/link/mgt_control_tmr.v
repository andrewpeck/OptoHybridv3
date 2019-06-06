`timescale 1ns / 1ps

module   mgt_control_tmr #(
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
  output       gtxtest_start_o,
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

  genvar I;
  generate
  for (I=0; I<3; I=I+1'b1) begin  : tmrloop
  mgt_control #(
    .TMR_INSTANCE         (I),
    .FPGA_TYPE_IS_VIRTEX6 (FPGA_TYPE_IS_VIRTEX6),
    .FPGA_TYPE_IS_ARTIX7  (FPGA_TYPE_IS_ARTIX7 ),
    .ALLOW_TTC_CHARS      (ALLOW_TTC_CHARS     ),
    .ALLOW_RETRY          (ALLOW_RETRY         ),
    .FRAME_CTRL_TTC       (FRAME_CTRL_TTC      )
  ) mgt_control (
    .clock_40  (clock_40),
    .clock_160 (clock_160),

    .mgt_startup_done  (mgt_startup_done),
    .reset_i           (reset_i),

    // ipbus control inputs
    .force_not_ready        (force_not_ready),
    .ext_pll_reset_i        (ext_pll_reset_i        ),
    .ext_mgt_reset_i        (ext_mgt_reset_i        ),
    .ext_gtxtest_start_i    (ext_gtxtest_start_i    ),
    .ext_txreset_i          (ext_txreset_i          ),
    .ext_mgt_realign_i      (ext_mgt_realign_i      ),
    .ext_txpowerdown_i      (ext_txpowerdown_i      ),
    .ext_txpowerdown_mode_i (ext_txpowerdown_mode_i ),
    .ext_txpllpowerdown_i   (ext_txpllpowerdown_i   ),

    // outputs
    .gtxtest_reset_o    (gtxtest_reset_tmr    [I]),
    .mgt_realign_o      (mgt_realign_tmr      [I]),
    .mgt_reset_o        (mgt_reset_tmr        [I]),
    .pll_reset_o        (pll_reset_tmr        [I]),
    .txpllpowerdown_o   (txpllpowerdown_tmr   [I]),
    .txpowerdown_mode_o (txpowerdown_mode_tmr [I]),
    .txpowerdown_o      (txpowerdown_tmr      [I]),
    .txreset_o          (txreset_tmr          [I]),
    .ready_o            (ready_tmr            [I])
  ) ;
  end
  endgenerate

(* DONT_TOUCH = "true" *)   wire [2:0] gtxtest_reset_tmr;
(* DONT_TOUCH = "true" *)   wire [2:0] gtxtest_start_tmr;
(* DONT_TOUCH = "true" *)   wire [2:0] mgt_realign_tmr;
(* DONT_TOUCH = "true" *)   wire [3:0] mgt_reset_tmr [2:0];
(* DONT_TOUCH = "true" *)   wire [2:0] pll_reset_tmr;
(* DONT_TOUCH = "true" *)   wire [1:0] txpowerdown_mode_tmr [2:0];
(* DONT_TOUCH = "true" *)   wire [2:0] txpllpowerdown_tmr;
(* DONT_TOUCH = "true" *)   wire [2:0] txpowerdown_tmr;
(* DONT_TOUCH = "true" *)   wire [2:0] txreset_tmr;
(* DONT_TOUCH = "true" *)   wire [2:0] ready_tmr;

  majority #(.g_NUM_BITS(1)) majority_gtxtest_reset (
    .a (gtxtest_reset_tmr[0]),
    .b (gtxtest_reset_tmr[1]),
    .c (gtxtest_reset_tmr[2]),
    .y (gtxtest_reset_o)
  );
  majority #(.g_NUM_BITS(1)) majority_gtxtest_start (
    .a (gtxtest_start_tmr[0]),
    .b (gtxtest_start_tmr[1]),
    .c (gtxtest_start_tmr[2]),
    .y (gtxtest_start_o)
  );
  majority #(.g_NUM_BITS(1)) majority_mgt_realign (
    .a (mgt_realign_tmr[0]),
    .b (mgt_realign_tmr[1]),
    .c (mgt_realign_tmr[2]),
    .y (mgt_realign_o)
  );
  majority #(.g_NUM_BITS(1)) majority_pll_reset (
    .a (pll_reset_tmr[0]),
    .b (pll_reset_tmr[1]),
    .c (pll_reset_tmr[2]),
    .y (pll_reset_o)
  );
  majority #(.g_NUM_BITS(3)) majority_txpowerdown_mode (
    .a (txpowerdown_mode_tmr[0]),
    .b (txpowerdown_mode_tmr[1]),
    .c (txpowerdown_mode_tmr[2]),
    .y (txpowerdown_mode_o)
  );
  majority #(.g_NUM_BITS(1)) majority_txpllpowerdown (
    .a (txpllpowerdown_tmr[0]),
    .b (txpllpowerdown_tmr[1]),
    .c (txpllpowerdown_tmr[2]),
    .y (txpllpowerdown_o)
  );
  majority #(.g_NUM_BITS(1)) majority_txpowerdown (
    .a (txpowerdown_tmr[0]),
    .b (txpowerdown_tmr[1]),
    .c (txpowerdown_tmr[2]),
    .y (txpowerdown_o)
  );
  majority #(.g_NUM_BITS(4)) majority_mgt_reset (
    .a (mgt_reset_tmr[0]),
    .b (mgt_reset_tmr[1]),
    .c (mgt_reset_tmr[2]),
    .y (mgt_reset_o)
  );
  majority #(.g_NUM_BITS(1)) majority_txreset (
    .a (txreset_tmr[0]),
    .b (txreset_tmr[1]),
    .c (txreset_tmr[2]),
    .y (txreset_o)
  );
  majority #(.g_NUM_BITS(1)) majority_ready (
    .a (ready_tmr[0]),
    .b (ready_tmr[1]),
    .c (ready_tmr[2]),
    .y (ready_o)
  );

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
