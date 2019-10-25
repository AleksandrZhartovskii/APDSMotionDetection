library ieee;
use ieee.std_logic_1164.all;

entity constant_ROM is

   port (
      clk  : in  std_logic;
      addr : in  std_logic_vector(1 downto 0);

      data : out std_logic_vector(7 downto 0)
   );

end entity constant_ROM;

architecture rtl of constant_ROM is
begin



end architecture rtl;
