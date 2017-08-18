`timescale 1ns/1ps
module sr64 (
  input CLK,
  input CE,
  input [5:0] SEL,
  input SI,
  output DO
);

parameter SELWIDTH = 6;
localparam DATAWIDTH = 2**SELWIDTH;
reg [DATAWIDTH-1:0] data;
assign DO = data[SEL];
always @(posedge CLK)
begin
  if (CE == 1'b1)
    data <= {data[DATAWIDTH-2:0], SI};
end
endmodule

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

module optohybrid_top_tb;

parameter DDR = 0;

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------


  //--------------------------------------------------------------------------------------------------------------------
  // clock synthesis
  //--------------------------------------------------------------------------------------------------------------------

  reg clk40     = 0; // 40  MHz for logic
  reg clk160    = 0; // 160 MHz for logic
  reg clk320    = 1; // 320 MHz for logic
  reg clk640    = 0; // 640  MHz for stimulus at DDR
  reg clk1280   = 0; // 1280 MHz for stimulus at DDR
  reg clk12G8   = 0; // 12.8 GHz for IOdelay generation

  always @* begin
    clk12G8   <= #  0.039 ~clk12G8; // 78 ps clock (12.8GHz) to simulate TAP delay
    clk1280   <= #  0.390 ~clk1280;
    clk640    <= #  0.780 ~clk640;
    clk320    <= #  1.560 ~clk320;
    clk160    <= #  3.120 ~clk160;
    clk40     <= # 12.480 ~clk40;
  end

  wire fastclk_0   =  clk320;
  wire fastclk_180 = ~clk320;

  //--------------------------------------------------------------------------------------------------------------------
  // S-bit Serialization
  //--------------------------------------------------------------------------------------------------------------------

  // s-bits are transmitted MSB first
  // with SOF aligned to the most significant bit
  reg [2:0] sot_cnt=3'd4; // cnt to 8
  wire sotd0 = (sot_cnt==7);
  // frame counter for the 8 S-bits in a 40 MHz clock cycle
  always @(posedge clk320)
    sot_cnt <= sot_cnt - 1'b1;

  reg [2:0] slow_cnt=0;
  always @(posedge clk320)
    if (sotd0)
      slow_cnt <= slow_cnt - 1'b1;

  reg [7:0] pat_sr = 0;


  generate

  if (DDR) begin

      // at DDR 128 bit test pattern gets shifted into the S-bit packer..
      // the same s-bits are inserted into every S-bit

      //parameter [127:0] test_pat = 128'hCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC;
        parameter [127:0] test_pat = 128'hff00ff00ff00ff00ff00ff00ff00ff00;

        wire [15:0] vfat_tu [7:0];

        assign vfat_tu [0] = slow_cnt==0 ? test_pat [0  +:16] : 0;
        assign vfat_tu [1] = slow_cnt==0 ? test_pat [16 +:16] : 0;
        assign vfat_tu [2] = slow_cnt==0 ? test_pat [32 +:16] : 0;
        assign vfat_tu [3] = slow_cnt==0 ? test_pat [48 +:16] : 0;
        assign vfat_tu [4] = slow_cnt==0 ? test_pat [64 +:16] : 0;
        assign vfat_tu [5] = slow_cnt==0 ? test_pat [80 +:16] : 0;
        assign vfat_tu [6] = slow_cnt==0 ? test_pat [96 +:16] : 0;
        assign vfat_tu [7] = slow_cnt==0 ? test_pat [112+:16] : 0;

        genvar itu;
        for (itu=0; itu<8; itu=itu+1'b1) begin: tuloop
          always @ (posedge clk1280) begin
            pat_sr [itu] <= vfat_tu[itu][sot_cnt];
          end
        end
  end
  else begin

    // at SDR, 64 bit test pattern gets shifted into the S-bit packer..
    // the same s-bits are inserted into every S-bit

        // send pattern in two subsequent bunch crossings (to test odd/even endcoders)
        // then remain idle for a period to make latency measurements clearer

        reg [63:0] test_pat = 128'h0101010101010101;

        reg [63:0] test_pat_odd;
        reg [63:0] test_pat_even;

        always @(posedge clk40) begin
          if (slow_cnt==0)
            test_pat_odd <= test_pat;
          else
            test_pat_odd <= 0;

          test_pat_even <= test_pat_odd << 1'b1;

        end

        wire [63:0] pat = test_pat_odd | test_pat_even;

        wire [7:0] vfat_tu [7:0];

        assign vfat_tu [0] = pat [0 +:8];
        assign vfat_tu [1] = pat [8 +:8];
        assign vfat_tu [2] = pat [16+:8];
        assign vfat_tu [3] = pat [24+:8];
        assign vfat_tu [4] = pat [32+:8];
        assign vfat_tu [5] = pat [40+:8];
        assign vfat_tu [6] = pat [48+:8];
        assign vfat_tu [7] = pat [56+:8];

        genvar itu;
        for (itu=0; itu<8; itu=itu+1'b1) begin: tuloop
          always @ (*) begin
            pat_sr [itu] <= vfat_tu[itu][sot_cnt];
          end
        end

  end

  endgenerate


  wire [191:0] phase_err;
  wire aligner_sump;

  wire [1535+1536*DDR:0] sbits;


  // apply a delay, opposite to the delay that we we later counteract with TU_POSNEG

  wire [191:0] tu_p;

  `include "trigger/trig_alignment/tap_delays.v"

  genvar ipin;
  generate
  for (ipin=0; ipin<192; ipin=ipin+1) begin: pinloop
    // clock at very high frequency so that SRL can simulate an IDELAY in 78 ps taps
    sr64 srp (clk12G8, 1'b1, 6'd63 - TU_OFFSET [ipin*5+:4],  pat_sr[ipin/24], tu_p[ipin]); // make each vfat the same
  end
  endgenerate


  wire [23:0] sof;

  genvar ifat;
  generate
  for (ifat=0; ifat<24; ifat=ifat+1) begin: fatloop
    // 40 taps @ 78 ps each = 3.125 ns
    sr64 srfp (clk12G8, 1'b1,6'd63-SOF_OFFSET [ifat*5+:4] - 6'd40*SOF_POSNEG[ifat],  sotd0, sof[ifat]);
  end
  endgenerate

  //--------------------------------------------------------------------------------------------------------------------
  // GBT Serialization
  //--------------------------------------------------------------------------------------------------------------------

  // gbt data

  wire         wr_en       = 1'b1;
  wire         wr_valid    = 1'b1;
  wire  [15:0] address     = {5'h0, 11'h0}; // 32'h0; // write to loopback
  reg   [31:0] data        = 32'h12345678;
  wire  [5:0]  frame_start = 6'h2A;

  wire l1a      = 1'b0;
  wire bc0      = 1'b0;
  wire resync   = 1'b0;
  wire calpulse = 1'b0;

  wire [3:0] gbt_ttc = {l1a, calpulse, resync, bc0};

  wire [48:0] gbt_packet = {wr_en, wr_valid, address[15:0], data[31:0]};

  `define tenbit_tx

  `ifdef tenbit_tx

    reg [9:0] gbt_dout;

    reg [3:0] gbt_frame=0;

    always @(posedge clk40) begin
    case (gbt_frame)
        4'h0: gbt_frame <= 4'h1; // start of transmit
        4'h1: gbt_frame <= 4'h2; // begin
        4'h2: gbt_frame <= 4'h3; // addr0
        4'h3: gbt_frame <= 4'h4; // addr1
        4'h4: gbt_frame <= 4'h5; // addr2
        4'h5: gbt_frame <= 4'h6; // data0
        4'h6: gbt_frame <= 4'h7; // data1
        4'h7: gbt_frame <= 4'h8; // data2
        4'h8: gbt_frame <= 4'h9; // data3
        4'h9: gbt_frame <= 4'h0; // data4
    endcase
    end


    always @(posedge clk40) begin
    case (gbt_frame) // prefetch
        4'h0: gbt_dout <= {gbt_ttc,               frame_start                             }; // 0x2A
        4'h1: gbt_dout <= {gbt_ttc,wr_valid,wr_en,                              4'd0      }; // begin
        4'h2: gbt_dout <= {gbt_ttc,                           address[15:10]              }; // addr0
        4'h3: gbt_dout <= {gbt_ttc,                           address[ 9: 4]              }; // addr1
        4'h4: gbt_dout <= {gbt_ttc,                           address[ 3: 0], data[31:30] }; // addr2
        4'h5: gbt_dout <= {gbt_ttc,                                           data[29:24] }; // data0
        4'h6: gbt_dout <= {gbt_ttc,                                           data[23:18] }; // data1
        4'h7: gbt_dout <= {gbt_ttc,                                           data[17:12] }; // data2
        4'h8: gbt_dout <= {gbt_ttc,                                           data[11: 6] }; // data3
        4'h9: gbt_dout <= {gbt_ttc,                                           data[ 5: 0] }; // data4
    endcase
    end

    reg [1:0] clk40_sync;

    reg [2:0] bitsel=0;

    always @(negedge clk320) begin

    clk40_sync[0] <= clk40;
    clk40_sync[1] <= clk40_sync[0];

    if (clk40_sync[1:0] == 2'b01) // catch the rising edge of clk40
        bitsel <= 3'd7;
    else
        bitsel <= bitsel-1'b1;
    end


    // Elinks
    reg [9:0] to_gbt_1;
    reg [9:0] to_gbt;
    always @(negedge clk320) begin
    to_gbt_1 <= gbt_dout;
    to_gbt   <= to_gbt_1;
    end

    wire [1:0] elink_i_p;
    assign elink_i_p [1]= to_gbt [bitsel+2];                  // 320 MHz
    assign elink_i_p [0]= bitsel[2] ? to_gbt [1] : to_gbt[0]; // 80  MHz


  `else

    reg[15:0] gbt_dout;

    reg [2:0] gbt_frame=0;

    always @(posedge clk40) begin
    case (gbt_frame)
        3'd0: gbt_frame <= 3'd1; // begin
        3'd1: gbt_frame <= 3'd2; // addr
        3'd2: gbt_frame <= 3'd3; // data
        3'd3: gbt_frame <= 3'd4; // data
        3'd4: gbt_frame <= 3'd5; // data
        3'd5: gbt_frame <= 3'd0; // end
    endcase
    end

    always @(posedge clk40) begin
    case (gbt_frame)
        3'd5: gbt_dout <= {gbt_ttc,wr_valid,wr_en,2'b00,address[15:12]}; // begin
        3'd0: gbt_dout <= {gbt_ttc,                     address[11:0 ]}; // addr
        3'd1: gbt_dout <= {gbt_ttc, 4'd0,               data   [31:24]}; // data
        3'd2: gbt_dout <= {gbt_ttc,                     data   [23:12]}; // data
        3'd3: gbt_dout <= {gbt_ttc,                     data   [11:0] }; // data
        3'd4: gbt_dout <= {gbt_ttc,                     frame_end     }; // end
    endcase
    end

    reg [1:0] clk40_sync;

    reg [2:0] bit=0;

    always @(negedge clk320) begin

    clk40_sync[0] <= clk40;
    clk40_sync[1] <= clk40_sync[0];

    if (clk40_sync[1:0] == 2'b01) // catch the rising edge of clk40
        bit <= 3'd7;
    else
        bit <= bit-1'b1;
    end



    // Elinks

    reg [15:0] to_gbt_1;
    reg [15:0] to_gbt;
    always @(negedge clk320) begin
    to_gbt_1 <= gbt_dout;
    to_gbt   <= to_gbt_1;
    end

    wire [1:0] elink_i_p;
    assign elink_i_p [1]= to_gbt [bit+8]; // msb first
    assign elink_i_p [0]= to_gbt [bit  ]; // msb first

  `endif

  wire [1:0] elink_i_n = ~elink_i_p;

//----------------------------------------------------------------------------------------------------------------------
// Optohybrid IO
//----------------------------------------------------------------------------------------------------------------------

  wire [1:0] gbt_eclk_p = {2{ clk320}};
  wire [1:0] gbt_eclk_n = {2{~clk320}};

  // 40 MHz clocks

  reg [1:0] gbtclk;
  always @(*) begin
    gbtclk[0] <= #6.8  clk40; // logic clock
    gbtclk[1] <= #0.00 clk40; // frame clock
  end

  wire [1:0] gbt_dclk_p =  gbtclk; // fixed and phase shiftable
  wire [1:0] gbt_dclk_n = ~gbtclk;


  wire [1:0] elink_o_p;
  wire [1:0] elink_o_n;

  // SCA IO
  wire [3:0] sca_io = {4'b0000};

  // GBTx Control
  wire gbt_txready_i = 1'b1;
  wire gbt_rxvalid_i = 1'b1;
  wire gbt_rxready_i = 1'b1;

  // MGT
  wire mgt_clk_p_i =  clk160;
  wire mgt_clk_n_i = ~clk160;

  wire [23:0] vfat_sof_p =  sof;
  wire [23:0] vfat_sof_n = ~sof;

  wire [191:0] vfat_sbits_p =  tu_p;
  wire [191:0] vfat_sbits_n = ~tu_p;

  wire [15:0] led_o;

  wire [11:0] ext_reset_o;

  wire [3:0] mgt_tx_p_o;
  wire [3:0] mgt_tx_n_o;

  optohybrid_top optohybrid_top (

      //.gbt_eclk_p    (gbt_eclk_p),
      //.gbt_eclk_n    (gbt_eclk_n),

      .gbt_dclk_p    (gbt_dclk_p),
      .gbt_dclk_n    (gbt_dclk_n),

      // elink      (// elink),

      .elink_i_p     (elink_i_p),
      .elink_i_n     (elink_i_n),

      .elink_o_p     (elink_o_p),
      .elink_o_n     (elink_o_n),

      .sca_io        (sca_io),

      .gbt_txready_i (gbt_txready_i),
      .gbt_rxvalid_i (gbt_rxvalid_i),
      .gbt_rxready_i (gbt_rxready_i),

      .mgt_clk_p_i   (mgt_clk_p_i),
      .mgt_clk_n_i   (mgt_clk_n_i),

      .vfat_sof_p    (vfat_sof_p),
      .vfat_sof_n    (vfat_sof_n),

      .vfat_sbits_p  (vfat_sbits_p),
      .vfat_sbits_n  (vfat_sbits_n),

      .led_o         (led_o),

      .ext_reset_o   (ext_reset_o),

      .mgt_tx_p_o    (mgt_tx_p_o),
      .mgt_tx_n_o    (mgt_tx_n_o)
  );

  //--------------------------------------------------------------------------------------------------------------------
  // GBT Deserialization
  //--------------------------------------------------------------------------------------------------------------------

  // for loopback need to take serialized elink s-bit outputs, deserialize them,
  // feed them into this module, parse the 16 bit packets, recover the data
  // :(


  reg  [15:0] fifo_tmp;

  reg  [15:0] elink_o_parallel;

  wire [15:0] fifo_dly;

  always @(posedge gbt_eclk_p[0]) begin
  // this may need to be bitslipped... depending on the phase alignment of the clocks
  fifo_tmp[7:0]  <= {fifo_tmp[ 6:0], elink_o_p[0]};
  fifo_tmp[15:8] <= {fifo_tmp[14:8],~elink_o_p[1]}; // account for polarity swap
  end

  `define tenbit_rx

  `ifdef tenbit_rx
      wire  [15:0] elink_o_fifo = {6'b0, fifo_tmp[15:8], fifo_tmp[6], fifo_tmp[2]};
  `else
      wire  [15:0] elink_o_fifo = fifo_tmp;
  `endif

  wire [3:0] dly_adr = 4'd2;
  genvar ibit;
  generate
  for (ibit=0; ibit<16; ibit=ibit+1) begin: gen_bitloop
    SRL16E dly (.CLK(~gbt_eclk_p[0]),.CE(1'b1),.D(elink_o_fifo[ibit]),.A0(dly_adr[0]),.A1(dly_adr[1]),.A2(dly_adr[2]),.A3(dly_adr[3]),.Q(fifo_dly[ibit]));
  end
  endgenerate


  always @(posedge clk40) begin
    elink_o_parallel <= fifo_dly;
  end

  wire [31:0] gbt_rx_request;
  wire        gbt_rx_valid;

  link_gbt_rx
  #(
      `ifdef tenbit_rx
      .g_16BIT (0)
      `else
      .g_16BIT (1)
      `endif
  )
  i_gbt_rx_link (
      .ttc_clk_40_i  (clk40),
      .reset_i       (1'b0),

      // inputs
      .gbt_rx_data_i (elink_o_parallel),

      // outputs
      .req_en_o      (gbt_rx_valid),
      .req_data_o    (gbt_rx_request)
  );

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
