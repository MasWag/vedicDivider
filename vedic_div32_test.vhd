library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity vedic_div32_test is
  port (
    Q : out std_logic);
end entity vedic_div32_test;

architecture test of vedic_div32_test is
  component vedic_div32 is
    port (
      mclk1    : in  std_logic;
      go       : in  std_logic;
      divisor  : in  std_logic_vector (31 downto 0);
      dividend : in  std_logic_vector (31 downto 0);
      quo      : out std_logic_vector (31 downto 0);
      re       : out std_logic_vector (31 downto 0));
  end component vedic_div32;

  signal clk      : std_logic                      := '0';
  signal divisor  : std_logic_vector (31 downto 0) := (others => '0');
  signal dividend : std_logic_vector (31 downto 0) := (others => '0');
  signal quo      : std_logic_vector (31 downto 0) := (others => '0');
  signal re       : std_logic_vector (31 downto 0) := (others => '0');

  signal go           : std_logic                      := '0';
  signal ccc          : std_logic_vector (31 downto 0) := (others => '0');
  signal ddd          : std_logic_vector (31 downto 0) := (others => '0');
  signal state        : std_logic_vector (1 downto 0)  := (others => '0');
  signal s            : std_logic                      := '0';
  constant clk_period : time                           := 10 ns;

  file inf : text open read_mode is "vedic_div32.dat";
begin  -- architecture test

  vedic_div32_1 : vedic_div32
    port map (
      mclk1    => clk,
      go       => go,
      divisor  => divisor,
      dividend => dividend,
      quo      => quo,
      re       => re);

  main_loop : process
    variable l  : line;
    variable aa : std_logic_vector (31 downto 0) := (others => '0');
    variable bb : std_logic_vector (31 downto 0) := (others => '0');
    variable cc : std_logic_vector (31 downto 0) := (others => '0');
    variable dd : std_logic_vector (31 downto 0) := (others => '0');
    variable ss : character;
    variable st : integer                        := 0;
    constant li : integer                        := 32;
  begin  -- process file_loop
    if not endfile(inf) then
      wait for clk_period/2;
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      if st = li then
        go <= '1';
        readline(inf, l);
        hread(l, aa);
        read(l, ss);                    -- read in the space character
        hread(l, bb);
        read(l, ss);                    -- read in the space character
        hread(l, cc);
        read(l, ss);                    -- read in the space character
        hread(l, dd);

        dividend <= aa;
        divisor  <= bb;
        ccc      <= cc;
        ddd      <= dd;

        st := 0;
        if s = '0' or ccc = quo then
          Q <= '0';
        else
          Q <= '1';
          assert false report "vedic div32 test not passed!!" severity failure;
        end if;
        s <= '1';
      else
        go <= '0';
        st := st + 1;
      end if;
    else
      wait;
    end if;
  end process main_loop;

end architecture test;
