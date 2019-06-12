`timescale 1ns / 1ps

module   gem_data_out #(
  parameter FPGA_TYPE_IS_VIRTEX6 = 0,
  parameter FPGA_TYPE_IS_ARTIX7  = 0,
  parameter ALLOW_TTC_CHARS      = 1,
  parameter ALLOW_RETRY          = 0,
  parameter FRAME_CTRL_TTC       = 1

)
(
  //--------------------------------------------------------------------------------------------------------------------
  // Core
  //--------------------------------------------------------------------------------------------------------------------
  input clock_40,
  input clock_160,
  input reset_i,

  //--------------------------------------------------------------------------------------------------------------------
  // Physical
  //--------------------------------------------------------------------------------------------------------------------
  output [3:0]  trg_tx_n,
  output [3:0]  trg_tx_p,

  input [1:0]  refclk_n,
  input [1:0]  refclk_p,

  //--------------------------------------------------------------------------------------------------------------------
  // Data
  //--------------------------------------------------------------------------------------------------------------------
  input [56*2-1:0]  gem_data_i,    // 56 bit gem data
  input             overflow_i,    // 1 bit gem has more than 8 clusters
  input [11:0]      bxn_counter_i, // 12 bit bxn counter
  input             bc0_i,         // 1  bit bx0 flag
  input             resync_i,      // 1  bit resync flag

  //--------------------------------------------------------------------------------------------------------------------
  // Control
  //--------------------------------------------------------------------------------------------------------------------
  input [2:0] tx_prbs_mode,
  input       pll_reset_i,
  input [3:0] mgt_reset_i,
  input       gtxtest_start_i,
  input       txreset_i,
  input       mgt_realign_i,
  input       txpowerdown_i,
  input [1:0] txpowerdown_mode_i,
  input       txpllpowerdown_i,
  input       force_not_ready,

  //--------------------------------------------------------------------------------------------------------------------
  // Ready
  //--------------------------------------------------------------------------------------------------------------------
  output txfsm_done_o,
  output pll_lock_o,
  output ready_o
);

  //----------------------------------------------------------------------------------------------------------------------
  // Core Signals
  //----------------------------------------------------------------------------------------------------------------------

  wire reset = reset_i;

  //--------------------------------------------------------------------------------------------------------------------
  // Control signals
  //--------------------------------------------------------------------------------------------------------------------

  wire txpllpowerdown;
  wire gtxtest_reset;
  wire [1:0] txpowerdown_mode;
  wire txpowerdown;
  wire mgt_realign;
  wire txreset;
  wire gtxtest_start;
  wire [3:0] mgt_reset;
  wire pll_reset;

  reg mgt_startup_done;

  (*shreg_extract ="no"*) reg [56*2-1:0]  gem_data;         // 56 bit gem data
  (*shreg_extract ="no"*) reg             bc0;              //
  (*shreg_extract ="no"*) reg             resync;           //
  (*shreg_extract ="no"*) reg             overflow;         //
  (*shreg_extract ="no"*) reg [1:0]       bxn_counter_lsbs; //

  //--------------------------------------------------------------------------------------------------------------------
  // Control
  //--------------------------------------------------------------------------------------------------------------------

  mgt_control_tmr #(
    .FPGA_TYPE_IS_VIRTEX6 (FPGA_TYPE_IS_VIRTEX6),
    .FPGA_TYPE_IS_ARTIX7  (FPGA_TYPE_IS_ARTIX7 ),
    .ALLOW_RETRY          (ALLOW_RETRY         )
  ) mgt_control_tmr (
    .clock_40  (clock_40),
    .clock_160 (clock_160),

    .mgt_startup_done (mgt_startup_done),
    .reset_i          (reset_i),

    // ipbus control inputs
    .force_not_ready        (force_not_ready),
    .ext_pll_reset_i        (pll_reset_i        ),
    .ext_mgt_reset_i        (mgt_reset_i        ),
    .ext_gtxtest_start_i    (gtxtest_start_i    ),
    .ext_txreset_i          (txreset_i          ),
    .ext_mgt_realign_i      (mgt_realign_i      ),
    .ext_txpowerdown_i      (txpowerdown_i      ),
    .ext_txpowerdown_mode_i (txpowerdown_mode_i ),
    .ext_txpllpowerdown_i   (txpllpowerdown_i   ),

    // outputs
    .pll_reset_o        (pll_reset),
    .mgt_reset_o        (mgt_reset),
    .gtxtest_start_o    (gtxtest_start),
    .txreset_o          (txreset),
    .mgt_realign_o      (mgt_realign),
    .txpowerdown_o      (txpowerdown),
    .txpowerdown_mode_o (txpowerdown_mode_o),
    .txpllpowerdown_o   (txpllpowerdown),
    .gtxtest_reset_o    (gtxtest_reset),
    .ready_o            (ready_o)
  );

  //--------------------------------------------------------------------------------------------------------------------
  // Data
  //--------------------------------------------------------------------------------------------------------------------

  wire [15:0] trg_tx_data_a, trg_tx_data_b;
  wire [1:0]  trg_tx_isk_a,  trg_tx_isk_b;

  wire [15:0] trg_tx_data [3:0] ;
  wire [1:0]  trg_tx_isk   [3:0];

  mgt_data_tmr #(
  .ALLOW_TTC_CHARS(ALLOW_TTC_CHARS),
  .FRAME_CTRL_TTC (FRAME_CTRL_TTC)
  ) mgt_data_tmr (
  .gem_data         (gem_data),         // 56 bit gem data
  .overflow_i       (overflow),         // 1 bit gem has more than 8 clusters
  .bxn_counter_lsbs (bxn_counter_lsbs), // 2 bit bxn counter lsbs
  .bc0_i            (bc0),              // 1  bit bx0 flag
  .resync_i         (resync),           // 1  bit resync flag

  .ready(mgt_startup_done),

  .clk_160(clock_160),

  .reset(reset),

  .trg_tx_data_a(trg_tx_data_a),
  .trg_tx_data_b(trg_tx_data_b),

  .trg_tx_isk_a(trg_tx_isk_a),
  .trg_tx_isk_b (trg_tx_isk_b)

  );

  assign trg_tx_data[0] = trg_tx_data_a;
  assign trg_tx_data[1] = trg_tx_data_b;
  assign trg_tx_data[2] = trg_tx_data_a;
  assign trg_tx_data[3] = trg_tx_data_b;

  assign trg_tx_isk[0]  = trg_tx_isk_a;
  assign trg_tx_isk[1]  = trg_tx_isk_b;
  assign trg_tx_isk[2]  = trg_tx_isk_a;
  assign trg_tx_isk[3]  = trg_tx_isk_b;

  //--------------------------------------------------------------------------------------------------------------------
  // MGTs
  //--------------------------------------------------------------------------------------------------------------------

  generate
  if (FPGA_TYPE_IS_ARTIX7) begin

      initial $display ("Generating optical links for Artix-7");

      always @(*) begin
        mgt_startup_done <= &tx_fsm_reset_done;
        gem_data         <= gem_data_i;
        bc0              <= bc0_i;
        resync           <= resync_i;
        bxn_counter_lsbs <= bxn_counter_i[1:0];
      end
      assign txfsm_done_o = &tx_fsm_reset_done;

      a7_gtp_wrapper a7_gtp_wrapper (

        .soft_reset_tx_in  (mgt_reset[0]),

        .pll_lock_out (pll_lock),

        .refclk_in_n (refclk_n),
        .refclk_in_p (refclk_p),

        .TXN_OUT                   (trg_tx_n),
        .TXP_OUT                   (trg_tx_p),

        .sysclk_in                 (clock_40),

        .gt0_txcharisk_i           (trg_tx_isk [0]),
        .gt1_txcharisk_i           (trg_tx_isk [1]),
        .gt2_txcharisk_i           (trg_tx_isk [2]),
        .gt3_txcharisk_i           (trg_tx_isk [3]),

        .gt0_txdata_i              (trg_tx_data[0]),
        .gt1_txdata_i              (trg_tx_data[1]),
        .gt2_txdata_i              (trg_tx_data[2]),
        .gt3_txdata_i              (trg_tx_data[3]),

        .tx_fsm_reset_done         (tx_fsm_reset_done),

        .txusrclk_i                (clock_160)
      );
  end
  endgenerate

  generate
  if (FPGA_TYPE_IS_VIRTEX6) begin

      initial $display ("Generating optical links for Virtex-6");

      assign pll_lock_o = &pll_lock;

      always @(*) begin
        gem_data         <= gem_data_i;
        bc0              <= bc0_i;
        resync           <= resync_i;
        bxn_counter_lsbs <= bxn_counter_i[1:0];
      end

      always @(*) mgt_startup_done <= (&tx_sync_done) && (&tx_fsm_reset_done) && (&pll_lock);

      assign txfsm_done_o = &tx_fsm_reset_done;

      v6_gtx_wrapper v6_gtx_wrapper (
        .refclk_n          (refclk_n),
        .refclk_p          (refclk_p),
        .clock_160         (clock_160),
        .gtx_txoutclk      (),
        .TXN_OUT           (trg_tx_n),
        .TXP_OUT           (trg_tx_p),
        .GTX0_TXCHARISK_IN (trg_tx_isk[0]),
        .GTX1_TXCHARISK_IN (trg_tx_isk[1]),
        .GTX2_TXCHARISK_IN (trg_tx_isk[2]),
        .GTX3_TXCHARISK_IN (trg_tx_isk[3]),
        .GTX0_TXDATA_IN    (trg_tx_data[0]),
        .GTX1_TXDATA_IN    (trg_tx_data[1]),
        .GTX2_TXDATA_IN    (trg_tx_data[2]),
        .GTX3_TXDATA_IN    (trg_tx_data[3]),
        .tx_resetdone_o    (tx_fsm_reset_done),
        .gtx_tx_sync_done  (tx_sync_done),
        .pll_lock          (pll_lock),
        .realign           (mgt_realign),
        .plltxreset_in     (pll_reset),                     // This port resets the TX PLL of the GTX transceiver when driven High.
                                                            // It affects the clock generated from the TX PMA. When this reset is
                                                            // asserted or deasserted, TXRESET must also be asserted or deasserted.
        .gttx_reset_in     (mgt_reset[3:0]),                // This port is driven High and then deasserted to start the full TX GTX
                                                            // transceiver reset sequence. This sequence takes about 120 µs to
                                                            // complete and systematically resets all subcomponents of the GTX
                                                            // transceiver TX.
                                                            // If the RX PLL is supplying the clock for the TX datapath,
                                                            // GTXTXRESET and GTXRXRESET must be tied together. In addition,
                                                            // the transmitter reference clock must also be supplied (see Reference Clock Selection, page 102)
        .txenprbstst_in    (tx_prbs_mode),                  // 000: Standard operation mode (test pattern generation is OFF)
                                                            // 001: PRBS-7
                                                            // 010: PRBS-15
                                                            // 011: PRBS-23
                                                            // 100: PRBS-31
                                                            // 101: PCI Express compliance pattern. Only works with 20-bit mode
                                                            // 110: Square wave with 2 UI (alternating 0’s/1’s)
                                                            // 111: Square wave with 16 UI or 20 UI period (based on data width)
        .txreset_in (txreset),                              // PCS TX system reset. Resets the TX FIFO, 8B/10B encoder and other
                                                            // transmitter registers. This reset is a subset of GTXTXRESET
        .txpowerdown (txpowerdown_mode),                    // 00: P0 (normal operation)
                                                            // 01: P0s (low recovery time power down)
                                                            // 10: P1 (longer recovery time; Receiver Detection still on)
                                                            // 11: P2 (lowest power state)
        .txpllpowerdown (txpllpowerdown),
        .gtxtest_in ({11'b10000000000,gtxtest_reset,1'b0})  // GTXTEST[0]: Reserved. Tied to 0.
                                                            // GTXTEST[1]: The default is 0. When this bit is set to 1, the TX output clock dividers are reset.
                                                            // GTXTEST[12:2]: Reserved. Tied to 10000000000.
      );

  end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
