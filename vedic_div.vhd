library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vedic_div is

  port (
    mclk1      : in  std_logic;
    divisor  : in  std_logic_vector (3 downto 0);
    dividend : in  std_logic_vector (7 downto 0);
    quo      : out std_logic_vector (7 downto 0);
    re       : out std_logic_vector (3 downto 0));

end entity vedic_div;

architecture rtl of vedic_div is
  signal i_divisor : std_logic_vector (3 downto 0) := (others => '0');
  signal i_result  : std_logic_vector (7 downto 0) := (others => '0');
  signal i_sign    : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry   : std_logic_vector (7 downto 0) := (others => '0');
  signal i_quo     : std_logic_vector (7 downto 0) := (others => '0');
  signal i_quo_p   : std_logic_vector (7 downto 0) := (others => '0');
  signal i_quo_p2  : std_logic_vector (7 downto 0) := (others => '0');
  signal i_quo_n   : std_logic_vector (7 downto 0) := (others => '0');
  signal i_quo_n2  : std_logic_vector (7 downto 0) := (others => '0');
  signal i_quo_n3  : std_logic_vector (7 downto 0) := (others => '0');
  signal i_re_p    : std_logic_vector (4 downto 0) := (others => '0');
  signal i_re_p2   : std_logic_vector (4 downto 0) := (others => '0');
  signal i_re_p3   : std_logic_vector (4 downto 0) := (others => '0');
  signal i_re_n    : std_logic_vector (4 downto 0) := (others => '0');
  signal i_re_n2   : std_logic_vector (4 downto 0) := (others => '0');
  signal test      : std_logic_vector (4 downto 0) := (others => '0');
  signal i_reg_n7 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_n6 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_n5 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_n4 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_n3 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_n2 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_n1 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_n0 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_p7 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_p6 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_p5 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_p4 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_p3 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_p2 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_p1 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_reg_p0 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry7 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry6 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry5 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry4 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry3 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry2 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry1 : std_logic_vector (7 downto 0) := (others => '0');
  signal i_carry0 : std_logic_vector (7 downto 0) := (others => '0');
  signal d_re_p7 : std_logic_vector (4 downto 0) := (others => '0');
  signal d_re_p6 : std_logic_vector (4 downto 0) := (others => '0');
  signal d_re_p5 : std_logic_vector (4 downto 0) := (others => '0');
  signal d_re_p4 : std_logic_vector (4 downto 0) := (others => '0');
  signal d_re_p3 : std_logic_vector (4 downto 0) := (others => '0');
  signal d_re_p2 : std_logic_vector (4 downto 0) := (others => '0');
  signal d_re_p1 : std_logic_vector (4 downto 0) := (others => '0');
  signal d_re_p0 : std_logic_vector (4 downto 0) := (others => '0');
