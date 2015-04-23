library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
  port (MCLK1 : in  std_logic;
        RS_TX : out std_logic);
end top;

architecture structure of top is
  type divisor_table_t is array (7 downto 0) of std_logic_vector (3 downto 0);
  type dividend_table_t is array (7 downto 0) of std_logic_vector (7 downto 0);
  signal divisor_table  : divisor_table_t  := (0 => x"a", 1 => x"b", 2 => x"f", 3 => x"1", others => x"c");
  signal dividend_table : dividend_table_t := (0 => x"ff", 1 => x"01", 2 => x"f0", 3 => x"a2", others => x"bb");
  signal clk, iclk      : std_logic;

  component vedic_div is
    port (
      clk      : in  std_logic;
      divisor  : in  std_logic_vector (3 downto 0);
      dividend : in  std_logic_vector (7 downto 0);
      quo      : out std_logic_vector (7 downto 0);
      re       : out std_logic_vector (3 downto 0));
  end component vedic_div;

  signal divisor  : std_logic_vector (3 downto 0) := (others => '0');
  signal dividend : std_logic_vector (7 downto 0) := (others => '0');
  signal quo      : std_logic_vector (7 downto 0) := (others => '0');
  signal re       : std_logic_vector (3 downto 0) := (others => '0');
begin
  ib : IBUFG port map (
    i => MCLK1,
    o => iclk);
  bg : BUFG port map (
    i => iclk,
    o => clk);

  vedic_div_1 : entity work.vedic_div
    port map (
      clk      => clk,
      divisor  => divisor,
      dividend => dividend,
      quo      => quo,
      re       => re);

  send_msg : process(clk)
    variable count : integer range 0 to 7 := 0;
  begin
    if rising_edge(clk) then
      divisor  <= divisor_table (count);
      dividend <= dividend_table (count);
      if count = 7 then
        count := 0;
      else
        count := count + 1;
      end if;
      RS_TX <= quo (count);
    end if;
  end process;
end architecture;

