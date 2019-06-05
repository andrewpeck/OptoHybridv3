---------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- Top Logic
-- A. Peck, E. Juska, T. Lenzi
----------------------------------------------------------------------------------
-- 2017/07/21 -- Initial port to version 3 electronics
-- 2017/07/22 -- Additional MMCM added to monitor and dejitter the eport clock
-- 2017/07/25 -- Restructure top level module to improve organization
-- 2018/04/18 -- Mods for for OH lite compatibility
-- 2019/05/09 -- Implementation of new gated clocking scheme
----------------------------------------------------------------------------------
-- TODO: triplicate IPBus control

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;
use work.ipbus_pkg.all;
use work.trig_pkg.all;
use work.param_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity optohybrid_top is
port(

    --== Clocking ==--

    clock_p : in std_logic;
    clock_n : in std_logic;

    --== Elinks ==--

    elink_i_p : in  std_logic;
    elink_i_n : in  std_logic;

    elink_o_p : out std_logic;
    elink_o_n : out std_logic;

    --== GBT ==--

    -- only 1 connected in GE11, 2 in GE21
    gbt_txready_i : in std_logic_vector (MXREADY-1 downto 0);
    gbt_rxvalid_i : in std_logic_vector (MXREADY-1 downto 0);
    gbt_rxready_i : in std_logic_vector (MXREADY-1 downto 0);

    -- START: Station Specific Ports DO NOT EDIT --

    ext_sbits_o : out  std_logic_vector (7 downto 0);

    ext_reset_o : out  std_logic_vector (MXRESET-1 downto 0);

    adc_vp      : in   std_logic;
    adc_vn      : in   std_logic;
    -- END: Station Specific Ports DO NOT EDIT --

    --== LEDs ==--

    led_o   : out std_logic_vector (MXLED-1 downto 0);

    --== GTX ==--

    mgt_clk_p_i : in std_logic_vector (1 downto 0);
    mgt_clk_n_i : in std_logic_vector (1 downto 0);

    mgt_tx_p_o : out std_logic_vector(3 downto 0);
    mgt_tx_n_o : out std_logic_vector(3 downto 0);

    --== VFAT Trigger Data ==--

    vfat_sot_p : in std_logic_vector (MXVFATS-1 downto 0);
    vfat_sot_n : in std_logic_vector (MXVFATS-1 downto 0);

    vfat_sbits_p : in std_logic_vector ((MXVFATS*8)-1 downto 0);
    vfat_sbits_n : in std_logic_vector ((MXVFATS*8)-1 downto 0)

);
end optohybrid_top;