begin  -- architecture rtl

  i_quo_p2 <= std_logic_vector(unsigned(i_quo_p)
                               + unsigned(i_result (7 downto 3) and not i_sign (7 downto 3))
                               + unsigned((i_carry (7 downto 3) and not i_sign (7 downto 3)) & '0'));
  
  i_re_n2 <= std_logic_vector (to_unsigned(to_integer(unsigned (i_re_n))
                                           + to_integer(unsigned (i_result (2 downto 0) and i_sign (2 downto 0)))
                                           + to_integer(unsigned (i_carry (2 downto 0) & "0" and i_sign (2 downto 0) & "0")), 5));

  i_quo_n2 <= std_logic_vector(to_unsigned(to_integer(unsigned(i_quo_n))
                                           + to_integer(unsigned(i_result (7 downto 3) and i_sign (7 downto 3)))
                                           + to_integer(unsigned((i_carry (7 downto 3) and i_sign (7 downto 3)) & '0')), 8));

  i_quo_n3 <= std_logic_vector(unsigned(i_quo_n2) + 2)
              when to_integer(unsigned(i_re_p2)) + to_integer(unsigned (i_divisor)) < to_integer(unsigned(i_re_n2)) else
              std_logic_vector(unsigned (i_quo_n2) + 1)
              when unsigned (i_re_p2) < unsigned (i_re_n2) else
              i_quo_n2;

  i_re_p2 <= std_logic_vector (to_unsigned(to_integer(unsigned (i_re_p))
                                           + to_integer(unsigned (i_result (2 downto 0) and not i_sign (2 downto 0)))
                                           + to_integer(unsigned (i_carry (2 downto 0) & "0" and not i_sign (2 downto 0) & "0")), 5));

  i_re_p3 <= std_logic_vector (unsigned (i_re_p2) + to_integer(unsigned(i_divisor & '0')))
             when to_integer(unsigned(i_re_p2)) + to_integer(unsigned (i_divisor)) < to_integer(unsigned(i_re_n2)) else
             std_logic_vector (unsigned (i_re_p2) + to_integer(unsigned(i_divisor)))
             when unsigned (i_re_p2) < unsigned (i_re_n2) else
             i_re_p2;


  with unsigned (i_re_p3) - unsigned (i_re_n2) >= unsigned (i_divisor) select
    quo <=
    std_logic_vector (
      to_unsigned(to_integer(unsigned (i_quo))
                  + to_integer(unsigned (i_quo_p2))
                  - to_integer(unsigned (i_quo_n3)) + 1, 8)) when true,
    std_logic_vector (
      to_unsigned(to_integer(unsigned (i_quo))
                  + to_integer(unsigned (i_quo_p2) - unsigned (i_quo_n3)), 8)) when others;

  with unsigned (i_re_p3) - unsigned (i_re_n2) >= unsigned (i_divisor) select
    re <=
    std_logic_vector (
      to_unsigned(to_integer(unsigned (i_re_p3) - unsigned (i_re_n2))
                  - to_integer(unsigned (i_divisor)), 4)) when true,
    std_logic_vector (
      to_unsigned(to_integer(unsigned (i_re_p3) - unsigned (i_re_n2)), 4)) when others;

  -- purpose: set ret -> Q
  -- type : combinational
  -- inputs : MCLK1
  -- outputs: Q
  set_loop : process (mclk1) is
    variable reg_n    : std_logic_vector (7 downto 0) := (others => '0');  -- negative_register
    variable reg_p    : std_logic_vector (7 downto 0) := (others => '0');  -- positive_register
    variable quo_p    : std_logic_vector (7 downto 0) := (others => '0');
    variable quo_n    : std_logic_vector (7 downto 0) := (others => '0');
    variable re_p     : std_logic_vector (4 downto 0) := (others => '0');
    variable re_n     : std_logic_vector (4 downto 0) := (others => '0');
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
    if rising_edge (mclk1) then

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
        reg_p := std_logic_vector(to_unsigned(to_integer(unsigned (reg_p)) - to_integer(unsigned(divisor & x"0")), 8));
        v_quo := x"10";
      end if;

      -- add lower 3bit to re
      re_p (2 downto 0)  := dividend (2 downto 0);
      reg_p (2 downto 0) := "000";

      for i in 7 downto 4 loop
        b_result (i) := b_result (i) or (reg_n (i) xor reg_p (i));
        b_sign (i)   := b_sign (i) or (reg_n (i) and not reg_p (i));
        if i = 7 then
          i_reg_n7 <= reg_n;
          i_reg_p7 <= reg_p;
          i_carry7 <= carry;
          d_re_p7 <= re_p;
        elsif i = 6 then
          i_reg_n6 <= reg_n;
          i_reg_p6 <= reg_p;
          i_carry6 <= carry;
          d_re_p6 <= re_p;
        elsif i = 5 then
          i_reg_n5 <= reg_n;
          i_reg_p5 <= reg_p;
          i_carry5 <= carry;
          d_re_p5 <= re_p;
        elsif i = 4 then
          i_reg_n4 <= reg_n;
          i_reg_p4 <= reg_p;
          i_carry4 <= carry;
          d_re_p4 <= re_p;
        end if;
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

              reg_p (i-j+1) := (b_n (3-j) and reg_p (i-j)) or reg_p (i-j+1);

            elsif j /= 1 and reg_p (i-j) = '1' and reg_p (i-j+1) = '1' and carry (i-j+1) = '0' then

              reg_p (i-j+1) := not b_n (3-j) and reg_p (i-j+1);
              carry (i-j+1) := carry (i-j+1) or b_n (3-j);

            else

              carry (i-j)  := carry (i-j) or (b_n(3-j) and reg_p (i-j));
              b_sign (i-j) := not (reg_p (i-j) and b_n (3-j)) and b_sign (i-j);

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
                           (b_n (3-j) and not (reg_n (i-j) or (b_sign (i-j) and carry (i-j))));

            reg_p (i-j)  := reg_p (i-j) or (b_n (3-j) and reg_n (i-j));
            reg_n (i-j)  := reg_n (i-j) and not b_n (3-j);
            b_sign (i-j) := b_sign (i-j) and not b_n (3-j);
          -- -3
          elsif b_result (i) = '1' and b_sign (i) = '0' and carry (i) = '1' then

            if reg_n (i-j) = '1' then
              carry (i-j) := '0';
              reg_n (i-j) := '0';

              quo_n := std_logic_vector(unsigned(quo_n) + 4);
              re_p  := std_logic_vector(to_unsigned(to_integer(unsigned(re_p)) + to_integer(unsigned(b_n & "00")), 5));
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
              re_n  := std_logic_vector(to_unsigned(to_integer(unsigned(re_n)) + to_integer(unsigned(b_n & "00")), 5));
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
          --TODO: tmp2 is unusable
          carry (i-j) := (tmp2 (i-j) and not (tmp1 (i-j) and (not b_sign (i-j)))) and
                         not (tmp0 (i-j) and b_sign (i-j));
        end loop;  -- j

      end loop;

      i_reg_n3 <= reg_n;
      i_reg_p3 <= reg_p;
      i_carry3 <= carry;
      d_re_p3 <= re_p;
      -- i = 3
      b_result (3) := b_result (3) or (reg_n (3) xor reg_p (3));
      b_sign (3)   := b_sign (3) or (reg_n (3) and not reg_p (3));

      for j in 1 to 3 loop
        -- -1
        if b_result (3) = '1' and b_sign (3) = '0' and carry (3) = '0' then
          re_n := std_logic_vector(unsigned (re_n) + unsigned(unsigned(b_n) and shift_left (arg => "001", count => 3-j)));
        -- +1
        elsif b_result (3) = '1' and b_sign (3) = '1' and carry (3) = '0' then
          re_p := std_logic_vector(unsigned (re_p) + unsigned(unsigned (b_n) and shift_left (arg => "001", count => 3-j)));
        -- -2
        elsif b_result (3) = '0' and b_sign (3) = '0' and carry (3) = '1' then
          re_n := std_logic_vector(unsigned (re_n) + unsigned(unsigned (b_n & '0') and shift_left (arg => x"1", count => 4-j)));
        -- +2
        elsif b_result (3) = '0' and b_sign (3) = '1' and carry (3) = '1' then
          re_p := std_logic_vector(unsigned (re_p) + unsigned(unsigned (b_n & '0') and shift_left (arg => x"1", count => 4-j)));
        -- -3
        elsif b_result (3) = '1' and b_sign (3) = '0' and carry (3) = '1' then
          re_n := std_logic_vector(to_unsigned(to_integer(unsigned (re_n) + 3 * unsigned (unsigned (b_n) and shift_left (arg => "001", count => 3-j))),5));
        -- +3
        elsif b_result (3) = '1' and b_sign (3) = '1' and carry (3) = '1' then
          re_p := std_logic_vector(to_unsigned(to_integer(unsigned (re_p)) + 3 * to_integer(unsigned (unsigned (b_n) and shift_left (arg => "001", count => 3-j))),5));
        end if;
      end loop;  -- j

      for i in 2 downto 0 loop
        if i = 2 then
          i_reg_n2 <= reg_n;
          i_reg_p2 <= reg_p;
          i_carry2 <= carry;
          d_re_p2 <= re_p;
        elsif i = 1 then
          i_reg_n1 <= reg_n;
          i_reg_p1 <= reg_p;
          i_carry1 <= carry;
          d_re_p1 <= re_p;
        elsif i = 0 then
          i_reg_n0 <= reg_n;
          i_reg_p0 <= reg_p;
          i_carry0 <= carry;
          d_re_p0 <= re_p;
        end if;
        b_result (i) := b_result (i) or (reg_n (i) xor reg_p (i));
        b_sign (i)   := b_sign (i) or (reg_n (i) and not reg_p (i));
      end loop;  -- i

      i_quo_p   <= quo_p;
      i_quo_n   <= quo_n;
      i_quo     <= v_quo;
      i_re_p    <= re_p;
      i_re_n    <= re_n;
      i_result  <= b_result;
      i_sign    <= b_sign;
      i_carry   <= carry;
      i_divisor <= divisor;
    end if;
  end process set_loop;

end architecture rtl;
