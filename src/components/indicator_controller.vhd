library ieee;
use ieee.std_logic_1164.all;

entity indicator_controller is

  port (
    clk       : in  std_logic;

    digit     : in  std_logic_vector(3 downto 0);
    seg_data  : out std_logic_vector(0 to 6)
  );

end entity indicator_controller;

architecture rtl of indicator_controller is
begin

  process (clk)
  begin
    if rising_edge(clk) then
      case digit is
        when "0000" => seg_data <= "0000001"; --0
        when "0001" => seg_data <= "1001111"; --1
        when "0010" => seg_data <= "0010010"; --2
        when "0011" => seg_data <= "0000110"; --3
        when "0100" => seg_data <= "1001100"; --4
        when "0101" => seg_data <= "0100100"; --5
        when "0110" => seg_data <= "0100000"; --6
        when "0111" => seg_data <= "0001111"; --7
        when "1000" => seg_data <= "0000000"; --8
        when "1001" => seg_data <= "0000100"; --9
        when others => seg_data <= "1111110"; --'-'
      end case;
    end if;
  end process;

end architecture rtl;