architecture Behavioral of optohybrid_top is

    --== SBit cluster packer ==--

    signal cluster_count : std_logic_vector     (10  downto 0);
    signal active_vfats  : std_logic_vector     (MXVFATS-1 downto 0);

    --== Global signals ==--

    signal mmcms_locked     : std_logic;
    signal trigger_mmcm_locked : std_logic;
    signal logic_mmcm_reset : std_logic;
    signal core_mmcm_locked : std_logic;

    signal clk_1x    : std_logic;
    signal clk_2x    : std_logic;
    signal clk_4x    : std_logic;
    signal clk_4x_90 : std_logic;
    signal clk_5x    : std_logic;

    signal clk_1x_trigger    : std_logic;
    signal clk_2x_trigger    : std_logic;
    signal clk_4x_trigger    : std_logic;
    signal clk_5x_trigger    : std_logic;
    signal clk_4x_90_trigger : std_logic;

    signal vtrx_mabs        : std_logic_vector (1 downto 0);

    signal gbt_txvalid      : std_logic_vector (MXREADY-1 downto 0);
    signal gbt_txready      : std_logic_vector (MXREADY-1 downto 0);
    signal gbt_rxvalid      : std_logic_vector (MXREADY-1 downto 0);
    signal gbt_rxready      : std_logic_vector (MXREADY-1 downto 0);

    signal gbt_link_rdy        : std_logic;
    signal gbt_request_received : std_logic;

    signal mgts_ready       : std_logic;
    signal pll_lock         : std_logic;
    signal txfsm_done       : std_logic;

    signal trigger_reset            : std_logic;
    signal core_reset       : std_logic;
    signal cnt_snap         : std_logic;

    signal dna : std_logic_vector (56 downto 0);

    signal ctrl_reset_vfats       : std_logic_vector (11 downto 0);
    signal ttc_resync             : std_logic;
    signal ttc_l1a                : std_logic;
    signal ttc_bc0                : std_logic;

    --== Wishbone ==--

    -- Master
    signal ipb_mosi_gbt : ipb_wbus;
    signal ipb_miso_gbt : ipb_rbus;

    -- Master
    signal ipb_mosi_masters : ipb_wbus_array (WB_MASTERS-1 downto 0);
    signal ipb_miso_masters : ipb_rbus_array (WB_MASTERS-1 downto 0);

    -- Slaves
    signal ipb_mosi_slaves  : ipb_wbus_array (WB_SLAVES-1 downto 0);
    signal ipb_miso_slaves  : ipb_rbus_array (WB_SLAVES-1 downto 0);

    --== TTC ==--

    signal bxn_counter  : std_logic_vector(11 downto 0);
    signal trig_stop    : std_logic;

    --== IOB Constraints for Outputs ==--

    attribute IOB : string;
    attribute KEEP : string;

    signal ext_sbits : std_logic_vector (7 downto 0);
    signal soft_reset : std_logic;
    signal reset_init : std_logic;

    signal led : std_logic_vector (15 downto 0);

    -- don't remove duplicates for fanout, needed to pack into iob
    signal ext_reset : std_logic_vector (11 downto 0);

    -- START: Station Specific Signals DO NOT EDIT --

    -- END: Station Specific Signals DO NOT EDIT --

    attribute IODELAY_GROUP: string;
    attribute IODELAY_GROUP of delayctrl : label is "IODELAY_GROUP";

