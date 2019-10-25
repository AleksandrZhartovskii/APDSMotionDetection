library ieee;
use ieee.std_logic_1164.all;

entity main_block is

   port (
      clk         : in  std_logic;
      checked_sw  : in  std_logic_vector(2 downto 0);
      sensor_data : in  std_logic_vector(7 downto 0);

      sensor_read : out std_logic;
      gesture_bcd : out std_logic_vector(3 downto 0)
   );

end entity main_block;

architecture rtl of main_block is
begin



end architecture rtl;
