library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity a7_gtp_wrapper is
  port
  (
    refclk_in_p               : in std_logic;
    refclk_in_n               : in std_logic;

    sysclk_in                 : in   std_logic;

    soft_reset_tx_in          : in   std_logic;

    pll_lock_out              : out  std_logic;

    txn_out                   : out  std_logic_vector(3 downto 0);
    txp_out                   : out  std_logic_vector(3 downto 0);

    tx_fsm_reset_done         : out std_logic_vector (3 downto 0);

    gt0_txcharisk_i           : in   std_logic_vector(1 downto 0);
    gt1_txcharisk_i           : in   std_logic_vector(1 downto 0);
    gt2_txcharisk_i           : in   std_logic_vector(1 downto 0);
    gt3_txcharisk_i           : in   std_logic_vector(1 downto 0);

    gt0_txdata_i              : in   std_logic_vector(15 downto 0);
    gt1_txdata_i              : in   std_logic_vector(15 downto 0);
    gt2_txdata_i              : in   std_logic_vector(15 downto 0);
    gt3_txdata_i              : in   std_logic_vector(15 downto 0);

    txusrclk_i                : in    std_logic

  );

end a7_gtp_wrapper;

architecture RTL of a7_gtp_wrapper is

  --GT0  (X0Y0)

  --------------- Transmit Ports - TX Configurable Driver Ports --------------
  signal  gt0_txdiffctrl_i                : std_logic_vector(3 downto 0);

  --GT1  (X0Y1)

  --------------- Transmit Ports - TX Configurable Driver Ports --------------
  signal  gt1_txdiffctrl_i                : std_logic_vector(3 downto 0);

  --GT2  (X0Y2)

  --------------- Transmit Ports - TX Configurable Driver Ports --------------
  signal  gt2_txdiffctrl_i                : std_logic_vector(3 downto 0);

  --GT3  (X0Y3)

  --------------- Transmit Ports - TX Configurable Driver Ports --------------
  signal  gt3_txdiffctrl_i                : std_logic_vector(3 downto 0);


  signal cpll_reset         : std_logic;
  signal cpll_pd            : std_logic;
  signal pllreset           : std_logic;
  signal refclk             : std_logic;
  signal common_reset       : std_logic;
  signal pll_outclk         : std_logic;
  signal pll_lock           : std_logic;
  signal pll_outrefclk      : std_logic;
  signal pll_refclklost     : std_logic;
  signal pll_reset_from_gtp : std_logic;

  attribute keep: string;

