module mgt_data #(
  parameter TMR_INSTANCE         = 0,
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

//----------------------------------------------------------------------------------------------------------------------
// Transmit data
//----------------------------------------------------------------------------------------------------------------------

  reg [7:0] frame_sep;
  reg [1:0] tx_frame=0;

(* keep="true", max_fanout = "4" *)  reg [15:0] trg_tx_data [1:0] ;
(* keep="true", max_fanout = "4" *)  reg [1:0]  trg_tx_isk   [1:0];

  wire [55:0] gem_link_data [1:0];

  assign gem_link_data[0] = gem_data[55:0];
  assign gem_link_data[1] = gem_data[111:56];

  always @(posedge clk_160) begin
    tx_frame  <= (reset || ~ready) ? 2'd0 : tx_frame + 1'b1;
  end

  genvar ilink;
  generate
    for (ilink=0; ilink < 2; ilink=ilink+1)
    begin: linkgen

      always @(posedge clk_160) begin

        if (reset || ~ready) begin
          trg_tx_data[ilink]  <= 16'hFFFC;
          trg_tx_isk [ilink]  <= 2'b01;
        end
        else begin
          case (tx_frame)
            2'd0: begin
                  trg_tx_data[ilink] <= {gem_link_data[ilink][7:0] , frame_sep[7:0]};
                  trg_tx_isk [ilink] <= 2'b01;
            end
            2'd1: begin
                  trg_tx_data[ilink] <= {gem_link_data[ilink][23:8]};
                  trg_tx_isk [ilink] <= 2'b00;
            end
            2'd2: begin
                  trg_tx_data[ilink] <= {gem_link_data[ilink][39:24]};
                  trg_tx_isk [ilink] <= 2'b00;
            end
            2'd3: begin
                  trg_tx_data[ilink] <= {gem_link_data[ilink][55:40]};
                  trg_tx_isk [ilink] <= 2'b00;
            end
          endcase
        end
      end

  end
  endgenerate

  //---------------------------------------------------
  // we should cycle through these four K-codes:  BC, F7, FB, FD to serve as
  // bunch sequence indicators.when we have more than 8 clusters
  // detected on an OH (an S-bit overflow)
  // we should send the "FC" K-code instead of the usual choice.
  //---------------------------------------------------

  //-local (ttc independent) counter ---------------------------------------------------------------------------------

  reg [3:0] frame_sep_cnt=0;

  always @(posedge clk_160) begin
    frame_sep_cnt <= (reset || ~ready) ? 3'd0 : frame_sep_cnt + 1'b1;
  end

  wire [1:0] frame_sep_cnt_switch = FRAME_CTRL_TTC ? bxn_counter_lsbs : frame_sep_cnt[3:2]; // take only the two MSBs because of divide by 4 40MHz <--> 160MHz conversion

  always @(*) begin
    if (bc0_i && ALLOW_TTC_CHARS)
      frame_sep <= 8'h1C;
    else if (resync_i && ALLOW_TTC_CHARS)
      frame_sep <= 8'h3C;
    else if (overflow_i && ALLOW_TTC_CHARS)
      frame_sep <= 8'hFC;
    else begin
      case (frame_sep_cnt_switch)
        2'd0:  frame_sep <= 8'hBC;
        2'd1:  frame_sep <= 8'hF7;
        2'd2:  frame_sep <= 8'hFB;
        2'd3:  frame_sep <= 8'hFD;
      endcase
    end
  end

  assign trg_tx_data_a = trg_tx_data[0];
  assign trg_tx_data_b = trg_tx_data[1];

  assign trg_tx_isk_a = trg_tx_isk[0];
  assign trg_tx_isk_b = trg_tx_isk[1];

endmodule
