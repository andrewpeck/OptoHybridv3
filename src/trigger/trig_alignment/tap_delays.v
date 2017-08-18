//--------------------------------------------------------------------------------
// CMS Muon Endcap
// GEM Collaboration
// Optohybrid v3 Firmware -- Tap Delays
// A. Peck
//--------------------------------------------------------------------------------
// Description:
//   This module holds timing parameters drived from the GEB v3 PCB
//--------------------------------------------------------------------------------
// 2017/07/24 -- Initial
//--------------------------------------------------------------------------------

localparam [23:0] SOF_POSNEG  = {
  1'b0, // SOF_POSNEG[0]  =
  1'b0, // SOF_POSNEG[1]  =
  1'b0, // SOF_POSNEG[2]  =
  1'b0, // SOF_POSNEG[3]  =
  1'b0, // SOF_POSNEG[4]  =
  1'b0, // SOF_POSNEG[5]  =
  1'b0, // SOF_POSNEG[6]  =
  1'b0, // SOF_POSNEG[7]  =
  1'b0, // SOF_POSNEG[8]  =
  1'b0, // SOF_POSNEG[9]  =
  1'b0, // SOF_POSNEG[10] =
  1'b1, // SOF_POSNEG[11] =
  1'b0, // SOF_POSNEG[12] =
  1'b0, // SOF_POSNEG[13] =
  1'b0, // SOF_POSNEG[14] =
  1'b0, // SOF_POSNEG[15] =
  1'b0, // SOF_POSNEG[16] =
  1'b0, // SOF_POSNEG[17] =
  1'b0, // SOF_POSNEG[18] =
  1'b0, // SOF_POSNEG[19] =
  1'b0, // SOF_POSNEG[20] =
  1'b0, // SOF_POSNEG[21] =
  1'b0, // SOF_POSNEG[22] =
  1'b0 // SOF_POSNEG[23] =
  };


localparam  [24*5-1:0] SOF_OFFSET  =
  120'd5  << 5*0  | // SOF_OFFSET[0]  =
  120'd5  << 5*1  | // SOF_OFFSET[1]  =
  120'd5  << 5*2  | // SOF_OFFSET[2]  =
  120'd2  << 5*3  | // SOF_OFFSET[3]  =
  120'd9  << 5*4  | // SOF_OFFSET[4]  =
  120'd0  << 5*5  | // SOF_OFFSET[5]  =
  120'd2  << 5*6  | // SOF_OFFSET[6]  =
  120'd0  << 5*7  | // SOF_OFFSET[7]  =
  120'd11 << 5*8  | // SOF_OFFSET[8]  =
  120'd1  << 5*9  | // SOF_OFFSET[9]  =
  120'd6  << 5*10 | // SOF_OFFSET[10] =
  120'd0  << 5*11 | // SOF_OFFSET[11] =
  120'd0  << 5*12 | // SOF_OFFSET[12] =
  120'd1  << 5*13 | // SOF_OFFSET[13] =
  120'd0  << 5*14 | // SOF_OFFSET[14] =
  120'd11 << 5*15 | // SOF_OFFSET[15] =
  120'd2  << 5*16 | // SOF_OFFSET[16] =
  120'd3  << 5*17 | // SOF_OFFSET[17] =
  120'd11 << 5*18 | // SOF_OFFSET[18] =
  120'd4  << 5*19 | // SOF_OFFSET[19] =
  120'd1  << 5*20 | // SOF_OFFSET[20] =
  120'd12 << 5*21 | // SOF_OFFSET[21] =
  120'd0  << 5*22 | // SOF_OFFSET[22] =
  120'd0  << 5*23;  // SOF_OFFSET[23] =

