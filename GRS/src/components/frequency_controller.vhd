library ieee;
use ieee.std_logic_1164.all;

entity frequency_controller is

   generic(
      gen_clk_in  : integer := 50_000_000;
      gen_clk_out : integer := 40_000
   );

   port (
      clk_in  : in  std_logic;
      clk_out : out std_logic
   );

end frequency_controller;

architecture rtl of frequency_controller is     

   signal temporal : std_logic := '0';

begin

   frequency_divider: process (clk_in)
      constant max_counter_v : natural := (gen_clk_in / (gen_clk_out * 2)) - 1;
      variable counter : natural range 0 to max_counter_v := 0;
   begin
      if rising_edge(clk_in) then
         if (counter = max_counter_v) then
            temporal <= NOT(temporal);
            counter := 0;
         else
            counter := counter + 1;
         end if;
      end if;
   end process;
    
   clk_out <= temporal;

end rtl;
