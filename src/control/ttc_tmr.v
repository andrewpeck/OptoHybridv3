//--------------------------------------------------------------------------------
// CMS Muon Endcap
// GEM Collaboration
// Optohybrid v3 Firmware -- TTC
// A. Peck
//--------------------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------------------
// 2019/05/16 -- Initial
//--------------------------------------------------------------------------------

module ttc_tmr #(
  parameter HOLD_UNTIL_BX0 = 0,
  parameter MXBXN          = 12 // Number BXN bits, LHC bunchs numbered 0 to 3563
) (

  input clock,

  input reset,

  input  ttc_bx0,

  input ttc_resync,

  input  [MXBXN-1:0] bxn_offset, // BXN offset at reset

  output [MXBXN-1:0] bxn_counter,

  output bx0_local,

  output     bx0_sync_err, // sync error on bx0
  output     bxn_sync_err  // bunch counter sync error

);
(* DONT_TOUCH = "true" *)   wire [2:0] bxn_sync_err_tmr;
(* DONT_TOUCH = "true" *)   wire [2:0] bx0_sync_err_tmr;
(* DONT_TOUCH = "true" *)   wire [2:0] bx0_local_tmr;
(* DONT_TOUCH = "true" *)   wire [MXBXN-1:0] bxn_counter_tmr [2:0];

  genvar I;
  generate
  for (I=0; I<3; I=I+1'b1) begin  : tmrloop
    ttc #(.TMR_INSTANCE  (I),
          .HOLD_UNTIL_BX0(HOLD_UNTIL_BX0),
          .MXBXN         (MXBXN)
    ) ttc (
      // inputs
      .clock        (clock),
      .reset        (reset),
      .ttc_bx0      (ttc_bx0),
      .ttc_resync   (ttc_resync),
      .bxn_offset   (bxn_offset),

      // outputs
      .bx0_local    (bx0_local_tmr[I]),
      .bxn_counter  (bxn_counter_tmr[I]),
      .bx0_sync_err (bx0_sync_err_tmr[I]),
      .bxn_sync_err (bxn_sync_err_tmr[I])
    );
  end
  endgenerate

  majority #(.g_NUM_BITS(1)) majority_bx0_local (
    .a (bx0_local_tmr[0]),
    .b (bx0_local_tmr[1]),
    .c (bx0_local_tmr[2]),
    .y (bx0_local)
  );
  majority #(.g_NUM_BITS(MXBXN)) majority_bxn_counter (
    .a (bxn_counter_tmr[0]),
    .b (bxn_counter_tmr[1]),
    .c (bxn_counter_tmr[2]),
    .y (bxn_counter)
  );
  majority #(.g_NUM_BITS(1)) majority_bx0_sync_err (
    .a (bx0_sync_err_tmr[0]),
    .b (bx0_sync_err_tmr[1]),
    .c (bx0_sync_err_tmr[2]),
    .y (bx0_sync_err)
  );
  majority #(.g_NUM_BITS(1)) majority_bxn_sync_err (
    .a (bxn_sync_err_tmr[0]),
    .b (bxn_sync_err_tmr[1]),
    .c (bxn_sync_err_tmr[2]),
    .y (bxn_sync_err)
  );

endmodule

