----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- GBT SerDes
-- T. Lenzi, E. Juska, A. Peck
----------------------------------------------------------------------------------
-- Description:
--   This module serializes and deserializes e-link data to and from the GBTx
----------------------------------------------------------------------------------
-- 2017/07/24 -- Conversion to 16 bit (2 elinks only)
-- 2017/07/24 -- Addition of flip-flop synchronization stages for X-domain transit
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library unisim;
use unisim.vcomponents.all;

library work;

entity gbt_serdes is
generic(
    DEBUG : boolean := FALSE
);
port(

    reset_i          : in std_logic;

    -- reset
    sync_reset_i     : in std_logic;

    -- input clocks
    data_clk_i       : in std_logic;
    frame_clk_i      : in std_logic;
    clock            : in std_logic;

    -- serial data
    elink_o_p        : out std_logic_vector(1 downto 0);
    elink_o_n        : out std_logic_vector(1 downto 0);

    elink_i_p        : in  std_logic_vector(1 downto 0);
    elink_i_n        : in  std_logic_vector(1 downto 0);

    -- parallel data
    data_i           : in std_logic_vector (15 downto 0);
    data_o           : out std_logic_vector(15 downto 0);
    valid_o          : out std_logic
);
end gbt_serdes;

architecture Behavioral of gbt_serdes is

    signal from_gbt_raw     : std_logic_vector(15 downto 0) := (others => '0');
    signal from_gbt         : std_logic_vector(15 downto 0) := (others => '0');

    signal to_gbt           : std_logic_vector(15 downto 0) := (others => '0');
    signal to_gbt_bitslipped       : std_logic_vector(15 downto 0) := (others => '0');

    signal io_reset         : std_logic := '1';

    signal from_gbt_s1      : std_logic_vector(15 downto 0) := (others => '0');
    signal from_gbt_s2      : std_logic_vector(15 downto 0) := (others => '0');

    signal   to_gbt_s1      : std_logic_vector(15 downto 0) := (others => '0');
    signal   to_gbt_s2      : std_logic_vector(15 downto 0) := (others => '0');

    signal data_clk_inv : std_logic;

    signal pulse_length     : std_logic_vector (3 downto 0) := x"f";

begin

    data_clk_inv <= not data_clk_i;

    --================--
    --==    RESET   ==--
    --================--

    -- power-on reset - this must be a clock synchronous pulse of a minimum of 2 and max 32 clock cycles (ISERDES spec)

    process(frame_clk_i)
    begin
    if (falling_edge(frame_clk_i)) then
        io_reset <= reset_i;
    end if;
    end process;

--    process(clock)
--    begin
--        if (falling_edge(frame_clk_i)) then
--            if (sync_reset_i = '1') then
--                pulse_length <= x"f";
--            else
--                if (pulse_length /= 0) then
--                    io_reset <= '1';
--                    pulse_length <= std_logic_vector(unsigned(pulse_length) - unsigned(1,4));
--                else
--                    io_reset <= '0';
--                end if;
--            end if;
--        end if;
--    end process;

    --================--
    --== INPUT DATA ==--
    --================--

    -- Input deserializer
    i_from_gbt_des : entity work.from_gbt_des
    port map(
        data_in_from_pins_p => elink_i_p,
        data_in_from_pins_n => elink_i_n,
        data_in_to_device   => from_gbt_raw,
        bitslip             => '0',
        clk_in              => data_clk_i,
        clk_div_in          => frame_clk_i,
        io_reset            => io_reset
    );

    -- remap to account for how the Xilinx IPcore assigns the output pins (?)
    -- from_gbt <= from_gbt_raw(1) & from_gbt_raw(3) & from_gbt_raw(5) & from_gbt_raw(7) & from_gbt_raw(9) & from_gbt_raw(11) & from_gbt_raw(13) & from_gbt_raw(15)  &
    --             from_gbt_raw(0) & from_gbt_raw(2) & from_gbt_raw(4) & from_gbt_raw(6) & from_gbt_raw(8) & from_gbt_raw(10) & from_gbt_raw(12) & from_gbt_raw(14);
    from_gbt <= from_gbt_raw(1) & from_gbt_raw(3) & from_gbt_raw(5) & from_gbt_raw(7) & from_gbt_raw(9) & from_gbt_raw(11) & from_gbt_raw(13) & from_gbt_raw(15)  &
                from_gbt_raw(0) & from_gbt_raw(2) & from_gbt_raw(4) & from_gbt_raw(6) & from_gbt_raw(8) & from_gbt_raw(10) & from_gbt_raw(12) & from_gbt_raw(14);

    --=================--
    --== OUTPUT DATA ==--
    --=================--

    -- Bitslip and format the output to serializer
    -- Static bitslip count = 3

    i_gbt_tx_bitslip : entity work.gbt_tx_bitslip
    port map(
        fabric_clk  => frame_clk_i,
        reset       => io_reset,
        --bitslip_cnt => 0,
        bitslip_cnt => 7,
        din         => to_gbt, -- 16 bit data input, synchronized to frame-clock
        dout        => to_gbt_bitslipped
    );

    -- Output serializer
    i_to_gbt_ser : entity work.to_gbt_ser
    port map(
        data_out_from_device    => to_gbt_bitslipped,
        data_out_to_pins_p      => elink_o_p,
        data_out_to_pins_n      => elink_o_n,
        clk_in                  => data_clk_inv,
        clk_div_in              => frame_clk_i,
        io_reset                => io_reset
    );

    valid_o <= not io_reset;

    --=====================--
    --== DOMAIN CROSSING ==--
    --=====================--

    -- transition data from sampling clock to fabric clock
    -- and vice versa

    process(clock)
    begin
        if (rising_edge(clock)) then
            from_gbt_s1 <= from_gbt;
            from_gbt_s2 <= from_gbt_s1;
        end if;
    end process;

    process(frame_clk_i)
    begin
        if (rising_edge(frame_clk_i)) then
            to_gbt_s1 <= data_i;
            to_gbt_s2 <= to_gbt_s1;
        end if;
    end process;


    data_o <= from_gbt_s2; -- synchronized from "from_gbt"
    to_gbt <= to_gbt_s2; -- synchronized from data_i

end Behavioral;