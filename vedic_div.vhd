library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vedic_div is

  port (
    clk      : in  std_logic;
    divisor  : in  std_logic_vector (3 downto 0);
    dividend : in  std_logic_vector (7 downto 0);
    quo      : out std_logic_vector (7 downto 0);
    re       : out std_logic_vector (3 downto 0));

end entity vedic_div;

architecture rtl of vedic_div is

begin  -- architecture rtl

  -- purpose: set ret -> Q
  -- type : combinational
  -- inputs : CLK
  -- outputs: Q
  set_loop : process (clk) is
    variable reg_n    : std_logic_vector (7 downto 0) := (others => '0');  -- negative_register
    variable reg_p    : std_logic_vector (7 downto 0) := (others => '0');  -- positive_register
    variable quo_p    : std_logic_vector (7 downto 0) := (others => '0');
    variable quo_n    : std_logic_vector (7 downto 0) := (others => '0');
    variable re_p     : std_logic_vector (3 downto 0) := (others => '0');
    variable re_n     : std_logic_vector (3 downto 0) := (others => '0');
    variable v_quo    : std_logic_vector (7 downto 0) := (others => '0');
    variable b_result : std_logic_vector (7 downto 0) := (others => '0');  -- Result bits
    variable b_sign   : std_logic_vector (7 downto 0) := (others => '0');  -- Sign bits
    variable carry    : std_logic_vector (7 downto 0) := (others => '0');
    variable b_n      : std_logic_vector (2 downto 0) := (others => '0');  -- negative divisor bits
    variable length   : integer                       := 0;
    variable tmp0     : std_logic_vector (7 downto 0) := (others => '0');
    variable tmp1     : std_logic_vector (7 downto 0) := (others => '0');
    variable tmp2     : std_logic_vector (7 downto 0) := (others => '0');
  begin  -- process set_loop
    if rising_edge (clk) then

      -- init
      reg_n    := (others => '0');
      reg_p    := dividend;
      quo_n    := (others => '0');
      quo_p    := (others => '0');
      re_n     := (others => '0');
      re_p     := (others => '0');
      b_result := (others => '0');
      b_sign   := (others => '0');
      carry    := (others => '0');
      v_quo    := (others => '0');
      if divisor (3) = '1' then
        length := 3;
        b_n    := divisor (2 downto 0);
      --elsif divisor (2) = '1' then
      --  length := 2;
      --  b_n    := '0' & divisor (1 downto 0);
      --elsif divisor (1) = '1' then
      --  length := 1;
      --  b_n    := "00" & divisor (0);
      --else
      --length := 0;
      --b_n    := "000";
      end if;

      if unsigned(reg_p (7 downto 4)) >= unsigned (divisor) then
        reg_p := std_logic_vector(to_unsigned(to_integer(unsigned (reg_p)) - to_integer(unsigned(divisor & "00")), 8));
        v_quo := std_logic_vector(to_unsigned(to_integer(unsigned(v_quo)) + 16, 8));
      end if;

      -- add lower 3bit to re
      re_p               := dividend (3 downto 0);
      reg_p (2 downto 0) := "000";

      for i in 7 downto 4 loop
        b_result (i) := b_result (i) or (reg_n (i) xor reg_p (i));
        b_sign (i)   := b_sign (i) or ((reg_n (i)) and not reg_p (i));

        for j in 1 to 3 loop
          -- -1
          if b_result (i) = '1' and b_sign (i) = '0' and carry (i) = '0' then

            if j /= 1 and reg_n (i-j+1) = '0' then

              reg_n (i-j+1) := (b_n (3-j) and reg_n (i-j)) or reg_n (i-j+1);

            elsif j /= 1 and reg_n (i-j) = '1' and reg_n (i-j+1) = '1' and carry (i-j+1) = '0' then

              reg_n (i-j+1)  := not b_n (3-j) and reg_n (i-j+1);
              carry (i-j+1)  := carry (i-j+1) or b_n (3-j);
              b_sign (i-j+1) := b_sign (i-j+1) or b_n (3-j);

            else

              carry (i-j)  := carry (i-j) or (b_n(3-j) and reg_n (i-j));
              b_sign (i-j) := (not reg_n (i-j) and b_sign (i-j)) or (b_n (3-j) and reg_n (i-j));

            end if;
            reg_n (i-j) := b_n (3-j) xor reg_n (i-j);

          -- +1
          elsif b_result (i) = '1' and b_sign (i) = '1' and carry (i) = '0' then

            if j /= 1 and reg_p (i-j+1) = '0' then

              reg_p (i-j+1) := (b_n (3-j) and reg_p (i-j)) or reg_n (i-j+1);

            elsif j /= 1 and reg_p (i-j) = '1' and reg_p (i-j+1) = '1' and carry (i-j+1) = '0' then

              reg_p (i-j+1) := not b_n (3-j) and reg_p (i-j+1);
              carry (i-j+1) := carry (i-j+1) or b_n (3-j);

            else

              carry (i-j)  := carry (i-j) or (b_n(3-j) and reg_p (i-j));
              b_sign (i-j) := not (reg_p (i-j) and b_n (3-j)) and reg_n (i-j);

            end if;

            reg_p (i-j) := b_n (3-j) xor reg_p (i-j);

          -- -2
          elsif b_result (i) = '0' and b_sign (i) = '0' and carry (i) = '1' then
            carry (i-j) := (not b_n (3-j) and carry (i-j)) or
                           (b_n (3-j) and not (reg_p (i-j) or (not b_sign (i-j) and carry (i-j))));

            reg_n (i-j)  := reg_n (i-j) or (b_n (3-j) and reg_p (i-j));
            reg_p (i-j)  := reg_p (i-j) and not b_n (3-j);
            b_sign (i-j) := b_sign (i-j) or b_n (3-j);
          -- +2 
          elsif b_result (i) = '0' and b_sign (i) = '1' and carry (i) = '1' then
            carry (i-j) := (not b_n (3-j) and carry (i-j)) or
                           (b_n (3-j) and not (reg_n (i-j) or (not b_sign (i-j) and carry (i-j))));

            reg_p (i-j)  := reg_p (i-j) or (b_n (3-j) and reg_n (i-j));
            reg_n (i-j)  := reg_n (i-j) and not b_n (3-j);
            b_sign (i-j) := b_sign (i-j) and not b_n (3-j);
          -- -3
          elsif b_result (i) = '1' and b_sign (i) = '0' and carry (i) = '1' then

            if reg_n (i-j) = '1' then
              carry (i-j) := '0';
              reg_n (i-j) := '0';

              quo_n := std_logic_vector(unsigned(quo_n) + 4);
              re_p  := std_logic_vector(to_unsigned(to_integer(unsigned(re_p) + unsigned(b_n & "00")), 8));
            else
              b_sign (i-j) := b_n (3-j);
              reg_n (i-j)  := reg_n (i-j) or b_n (3-j);
              carry (i-j)  := carry (i-j) xor b_n (3-j);
            end if;

          -- +3
          elsif b_result (i) = '1' and b_sign (i) = '1' and carry (i) = '1' then

            if reg_p (i-j) = '1' then
              carry (i-j) := '0';
              reg_p (i-j) := '0';

              quo_p := std_logic_vector(unsigned(quo_p) + 4);
              re_n  := std_logic_vector(to_unsigned(to_integer(unsigned(re_n) + unsigned(b_n & "00")), 8));
            else
              b_sign (i-j) := not b_n (3-j);
              reg_p (i-j)  := reg_p (i-j) or b_n (3-j);
              carry (i-j)  := carry (i-j) xor b_n (3-j);
            end if;

          end if;
        end loop;

        for j in 1 to 3 loop
          tmp0 := reg_p;
          tmp1 := reg_n;

          reg_p (i-j) := tmp0 (i-j) and not tmp1 (i-j);
          reg_n (i-j) := tmp1 (i-j) and not tmp0 (i-j);

          tmp0 := reg_p;
          tmp1 := reg_n;
          tmp2 := carry;

          reg_n (i-j) := (tmp1 (i-j) and (b_sign (i-j) or not tmp2 (i-j))) or
                         (tmp0 (i-j) and tmp2 (i-j) and b_sign (i-j));
          reg_p (i-j) := (tmp0 (i-j) and (not b_sign (i-j) or not tmp2 (i-j))) or
                         (tmp1 (i-j) and tmp2 (i-j) and not b_sign (i-j));
          carry (i-j) := (carry (i-j) and not tmp1 (i-j) and not b_sign (i-j)) and
                         not (tmp0 (i-j) and b_sign (i-j));
        end loop;  -- j
      end loop;

      -- i = 3
      b_result (3) := b_result (3) or (reg_n (3) xor reg_p (3));
      b_sign (3)   := b_sign (3) or (reg_n (3) and not reg_p (3));
      for j in 1 to 3 loop
        -- -1
        if b_result (3) = '1' and b_sign (3) = '0' and carry (3) = '0' then
          re_n := std_logic_vector(unsigned (re_n) + shift_left (arg => unsigned(b_n), count => 3-j));
        -- +1
        elsif b_result (3) = '1' and b_sign (3) = '1' and carry (3) = '0' then
          re_p := std_logic_vector(unsigned (re_p) + shift_left (arg => unsigned(b_n), count => 3-j));
        -- -2
        elsif b_result (3) = '0' and b_sign (3) = '0' and carry (3) = '1' then
          re_n := std_logic_vector(unsigned (re_n) + shift_left (arg => unsigned(b_n), count => 4-j));
        -- +2
        elsif b_result (3) = '0' and b_sign (3) = '1' and carry (3) = '1' then
          re_p := std_logic_vector(unsigned (re_p) + shift_left (arg => unsigned(b_n), count => 4-j));
        -- -3
        elsif b_result (3) = '1' and b_sign (3) = '0' and carry (3) = '1' then
          re_n := std_logic_vector(unsigned (re_n) + shift_left (arg => 3 * unsigned(b_n), count => 3-j));
        -- +3
        elsif b_result (3) = '1' and b_sign (3) = '1' and carry (3) = '1' then
          re_p := std_logic_vector(unsigned (re_p) + shift_left (arg => 3 * unsigned(b_n), count => 3-j));
        end if;
      end loop;  -- j

      for i in 2 downto 0 loop
        b_result (i) := b_result (i) or (reg_n (i) xor reg_p (i));
        b_sign (i)   := b_sign (i) or (reg_n (i) and not reg_p (i));
      end loop;  -- i

      quo_p := std_logic_vector(unsigned(quo_p) + unsigned(b_result (7 downto 3) and not b_sign (7 downto 3)) + unsigned((carry (7 downto 3) and not b_sign (7 downto 3)) & '0'));
      re_p := std_logic_vector (unsigned (re_p) + unsigned (b_result (2 downto 0) and not b_sign (2 downto 0)) + unsigned (carry (2 downto 0) and not b_sign (2 downto 0)));
      quo_n := std_logic_vector(unsigned(quo_n) + unsigned(b_result (7 downto 3) and b_sign (7 downto 3)) + unsigned((carry (7 downto 3) and b_sign (7 downto 3)) & '0'));
      re_n := std_logic_vector (unsigned (re_n) + unsigned (b_result (2 downto 0) and b_sign (2 downto 0)) + unsigned (carry (2 downto 0) and b_sign (2 downto 0)));

      if unsigned(re_p) + unsigned (divisor) < unsigned(re_n) then
        re_p := std_logic_vector(unsigned(re_p) + unsigned(divisor & '0'));
        quo_n := std_logic_vector(unsigned(quo_n) + 2);
      elsif unsigned (re_p) < unsigned (re_n) then
        re_p := std_logic_vector (unsigned (re_p) + unsigned(divisor));
        quo_n := std_logic_vector(unsigned(quo_n) + 1);
      end if;

      if unsigned(re_p) - unsigned(re_n) >= unsigned(divisor) then
        quo <= std_logic_vector(unsigned(v_quo) + unsigned(quo_p) - unsigned(quo_n) + 1);
        re <= std_logic_vector(unsigned(re_p) - unsigned(re_n) - unsigned(divisor));
      else
        quo <= std_logic_vector(unsigned(v_quo) + unsigned(quo_p) - unsigned(quo_n));
        re <= std_logic_vector(unsigned(re_p) - unsigned(re_n));        
      end if;
    end if;
  end process set_loop;

end architecture rtl;
