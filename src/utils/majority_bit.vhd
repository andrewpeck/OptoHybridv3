library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity majority_bit is
port(
  a : in  std_logic;
  b : in  std_logic;
  c : in  std_logic;
  y : out std_logic
);
end majority_bit;

architecture behavioral of majority_bit is

begin

  y <= (a and b) or (b and c) or (a and c);

end behavioral;

