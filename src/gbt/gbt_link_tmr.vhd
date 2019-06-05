----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- GBT Link Parser
-- A. Peck
----------------------------------------------------------------------------------
-- Description: TMR wrapper for gbt link module
----------------------------------------------------------------------------------
-- 2019/05/16 -- Init
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;
use work.ipbus_pkg.all;

entity gbt_link_tmr is
port(

    -- reset
    rst_i                           : in std_logic;

    -- clk inputs
    clk_i                           : in std_logic;

    -- parallel data to/from serdes
    data_i                          : in std_logic_vector (7 downto 0);
    data_o                          : out std_logic_vector(7 downto 0);

    -- wishbone
    ipb_mosi_o                      : out ipb_wbus;
    ipb_miso_i                      : in  ipb_rbus;

    -- decoded ttc
    l1a_o                           : out std_logic;
    bc0_o                           : out std_logic;
    resync_o                        : out std_logic;

    -- status
    rdy_o                           : out std_logic;
    err_o                           : out std_logic;
    unstable_o                      : out std_logic
);
end gbt_link_tmr;

architecture Behavioral of gbt_link_tmr is

  signal resync_tmr   : std_logic_vector(2 downto 0);
  signal l1a_tmr      : std_logic_vector(2 downto 0);
  signal bc0_tmr      : std_logic_vector(2 downto 0);
  signal unstable_tmr : std_logic_vector(2 downto 0);
  signal rdy_tmr      : std_logic_vector(2 downto 0);
  signal err_tmr      : std_logic_vector(2 downto 0);
  signal ipb_mosi_tmr : ipb_wbus_array  (2 downto 0);
  signal data_tmr     : t_std8_array    (2 downto 0);

  attribute DONT_TOUCH : string;

  attribute DONT_TOUCH of resync_tmr    : signal is "true";
  attribute DONT_TOUCH of l1a_tmr       : signal is "true";
  attribute DONT_TOUCH of bc0_tmr       : signal is "true";
  attribute DONT_TOUCH of unstable_tmr  : signal is "true";
  attribute DONT_TOUCH of rdy_tmr       : signal is "true";
  attribute DONT_TOUCH of err_tmr       : signal is "true";
  attribute DONT_TOUCH of ipb_mosi_tmr  : signal is "true";
  attribute DONT_TOUCH of data_tmr      : signal is "true";

  begin

    tmr_loop : for I in 0 to 2 generate
    begin
    gbt_link_tmr : entity work.gbt_link
    generic map(
        g_TMR_INSTANCE         => I
    )
    port map(

        -- rst
        rst_i              => rst_i,

        -- clock inputs
        clk_i              => clk_i,

        -- parallel data
        data_i             => data_i,
        data_o             => data_tmr(I),

        -- wishbone master
        ipb_mosi_o         => ipb_mosi_tmr(I),
        ipb_miso_i         => ipb_miso_i,

        -- decoded TTC
        resync_o           => resync_tmr(I),
        l1a_o              => l1a_tmr(I),
        bc0_o              => bc0_tmr(I),

        -- outputs
        unstable_o         => unstable_tmr(I),
        rdy_o              => rdy_tmr(I),
        err_o              => err_tmr(I)

    );

  end generate;

  majority_data_o : entity work.majority
  generic map ( g_NUM_BITS => 8)
  port map (
      a => data_tmr(0),
      b => data_tmr(1),
      c => data_tmr(2),
      y => data_o
  );

  majority_ipb_mosi_wdata : entity work.majority
  generic map ( g_NUM_BITS => 32)
  port map (
      a => ipb_mosi_tmr(0).ipb_wdata,
      b => ipb_mosi_tmr(1).ipb_wdata,
      c => ipb_mosi_tmr(2).ipb_wdata,
      y => ipb_mosi_o.ipb_wdata
  );

  majority_ipb_mosi_write : entity work.majority_bit
  port map (
      a => ipb_mosi_tmr(0).ipb_write,
      b => ipb_mosi_tmr(1).ipb_write,
      c => ipb_mosi_tmr(2).ipb_write,
      y => ipb_mosi_o.ipb_write
  );

  majority_ipb_mosi_strobe : entity work.majority_bit
  port map (
      a => ipb_mosi_tmr(0).ipb_strobe,
      b => ipb_mosi_tmr(1).ipb_strobe,
      c => ipb_mosi_tmr(2).ipb_strobe,
      y => ipb_mosi_o.ipb_strobe
  );

  majority_ipb_mosi_addr : entity work.majority
  generic map ( g_NUM_BITS => 16)
  port map (
      a => ipb_mosi_tmr(0).ipb_addr,
      b => ipb_mosi_tmr(1).ipb_addr,
      c => ipb_mosi_tmr(2).ipb_addr,
      y => ipb_mosi_o.ipb_addr
  );

  majority_resync_o : entity work.majority_bit
  port map (
      a => resync_tmr(0),
      b => resync_tmr(1),
      c => resync_tmr(2),
      y => resync_o
  );

  majority_l1a_o : entity work.majority_bit
  port map (
      a => l1a_tmr(0),
      b => l1a_tmr(1),
      c => l1a_tmr(2),
      y => l1a_o
  );

  majority_bc0_o : entity work.majority_bit
  port map (
      a => bc0_tmr(0),
      b => bc0_tmr(1),
      c => bc0_tmr(2),
      y => bc0_o
  );

  majority_unstable_o : entity work.majority_bit
  port map (
      a => unstable_tmr(0),
      b => unstable_tmr(1),
      c => unstable_tmr(2),
      y => unstable_o
  );

  majority_err_o : entity work.majority_bit
  port map (
      a => err_tmr(0),
      b => err_tmr(1),
      c => err_tmr(2),
      y => err_o
  );

  majority_rdy_o : entity work.majority_bit
  port map (
      a => rdy_tmr(0),
      b => rdy_tmr(1),
      c => rdy_tmr(2),
      y => rdy_o
  );

end Behavioral;
