module frame_aligner_tmr (

  input  [MXSBITS-1:0] sbits_i,

  input [FRAME_SIZE-1:0] start_of_frame,

  input reset_i,

  input clock,

  input [11:0] aligned_count_to_ready,

  output [2:0] bitslip_cnt_o,
  output reg [MXSBITS-1:0] sbits_o,
  output sot_unstable,
  output sot_is_aligned
);

  parameter DDR=0;
  parameter MXSBITS=64*(1+DDR);
  parameter FRAME_SIZE = 8*(1+DDR);

  wire [MXSBITS-1:0] sbits_majority;

  wire [MXSBITS-1:0] sbits_o_tmr        [2:0];
  wire [2:0]         bitslip_cnt_o_tmr  [2:0];
  wire [0:0]         sot_unstable_tmr   [2:0];
  wire [0:0]         sot_is_aligned_tmr [2:0];

  genvar I;
  generate
    for (I=0; I<3; I=I+1'b1) begin  : tmrloop
      frame_aligner #(.TMR_INSTANCE(I), .DDR(DDR)) frame_aligner (
        .sbits_i(sbits_i),
        .start_of_frame(start_of_frame),
        .reset_i(reset_i),
        .clock(clock),
        .aligned_count_to_ready(aligned_count_to_ready),

        .bitslip_cnt_o(bitslip_cnt_o_tmr[I]),
        .sbits_o(sbits_o_tmr[I]),
        .sot_unstable(sot_unstable_tmr[I]),
        .sot_is_aligned(sot_is_aligned_tmr[I])
      );
    end
  endgenerate

  majority #(.g_NUM_BITS(3)) majority_bitslip_cnt (
    .a (bitslip_cnt_o_tmr[0]),
    .b (bitslip_cnt_o_tmr[1]),
    .c (bitslip_cnt_o_tmr[2]),
    .y (bitslip_cnt_o)
  );

  majority #(.g_NUM_BITS(MXSBITS)) majority_sbits_o (
    .a (sbits_o_tmr[0]),
    .b (sbits_o_tmr[1]),
    .c (sbits_o_tmr[2]),
    .y (sbits_majority)
  );

  majority #(.g_NUM_BITS(1)) majority_sot_unstable (
    .a (sot_unstable_tmr[0]),
    .b (sot_unstable_tmr[1]),
    .c (sot_unstable_tmr[2]),
    .y (sot_unstable)
  );

  majority #(.g_NUM_BITS(1)) majority_sot_is_aligned (
    .a (sot_is_aligned_tmr[0]),
    .b (sot_is_aligned_tmr[1]),
    .c (sot_is_aligned_tmr[2]),
    .y (sot_is_aligned)
  );

  always @(posedge clock)
    sbits_o <= sbits_majority;

endmodule
