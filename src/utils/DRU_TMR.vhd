library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;

entity dru_tmr is
generic (
  g_PHASE_SEL_EXTERNAL : boolean := FALSE
);
port(
  clk1x : in  std_logic;                    -- 80 MHz clock
  clk2x : in  std_logic;                    -- 160 MHz clock
  i     : in  std_logic_vector(7 downto 0); -- 8-bit input, the even bits are inverted!
  o     : out std_logic_vector(7 downto 0); -- 8-bit recovered output

  e4_out        : out std_logic_vector (3 downto 0);
  e4_in         : in  std_logic_vector (3 downto 0);
  phase_sel_in  : in std_logic_vector (1 downto 0);
  phase_sel_out : out std_logic_vector (1 downto 0);

  vo    : out std_logic);                   -- valid data out
end dru_tmr;

architecture behavioral of dru_tmr is

  signal vo_tmr            : std_logic_vector (2 downto 0);
  signal o_tmr             : t_std8_array    (2 downto 0);
  signal phase_sel_out_tmr : t_std2_array    (2 downto 0);
  signal e4_out_tmr        : t_std4_array    (2 downto 0);

begin

  tmr_loop : for ILOOP in 0 to 2 generate
  begin
  dru: entity work.dru
  generic map(
    g_TMR_INSTANCE       => ILOOP,
    g_PHASE_SEL_EXTERNAL => g_PHASE_SEL_EXTERNAL
  )
  port map(
          i             => i,                    -- the even bits are inverted!
          clk1x         => clk1x,                --
          clk2x         => clk2x,                --
          phase_sel_in  => phase_sel_in,         --
          e4_in         => e4_in,                --
          phase_sel_out => phase_sel_out_tmr(ILOOP), --
          e4_out        => e4_out_tmr(ILOOP),        --
          o             => o_tmr(ILOOP),             -- 8-bit deserialized data
          vo            => vo_tmr(ILOOP)             -- rx valid
  );

  end generate;

  majority_phase_sel_out : entity work.majority
  generic map ( g_NUM_BITS => 2)
  port map (
      a => phase_sel_out_tmr(0),
      b => phase_sel_out_tmr(1),
      c => phase_sel_out_tmr(2),
      y => phase_sel_out
  );

  majority_e4_out : entity work.majority
  generic map ( g_NUM_BITS => 4)
  port map (
      a => e4_out_tmr(0),
      b => e4_out_tmr(1),
      c => e4_out_tmr(2),
      y => e4_out
  );

  majority_o : entity work.majority
  generic map ( g_NUM_BITS => 8)
  port map (
      a => o_tmr(0),
      b => o_tmr(1),
      c => o_tmr(2),
      y => o
  );

  majority_vo : entity work.majority_bit
  port map (
      a => vo_tmr(0),
      b => vo_tmr(1),
      c => vo_tmr(2),
      y => vo
  );

end behavioral;
