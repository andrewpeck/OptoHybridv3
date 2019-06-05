----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration (A. Peck)
-- Optohybrid v3 Firmware -- IpBus Switch
----------------------------------------------------------------------------------
-- TMR Wrapper
----------------------------------------------------------------------------------

 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;
use work.ipbus_pkg.all;

entity ipb_switch_tmr is
port(

    clock_i   : in std_logic;
    reset_i     : in std_logic;

    -- Master
    mosi_masters : in  ipb_wbus_array (WB_MASTERS-1 downto 0);
    miso_masters : out ipb_rbus_array (WB_MASTERS-1 downto 0);

    -- Slaves
    mosi_slaves  : out ipb_wbus_array (WB_SLAVES-1 downto 0);
    miso_slaves  : in  ipb_rbus_array (WB_SLAVES-1 downto 0)

);
end ipb_switch_tmr;

architecture Behavioral of ipb_switch_tmr is

    attribute DONT_TOUCH : string;
    type t_miso_masters_tmr is array(2 downto 0) of ipb_rbus_array (WB_MASTERS-1 downto 0);
    type t_mosi_slaves_tmr  is array(2 downto 0) of ipb_wbus_array (WB_SLAVES-1 downto 0);
    signal miso_masters_tmr : t_miso_masters_tmr;
    signal mosi_slaves_tmr  : t_mosi_slaves_tmr;

    attribute DONT_TOUCH of miso_masters_tmr : signal is "true";
    attribute DONT_TOUCH of mosi_slaves_tmr  : signal is "true";

begin

    tmr_loop : for I in 0 to 2 generate
    begin

    ipb_switch_inst : entity work.ipb_switch generic map( g_TMR_INSTANCE => I)
    port map(
        clock_i              => clock_i,
        reset_i              => reset_i,

        -- connect to master
        mosi_masters         => mosi_masters,
        miso_masters         => miso_masters_tmr(I),

        -- connect to slaves
        mosi_slaves          => mosi_slaves_tmr(I),
        miso_slaves          => miso_slaves
    );

  end generate;

  master_voter_loop : for I in 0 to (WB_MASTERS-1) generate
  begin

    --===========--
    --== MISO  ==--
    --===========--

    majority_ipb_miso_rdata : entity work.majority
    generic map ( g_NUM_BITS => 32)
    port map (
      a => miso_masters_tmr(0)(I).ipb_rdata,
      b => miso_masters_tmr(1)(I).ipb_rdata,
      c => miso_masters_tmr(2)(I).ipb_rdata,
      y => miso_masters(I).ipb_rdata
    );

    majority_ipb_miso_ack : entity work.majority_bit
    port map (
      a => miso_masters_tmr(0)(I).ipb_ack,
      b => miso_masters_tmr(1)(I).ipb_ack,
      c => miso_masters_tmr(2)(I).ipb_ack,
      y => miso_masters(I).ipb_ack
    );

    majority_ipb_miso_err : entity work.majority_bit
    port map (
      a => miso_masters_tmr(0)(I).ipb_err,
      b => miso_masters_tmr(1)(I).ipb_err,
      c => miso_masters_tmr(2)(I).ipb_err,
      y => miso_masters(I).ipb_err
    );

  end generate;

  slave_voter_loop : for I in 0 to (WB_SLAVES-1) generate
  begin


    --===========--
    --== MOSI  ==--
    --===========--

    majority_ipb_mosi_wdata : entity work.majority
    generic map ( g_NUM_BITS => 32)
    port map (
      a => mosi_slaves_tmr(0)(I).ipb_wdata,
      b => mosi_slaves_tmr(1)(I).ipb_wdata,
      c => mosi_slaves_tmr(2)(I).ipb_wdata,
      y => mosi_slaves(I).ipb_wdata
    );

    majority_ipb_mosi_addr : entity work.majority
    generic map ( g_NUM_BITS => 16)
    port map (
      a => mosi_slaves_tmr(0)(I).ipb_addr,
      b => mosi_slaves_tmr(1)(I).ipb_addr,
      c => mosi_slaves_tmr(2)(I).ipb_addr,
      y => mosi_slaves(I).ipb_addr
    );

    majority_ipb_mosi_strobe : entity work.majority_bit
    port map (
      a => mosi_slaves_tmr(0)(I).ipb_strobe,
      b => mosi_slaves_tmr(1)(I).ipb_strobe,
      c => mosi_slaves_tmr(2)(I).ipb_strobe,
      y => mosi_slaves(I).ipb_strobe
    );

    majority_ipb_mosi_write : entity work.majority_bit
    port map (
      a => mosi_slaves_tmr(0)(I).ipb_write,
      b => mosi_slaves_tmr(1)(I).ipb_write,
      c => mosi_slaves_tmr(2)(I).ipb_write,
      y => mosi_slaves(I).ipb_write
    );

  end generate;

end Behavioral;
