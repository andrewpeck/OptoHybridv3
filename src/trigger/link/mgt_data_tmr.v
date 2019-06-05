module mgt_data_tmr #(
  parameter ALLOW_TTC_CHARS      = 1,
  parameter FRAME_CTRL_TTC       = 1
)
(
  input [56*2-1:0]  gem_data,         // 56 bit gem data
  input             overflow_i,       // 1 bit gem has more than 8 clusters
  input [1:0]       bxn_counter_lsbs, // 2 bit bxn counter lsbs
  input             bc0_i,            // 1  bit bx0 flag
  input             resync_i,         // 1  bit resync flag

  input ready,

  input clk_160,

  input reset,

  output [15:0] trg_tx_data_a,
  output [15:0] trg_tx_data_b,

  output [1:0] trg_tx_isk_a,
  output [1:0] trg_tx_isk_b

);

(* DONT_TOUCH = "true" *)   wire [15:0] trg_tx_data_a_tmr [2:0] ;
(* DONT_TOUCH = "true" *)   wire [15:0] trg_tx_data_b_tmr [2:0] ;
(* DONT_TOUCH = "true" *)   wire [1:0]  trg_tx_isk_a_tmr   [2:0];
(* DONT_TOUCH = "true" *)   wire [1:0]  trg_tx_isk_b_tmr   [2:0];

  genvar I;
  generate
  for (I=0; I<3; I=I+1'b1) begin  : tmrloop
    mgt_data #(
    .TMR_INSTANCE   (I),
    .ALLOW_TTC_CHARS(ALLOW_TTC_CHARS),
    .FRAME_CTRL_TTC (FRAME_CTRL_TTC)
    ) mgt_data (
    // inputs
    .gem_data         (gem_data_sync),    // 56 bit gem data
    .overflow_i       (overflow),         // 1 bit gem has more than 8 clusters
    .bxn_counter_lsbs (bxn_counter_lsbs), // 2 bit bxn counter lsbs
    .bc0_i            (bc0),              // 1  bit bx0 flag
    .resync_i         (resync),           // 1  bit resync flag

    .ready(mgt_startup_done),

    .clk_160(usrclk_160),

    .reset(reset),

    // outputs
    .trg_tx_data_a(trg_tx_data_a_tmr[I]),
    .trg_tx_data_b(trg_tx_data_b_tmr[I]),

    .trg_tx_isk_a(trg_tx_isk_a_tmr [I]),
    .trg_tx_isk_b (trg_tx_isk_b_tmr[I])

    );
    end
  endgenerate

  majority #(.g_NUM_BITS(15)) majority_trg_tx_data_a (
    .a (trg_tx_data_a_tmr[0]),
    .b (trg_tx_data_a_tmr[1]),
    .c (trg_tx_data_a_tmr[2]),
    .y (trg_tx_data_a)
  );

  majority #(.g_NUM_BITS(15)) majority_trg_tx_data_b (
    .a (trg_tx_data_b_tmr[0]),
    .b (trg_tx_data_b_tmr[1]),
    .c (trg_tx_data_b_tmr[2]),
    .y (trg_tx_data_b)
  );

  majority #(.g_NUM_BITS(2)) majority_trg_tx_isk_a (
    .a (trg_tx_isk_a_tmr[0]),
    .b (trg_tx_isk_a_tmr[1]),
    .c (trg_tx_isk_a_tmr[2]),
    .y (trg_tx_isk_a)
  );

  majority #(.g_NUM_BITS(2)) majority_trg_tx_isk_b (
    .a (trg_tx_isk_b_tmr[0]),
    .b (trg_tx_isk_b_tmr[1]),
    .c (trg_tx_isk_b_tmr[2]),
    .y (trg_tx_isk_b)
  );

endmodule

