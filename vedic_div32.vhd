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
    quo_reg   : std_logic_vector (31 downto 0);
    re_reg    : std_logic_vector (35 downto 0);
    quo       : std_logic_vector (31 downto 0);
    quo_sign  : std_logic;              -- 0 : positive,1 : negative
    re_sign   : std_logic;              -- 0 : positive,1 : negative
    shift_val : integer range 0 to 31;
  end record reg_t;

  type state_t is (init_state, main_state, wait_state, fin_state);

  signal reg      : reg_t := (quo_sign => '0', re_sign => '0', shift_val => 0, others => (others => '0'));
  signal init_reg : reg_t := (quo_sign => '0', re_sign => '0', shift_val => 0, others => (others => '0'));
  signal main_reg : reg_t := (quo_sign => '0', re_sign => '0', shift_val => 0, others => (others => '0'));

  signal b_n   : std_logic_vector (30 downto 0) := (others => '0');
  signal state : state_t                        := init_state;

begin  -- architecture rtl

  with state select
    reg <=
    init_reg when init_state,
    main_reg when others;

  -- purpose: init reg
  -- type   : combinational
  -- inputs : clk
  -- outputs: init_reg

  init_reg.quo      <= (others => '0');
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
      init_reg.shift_val <= 31 - i;

      init_reg.quo_reg <= dividend (31 downto i);
      if i = 0 then
        init_reg.re_reg <= (others => '0');
        b_n             <= (others => '0');
      else
        b_n <= std_logic_vector(shift_left (arg   => unsigned(divisor (30 downto 31 - i)),
                                            count => 31 - i));
        init_reg.re_reg <= std_logic_vector(shift_left(arg   => unsigned(dividend (i-1 downto 0)),
                                                       count => 31 - i));
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
    variable v_reg       : reg_t                  := (quo_sign => '0', re_sign => '0', shift_val => 0, others => (others => '0'));
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

      v_reg.quo_reg (31 downto i) := (others => '0');

      quo_tmp := tmp_quo_reg * unsigned(b_n (30 downto 31 - i));
      re_tmp := shift_left(arg   => tmp_quo_reg * unsigned(b_n (30 - i downto 0)),
                           count => i);

      tmp_sign := v_reg.quo_sign;

      if tmp_sign /= v_reg.quo_sign then
        v_reg.quo_reg := std_logic_vector(unsigned(v_reg.quo_reg) + quo_tmp);
      elsif unsigned(v_reg.quo_reg) > quo_tmp then
        v_reg.quo_reg := std_logic_vector(unsigned(v_reg.quo_reg) - quo_tmp);
      else
        v_reg.quo_sign := not v_reg.quo_sign;
        v_reg.quo_reg  := std_logic_vector(quo_tmp - unsigned(v_reg.quo_reg));
      end if;

      if tmp_sign /= v_reg.re_sign then
        v_reg.re_reg := std_logic_vector(unsigned(v_reg.re_reg) + re_tmp);
      elsif unsigned(v_reg.re_reg) > re_tmp then
        v_reg.re_reg := std_logic_vector(unsigned(v_reg.re_reg) - re_tmp);
      else
        v_reg.re_sign := not v_reg.re_sign;
        v_reg.re_reg  := std_logic_vector(re_tmp - unsigned(v_reg.re_reg));
      end if;

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
    variable k_reg : reg_t := (quo_sign => '0', re_sign => '0', shift_val => 0, others => (others => '0'));
    variable v_reg : reg_t := (quo_sign => '0', re_sign => '0', shift_val => 0, others => (others => '0'));
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

      v_re := shift_right (arg => v_re, count => v_reg.shift_val);

      for t in 0 to 8 loop
        if v_re < 0 then
          v_re      := v_re + to_integer(unsigned(divisor));
          v_reg.quo := std_logic_vector(unsigned(v_reg.quo) - 1);
        end if;
      end loop;  -- t

      for t in 0 to 8 loop
        if v_re >= to_integer(unsigned(divisor)) then
          v_re      := v_re - to_integer(unsigned(divisor));
          v_reg.quo := std_logic_vector(unsigned(v_reg.quo) + 1);
        end if;
      end loop;  -- t
      re  <= std_logic_vector(v_re (31 downto 0));
      quo <= v_reg.quo;
    end if;
  end process fin_calc;

end architecture rtl;