begin


    --------------------------------------------------------------------------------------------------------------------
    -- Wiring
    --------------------------------------------------------------------------------------------------------------------

    led_o (MXLED-1 downto 0) <= led (MXLED-1 downto 0);

    gbt_request_received <= ipb_mosi_gbt.ipb_strobe;

    gbt_rxready   <= gbt_rxready_i;
    gbt_rxvalid   <= gbt_rxvalid_i;
    gbt_txready   <= gbt_txready_i;

    -- START: Station Specific IO DO NOT EDIT --
    --===========--
    --== GE11  ==--
    --===========--
    ext_reset_o  <= ctrl_reset_vfats;
    ext_sbits_o  <= ext_sbits;
    -- END: Station Specific IO DO NOT EDIT --

    --------------------------------------------------------------------------------------------------------------------
    -- Clocking
    --------------------------------------------------------------------------------------------------------------------

    clocking : entity work.clocking
    port map(

        -- clock input from pins
        clock_i_p       => clock_p, -- phase shiftable 40MHz ttc clocks
        clock_i_n       => clock_n, --

        -- ipbus
        ipb_mosi_i          => ipb_mosi_slaves (IPB_SLAVE.CLOCKING),
        ipb_miso_o          => ipb_miso_slaves (IPB_SLAVE.CLOCKING),
        ipb_reset_i         => core_reset,

        -- mmcm locked outputs
        mmcms_locked_o      => mmcms_locked,
        core_mmcm_locked_o   => core_mmcm_locked,
        trigger_mmcm_locked_o => trigger_mmcm_locked,

        -- gbt communication clocks

        clock_enable_i      => mgts_ready,

        -- logic clocks
        clk_1x_o            => clk_1x,
        clk_2x_o            => clk_2x,
        clk_4x_o            => clk_4x,
        clk_4x_90_o         => clk_4x_90,  -- 160  MHz e-port aligned GBT clock
        clk_5x_o            => clk_5x,

        -- trigger (stoppable) clocks
        clk_1x_gated_o      => clk_1x_trigger, -- phase shiftable logic clocks
        clk_2x_gated_o      => clk_2x_trigger,
        clk_4x_gated_o      => clk_4x_trigger,
        clk_5x_gated_o      => clk_5x_trigger,
        clk_4x_90_gated_o   => clk_4x_90_trigger
    );

    --------------------------------------------------------------------------------------------------------------------
    -- Reset
    --------------------------------------------------------------------------------------------------------------------

    reset_init <= soft_reset or (not mgts_ready);
    reset_ctl : entity work.reset_tmr
    port map (
        clock_i        => clk_1x,
        soft_reset     => reset_init,
        mmcms_locked_i => mmcms_locked,
        gbt_rxready_i  => gbt_rxready(0),
        gbt_rxvalid_i  => gbt_rxvalid(0),
        gbt_txready_i  => gbt_txready(0),
        core_reset_o   => core_reset,
        reset_o        => trigger_reset
    );

    --------------------------------------------------------------------------------------------------------------------
    -- GBT Communication
    --------------------------------------------------------------------------------------------------------------------

    gbt : entity work.gbt
    port map(

        -- reset

        rst_i              => core_reset,

        -- input clocks

        clk_1x             => clk_1x,     -- 40 MHz frame clock
        clk_2x             => clk_2x,     -- 80  MHz e-port aligned GBT clock
        clk_4x             => clk_4x,  --
        clk_4x_90          => clk_4x_90, --

        -- GBT

        gbt_rxready_i      => gbt_rxready(0),
        gbt_rxvalid_i      => gbt_rxvalid(0),
        gbt_txready_i      => gbt_txready(0),

        -- elinks
        elink_i_p          => elink_i_p,
        elink_i_n          => elink_i_n,

        elink_o_p          => elink_o_p,
        elink_o_n          => elink_o_n,

        gbt_link_rdy_o     => gbt_link_rdy,

        -- wishbone master
        ipb_mosi_o         => ipb_mosi_gbt,
        ipb_miso_i         => ipb_miso_gbt,

        -- wishbone slave

        ipb_mosi_i         => ipb_mosi_slaves (IPB_SLAVE.GBT),
        ipb_miso_o         => ipb_miso_slaves (IPB_SLAVE.GBT),
        ipb_rst_i          => core_reset,

        cnt_snap           => cnt_snap,

        -- decoded TTC
        resync_o           => ttc_resync,
        l1a_o              => ttc_l1a,
        bc0_o              => ttc_bc0

    );

    --------------------------------------------------------------------------------------------------------------------
    -- Wishbone switch
    --------------------------------------------------------------------------------------------------------------------

    -- This module is the Wishbone switch which redirects requests from the masters to the slaves.

    ipb_mosi_masters(0) <= ipb_mosi_gbt;
    ipb_miso_gbt <= ipb_miso_masters(0);

    ipb_switch_inst : entity work.ipb_switch_tmr
    port map(
        clock_i              => clk_1x,
        reset_i              => core_reset,

        -- connect to master
        mosi_masters         => ipb_mosi_masters,
        miso_masters         => ipb_miso_masters,

        -- connect to slaves
        mosi_slaves          => ipb_mosi_slaves,
        miso_slaves          => ipb_miso_slaves
    );

    --------------------------------------------------------------------------------------------------------------------
    -- XADC Instantiation
    --------------------------------------------------------------------------------------------------------------------

    adc_inst : entity work.adc port map(
        clock_i     => clk_1x,
        reset_i     => core_reset,

        cnt_snap    => cnt_snap,

        ipb_mosi_i  => ipb_mosi_slaves (IPB_SLAVE.ADC),
        ipb_miso_o  => ipb_miso_slaves (IPB_SLAVE.ADC),
        ipb_reset_i => core_reset,
        ipb_clk_i   => clk_1x,

        adc_vp      => adc_vp,
        adc_vn      => adc_vn
    );

    --------------------------------------------------------------------------------------------------------------------
    -- Control
    --------------------------------------------------------------------------------------------------------------------

    control : entity work.control
    port map (

        mgts_ready             => mgts_ready,
        pll_lock               => pll_lock,
        txfsm_done             => txfsm_done,

        --== TTC ==--

        clock_i                => clk_1x,
        gbt_clock_i            => clk_1x,
        reset_i                => core_reset,

        ttc_l1a                => ttc_l1a,
        ttc_bc0                => ttc_bc0,
        ttc_resync             => ttc_resync,

        ipb_mosi_i             => ipb_mosi_slaves (IPB_SLAVE.CONTROL),
        ipb_miso_o             => ipb_miso_slaves (IPB_SLAVE.CONTROL),

        -- MMCM
        mmcms_locked_i         => mmcms_locked,
        trigger_mmcm_locked_i  => trigger_mmcm_locked,
        core_mmcm_locked_i     => core_mmcm_locked,

        -- GBT
        dna  => dna,

        -- GBT

        gbt_link_ready_i       => gbt_link_rdy,

        gbt_rxready_i          => gbt_rxready(0),
        gbt_rxvalid_i          => gbt_rxvalid(0),
        gbt_txready_i          => gbt_txready(0),

        gbt_request_received_i => gbt_request_received,

        -- Trigger

        active_vfats_i         => active_vfats,
        cluster_count_i        => cluster_count,

        -- TTC

        bxn_counter_o          => bxn_counter,

        trig_stop_o            => trig_stop,

        -- config outputs

        -- VFAT
        vfat_reset_o           => ctrl_reset_vfats,
        ext_sbits_o            => ext_sbits,

        -- LEDs
        led_o                  => led,

        soft_reset_o           => soft_reset,

        cnt_snap_o             => cnt_snap,

        sump                   => open

    );

    --------------------------------------------------------------------------------------------------------------------
    -- Trigger: S-bit Deserialization, Cluster building, and trigger links
    --------------------------------------------------------------------------------------------------------------------

    trigger : entity work.trigger
    port map (

        -- wishbone

        ipb_mosi_i            => ipb_mosi_slaves(IPB_SLAVE.TRIG),
        ipb_miso_o            => ipb_miso_slaves(IPB_SLAVE.TRIG),

        mgts_ready            => mgts_ready,
        pll_lock_o            => pll_lock,
        txfsm_done_o          => txfsm_done,

        -- reset
        trigger_reset_i       => trigger_reset,
        core_reset_i          => core_reset,
        cnt_snap              => cnt_snap,
        ttc_resync            => ttc_resync,

        -- clocks
        mgt_clk_p             => mgt_clk_p_i,
        mgt_clk_n             => mgt_clk_n_i,

        clk_40_sbit           => clk_1x_trigger,
        clk_80_sbit           => clk_2x_trigger,
        clk_160_sbit          => clk_4x_trigger,
        clk_200_sbit          => clk_5x_trigger,
        clk_160_90_sbit       => clk_4x_90_trigger,

        clk_40                => clk_1x,
        clk_160               => clk_4x,

        -- mgt pairs
        mgt_tx_p              => mgt_tx_p_o,
        mgt_tx_n              => mgt_tx_n_o,

        -- config
        cluster_count_o       => cluster_count,
        bxn_counter_i         => bxn_counter,
        ttc_bx0_i             => ttc_bc0,
        ttc_l1a_i             => ttc_l1a,

        -- sbit_ors

        active_vfats_o        => active_vfats,

        -- trig stop from fmm

        trig_stop_i           => trig_stop,

        -- sbits follow

        vfat_sbits_p          => vfat_sbits_p,
        vfat_sbits_n          => vfat_sbits_n,

        vfat_sot_p            => vfat_sot_p,
        vfat_sot_n            => vfat_sot_n

    );

    --------------------------------------------------------------------------------------------------------------------
    -- Device DNA
    --------------------------------------------------------------------------------------------------------------------

    device_dna : entity work.device_dna
    port map (
        clock => clk_1x,
        reset => core_reset,
        dna   => dna
    );

    --------------------------------------------------------------------------------------------------------------------
    -- IODELAY IDELAYCTRL
    --------------------------------------------------------------------------------------------------------------------

    delayctrl : IDELAYCTRL
    port map (
        RDY    => open,
        REFCLK => clk_5x,
        RST    => not (trigger_mmcm_locked)
    );

end Behavioral;
