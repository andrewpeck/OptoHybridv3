----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- Trigger Alignment
-- A. Peck
----------------------------------------------------------------------------------
-- Description:
--   This module takes in 192 s-bits and 24 start-of-frame signals and outputs
--   1536 (or x2 at DDR) aligned S-bits
----------------------------------------------------------------------------------
-- 2017/07/24 -- Initial
-- 2017/11/13 -- Port to VHDL
-- 2018/04/18 -- Mods for OH Lite
-- 2018/10/11 -- New oversampler and frame aligner modules
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.types_pkg.all;
use work.trig_pkg.all;
use work.param_pkg.all;

entity trig_alignment is
port(

    sbits_p                : in std_logic_vector (MXVFATS*8-1 downto 0);
    sbits_n                : in std_logic_vector (MXVFATS*8-1 downto 0);

    reset_i                : in std_logic;

    sot_invert_i           : in std_logic_vector (MXVFATS-1 downto 0);
    tu_invert_i            : in std_logic_vector (MXVFATS*8-1 downto 0);

    vfat_mask_i            : in std_logic_vector (MXVFATS-1 downto 0);
    tu_mask_i              : in std_logic_vector (MXVFATS*8-1 downto 0);

    start_of_frame_p       : in std_logic_vector (MXVFATS-1 downto 0);
    start_of_frame_n       : in std_logic_vector (MXVFATS-1 downto 0);

    sot_tap_delay          : in t_std5_array (MXVFATS-1 downto 0);
    trig_tap_delay         : in t_std5_array (MXVFATS*8-1 downto 0);

    sot_is_aligned         : out std_logic_vector (MXVFATS-1 downto 0);
    sot_unstable           : out std_logic_vector (MXVFATS-1 downto 0);

    aligned_count_to_ready : in std_logic_vector (11 downto 0);

    clock                  : in std_logic;

    clk80_0                : in std_logic;
    clk160_0               : in std_logic;
    clk160_90              : in std_logic;
    clk160_180             : in std_logic;

    sbits                  : out std_logic_vector (( MXSBITS_CHAMBER - 1) downto 0)
);
end trig_alignment;

architecture Behavioral of trig_alignment is

    signal reset              : std_logic := '0';
    signal start_of_frame_8b  : t_std8_array (MXVFATS-1 downto 0);
    signal vfat_phase_sel     : t_std2_array (MXVFATS-1 downto 0);
    signal vfat_e4            : t_std4_array (MXVFATS-1 downto 0);
    signal sbits_unaligned    : std_logic_vector (( MXSBITS_CHAMBER - 1) downto 0);
    signal sot_invert         : std_logic_vector (MXVFATS-1 downto 0);
    signal tu_invert          : std_logic_vector (MXVFATS*8-1 downto 0);
    signal vfat_mask          : std_logic_vector (MXVFATS-1 downto 0);
    signal tu_mask            : std_logic_vector (MXVFATS*8-1 downto 0);
    signal sot_is_aligned_int : std_logic_vector (MXVFATS-1 downto 0);

    -- fanout reset to help with timing
    signal sot_reset         : std_logic_vector (MXVFATS-1 downto 0);
    signal tu_reset          : std_logic_vector (MXVFATS*8-1 downto 0);

    attribute EQUIVALENT_REGISTER_REMOVAL : string;
    attribute EQUIVALENT_REGISTER_REMOVAL of sot_reset : signal is "NO";
    attribute EQUIVALENT_REGISTER_REMOVAL of  tu_reset : signal is "NO";