begin

  ------------ optional Ports assignments --------------
  gt0_txdiffctrl_i                             <= "1100";
  gt1_txdiffctrl_i                             <= "1100";
  gt2_txdiffctrl_i                             <= "1100";
  gt3_txdiffctrl_i                             <= "1100";
  ------------------------------------------------------

  pll_lock_out <= pll_lock;

    --IBUFDS_GTE2
  ibufds_i : IBUFDS_GTE2
  port map
  (
    O               => refclk,
    ODIV2           => open,
    CEB             => std_logic'('0'),
    I               => refclk_in_p,
    IB              => refclk_in_n
  );

  common_i : entity work.a7_mgts_common
  generic map
  (
    WRAPPER_SIM_GTRESET_SPEEDUP => string'("FALSE"),
    SIM_PLL0REFCLK_SEL => bit_vector'("001"),
    SIM_PLL1REFCLK_SEL => bit_vector'("001")
  )
  port map
  (
    DRPADDR_COMMON_IN  => std_logic_vector'(others => '0'),
    DRPCLK_COMMON_IN   => sysclk_in,
    DRPDI_COMMON_IN    => std_logic_vector'(others => '0'),
    DRPDO_COMMON_OUT   => open,
    DRPEN_COMMON_IN    => std_logic'('0'),
    DRPRDY_COMMON_OUT  => open,
    DRPWE_COMMON_IN    => std_logic'('0'),
    PLL0OUTCLK_OUT     => pll_outclk,
    PLL0OUTREFCLK_OUT  => pll_outrefclk,
    PLL0LOCK_OUT       => pll_lock,
    PLL0LOCKDETCLK_IN  => sysclk_in,
    PLL0REFCLKLOST_OUT => pll_refclklost,
    PLL0REFCLKSEL_IN   => std_logic_vector'("001"),
    PLL0PD_IN          => cpll_pd,
    PLL0RESET_IN       => pll_reset_from_gtp or cpll_reset or common_reset,
    PLL1OUTCLK_OUT     => open,
    PLL1OUTREFCLK_OUT  => open,
    GTREFCLK0_IN       => refclk,
    GTREFCLK1_IN       => std_logic'('0')


  );

  common_reset_i : entity work.a7_mgts_common_reset
  generic map (
    STABLE_CLOCK_PERIOD => integer'(25) -- Period of the stable clock driving this state-machine, unit is [ns]
  )
  port map (
    STABLE_CLOCK => sysclk_in,        -- Stable Clock, either a stable clock from the PCB
    SOFT_RESET   => soft_reset_tx_in, -- User Reset, can be pulled any time
    COMMON_RESET => common_reset      -- Reset QPLL
  );


  a7_mgts_init_i : entity work.a7_mgts_init
  port map
  (
    soft_reset_tx_in                => soft_reset_tx_in,

    dont_reset_on_data_error_in     => std_logic'('0'),

    gt0_data_valid_in               => std_logic'('0'),
    gt1_data_valid_in               => std_logic'('0'),
    gt2_data_valid_in               => std_logic'('0'),
    gt3_data_valid_in               => std_logic'('0'),

    gt0_tx_fsm_reset_done_out       => tx_fsm_reset_done(0),
    gt1_tx_fsm_reset_done_out       => tx_fsm_reset_done(1),
    gt2_tx_fsm_reset_done_out       => tx_fsm_reset_done(2),
    gt3_tx_fsm_reset_done_out       => tx_fsm_reset_done(3),

    gt0_rx_fsm_reset_done_out       => open,
    gt1_rx_fsm_reset_done_out       => open,
    gt2_rx_fsm_reset_done_out       => open,
    gt3_rx_fsm_reset_done_out       => open,

    --_____________________________________________________________________
    --_____________________________________________________________________
    --GT0

    ---------------------------- Channel - DRP Ports  --------------------------
    gt0_drpaddr_in                  =>      std_logic_vector'(others => '0'),
    gt0_drpclk_in                   =>      sysclk_in,
    gt0_drpdi_in                    =>      std_logic_vector'(others => '0'),
    gt0_drpdo_out                   =>      open,
    gt0_drpen_in                    =>      std_logic'('0'),
    gt0_drprdy_out                  =>      open,
    gt0_drpwe_in                    =>      std_logic'('0'),

    --------------------- RX Initialization and Reset Ports --------------------
    gt0_eyescanreset_in             =>      std_logic'('0'),
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out        =>      open,
    gt0_eyescantrigger_in           =>      std_logic'('0'),
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt0_dmonitorout_out             =>      open,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in                =>      std_logic'('0'),
    gt0_rxlpmreset_in               =>      std_logic'('0'),
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in                =>      std_logic'('0'), -- not internally connected
    gt0_txuserrdy_in                =>      std_logic'('0'), -- not internally connected
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    gt0_txdata_in                   =>      gt0_txdata_i,
    gt0_txusrclk_in                 =>      txusrclk_i,
    gt0_txusrclk2_in                =>      txusrclk_i,
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt0_txcharisk_in                =>      gt0_txcharisk_i,
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    gt0_gtptxn_out                  =>      txn_out(0),
    gt0_gtptxp_out                  =>      txp_out(0),
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt0_txoutclkfabric_out          =>      open,
    gt0_txoutclkpcs_out             =>      open,
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt0_txresetdone_out             =>      open,

    --_____________________________________________________________________
    --_____________________________________________________________________
    --GT1

    ---------------------------- Channel - DRP Ports  --------------------------
    gt1_drpaddr_in                  =>      std_logic_vector'(others => '0'),
    gt1_drpclk_in                   =>      sysclk_in,
    gt1_drpdi_in                    =>      std_logic_vector'(others => '0'),
    gt1_drpdo_out                   =>      open,
    gt1_drpen_in                    =>      std_logic'('0'),
    gt1_drprdy_out                  =>      open,
    gt1_drpwe_in                    =>      std_logic'('0'),

    --------------------- RX Initialization and Reset Ports --------------------
    gt1_eyescanreset_in             =>      std_logic'('0'),
    -------------------------- RX Margin Analysis Ports ------------------------
    gt1_eyescandataerror_out        =>      open,
    gt1_eyescantrigger_in           =>      std_logic'('0'),
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt1_dmonitorout_out             =>      open,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt1_gtrxreset_in                =>      std_logic'('0'),
    gt1_rxlpmreset_in               =>      std_logic'('0'),
    --------------------- TX Initialization and Reset Ports --------------------
    gt1_gttxreset_in                =>      std_logic'('0'), -- not internally connected
    gt1_txuserrdy_in                =>      std_logic'('0'), -- not internally connected
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    gt1_txdata_in                   =>      gt1_txdata_i,
    gt1_txusrclk_in                 =>      txusrclk_i,
    gt1_txusrclk2_in                =>      txusrclk_i,
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt1_txcharisk_in                =>      gt1_txcharisk_i,
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    gt1_gtptxn_out                  =>      txn_out(1),
    gt1_gtptxp_out                  =>      txp_out(1),
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt1_txoutclkfabric_out          =>      open,
    gt1_txoutclkpcs_out             =>      open,
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt1_txresetdone_out             =>      open,

    --_____________________________________________________________________
    --_____________________________________________________________________
    --GT2

    ---------------------------- Channel - DRP Ports  --------------------------
    gt2_drpaddr_in                  =>      std_logic_vector'(others => '0'),
    gt2_drpclk_in                   =>      sysclk_in,
    gt2_drpdi_in                    =>      std_logic_vector'(others => '0'),
    gt2_drpdo_out                   =>      open,
    gt2_drpen_in                    =>      std_logic'('0'),
    gt2_drprdy_out                  =>      open,
    gt2_drpwe_in                    =>      std_logic'('0'),

    --------------------- RX Initialization and Reset Ports --------------------
    gt2_eyescanreset_in             =>      std_logic'('0'),
    -------------------------- RX Margin Analysis Ports ------------------------
    gt2_eyescandataerror_out        =>      open,
    gt2_eyescantrigger_in           =>      std_logic'('0'),
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt2_dmonitorout_out             =>      open,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt2_gtrxreset_in                =>      std_logic'('0'),
    gt2_rxlpmreset_in               =>      std_logic'('0'),
    --------------------- TX Initialization and Reset Ports --------------------
    gt2_gttxreset_in                =>      std_logic'('0'), -- not internally connected
    gt2_txuserrdy_in                =>      std_logic'('0'), -- not internally connected
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    gt2_txdata_in                   =>      gt2_txdata_i,
    gt2_txusrclk_in                 =>      txusrclk_i,
    gt2_txusrclk2_in                =>      txusrclk_i,
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt2_txcharisk_in                =>      gt2_txcharisk_i,
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    gt2_gtptxn_out                  =>      txn_out(2),
    gt2_gtptxp_out                  =>      txp_out(2),
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt2_txoutclkfabric_out          =>      open,
    gt2_txoutclkpcs_out             =>      open,
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt2_txresetdone_out             =>      open,

    --_____________________________________________________________________
    --_____________________________________________________________________
    --GT3

    ---------------------------- Channel - DRP Ports  --------------------------
    gt3_drpaddr_in                  =>      std_logic_vector'(others => '0'),
    gt3_drpclk_in                   =>      sysclk_in,
    gt3_drpdi_in                    =>      std_logic_vector'(others => '0'),
    gt3_drpdo_out                   =>      open,
    gt3_drpen_in                    =>      std_logic'('0'),
    gt3_drprdy_out                  =>      open,
    gt3_drpwe_in                    =>      std_logic'('0'),

    --------------------- RX Initialization and Reset Ports --------------------
    gt3_eyescanreset_in             =>      std_logic'('0'),
    -------------------------- RX Margin Analysis Ports ------------------------
    gt3_eyescandataerror_out        =>      open,
    gt3_eyescantrigger_in           =>      std_logic'('0'),
    ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    gt3_dmonitorout_out             =>      open,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt3_gtrxreset_in                =>      std_logic'('0'),
    gt3_rxlpmreset_in               =>      std_logic'('0'),
    --------------------- TX Initialization and Reset Ports --------------------
    gt3_gttxreset_in                =>      std_logic'('0'), -- not internally connected
    gt3_txuserrdy_in                =>      std_logic'('0'), -- not internally connected
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    gt3_txdata_in                   =>      gt3_txdata_i,
    gt3_txusrclk_in                 =>      txusrclk_i,
    gt3_txusrclk2_in                =>      txusrclk_i,
    ------------------ Transmit Ports - TX 8B/10B Encoder Ports ----------------
    gt3_txcharisk_in                =>      gt3_txcharisk_i,
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    gt3_gtptxn_out                  =>      txn_out(3),
    gt3_gtptxp_out                  =>      txp_out(3),
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt3_txoutclkfabric_out          =>      open,
    gt3_txoutclkpcs_out             =>      open,
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt3_txresetdone_out             =>      open,

    --____________________________COMMON PORTS________________________________
    gt0_pll0outclk_in               => pll_outclk,
    gt0_pll0outrefclk_in            => pll_outrefclk,
    gt0_pll0reset_out               => pll_reset_from_gtp,
    gt0_pll0lock_in                 => pll_lock,
    gt0_pll0refclklost_in           => pll_refclklost,
    gt0_pll1outclk_in               => '0',
    gt0_pll1outrefclk_in            => '0',

    sysclk_in                       => sysclk_in
  );

  cpll_reset_i : entity work.a7_mgts_cpll_railing
  generic map( USE_BUFG => 0)
  port map (
    cpll_reset_out => cpll_reset,
    cpll_pd_out    => cpll_pd,
    refclk_out     => open,
    refclk_in      => refclk
  );

end RTL;