localparam [191:0] TU_POSNEG   =
  {
  1'd0, // TU_POSNEG[0][0]
  1'd0, // TU_POSNEG[0][1]
  1'd0, // TU_POSNEG[0][2]
  1'd0, // TU_POSNEG[0][3]
  1'd0, // TU_POSNEG[0][4]
  1'd0, // TU_POSNEG[0][5]
  1'd0, // TU_POSNEG[0][6]
  1'd0, // TU_POSNEG[0][7]
  1'd0, // TU_POSNEG[1][0]
  1'd0, // TU_POSNEG[1][1]
  1'd0, // TU_POSNEG[1][2]
  1'd0, // TU_POSNEG[1][3]
  1'd0, // TU_POSNEG[1][4]
  1'd0, // TU_POSNEG[1][5]
  1'd0, // TU_POSNEG[1][6]
  1'd0, // TU_POSNEG[1][7]
  1'd0, // TU_POSNEG[2][0]
  1'd0, // TU_POSNEG[2][1]
  1'd0, // TU_POSNEG[2][2]
  1'd0, // TU_POSNEG[2][3]
  1'd0, // TU_POSNEG[2][4]
  1'd0, // TU_POSNEG[2][5]
  1'd0, // TU_POSNEG[2][6]
  1'd0, // TU_POSNEG[2][7]
  1'd0, // TU_POSNEG[3][0]
  1'd0, // TU_POSNEG[3][1]
  1'd0, // TU_POSNEG[3][2]
  1'd0, // TU_POSNEG[3][3]
  1'd0, // TU_POSNEG[3][4]
  1'd0, // TU_POSNEG[3][5]
  1'd0, // TU_POSNEG[3][6]
  1'd0, // TU_POSNEG[3][7]
  1'd0, // TU_POSNEG[4][0]
  1'd0, // TU_POSNEG[4][1]
  1'd0, // TU_POSNEG[4][2]
  1'd0, // TU_POSNEG[4][3]
  1'd0, // TU_POSNEG[4][4]
  1'd0, // TU_POSNEG[4][5]
  1'd0, // TU_POSNEG[4][6]
  1'd0, // TU_POSNEG[4][7]
  1'd0, // TU_POSNEG[5][0]
  1'd0, // TU_POSNEG[5][1]
  1'd0, // TU_POSNEG[5][2]
  1'd0, // TU_POSNEG[5][3]
  1'd0, // TU_POSNEG[5][4]
  1'd0, // TU_POSNEG[5][5]
  1'd0, // TU_POSNEG[5][6]
  1'd0, // TU_POSNEG[5][7]
  1'd0, // TU_POSNEG[6][0]
  1'd0, // TU_POSNEG[6][1]
  1'd0, // TU_POSNEG[6][2]
  1'd0, // TU_POSNEG[6][3]
  1'd0, // TU_POSNEG[6][4]
  1'd0, // TU_POSNEG[6][5]
  1'd0, // TU_POSNEG[6][6]
  1'd0, // TU_POSNEG[6][7]
  1'd0, // TU_POSNEG[7][0]
  1'd0, // TU_POSNEG[7][1]
  1'd0, // TU_POSNEG[7][2]
  1'd0, // TU_POSNEG[7][3]
  1'd0, // TU_POSNEG[7][4]
  1'd0, // TU_POSNEG[7][5]
  1'd0, // TU_POSNEG[7][6]
  1'd0, // TU_POSNEG[7][7]
  1'd0, // TU_POSNEG[8][0]
  1'd0, // TU_POSNEG[8][1]
  1'd0, // TU_POSNEG[8][2]
  1'd0, // TU_POSNEG[8][3]
  1'd0, // TU_POSNEG[8][4]
  1'd0, // TU_POSNEG[8][5]
  1'd0, // TU_POSNEG[8][6]
  1'd0, // TU_POSNEG[8][7]
  1'd0, // TU_POSNEG[9][0]
  1'd0, // TU_POSNEG[9][1]
  1'd0, // TU_POSNEG[9][2]
  1'd0, // TU_POSNEG[9][3]
  1'd0, // TU_POSNEG[9][4]
  1'd0, // TU_POSNEG[9][5]
  1'd0, // TU_POSNEG[9][6]
  1'd0, // TU_POSNEG[9][7]
  1'd0, // TU_POSNEG[10][0]
  1'd0, // TU_POSNEG[10][1]
  1'd0, // TU_POSNEG[10][2]
  1'd0, // TU_POSNEG[10][3]
  1'd0, // TU_POSNEG[10][4]
  1'd0, // TU_POSNEG[10][5]
  1'd0, // TU_POSNEG[10][6]
  1'd0, // TU_POSNEG[10][7]
  1'd0, // TU_POSNEG[11][0]
  1'd0, // TU_POSNEG[11][1]
  1'd0, // TU_POSNEG[11][2]
  1'd0, // TU_POSNEG[11][3]
  1'd0, // TU_POSNEG[11][4]
  1'd0, // TU_POSNEG[11][5]
  1'd0, // TU_POSNEG[11][6]
  1'd0, // TU_POSNEG[11][7]
  1'd0, // TU_POSNEG[12][0]
  1'd0, // TU_POSNEG[12][1]
  1'd0, // TU_POSNEG[12][2]
  1'd0, // TU_POSNEG[12][3]
  1'd0, // TU_POSNEG[12][4]
  1'd0, // TU_POSNEG[12][5]
  1'd0, // TU_POSNEG[12][6]
  1'd0, // TU_POSNEG[12][7]
  1'd0, // TU_POSNEG[13][0]
  1'd0, // TU_POSNEG[13][1]
  1'd0, // TU_POSNEG[13][2]
  1'd0, // TU_POSNEG[13][3]
  1'd0, // TU_POSNEG[13][4]
  1'd0, // TU_POSNEG[13][5]
  1'd0, // TU_POSNEG[13][6]
  1'd0, // TU_POSNEG[13][7]
  1'd0, // TU_POSNEG[14][0]
  1'd0, // TU_POSNEG[14][1]
  1'd0, // TU_POSNEG[14][2]
  1'd0, // TU_POSNEG[14][3]
  1'd0, // TU_POSNEG[14][4]
  1'd0, // TU_POSNEG[14][5]
  1'd0, // TU_POSNEG[14][6]
  1'd0, // TU_POSNEG[14][7]
  1'd0, // TU_POSNEG[15][0]
  1'd0, // TU_POSNEG[15][1]
  1'd0, // TU_POSNEG[15][2]
  1'd0, // TU_POSNEG[15][3]
  1'd0, // TU_POSNEG[15][4]
  1'd0, // TU_POSNEG[15][5]
  1'd0, // TU_POSNEG[15][6]
  1'd0, // TU_POSNEG[15][7]
  1'd0, // TU_POSNEG[16][0]
  1'd0, // TU_POSNEG[16][1]
  1'd0, // TU_POSNEG[16][2]
  1'd0, // TU_POSNEG[16][3]
  1'd0, // TU_POSNEG[16][4]
  1'd0, // TU_POSNEG[16][5]
  1'd0, // TU_POSNEG[16][6]
  1'd0, // TU_POSNEG[16][7]
  1'd0, // TU_POSNEG[17][0]
  1'd0, // TU_POSNEG[17][1]
  1'd0, // TU_POSNEG[17][2]
  1'd0, // TU_POSNEG[17][3]
  1'd0, // TU_POSNEG[17][4]
  1'd0, // TU_POSNEG[17][5]
  1'd0, // TU_POSNEG[17][6]
  1'd0, // TU_POSNEG[17][7]
  1'd0, // TU_POSNEG[18][0]
  1'd0, // TU_POSNEG[18][1]
  1'd0, // TU_POSNEG[18][2]
  1'd0, // TU_POSNEG[18][3]
  1'd0, // TU_POSNEG[18][4]
  1'd0, // TU_POSNEG[18][5]
  1'd0, // TU_POSNEG[18][6]
  1'd0, // TU_POSNEG[18][7]
  1'd0, // TU_POSNEG[19][0]
  1'd0, // TU_POSNEG[19][1]
  1'd0, // TU_POSNEG[19][2]
  1'd0, // TU_POSNEG[19][3]
  1'd0, // TU_POSNEG[19][4]
  1'd0, // TU_POSNEG[19][5]
  1'd0, // TU_POSNEG[19][6]
  1'd0, // TU_POSNEG[19][7]
  1'd0, // TU_POSNEG[20][0]
  1'd0, // TU_POSNEG[20][1]
  1'd0, // TU_POSNEG[20][2]
  1'd0, // TU_POSNEG[20][3]
  1'd0, // TU_POSNEG[20][4]
  1'd0, // TU_POSNEG[20][5]
  1'd0, // TU_POSNEG[20][6]
  1'd0, // TU_POSNEG[20][7]
  1'd0, // TU_POSNEG[21][0]
  1'd0, // TU_POSNEG[21][1]
  1'd0, // TU_POSNEG[21][2]
  1'd0, // TU_POSNEG[21][3]
  1'd0, // TU_POSNEG[21][4]
  1'd0, // TU_POSNEG[21][5]
  1'd0, // TU_POSNEG[21][6]
  1'd0, // TU_POSNEG[21][7]
  1'd0, // TU_POSNEG[22][0]
  1'd0, // TU_POSNEG[22][1]
  1'd0, // TU_POSNEG[22][2]
  1'd0, // TU_POSNEG[22][3]
  1'd0, // TU_POSNEG[22][4]
  1'd0, // TU_POSNEG[22][5]
  1'd0, // TU_POSNEG[22][6]
  1'd0, // TU_POSNEG[22][7]
  1'd0, // TU_POSNEG[23][0]
  1'd0, // TU_POSNEG[23][1]
  1'd0, // TU_POSNEG[23][2]
  1'd0, // TU_POSNEG[23][3]
  1'd0, // TU_POSNEG[23][4]
  1'd0, // TU_POSNEG[23][5]
  1'd0, // TU_POSNEG[23][6]
  1'd0  // TU_POSNEG[23][7]
  };

  localparam [192*5-1:0] TU_OFFSET =
    (960'd3    << 5*0  ) |  // TU_OFFSET[0][0]
    (960'd3    << 5*1  ) |  // TU_OFFSET[0][1]
    (960'd3    << 5*2  ) |  // TU_OFFSET[0][2]
    (960'd2    << 5*3  ) |  // TU_OFFSET[0][3]
    (960'd2    << 5*4  ) |  // TU_OFFSET[0][4]
    (960'd1    << 5*5  ) |  // TU_OFFSET[0][5]
    (960'd1    << 5*6  ) |  // TU_OFFSET[0][6]
    (960'd0    << 5*7  ) |  // TU_OFFSET[0][7]
    (960'd3    << 5*8  ) |  // TU_OFFSET[1][0]
    (960'd2    << 5*9  ) |  // TU_OFFSET[1][1]
    (960'd2    << 5*10 ) |  // TU_OFFSET[1][2]
    (960'd2    << 5*11 ) |  // TU_OFFSET[1][3]
    (960'd2    << 5*12 ) |  // TU_OFFSET[1][4]
    (960'd1    << 5*13 ) |  // TU_OFFSET[1][5]
    (960'd1    << 5*14 ) |  // TU_OFFSET[1][6]
    (960'd0    << 5*15 ) |  // TU_OFFSET[1][7]
    (960'd6    << 5*16 ) |  // TU_OFFSET[2][0]
    (960'd5    << 5*17 ) |  // TU_OFFSET[2][1]
    (960'd5    << 5*18 ) |  // TU_OFFSET[2][2]
    (960'd2    << 5*19 ) |  // TU_OFFSET[2][3]
    (960'd2    << 5*20 ) |  // TU_OFFSET[2][4]
    (960'd1    << 5*21 ) |  // TU_OFFSET[2][5]
    (960'd1    << 5*22 ) |  // TU_OFFSET[2][6]
    (960'd0    << 5*23 ) |  // TU_OFFSET[2][7]
    (960'd3    << 5*24 ) |  // TU_OFFSET[3][0]
    (960'd2    << 5*25 ) |  // TU_OFFSET[3][1]
    (960'd2    << 5*26 ) |  // TU_OFFSET[3][2]
    (960'd2    << 5*27 ) |  // TU_OFFSET[3][3]
    (960'd2    << 5*28 ) |  // TU_OFFSET[3][4]
    (960'd1    << 5*29 ) |  // TU_OFFSET[3][5]
    (960'd1    << 5*30 ) |  // TU_OFFSET[3][6]
    (960'd0    << 5*31 ) |  // TU_OFFSET[3][7]
    (960'd6    << 5*32 ) |  // TU_OFFSET[4][0]
    (960'd5    << 5*33 ) |  // TU_OFFSET[4][1]
    (960'd4    << 5*34 ) |  // TU_OFFSET[4][2]
    (960'd3    << 5*35 ) |  // TU_OFFSET[4][3]
    (960'd2    << 5*36 ) |  // TU_OFFSET[4][4]
    (960'd2    << 5*37 ) |  // TU_OFFSET[4][5]
    (960'd1    << 5*38 ) |  // TU_OFFSET[4][6]
    (960'd0    << 5*39 ) |  // TU_OFFSET[4][7]
    (960'd9    << 5*40 ) |  // TU_OFFSET[5][0]
    (960'd9    << 5*41 ) |  // TU_OFFSET[5][1]
    (960'd9    << 5*42 ) |  // TU_OFFSET[5][2]
    (960'd9    << 5*43 ) |  // TU_OFFSET[5][3]
    (960'd9    << 5*44 ) |  // TU_OFFSET[5][4]
    (960'd12   << 5*45 ) |  // TU_OFFSET[5][5]
    (960'd13   << 5*46 ) |  // TU_OFFSET[5][6]
    (960'd13   << 5*47 ) |  // TU_OFFSET[5][7]
    (960'd1    << 5*48 ) |  // TU_OFFSET[6][0]
    (960'd1    << 5*49 ) |  // TU_OFFSET[6][1]
    (960'd1    << 5*50 ) |  // TU_OFFSET[6][2]
    (960'd1    << 5*51 ) |  // TU_OFFSET[6][3]
    (960'd0    << 5*52 ) |  // TU_OFFSET[6][4]
    (960'd0    << 5*53 ) |  // TU_OFFSET[6][5]
    (960'd0    << 5*54 ) |  // TU_OFFSET[6][6]
    (960'd0    << 5*55 ) |  // TU_OFFSET[6][7]
    (960'd1    << 5*56 ) |  // TU_OFFSET[7][0]
    (960'd1    << 5*57 ) |  // TU_OFFSET[7][1]
    (960'd2    << 5*58 ) |  // TU_OFFSET[7][2]
    (960'd2    << 5*59 ) |  // TU_OFFSET[7][3]
    (960'd2    << 5*60 ) |  // TU_OFFSET[7][4]
    (960'd3    << 5*61 ) |  // TU_OFFSET[7][5]
    (960'd3    << 5*62 ) |  // TU_OFFSET[7][6]
    (960'd3    << 5*63 ) |  // TU_OFFSET[7][7]
    (960'd0    << 5*64 ) |  // TU_OFFSET[8][0]
    (960'd0    << 5*65 ) |  // TU_OFFSET[8][1]
    (960'd9    << 5*66 ) |  // TU_OFFSET[8][2]
    (960'd8    << 5*67 ) |  // TU_OFFSET[8][3]
    (960'd9    << 5*68 ) |  // TU_OFFSET[8][4]
    (960'd9    << 5*69 ) |  // TU_OFFSET[8][5]
    (960'd9    << 5*70 ) |  // TU_OFFSET[8][6]
    (960'd8    << 5*71 ) |  // TU_OFFSET[8][7]
    (960'd0    << 5*72 ) |  // TU_OFFSET[9][0]
    (960'd0    << 5*73 ) |  // TU_OFFSET[9][1]
    (960'd1    << 5*74 ) |  // TU_OFFSET[9][2]
    (960'd0    << 5*75 ) |  // TU_OFFSET[9][3]
    (960'd1    << 5*76 ) |  // TU_OFFSET[9][4]
    (960'd1    << 5*77 ) |  // TU_OFFSET[9][5]
    (960'd1    << 5*78 ) |  // TU_OFFSET[9][6]
    (960'd1    << 5*79 ) |  // TU_OFFSET[9][7]
    (960'd0    << 5*80 ) |  // TU_OFFSET[10][0]
    (960'd0    << 5*81 ) |  // TU_OFFSET[10][1]
    (960'd1    << 5*82 ) |  // TU_OFFSET[10][2]
    (960'd1    << 5*83 ) |  // TU_OFFSET[10][3]
    (960'd1    << 5*84 ) |  // TU_OFFSET[10][4]
    (960'd1    << 5*85 ) |  // TU_OFFSET[10][5]
    (960'd2    << 5*86 ) |  // TU_OFFSET[10][6]
    (960'd2    << 5*87 ) |  // TU_OFFSET[10][7]
    (960'd7    << 5*88 ) |  // TU_OFFSET[11][0]
    (960'd7    << 5*89 ) |  // TU_OFFSET[11][1]
    (960'd8    << 5*90 ) |  // TU_OFFSET[11][2]
    (960'd9    << 5*91 ) |  // TU_OFFSET[11][3]
    (960'd9    << 5*92 ) |  // TU_OFFSET[11][4]
    (960'd10   << 5*93 ) |  // TU_OFFSET[11][5]
    (960'd13   << 5*94 ) |  // TU_OFFSET[11][6]
    (960'd13   << 5*95 ) |  // TU_OFFSET[11][7]
    (960'd1    << 5*96 ) |  // TU_OFFSET[12][0]
    (960'd5    << 5*97 ) |  // TU_OFFSET[12][1]
    (960'd5    << 5*98 ) |  // TU_OFFSET[12][2]
    (960'd4    << 5*99 ) |  // TU_OFFSET[12][3]
    (960'd4    << 5*100) |  // TU_OFFSET[12][4]
    (960'd4    << 5*101) |  // TU_OFFSET[12][5]
    (960'd4    << 5*102) |  // TU_OFFSET[12][6]
    (960'd3    << 5*103) |  // TU_OFFSET[12][7]
    (960'd2    << 5*104) |  // TU_OFFSET[13][0]
    (960'd2    << 5*105) |  // TU_OFFSET[13][1]
    (960'd1    << 5*106) |  // TU_OFFSET[13][2]
    (960'd1    << 5*107) |  // TU_OFFSET[13][3]
    (960'd1    << 5*108) |  // TU_OFFSET[13][4]
    (960'd1    << 5*109) |  // TU_OFFSET[13][5]
    (960'd0    << 5*110) |  // TU_OFFSET[13][6]
    (960'd0    << 5*111) |  // TU_OFFSET[13][7]
    (960'd3    << 5*112) |  // TU_OFFSET[14][0]
    (960'd3    << 5*113) |  // TU_OFFSET[14][1]
    (960'd3    << 5*114) |  // TU_OFFSET[14][2]
    (960'd2    << 5*115) |  // TU_OFFSET[14][3]
    (960'd2    << 5*116) |  // TU_OFFSET[14][4]
    (960'd2    << 5*117) |  // TU_OFFSET[14][5]
    (960'd2    << 5*118) |  // TU_OFFSET[14][6]
    (960'd4    << 5*119) |  // TU_OFFSET[14][7]
    (960'd0    << 5*120) |  // TU_OFFSET[15][0]
    (960'd1    << 5*121) |  // TU_OFFSET[15][1]
    (960'd2    << 5*122) |  // TU_OFFSET[15][2]
    (960'd2    << 5*123) |  // TU_OFFSET[15][3]
    (960'd3    << 5*124) |  // TU_OFFSET[15][4]
    (960'd4    << 5*125) |  // TU_OFFSET[15][5]
    (960'd5    << 5*126) |  // TU_OFFSET[15][6]
    (960'd6    << 5*127) |  // TU_OFFSET[15][7]
    (960'd0    << 5*128) |  // TU_OFFSET[16][0]
    (960'd0    << 5*129) |  // TU_OFFSET[16][1]
    (960'd0    << 5*130) |  // TU_OFFSET[16][2]
    (960'd1    << 5*131) |  // TU_OFFSET[16][3]
    (960'd1    << 5*132) |  // TU_OFFSET[16][4]
    (960'd2    << 5*133) |  // TU_OFFSET[16][5]
    (960'd2    << 5*134) |  // TU_OFFSET[16][6]
    (960'd2    << 5*135) |  // TU_OFFSET[16][7]
    (960'd0    << 5*136) |  // TU_OFFSET[17][0]
    (960'd0    << 5*137) |  // TU_OFFSET[17][1]
    (960'd1    << 5*138) |  // TU_OFFSET[17][2]
    (960'd1    << 5*139) |  // TU_OFFSET[17][3]
    (960'd2    << 5*140) |  // TU_OFFSET[17][4]
    (960'd2    << 5*141) |  // TU_OFFSET[17][5]
    (960'd3    << 5*142) |  // TU_OFFSET[17][6]
    (960'd3    << 5*143) |  // TU_OFFSET[17][7]
    (960'd0    << 5*144) |  // TU_OFFSET[18][0]
    (960'd1    << 5*145) |  // TU_OFFSET[18][1]
    (960'd1    << 5*146) |  // TU_OFFSET[18][2]
    (960'd1    << 5*147) |  // TU_OFFSET[18][3]
    (960'd1    << 5*148) |  // TU_OFFSET[18][4]
    (960'd2    << 5*149) |  // TU_OFFSET[18][5]
    (960'd2    << 5*150) |  // TU_OFFSET[18][6]
    (960'd2    << 5*151) |  // TU_OFFSET[18][7]
    (960'd0    << 5*152) |  // TU_OFFSET[19][0]
    (960'd0    << 5*153) |  // TU_OFFSET[19][1]
    (960'd1    << 5*154) |  // TU_OFFSET[19][2]
    (960'd2    << 5*155) |  // TU_OFFSET[19][3]
    (960'd3    << 5*156) |  // TU_OFFSET[19][4]
    (960'd3    << 5*157) |  // TU_OFFSET[19][5]
    (960'd3    << 5*158) |  // TU_OFFSET[19][6]
    (960'd4    << 5*159) |  // TU_OFFSET[19][7]
    (960'd2    << 5*160) |  // TU_OFFSET[20][0]
    (960'd2    << 5*161) |  // TU_OFFSET[20][1]
    (960'd1    << 5*162) |  // TU_OFFSET[20][2]
    (960'd1    << 5*163) |  // TU_OFFSET[20][3]
    (960'd1    << 5*164) |  // TU_OFFSET[20][4]
    (960'd1    << 5*165) |  // TU_OFFSET[20][5]
    (960'd0    << 5*166) |  // TU_OFFSET[20][6]
    (960'd0    << 5*167) |  // TU_OFFSET[20][7]
    (960'd0    << 5*168) |  // TU_OFFSET[21][0]
    (960'd0    << 5*169) |  // TU_OFFSET[21][1]
    (960'd0    << 5*170) |  // TU_OFFSET[21][2]
    (960'd0    << 5*171) |  // TU_OFFSET[21][3]
    (960'd0    << 5*172) |  // TU_OFFSET[21][4]
    (960'd0    << 5*173) |  // TU_OFFSET[21][5]
    (960'd0    << 5*174) |  // TU_OFFSET[21][6]
    (960'd15   << 5*175) |  // TU_OFFSET[21][7]
    (960'd9    << 5*176) |  // TU_OFFSET[22][0]
    (960'd9    << 5*177) |  // TU_OFFSET[22][1]
    (960'd8    << 5*178) |  // TU_OFFSET[22][2]
    (960'd8    << 5*179) |  // TU_OFFSET[22][3]
    (960'd8    << 5*180) |  // TU_OFFSET[22][4]
    (960'd8    << 5*181) |  // TU_OFFSET[22][5]
    (960'd7    << 5*182) |  // TU_OFFSET[22][6]
    (960'd7    << 5*183) |  // TU_OFFSET[22][7]
    (960'd12   << 5*184) |  // TU_OFFSET[23][0]
    (960'd11   << 5*185) |  // TU_OFFSET[23][1]
    (960'd11   << 5*186) |  // TU_OFFSET[23][2]
    (960'd10   << 5*187) |  // TU_OFFSET[23][3]
    (960'd10   << 5*188) |  // TU_OFFSET[23][4]
    (960'd10   << 5*189) |  // TU_OFFSET[23][5]
    (960'd10   << 5*190) |  // TU_OFFSET[23][6]
    (960'd10   << 5*191) ;  // TU_OFFSET[23][7]

