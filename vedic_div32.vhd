library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vedic_div32 is

  port (
    mclk1    : in  std_logic;
    go       : in  std_logic;
    divisor  : in  std_logic_vector (31 downto 0);
    dividend : in  std_logic_vector (31 downto 0);
    quo      : out std_logic_vector (31 downto 0);
    re       : out std_logic_vector (31 downto 0));

end entity vedic_div32;

architecture rtl of vedic_div32 is
  type unit_reg_t is array(natural range <>) of integer range 0 to 32;
  type reg_t is record
    quo_reg  : std_logic_vector (31 downto 0);
    re_reg   : std_logic_vector (35 downto 0);
    quo      : std_logic_vector (31 downto 0);
    quo_sign : std_logic;               -- 0 : positive,1 : negative
    re_sign  : std_logic;               -- 0 : positive,1 : negative
  end record reg_t;

  type state_t is (init_state, main_state, wait_state, fin_state);

  signal reg      : reg_t := (quo_sign => '0', re_sign => '0', others => (others => '0'));
  signal init_reg : reg_t := (quo_sign => '0', re_sign => '0', others => (others => '0'));
  signal main_reg : reg_t := (quo_sign => '0', re_sign => '0', others => (others => '0'));

  signal b_n       : std_logic_vector (30 downto 0) := (others => '0');
  signal state     : state_t                        := init_state;
  signal i_re      : signed (31 downto 0)           := (others => '0');
  signal i_quo     : std_logic_vector (31 downto 0) := (others => '0');
  signal shift_val : integer range 0 to 31          := 0;

