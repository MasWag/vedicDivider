library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity vedic_div_test is
  port (
    Q : out std_logic);
end entity vedic_div_test;

architecture test of vedic_div_test is
  component vedic_div is
    port (
      mclk1      : in  std_logic;
      divisor  : in  std_logic_vector (3 downto 0);
      dividend : in  std_logic_vector (7 downto 0);
      quo      : out std_logic_vector (7 downto 0);
      re       : out std_logic_vector (3 downto 0));
  end component vedic_div;

  signal clk : std_logic := '0';
  signal divisor : std_logic_vector (3 downto 0) := (others => '0');
  signal dividend : std_logic_vector (7 downto 0) := (others => '0');
  signal quo : std_logic_vector (7 downto 0) := (others => '0');
  signal re : std_logic_vector (3 downto 0) := (others => '0');

  type quo_buff is array (3 downto 0) of std_logic_vector (7 downto 0);
  type re_buff is array (3 downto 0) of std_logic_vector (3 downto 0);
  signal cc : quo_buff := (others => (others => '0'));
  signal dd : re_buff := (others => (others => '0'));
  signal tmpc : std_logic_vector (7 downto 0) := (others => '0');  
  signal state : std_logic_vector (1 downto 0) := (others => '0');
  signal s : std_logic := '0';
  constant clk_period : time := 10 ns;
  file inf : text open read_mode is "vedic_div.dat";
begin  -- architecture test

  vedic_div_1: vedic_div
    port map (
      mclk1      => clk,
      divisor  => divisor,
      dividend => dividend,
      quo      => quo,
      re       => re);

    main_loop: process 
    variable l : line;
    variable aa : std_logic_vector (7 downto 0) := (others => '0');
    variable bb : std_logic_vector (3 downto 0) := (others => '0');
    variable ccc : std_logic_vector (7 downto 0) := (others => '0');
    variable ddd : std_logic_vector (3 downto 0) := (others => '0');
    variable ss : character;

  begin  -- process file_loop
    if not endfile(inf) then
      wait for clk_period/2;
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      case state is
        when "00" =>
          state <= "01";
        when "01" =>
          state <= "11";
        when "11" =>
          state <= "10";
        when "10" =>
          state <= "00";
        when others =>
          state <= "00";
      end case;
      readline(inf, l);
      hread(l, aa);
      read(l, ss);           -- read in the space character
      hread(l , bb);
      read(l, ss);           -- read in the space character
      hread(l , ccc);
      read(l, ss);           -- read in the space character
      hread(l , ddd);
      dividend <= aa;
      divisor <= bb;
      tmpc <= ccc;
      dd(conv_integer(state)) <= ddd;
      if s = '0' or tmpc = quo then
        Q <= '0';
      else
        Q <= '1';
        assert false report "vedic div test not passed!!" severity failure;
      end if;
      s <= '1';
    else
      wait;
    end if;
  end process main_loop;

end architecture test;
