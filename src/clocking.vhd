----------------------------------------------------------------------------------
-- Company:        IIHE - ULB
-- Engineer:       Thomas Lenzi (thomas.lenzi@cern.ch)
-- 
-- Create Date:    12:59:03 09/30/2015 
-- Design Name:    OptoHybrid v2
-- Module Name:    clocking - Behavioral 
-- Project Name:   OptoHybrid v2
-- Target Devices: xc6vlx130t-1ff1156
-- Tool versions:  ISE  P.20131013
-- Description: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;


entity clocking is
port(

    qpll_clk_i      : in std_logic;
    gbt_clk_i       : in std_logic;
    clk_source_i    : in std_logic;
    
    ref_clk_o       : out std_logic;
    clk_1x_o        : out std_logic;
    clk_2x_o        : out std_logic;
    clk_4x_o        : out std_logic
    
);
end clocking;

architecture Behavioral of clocking is

    signal clk : std_logic;

begin

    ------ !!!!!
    -- Modified version !!!!
    -- GBT clock by default !!!! 0 = GBT, 1 = QPLL
    -- Revert when not needed anymore !!!!

    clk <= qpll_clk_i when clk_source_i = '1' else gbt_clk_i; -- switch using clk_source
    
    clk_gen_inst : entity work.clk_gen
    port map(
        clk_i       => clk,
        ref_clk_o   => ref_clk_o,
        clk_1x_o    => clk_1x_o,
        clk_2x_o    => clk_2x_o,
        clk_4x_o    => clk_4x_o
    );    

                   
end Behavioral;

