library ieee;
use ieee.std_logic_1164.all;

entity indicator_controller is

  port (
    clk       : in  std_logic;

    ena       : in  std_logic;

    digit     : in  std_logic_vector(3 downto 0);
    seg_data  : out std_logic_vector(0 to 6)
  );

end entity indicator_controller;

architecture rtl of indicator_controller is

  constant SEG_DATA_OFF : std_logic_vector(0 to 6) := "1111111";
  constant SEG_DATA_UND : std_logic_vector(0 to 6) := "1111110";

  signal t_data         : std_logic_vector(0 to 6);

begin

  process (clk)
  begin
    if rising_edge(clk) then
      case digit is
        when "0000" => t_data <= "0000001"; --0
        when "0001" => t_data <= "1001111"; --1
        when "0010" => t_data <= "0010010"; --2
        when "0011" => t_data <= "0000110"; --3
        when "0100" => t_data <= "1001100"; --4
        when "0101" => t_data <= "0100100"; --5
        when "0110" => t_data <= "0100000"; --6
        when "0111" => t_data <= "0001111"; --7
        when "1000" => t_data <= "0000000"; --8
        when "1001" => t_data <= "0000100"; --9
        when others => t_data <= SEG_DATA_UND;
      end case;
    end if;
  end process;

  seg_data <= t_data when ena = '1' else SEG_DATA_OFF;

end architecture rtl;