begin  -- architecture rtl

  with state select
    reg <=
    init_reg when init_state,
    main_reg when others;

  -- purpose: init reg
  -- type   : combinational
  -- inputs : clk
  -- outputs: init_reg

  init_reg.quo_sign <= '0';
  init_reg.re_sign  <= '0';

  -- purpose: init 
  -- type   : combinational
  -- inputs : divisor,dividend
  -- outputs: shifted_divisor,shift_val,re_reg,quo_reg,b_n
  init_calc : process (divisor, dividend) is
  begin  -- process init_calc

    for i in 31 downto 0 loop
      next when divisor (i) = '0';
      shift_val <= 31 - i;
      b_n <= std_logic_vector(shift_left (arg   => unsigned(divisor (shift_val + 30 downto shift_val)),
                                          count => shift_val));
      init_reg.quo_reg (31 - i downto 0) <= dividend (31 downto i);
      if i = 0 then
        init_reg.re_reg <= (others => '0');
      else
        init_reg.quo_reg (31 downto 32 - i) <= (others => '0');
        init_reg.re_reg (31 downto 32 - i) <= dividend (i-1 downto 0);
        init_reg.re_reg (31 - i downto 0) <= (others => '0');
      end if;
      exit;
    end loop;  -- i

  end process init_calc;

  -- purpose: main calc
  -- type   : combinational
  -- inputs : reg
  -- outputs: main_reg
  main_calc : process (mclk1, reg) is
    variable tmp_quo_reg : unsigned (31 downto 0) := (others   => '0');
    variable quo_tmp     : unsigned (31 downto 0) := (others   => '0');
    variable re_tmp      : unsigned (31 downto 0) := (others   => '0');
    variable tmp_sign    : std_logic              := '0';
    variable v_reg       : reg_t                  := (quo_sign => '0', re_sign => '0', others => (others => '0'));
    variable i           : integer range 0 to 31  := 31;
  begin  -- process main_calc
    -- i = 31 downto 0
    if rising_edge (mclk1) then
      v_reg := reg;
      tmp_quo_reg := shift_right (arg   => unsigned (v_reg.quo_reg),
                                  count => i);

      if v_reg.quo_sign = '0' then
        v_reg.quo := std_logic_vector(unsigned(v_reg.quo) + shift_left(arg => tmp_quo_reg, count => i));
      else
        v_reg.quo := std_logic_vector(unsigned(v_reg.quo) - shift_left(arg => tmp_quo_reg, count => i));
      end if;

      v_reg.quo_reg (31 downto i):= (others => '0');

      quo_tmp := to_unsigned(to_integer(unsigned(tmp_quo_reg)) * to_integer(unsigned(b_n (30 downto 31 - i))), 32);
      re_tmp := shift_left(arg   => to_unsigned(to_integer(unsigned(tmp_quo_reg)) * to_integer(unsigned(b_n (30 - i downto 0))), 32),
                           count => i);

      tmp_sign := v_reg.quo_sign;

      if tmp_sign /= v_reg.quo_sign then
        v_reg.quo_reg := std_logic_vector(unsigned(v_reg.quo_reg) + quo_tmp);
      elsif unsigned(v_reg.quo_reg) > quo_tmp then
        v_reg.quo_reg := std_logic_vector(to_unsigned(to_integer(unsigned(v_reg.quo_reg)) - to_integer(quo_tmp), 32));
      else
        v_reg.quo_sign := not v_reg.quo_sign;
        v_reg.quo_reg  := std_logic_vector(to_unsigned(to_integer(quo_tmp) - to_integer(unsigned(v_reg.quo_reg)), 32));
      end if;

      if tmp_sign /= v_reg.re_sign then
        v_reg.re_reg := std_logic_vector(unsigned(v_reg.re_reg) + re_tmp);
      elsif unsigned(v_reg.re_reg) > re_tmp then
        v_reg.re_reg := std_logic_vector(unsigned(v_reg.re_reg) - re_tmp);
      else
        v_reg.re_sign := not v_reg.re_sign;
        v_reg.re_reg  := std_logic_vector(re_tmp - unsigned(v_reg.re_reg));
      end if;

      -- from here
      -- i = 31 downto 0
      if i = 0 then
        i := 31;
      else
        i := i - 1;
      end if;

      if state = main_state and i = 31 then
        state <= fin_state;
      elsif go = '1' then
        i     := 31;
        state <= init_state;
      elsif state = init_state then
        state <= main_state;
      elsif state = fin_state then
        state <= wait_state;
      end if;

      main_reg <= v_reg;
    end if;
  end process main_calc;

  -- purpose: fin calc
  -- type   : combinational
  -- inputs : clk
  -- outputs: fin_reg
  fin_calc : process (mclk1) is
    variable k_reg : reg_t := (quo_sign => '0', re_sign => '0', others => (others => '0'));
    variable v_reg : reg_t := (quo_sign => '0', re_sign => '0', others => (others => '0'));
    variable v_re  : signed (35 downto 0);
  begin  -- process fin_calc
    if rising_edge (mclk1) then

      if state = fin_state then
        k_reg := main_reg;
      end if;
      v_reg := k_reg;

      if v_reg.re_sign = '0' then
        v_re := signed(v_reg.re_reg);
      else
        v_re := signed(unsigned(not v_reg.re_reg) + 1);
      end if;

      v_re := shift_right (arg => v_re, count => shift_val);
      i_re  <= v_re (31 downto 0);
      i_quo <= v_reg.quo;

    end if;
  end process fin_calc;

  re <= std_logic_vector(i_re - 7 * to_integer(unsigned(divisor))) when i_re >= to_integer(unsigned(divisor)) * 7 else
        std_logic_vector(i_re - 6 * to_integer(unsigned(divisor))) when i_re >= to_integer(unsigned(divisor)) * 6 else
        std_logic_vector(i_re - 5 * to_integer(unsigned(divisor))) when i_re >= to_integer(unsigned(divisor)) * 5 else
        std_logic_vector(i_re - 4 * to_integer(unsigned(divisor))) when i_re >= to_integer(unsigned(divisor)) * 4 else
        std_logic_vector(i_re - 3 * to_integer(unsigned(divisor))) when i_re >= to_integer(unsigned(divisor)) * 3 else
        std_logic_vector(i_re - 2 * to_integer(unsigned(divisor))) when i_re >= to_integer(unsigned(divisor)) * 2 else
        std_logic_vector(i_re - to_integer(unsigned(divisor)))     when i_re >= to_integer(unsigned(divisor)) else
        std_logic_vector(i_re)                                     when i_re >= 0 else
        std_logic_vector(i_re + to_integer(unsigned(divisor)))     when i_re >= -to_integer(unsigned(divisor)) else
        std_logic_vector(i_re + 2 * to_integer(unsigned(divisor))) when i_re >= - 2 * to_integer(unsigned(divisor)) else
        std_logic_vector(i_re + 3 * to_integer(unsigned(divisor))) when i_re >= - 3 * to_integer(unsigned(divisor)) else
        std_logic_vector(i_re + 4 * to_integer(unsigned(divisor))) when i_re >= - 4 * to_integer(unsigned(divisor)) else
        std_logic_vector(i_re + 5 * to_integer(unsigned(divisor))) when i_re >= - 5 * to_integer(unsigned(divisor)) else
        std_logic_vector(i_re + 6 * to_integer(unsigned(divisor))) when i_re >= - 6 * to_integer(unsigned(divisor)) else
        std_logic_vector(i_re + 7 * to_integer(unsigned(divisor)));

  quo <= std_logic_vector(unsigned(i_quo) + 7) when unsigned(i_re) >= to_integer(unsigned(divisor)) * 7 else
         std_logic_vector(unsigned(i_quo) + 6) when unsigned(i_re) >= to_integer(unsigned(divisor)) * 6 else
         std_logic_vector(unsigned(i_quo) + 5) when unsigned(i_re) >= to_integer(unsigned(divisor)) * 5 else
         std_logic_vector(unsigned(i_quo) + 4) when unsigned(i_re) >= to_integer(unsigned(divisor)) * 4 else
         std_logic_vector(unsigned(i_quo) + 3) when unsigned(i_re) >= to_integer(unsigned(divisor)) * 3 else
         std_logic_vector(unsigned(i_quo) + 2) when unsigned(i_re) >= to_integer(unsigned(divisor)) * 2 else
         std_logic_vector(unsigned(i_quo) + 1) when unsigned(i_re) >= to_integer(unsigned(divisor)) else
         i_quo                                 when i_re >= 0 else
         std_logic_vector(unsigned(i_quo) - 1) when i_re >= -to_integer(unsigned(divisor)) else
         std_logic_vector(unsigned(i_quo) - 2) when i_re >= - 2 * to_integer(unsigned(divisor)) else
         std_logic_vector(unsigned(i_quo) - 3) when i_re >= - 3 * to_integer(unsigned(divisor)) else
         std_logic_vector(unsigned(i_quo) - 4) when i_re >= - 4 * to_integer(unsigned(divisor)) else
         std_logic_vector(unsigned(i_quo) - 5) when i_re >= - 5 * to_integer(unsigned(divisor)) else
         std_logic_vector(unsigned(i_quo) - 6) when i_re >= - 6 * to_integer(unsigned(divisor)) else
         std_logic_vector(unsigned(i_quo) - 7);

end architecture rtl;
