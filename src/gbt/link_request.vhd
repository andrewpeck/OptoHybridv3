----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- Link Request
-- A. Peck
----------------------------------------------------------------------------------
-- Description:
--   This module buffers wishbone requests to and from the OH
----------------------------------------------------------------------------------
-- 2017/08/01 -- Initial working version
-- 2018/09/10 -- Addition of Artix-7 primitives
-- 2019/05/14 -- Consolidate A7 and V6 components
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.types_pkg.all;
use work.ipbus_pkg.all;
use work.param_pkg.all;

entity link_request is
port(

    clk_i      : in std_logic;
    rst_i    : in std_logic;

    ipb_mosi_o : out ipb_wbus;
    ipb_miso_i : in  ipb_rbus;

    rx_en_i    : in std_logic;
    rx_data_i  : in std_logic_vector(IPB_REQ_BITS-1 downto 0);

    tx_en_i    : in std_logic;
    tx_valid_o : out std_logic;
    tx_data_o  : out std_logic_vector(31 downto 0);

    sump       : out std_logic

);
end link_request;

architecture Behavioral of link_request is

    signal rd_valid : std_logic;
    signal rd_data  : std_logic_vector(IPB_REQ_BITS-1 downto 0);

    signal sbiterr : std_logic;
    signal dbiterr : std_logic;

    signal sump_vector : std_logic_vector (3 downto 0);

begin

    --==============================================================================
    --== RX buffer
    --==============================================================================

    fifo_request_rx_inst : entity work.fifo_request_rx
    port map(
        srst    => rst_i,
        clk     => clk_i,
        wr_en   => rx_en_i,
        din     => rx_data_i,
        rd_en   => '1',
        valid   => rd_valid,
        dout    => rd_data,
        full    => sump_vector(0),
        empty   => sump_vector(1),
        sbiterr => sump_vector(2),
        dbiterr => sump_vector(3)
    );
    --== Rx Request processing ==--

    process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            if (rst_i = '1') then
                ipb_mosi_o <= (ipb_strobe => '0', ipb_write => '0', ipb_addr => (others => '0'), ipb_wdata => (others => '0'));
            else
                if (rd_valid = '1') then
                    ipb_mosi_o <= (
                                    ipb_strobe => '1',
                                    ipb_write  => rd_data(IPB_REQ_BITS-1),
                                    ipb_addr   => rd_data(47 downto 32),
                                    ipb_wdata  => rd_data(31 downto 0)
                    );
                else
                    ipb_mosi_o.ipb_strobe <= '0';
                end if;
            end if;
        end if;
    end process;

    --==============================================================================
    --== TX buffer
    --==============================================================================

    fifo_request_tx_inst : entity work.fifo_request_tx
    port map(
        srst    => rst_i,
        clk     => clk_i,
        wr_en   => ipb_miso_i.ipb_ack,
        din     => ipb_miso_i.ipb_rdata,
        rd_en   => tx_en_i,
        valid   => tx_valid_o,
        dout    => tx_data_o,
        full    => open,
        empty   => open,
        sbiterr => open,
        dbiterr => open
    );

end Behavioral;
