//--------------------------------------------------------------------------------
// CMS Muon Endcap
// GEM Collaboration
// Optohybrid v3 Firmware -- Frame Alignment
// A. Peck
//--------------------------------------------------------------------------------
// Description:
//   This module takes in 8 serial data streams from a single VFAT, and phase
//   aligns them to 40 MHz LHC clock, aligns the bitstream to the frame clock
//   and deserialize to 40MHz
//--------------------------------------------------------------------------------
// 2017/07/24 -- Initial
//--------------------------------------------------------------------------------

module frame_aligner (
  input [MXIO-1:0] d0, // data from posedge of ddr
  input [MXIO-1:0] d1, // data from negedge of ddr

  input start_of_frame,

  input reset_i,
  input mask,

  input clock,
  input fastclock,

  output reg alignment_error,
  output sof_delayed,
  output [MXSBITS-1:0] sbits
);

  parameter DDR=0;
  parameter MXSBITS=64+64*DDR;
  parameter MXIO = 8;
  parameter WORD_SIZE = MXSBITS / MXIO;

  reg reset=1;
  always @(posedge clock) begin
    reset <= reset_i;
  end

  reg ready=0;


  //--------------------------------------------------------------------------------------------------------------------
  // Start of Frame Delays
  //--------------------------------------------------------------------------------------------------------------------

  wire sof_dly_srl;
  wire sof_dly2_srl;

  reg  [3:0] srl_adr=0; // frame alignment srl_adr
  wire [3:0] srl_adr2 = 4'd4;

  SRL16E  srlsof0a   (.CLK(fastclock),.CE(1'b1),.D(start_of_frame),.A0(srl_adr[0]), .A1(srl_adr[1]), .A2(srl_adr[2]), .A3(srl_adr[3]), .Q(sof_dly_srl));
  SRL16E  srlsof0b   (.CLK(fastclock),.CE(1'b1),.D(sof_dly_srl),   .A0(srl_adr2[0]),.A1(srl_adr2[1]),.A2(srl_adr2[2]),.A3(srl_adr2[3]),.Q(sof_dly2_srl));
  // delay sof by 3 to compensate for the s-bit even/odd fifo output equivalent delay

  // reg for fanout
  reg sof_dly2;
  always @(posedge fastclock)
    sof_dly2 <= sof_dly2_srl;

  //--------------------------------------------------------------------------------------------------------------------
  // Data Delays
  //--------------------------------------------------------------------------------------------------------------------

  wire [7:0] d0_dly_srl;
  wire [7:0] d1_dly_srl;

  wire [4:0] srl_adr0 = srl_adr+1'b1;
  wire [4:0] srl_adr1 = srl_adr;

  genvar ibit;
  generate
    for (ibit=0; ibit<8; ibit=ibit+1) begin: bloop
    // odd bits
    SRL16E srldat0 (.CLK(fastclock),.CE(1'b1),.D(d0[ibit]),.A0(srl_adr0[0]),.A1(srl_adr0[1]),.A2(srl_adr0[2]),.A3(srl_adr0[3]),.Q(d0_dly_srl[ibit]));

    // even bits
    SRL16E srldat1 (.CLK(fastclock),.CE(1'b1),.D(d1[ibit]),.A0(srl_adr1[0]),.A1(srl_adr1[1]),.A2(srl_adr1[2]),.A3(srl_adr1[3]),.Q(d1_dly_srl[ibit]));
    end
  endgenerate

  reg [7:0] d0_dly;
  reg [7:0] d1_dly;

  always @(posedge fastclock) begin
    d0_dly <= d0_dly_srl;
    d1_dly <= d1_dly_srl;
  end

  // fifo rising (even) and falling (odd) bits separately, interleave leater

  reg [WORD_SIZE/2-1:0] sbit_fifo_odd  [MXIO-1:0];
  reg [WORD_SIZE/2-1:0] sbit_fifo_even [MXIO-1:0];

  wire [7:0] sbits_interleaved_lsbs [MXIO-1:0];
  wire [7:0] sbits_interleaved_msbs [MXIO-1:0];

  wire [WORD_SIZE-1:0] sbits_interleaved      [MXIO-1:0];


  genvar ipin;
  generate
  for (ipin=0; ipin<8; ipin=ipin+1) begin: bloop2

    initial sbit_fifo_odd [ipin] <= 0;
    initial sbit_fifo_even[ipin] <= 0;

    // shift data in, MSB first -- posedge
    always @(posedge fastclock) begin
      sbit_fifo_odd  [ipin][WORD_SIZE/2-1:0] <= {sbit_fifo_odd  [ipin][WORD_SIZE/2-2:0] , d1_dly[ipin]};
      sbit_fifo_even [ipin][WORD_SIZE/2-1:0] <= {sbit_fifo_even [ipin][WORD_SIZE/2-2:0] , d0_dly[ipin]};
    end

    // at VFAT double-data rate, we want to deserialize 16 bits at once
    if (DDR) begin
    assign sbits_interleaved_msbs[ipin] =

      DDR ?

      {
      sbit_fifo_even[ipin][7],
      sbit_fifo_odd [ipin][7],
      sbit_fifo_even[ipin][6],
      sbit_fifo_odd [ipin][6],
      sbit_fifo_even[ipin][5],
      sbit_fifo_odd [ipin][5],
      sbit_fifo_even[ipin][4],
      sbit_fifo_odd [ipin][4]

      } :
      0 ;

    end

    // at VFAT single-data rate, we want to deserialize 8 bits at once
    assign sbits_interleaved_lsbs[ipin] = {
      sbit_fifo_even[ipin][3],
      sbit_fifo_odd [ipin][3],
      sbit_fifo_even[ipin][2],
      sbit_fifo_odd [ipin][2],
      sbit_fifo_even[ipin][1],
      sbit_fifo_odd [ipin][1],
      sbit_fifo_even[ipin][0],
      sbit_fifo_odd [ipin][0]
    };

    if (DDR)
      assign sbits_interleaved[ipin]= {sbits_interleaved_msbs[ipin], sbits_interleaved_lsbs[ipin]};
    else
      assign sbits_interleaved[ipin] = sbits_interleaved_lsbs[ipin];

  end
  endgenerate

  // output
  reg [MXSBITS-1:0] sbits_reg;
  assign sbits = sbits_reg;

  always @(posedge clock) begin
    // kill the outputs if we aren't aligned to SOF
    if (reset || mask || ~ready)
      sbits_reg <= {MXSBITS{1'b0}};
    else
      sbits_reg <= {
        sbits_interleaved[7],
        sbits_interleaved[6],
        sbits_interleaved[5],
        sbits_interleaved[4],
        sbits_interleaved[3],
        sbits_interleaved[2],
        sbits_interleaved[1],
        sbits_interleaved[0]
        };
  end

  // look for rising edge of the sof signal
  reg sof_last;
  always @(posedge fastclock) begin
    sof_last <= sof_dly2;
  end

  // 40 MHz stable sof aligned flag
  reg sof_aligned = 0;
  always @(posedge clock) begin
    sof_aligned <= !sof_last && sof_dly2;
  end

  // output
  assign sof_delayed = sof_dly2;

  reg [7:0] sof_r;
  always @(posedge clock) begin
    sof_r <= {sof_r[6:0],sof_aligned};
    ready <= &sof_r;
  end

  // can't check this every clock cycle because there is latency between changing it and the result propagating to the output
  // use a check strope every few bx and only do the check when strobe is high, giving time for the result to propagate
  reg [1:0] check_sof = 0;
  always @(negedge clock) begin

    check_sof <= check_sof + 1'b1;

    if (check_sof==0 && !sof_aligned)
      srl_adr=srl_adr+1'b1;
  end

  always @(posedge clock) begin
    alignment_error = ready && !sof_aligned;
  end

endmodule
