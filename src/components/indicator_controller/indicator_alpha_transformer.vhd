library ieee;
use ieee.std_logic_1164.all;

entity indicator_alpha_transformer is

  generic (
    SEG_DATA_UND : std_logic_vector(0 to 6) := "1111110"
  );

  port (
    char      : in  std_logic_vector(3 downto 0);
    seg_data  : out std_logic_vector(0 to 6)
  );

end entity indicator_alpha_transformer;

architecture rtl of indicator_alpha_transformer is
begin

  with char select
    seg_data <= "1001111" when "0000", --i
                "1000001" when "0001", --u
                "1000010" when "0010", --d
                "1110001" when "0011", --l
                "0111001" when "0100", --r
                "1101010" when "0101", --n
                "0111000" when "0110", --f
                "0110000" when "0111", --e
                SEG_DATA_UND when others;

end architecture rtl;
