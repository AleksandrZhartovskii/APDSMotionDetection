library ieee;
use ieee.std_logic_1164.all;

entity constant_rom is

   port (
      clk  : in  std_logic;
      addr : in  std_logic_vector(5 downto 0);

      data : out std_logic_vector(7 downto 0)
   );

end entity constant_rom;

architecture rtl of constant_rom is
begin



end architecture rtl;
