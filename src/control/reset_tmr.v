//--------------------------------------------------------------------------------
// CMS Muon Endcap
// GEM Collaboration
// Optohybrid v3 Firmware -- Reset
// A. Peck
//--------------------------------------------------------------------------------
// Description:
//   TMR wrapper on reset module
//--------------------------------------------------------------------------------
// 2019/05/15 -- Initial
//--------------------------------------------------------------------------------

module reset_tmr (

  input clock_i,

  input soft_reset,

  input mmcms_locked_i,

  input gbt_rxready_i,
  input gbt_rxvalid_i,
  input gbt_txready_i,

  output core_reset_o,
  output reset_o
);

(* DONT_TOUCH = "true" *) wire [3:0] core_reset;
(* DONT_TOUCH = "true" *) wire [3:0] trigger_reset;

reset #(.TMR_INSTANCE(0)) reset0 (
    .clock_i        (clock_i),
    .soft_reset     (soft_reset),
    .mmcms_locked_i (mmcms_locked_i),
    .gbt_rxready_i  (gbt_rxready_i),
    .gbt_rxvalid_i  (gbt_rxvalid_i),
    .gbt_txready_i  (gbt_txready_i),
    .core_reset_o   (core_reset[0]),
    .reset_o        (trigger_reset[0])
);

reset #(.TMR_INSTANCE(1)) reset1 (
    .clock_i        (clock_i),
    .soft_reset     (soft_reset),
    .mmcms_locked_i (mmcms_locked_i),
    .gbt_rxready_i  (gbt_rxready_i),
    .gbt_rxvalid_i  (gbt_rxvalid_i),
    .gbt_txready_i  (gbt_txready_i),
    .core_reset_o   (core_reset[1]),
    .reset_o        (trigger_reset[1])
);

reset #(.TMR_INSTANCE(2)) reset2 (
    .clock_i        (clock_i),
    .soft_reset     (soft_reset),
    .mmcms_locked_i (mmcms_locked_i),
    .gbt_rxready_i  (gbt_rxready_i),
    .gbt_rxvalid_i  (gbt_rxvalid_i),
    .gbt_txready_i  (gbt_txready_i),
    .core_reset_o   (core_reset[2]),
    .reset_o        (trigger_reset[2])
);

majority #(.g_NUM_BITS(1)) majority_reset_core (
  .a (core_reset[0]),
  .b (core_reset[1]),
  .c (core_reset[2]),
  .y (core_reset_o)
);

majority #(.g_NUM_BITS(1)) majority_reset_trigger (
  .a (trigger_reset[0]),
  .b (trigger_reset[1]),
  .c (trigger_reset[2]),
  .y (reset_o)
);

endmodule