begin

    assert_fpga_type :
    IF ( FPGA_TYPE/="VIRTEX6" and FPGA_TYPE/="ARTIX7") GENERATE
        assert false report "Unknown FPGA TYPE" severity error;
    end GENERATE assert_fpga_type;

    --------------------------------------------------------------------------------------------------------------------
    -- Reset
    --------------------------------------------------------------------------------------------------------------------

    process (clock) is begin
        if (rising_edge(clock)) then
            reset <= reset_i;
        end if;
    end process;

    process (clock) is begin
        if (rising_edge(clock)) then
            sot_invert <= sot_invert_i;
            tu_invert  <= tu_invert_i;
            vfat_mask  <= vfat_mask_i;
            tu_mask    <= tu_mask_i;
        end if;
    end process;

    --------------------------------------------------------------------------------------------------------------------
    -- SOT Oversampler
    --------------------------------------------------------------------------------------------------------------------

    sot_loop: for ivfat in 0 to MXVFATS-1 generate begin

        process (clock) is begin
            if (rising_edge(clock)) then
                sot_reset(ivfat) <= reset or (vfat_mask(ivfat));
            end if;
        end process;

        sot_oversample : entity work.oversample
        generic map (
            g_PHASE_SEL_EXTERNAL => FALSE
        )
        port map (
            rst           => sot_reset(ivfat),
            invert        => sot_invert (ivfat),
            rxd_p         => start_of_frame_p(ivfat),
            rxd_n         => start_of_frame_n(ivfat),
            clk1x_logic   => clk80_0,
            clk2x_logic   => clk160_0,
            clk2x_0       => clk160_0,
            clk2x_90      => clk160_90,
            clk2x_180     => clk160_180,
            rxdata_o      => start_of_frame_8b(ivfat),
            tap_delay_i   => sot_tap_delay(ivfat),
            e4_in         => (others => '0'),
            e4_out        => vfat_e4(ivfat),
            phase_sel_in  => (others => '0'),
            phase_sel_out => vfat_phase_sel(ivfat)
        );

    end generate;

    --------------------------------------------------------------------------------------------------------------------
    -- S-bit Oversamplers
    --------------------------------------------------------------------------------------------------------------------

    trig_loop: for ipin in 0 to (MXVFATS*8-1) generate begin

        process (clock) is begin
            if (rising_edge(clock)) then
                tu_reset(ipin) <= reset or tu_mask(ipin) or (not sot_is_aligned_int (ipin/8)) or vfat_mask(ipin/8);
            end if;
        end process;

        sbit_oversample : entity work.oversample
        generic map (
            g_PHASE_SEL_EXTERNAL => TRUE
        )
        port map (
            rst           => tu_reset(ipin),
            invert        => tu_invert (ipin),
            rxd_p         => sbits_p(ipin),
            rxd_n         => sbits_n(ipin),
            clk1x_logic   => clk80_0,
            clk2x_logic   => clk160_0,
            clk2x_0       => clk160_0,
            clk2x_90      => clk160_90,
            clk2x_180     => clk160_180,
            rxdata_o      => sbits_unaligned ((ipin+1)*8 - 1 downto ipin*8),
            tap_delay_i   => trig_tap_delay(ipin),
            e4_in         => vfat_e4(ipin/8),
            e4_out        => open,
            phase_sel_in  => vfat_phase_sel(ipin/8),
            phase_sel_out => open
        );

    end generate;

    --------------------------------------------------------------------------------------------------------------------
    -- Frame alignment
    --------------------------------------------------------------------------------------------------------------------

    aligner_loop: for ivfat in 0 to MXVFATS-1 generate begin

        frame_aligner_inst : entity work.frame_aligner
        generic map (
            DDR     => DDR
        )
        port map (

            sbits_i => sbits_unaligned ((ivfat+1)*MXSBITS - 1 downto ivfat*MXSBITS),
            sbits_o => sbits((ivfat+1)*MXSBITS - 1 downto ivfat*MXSBITS),
            mask    => vfat_mask(ivfat),
            reset_i => reset,

            start_of_frame => start_of_frame_8b(ivfat),

            clock          => clock,
            clock4x        => clk160_0,

            aligned_count_to_ready => aligned_count_to_ready,

            sot_is_aligned => sot_is_aligned_int(ivfat),

            sot_unstable   => sot_unstable(ivfat)
        );

    end generate;

    sot_is_aligned <= sot_is_aligned_int;

end Behavioral;
