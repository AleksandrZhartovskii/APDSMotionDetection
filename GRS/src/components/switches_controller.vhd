library ieee;
use ieee.std_logic_1164.all;

entity switches_controller is

   port (
      clk            : in  std_logic;
      checked_sw_in  : in  std_logic_vector(2 downto 0);

      checked_sw_out : out std_logic_vector(2 downto 0)
   );

end entity switches_controller;

architecture rtl of switches_controller is
begin



end architecture rtl;
