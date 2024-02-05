-- (adapted from) Listing 4.10
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity xreg is
   generic(
      N: integer := 8
   );
   port(
      clk, reset: in std_logic;      
      d: in std_logic_vector(N-1 downto 0);
      clr, load: in std_logic;
      q: out std_logic_vector(N-1 downto 0)
   );
end xreg;

architecture arch of xreg is
   signal r_reg: std_logic_vector(N-1 downto 0);
   signal r_next: std_logic_vector(N-1 downto 0);
begin
   -- register
   process(clk,reset)
   begin
      if (reset='1') then
         r_reg <= (others=>'0');
      elsif rising_edge(clk) then
         r_reg <= r_next;
      end if;
   end process;
   -- next-state logic
   r_next <= (others => '0') when clr='1' else
              d when load='1' else
              r_reg;
   -- output logic
   q <= std_logic_vector(r_reg);
end arch;